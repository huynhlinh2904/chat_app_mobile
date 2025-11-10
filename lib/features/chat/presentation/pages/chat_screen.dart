import 'dart:async';
import 'dart:io';
import 'package:chat_mobile_app/core/constants/flutter_secure_storage.dart';
import 'package:chat_mobile_app/features/chat/data/clients/signalr_client.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/widgets/message_bubble.dart';
import '../../../../../core/widgets/typing_indicator.dart';
import '../providers/chat_get_message_redis_notifier.dart';
import '../providers/chat_messages_notifier.dart';
import '../providers/chat_send_messages_notifier.dart';
import '../../../../../core/utils/date_utils.dart';
import '../providers/combined_messages_provider.dart';
import '../providers/get_message_id_by_uuid_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? _signalrSub;

  bool _isTyping = false;
  bool _isLoaded = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _disposed = false;
  bool _initialLoadDone = false;

  DateTime? _lastLoadTime;
  int? idGroup;
  String? groupName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _hasMore = true;

    // 🔹 Listen SignalR realtime
    _signalrSub = SignalRService().events.listen((event) {
      if (!mounted) return;
      if (event['type'] == 'ReceiveMessage') {
        final data = event['data'];
        try {
          final msg = data is Map<String, dynamic>
              ? ChatGetMessage.fromJson(data)
              : ChatGetMessage.fromJsonString(data.toString());
          ref.read(chatMessageProvider.notifier).upsertApiMessage(msg);
          _scrollToBottom();
        } catch (e) {
          debugPrint("❌ Parse ReceiveMessage error: $e");
        }
      }
    });

    Future.microtask(() async {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        idGroup = args['idGroup'] as int?;
        groupName = (args['groupName'] as String?) ?? 'Nhóm mặc định';
      } else {
        groupName = 'Nhóm mặc định';
      }

      if (idGroup != null && !_isLoaded) {
        _isLoaded = true;

        await SignalRService().joinConversation(idGroup!);
        final dateOlder = formatSqlDate(DateTime.now().add(const Duration(days: 1)));

        await Future.wait([
          ref.read(chatMessageProvider.notifier)
              .fetchMessages(idGroup: idGroup!, dateOlder: dateOlder, type: 0),
          ref.read(chatGetMessageRedisProvider.notifier)
              .fetchMessageRedis(idGroup: idGroup!),
        ]);

        _initialLoadDone = true;
      }
    });
  }

  // 🔹 Detect scroll lên để load cũ
  void _onScroll() {
    if (!_initialLoadDone || !_hasMore || _isLoadingMore || !_scrollController.hasClients) return;

    final pos = _scrollController.position;
    const threshold = 80.0;

    // Với reverse: true, đầu danh sách (tin cũ) nằm ở maxScrollExtent
    final nearTop = pos.pixels >= (pos.maxScrollExtent - threshold);
    if (nearTop) {
      final now = DateTime.now();
      if (_lastLoadTime != null &&
          now.difference(_lastLoadTime!).inMilliseconds < 800) return;
        _lastLoadTime = now;
      _loadOlder();
    }
  }

  Future<void> _loadOlder() async {
    if (idGroup == null || _isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
    if (mounted) setState(() {});

    final prevState = ref.read(combinedMessagesProvider);
    final prevMsgs = prevState.value ?? <ChatGetMessage>[];
    final beforeLen = prevMsgs.length;
    final prevMax = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;

    // Lấy message cũ nhất hiện có
    DateTime oldest = DateTime.now();
    if (prevMsgs.isNotEmpty) {
      for (final m in prevMsgs) {
        final d = m.dateSent;
        if (d != null && d.isBefore(oldest)) oldest = d;
      }
    }

    final dateOlder = formatSqlDate(oldest);

    await ref.read(chatMessageProvider.notifier).fetchMessages(
      idGroup: idGroup!,
      dateOlder: dateOlder,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final newMax = _scrollController.position.maxScrollExtent;
      final delta = newMax - prevMax;
      final nextOffset = (_scrollController.offset + delta)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(nextOffset);
    });

    final afterLen = ref.read(chatMessageProvider).value?.length ?? beforeLen;
    if (afterLen == beforeLen) _hasMore = false;

    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  // 🔹 Gửi tin nhắn text
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || idGroup == null) return;

    final idSender = await LocalStorageService.getIDUser();
    final fullName = await LocalStorageService.getFullNameUser();
    final uuid = const Uuid().v4();

    ref.read(chatMessageProvider.notifier).appendLocalMessage(
      idGroup: idGroup!,
      content: text,
      idSender: idSender ?? 0,
      fullNameUser: fullName ?? "Unknown",
      idMessageOverride: 'temp_$uuid',
    );

    ref.read(chatSendMessagesProvider.notifier).sendMessage(
      idGroup: idGroup!,
      idMessage: uuid,
      content: text,
      type: 0,
      idSender: idSender ?? 0,
      fullNameUser: fullName ?? "",
      ref: ref,
      typeMessage: 0,
    );

    _resolveUuidAndReplace(uuid);

    _messageController.clear();
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  Future<void> _resolveUuidAndReplace(String uuid) async {
    final delays = [200, 300, 500, 800, 1200, 1800, 2500, 3500];
    for (final d in delays) {
      if (_disposed) return
        await Future.delayed(Duration(milliseconds: d));
      final id = await ref.read(getMessageIdByUuidUseCaseProvider).call(uuid);
      if (id != null) {
        if (_disposed) return
          ref.read(chatMessageProvider.notifier)
              .replaceTempWithServerId(uuid: uuid, idMessage: id);
        return;
      };
    }
  }

  // 🔹 Cuộn xuống đáy (tin mới)
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController.hasClients) return
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  // 🔹 Gửi file/ảnh
  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.deepPurple),
              title: const Text('Gửi ảnh'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) _handleFilePicked(File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.deepPurple),
              title: const Text('Gửi tệp'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final XFile? file = await picker.pickMedia();
                if (file != null) _handleFilePicked(File(file.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleFilePicked(File file) async {
    debugPrint("📎 [FilePicker] ${file.path}");
    final idUser = await LocalStorageService.getIDUser();
    final fullName = await LocalStorageService.getFullNameUser();
    ref.read(chatMessageProvider.notifier).appendLocalMessage(
      idGroup: idGroup ?? 0,
      content: '📎 ${file.path.split('/').last}',
      idSender: idUser ?? 0,
      fullNameUser: fullName ?? 'Unknown',
      typeMessage: 1,
    );
  }

  // 🔹 UI render
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(combinedMessagesProvider);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150'),
            ),
            const SizedBox(width: 10),
            Text(
              groupName ?? 'Đang tải...',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _buildError(err.toString()),
                data: (messages) => _buildMessageList(messages),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatGetMessage> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)));
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isTyping && index == 0) return const TypingIndicator();

            final msg = messages[messages.length - 1 - index];
            final isDeleted = msg.statusMess == 999;
            final text = isDeleted ? 'Tin nhắn đã bị xoá' : (msg.content ?? '');

            return Opacity(
              opacity: isDeleted ? 0.6 : 1,
              child: MessageBubble(
                text: text,
                isMe: msg.idSender == 1,
                time: msg.dateSent ?? DateTime.now(),
                avatarUrl: msg.avatarImg ?? 'https://i.pravatar.cc/150?u=${msg.idSender}',
              ),
            );
          },
        ),
        if (_isLoadingMore)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (val) => setState(() => _isTyping = val.isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        const Text('Lỗi tải tin nhắn', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            if (idGroup != null) {
              final dateOlder = formatSqlDate(DateTime.now().add(const Duration(days: 1)));
              ref.read(chatMessageProvider.notifier)
                  .fetchMessages(idGroup: idGroup!, dateOlder: dateOlder);
            }
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    _signalrSub?.cancel();
    _disposed = true;
    super.dispose();
  }
}
