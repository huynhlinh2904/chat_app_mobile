import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_get_message.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../../../core/network/dio_client.dart';

final chatMessageProvider =
StateNotifierProvider.autoDispose<ChatMessageNotifier, AsyncValue<List<ChatGetMessage>>>(
      (ref) {
    final dio = ref.read(dioProvider);
    final repo = ChatRepositoryImpl(dio);
    final usecase = GetChatMessagesUseCase(repo);
    return ChatMessageNotifier(usecase);
  },
);

class ChatMessageNotifier extends StateNotifier<AsyncValue<List<ChatGetMessage>>> {
  final GetChatMessagesUseCase _usecase;

  ChatMessageNotifier(this._usecase) : super(const AsyncValue.data([]));

  /// 📨 Lấy danh sách tin nhắn (support null dateOlder để usecase fallback)
  Future<void> fetchMessages({
    required int idGroup,
    String? dateOlder,
    int type = 0,
  }) async {
    try {
      final prev = state;
      final previous = prev.value ?? <ChatGetMessage>[];

      // Loading nhưng vẫn giữ previous để UI mượt
      state = const AsyncValue<List<ChatGetMessage>>.loading().copyWithPrevious(prev);

      final fetched = await _usecase.call(
        idGroup: idGroup,
        dateOlder: dateOlder,
        type: type,
      );

      // Khử trùng lặp theo idMessage (string hoá để tránh lệch kiểu)
      final map = <String, ChatGetMessage>{
        for (final m in previous) '${m.idMessage}': m,
      };
      for (final m in fetched) {
        map['${m.idMessage}'] = m;
      }

      final merged = map.values.toList()
        ..sort((a, b) {
          final ad = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ad.compareTo(bd);
        });

      state = AsyncValue.data(merged);
    } catch (e, st) {
      // ignore: avoid_print
      print('💥 [ChatMessageNotifier] fetchMessages error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// ➕ Thêm tin nhắn local tạm thời khi nhấn "Gửi"
  void appendLocalMessage({
    required int idGroup,
    required String content,
    required int idSender,
    required String fullNameUser,
    String? avatarUrl,
    String? idMessageOverride, // có thể là UUID, sẽ auto prefix temp_
    int typeMessage = 0,
  }) {
    final current = state.value ?? <ChatGetMessage>[];

    final tempId = (() {
      if (idMessageOverride == null) {
        return 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }
      return idMessageOverride.startsWith('temp_')
          ? idMessageOverride
          : 'temp_$idMessageOverride';
    })();

    final temp = ChatGetMessage(
      0, '', '', idGroup,
      idMessage: tempId,
      idSender: idSender,
      content: content,
      replyToID: null,
      dateSent: DateTime.now(),
      statusMess: 0,            // 0 = sending (tuỳ convention của bạn)
      typeMessage: typeMessage, // text
      fileSend: null,
      fullNameUser: fullNameUser,
      avatarImg: avatarUrl,
      replyToContent: null,
      fileName: null,
      fileNameCode: null,
    );

    state = AsyncValue.data([...current, temp]);
  }

  /// Upsert 1 message "thật" (từ API/Redis) theo idMessage
  void upsertApiMessage(ChatGetMessage msg) {
    final cur = state.value ?? <ChatGetMessage>[];
    final map = <String, ChatGetMessage>{
      for (final m in cur) '${m.idMessage}': m,
    };
    map['${msg.idMessage}'] = msg;

    final merged = map.values.toList()
      ..sort((a, b) {
        final ad = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });

    state = AsyncValue.data(merged);
  }

  /// Xoá hết message tạm (id bắt đầu bằng temp_)
  void purgeTempMessages() {
    final cur = state.value ?? <ChatGetMessage>[];
    final cleaned = cur.where((m) => !'${m.idMessage}'.startsWith('temp_')).toList()
      ..sort((a, b) {
        final ad = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });
    state = AsyncValue.data(cleaned);
  }

  /// Thay temp_<uuid> bằng idMessage thật (int) sau khi BE map UUID -> ID
  void replaceTempWithServerId({
    required String uuid,
    required int idMessage,
  }) {
    final cur = state.value ?? <ChatGetMessage>[];
    if (cur.isEmpty) return;

    final replaced = <ChatGetMessage>[];

    for (final m in cur) {
      final idStr = '${m.idMessage}';
      if (idStr == 'temp_$uuid') {
        // Tạo bản mới y hệt m nhưng đổi idMessage sang id thật
        replaced.add(
          ChatGetMessage(
            0, '', '', m.idGroup,
            idMessage: idMessage.toString(),           // <-- id thật (int)
            idSender: m.idSender,
            content: m.content,
            replyToID: m.replyToID,
            dateSent: m.dateSent,
            statusMess: 1,                  // ví dụ 1 = sent/synced (tuỳ convention)
            typeMessage: m.typeMessage,
            fileSend: m.fileSend,
            fullNameUser: m.fullNameUser,
            avatarImg: m.avatarImg,
            replyToContent: m.replyToContent,
            fileName: m.fileName,
            fileNameCode: m.fileNameCode,
          ),
        );
      } else {
        replaced.add(m);
      }
    }

    replaced.sort((a, b) {
      final ad = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ad.compareTo(bd);
    });

    state = AsyncValue.data(replaced);
  }

  void clearMessages() {
    state = const AsyncValue.data([]);
  }
}
