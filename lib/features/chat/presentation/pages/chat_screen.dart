import 'dart:async';
import 'dart:io';
import 'package:chat_mobile_app/core/constants/flutter_secure_storage.dart';
import 'package:chat_mobile_app/core/utils/utils.dart';
import 'package:chat_mobile_app/features/chat/data/clients/signalr_client.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/widgets/message_bubble.dart';
import '../../../../../core/widgets/typing_indicator.dart';
import '../providers/chat_get_message_redis_notifier.dart';
import '../providers/chat_groups_notifier.dart';
import '../providers/chat_messages_notifier.dart';
import '../providers/chat_send_messages_notifier.dart';
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
  ChatGetMessage? _replyingMessage;

  bool _isTyping = false;
  bool _isLoaded = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _disposed = false;
  bool _initialLoadDone = false;

  double? _lastPixel;
  DateTime? _lastLoadTime;
  int? idGroup;
  String? groupName;
  final List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _hasMore = true;

    Future.microtask(() {
      ref.read(chatMessageProvider.notifier).clearMessages();
      ref.read(chatGetMessageRedisProvider.notifier).clearMessages();
      ref.refresh(combinedMessagesProvider);
    });

    // 🔹 Listen SignalR realtime
    _signalrSub = SignalRService().events.listen((event) {
      if (event['type'] == 'ReceiveMessage') {
        final msg = ChatGetMessage.fromJson(event['data']);

        ref.read(chatMessageProvider.notifier).upsertApiMessage(msg);
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
        final dateOlder = ChatUtils.formatSqlDate(DateTime.now().add(const Duration(days: 1)));

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
    if (!_scrollController.hasClients || !_initialLoadDone) return;

    final pos = _scrollController.position.pixels;

    // khởi tạo lastPixel
    if (_lastPixel == null) {
      _lastPixel = pos;
      return;
    }

    // detect direction (reverse:true → scroll UI lên = pos tăng)
    final bool scrollingDown = pos < _lastPixel!;

    _lastPixel = pos;

    //Không load khi scroll xuống
    if (scrollingDown) return;

    //Đang load rồi → không load tiếp
    if (_isLoadingMore) return;

    // Debounce: ngăn gọi liên tục
    final now = DateTime.now();
    if (_lastLoadTime != null &&
        now.difference(_lastLoadTime!).inMilliseconds < 800) {
      return;
    }

    // KIỂM TRA GẦN TOP
    final threshold = 100.0;
    final nearTop = pos >= (_scrollController.position.maxScrollExtent - threshold);

    if (nearTop && _hasMore) {
      _lastLoadTime = now;
      _loadOlder();
    }
  }



  Future<void> _loadOlder() async {
    if (_isLoadingMore || !_hasMore || idGroup == null) return;

    _isLoadingMore = true;
    setState(() {});

    if (!_scrollController.hasClients) return;

    final oldOffset = _scrollController.position.pixels;
    final oldMax = _scrollController.position.maxScrollExtent;

    // lấy message cũ nhất hiện có
    final messages = ref.read(combinedMessagesProvider).value ?? [];
    DateTime oldest = messages.isEmpty
        ? DateTime.now()
        : messages.first.dateSent ?? DateTime.now();

    final dateOlder = ChatUtils.formatSqlDate(oldest);

    // fetch thêm từ API
    await ref.read(chatMessageProvider.notifier).fetchMessages(
      idGroup: idGroup!,
      dateOlder: dateOlder,
    );

    // CHỈNH OFFSET → KHÔNG GIẬT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final newMax = _scrollController.position.maxScrollExtent;

      final offsetToRestore = newMax - oldMax + oldOffset;

      _scrollController.jumpTo(offsetToRestore);
    });

    // check còn tin để load không
    final updated = ref.read(chatMessageProvider).value ?? [];
    if (updated.length == messages.length) _hasMore = false;

    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  void _showMessageMenu(ChatGetMessage msg) async {
    final idUser = await LocalStorageService.getIDUser();
    final isMe = msg.idSender == idUser;
    final isDeleted = msg.statusMess == 999;

    final actions = <Widget>[];

    // ✅ 1. Luôn có "Phản hồi"
    actions.add(
      ListTile(
        leading: const Icon(Icons.reply, color: Colors.blue),
        title: const Text('Phản hồi'),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _replyingMessage = msg;
          });
        },
      ),
    );

    // ✅ 2. Nếu là tin của bản thân
    if (isMe) {
      if (!isDeleted) {
        // ➕ Chưa xóa → cho phép "Xóa tin nhắn"
        actions.add(
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Xóa tin nhắn'),
            onTap: () {
              Navigator.pop(context);
              debugPrint('🗑️ Delete message ${msg.idMessage}');
              // TODO: Gọi provider/API xóa tin nhắn
            },
          ),
        );
      } else {
        // ➕ Đã xóa → cho phép "Khôi phục tin nhắn"
        actions.add(
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.green),
            title: const Text('Khôi phục tin nhắn'),
            onTap: () {
              Navigator.pop(context);
              debugPrint('🔁 Restore message ${msg.idMessage}');
              // TODO: Gọi provider/API khôi phục tin nhắn
            },
          ),
        );
      }
    }

    // ✅ 3. Nếu là tin nhắn người khác → chỉ hiện "Phản hồi" (đã thêm ở trên)

    // Nếu chỉ có 1 hành động → vẫn show gọn đẹp
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
        );
      },
    );
  }

  void _showReactionBar(ChatGetMessage msg) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry overlayEntry; // ✅ khai báo trước

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () => overlayEntry.remove(),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final emoji in ['👍', '❤️', '😂', '😮', '😢', '👎'])
                      GestureDetector(
                        onTap: () {
                          debugPrint('💬 React ${msg.idMessage} with $emoji');
                          overlayEntry.remove();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
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
      replyToID: _replyingMessage?.idMessage,
      replyToContent: _replyingMessage?.content,
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
      replyToID: _replyingMessage?.idMessage ?? "",
      replyToContent: _replyingMessage?.content ?? "",
      ref: ref,
      typeMessage: 0,
    );

    _resolveUuidAndReplace(uuid);

    _messageController.clear();
    setState(() {
      _isTyping = false;
      _replyingMessage = null;
    });
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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
  void _handleFilePicked(File file) {
    setState(() {
      _selectedFiles.add(file);
    });
  }
  // void _handleFilePicked(File file) async {
  //   debugPrint("📎 [FilePicker] ${file.path}");
  //   final idUser = await LocalStorageService.getIDUser();
  //   final fullName = await LocalStorageService.getFullNameUser();
  //   ref.read(chatMessageProvider.notifier).appendLocalMessage(
  //     idGroup: idGroup ?? 0,
  //     content: '📎 ${file.path.split('/').last}',
  //     idSender: idUser ?? 0,
  //     fullNameUser: fullName ?? 'Unknown',
  //     typeMessage: 1,
  //   );
  // }

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
            Expanded(
              child: Text(
                groupName ?? 'Đang tải...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
      return const Center(
        child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)),
      );
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
            final isMe = msg.idSender == 1; // TODO: thay bằng ID user thật

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onLongPress: () {
                        _showReactionBar(msg);
                        _showMessageMenu(msg);
                      },

                      child: MessageBubble(
                        text: text,
                        isMe: isMe,
                        time: msg.dateSent ?? DateTime.now(),
                        avatarUrl: msg.avatarImg ??
                            'https://i.pravatar.cc/150?u=${msg.idSender}',
                      ),
                    ),
                  ),
                ],
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, -2),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Reply preview
          if (_replyingMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Colors.deepPurple, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingMessage!.content ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingMessage = null),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          // ✅ Input row (luôn hiển thị)
          Row(
            children: [
              // 📎 Attachment button
              IconButton(
                onPressed: _showAttachmentOptions,
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.deepPurple,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _replyingMessage != null
                        ? "Trả lời ${_replyingMessage!.content ?? ''}..."
                        : "Nhập tin nhắn...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Colors.deepPurple),
              ),
            ],
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
              final dateOlder = ChatUtils.formatSqlDate(DateTime.now().add(const Duration(days: 1)));
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
    ref.read(chatGroupsNotifierProvider.notifier).setCurrentOpenGroup(-1);
    super.dispose();
  }
}