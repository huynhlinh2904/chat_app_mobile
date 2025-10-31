import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message_redis.dart';
import 'package:chat_mobile_app/features/chat/domain/usecases/get_chat_message_redis_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/chat_repository_impl.dart';

final chatGetMessageRedisProvider =
StateNotifierProvider.autoDispose<ChatMessageRedisNotifier, AsyncValue<List<ChatGetMessageRedis>>>(
      (ref) {
    final dio = ref.read(dioProvider);
    final repo = ChatRepositoryImpl(dio);
    final usecase = GetChatMessageRedisUsecase(repo);
    return ChatMessageRedisNotifier(usecase);
  },
);

class ChatMessageRedisNotifier extends StateNotifier<AsyncValue<List<ChatGetMessageRedis>>> {
  final GetChatMessageRedisUsecase _usecase;

  ChatMessageRedisNotifier(this._usecase) : super(const AsyncValue.data([]));

  /// 📨 Lấy danh sách tin nhắn (support null dateOlder để usecase fallback)
  Future<void> fetchMessageRedis({
    required int idGroup,
  }) async {
    try {
      final prev = state;
      final previous = prev.value ?? <ChatGetMessageRedis>[];

      // Giữ UI mượt: loading nhưng vẫn có previous
      state = const AsyncValue<List<ChatGetMessageRedis>>.loading()
          .copyWithPrevious(prev);

      final fetched = await _usecase.call(
        idGroup: idGroup,
      );

      // Khử trùng lặp theo idMessage (dạng String để tránh mismatch int/String)
      final map = <String, ChatGetMessageRedis>{
        for (final m in previous) '${m.idMessage}': m,
      };
      for (final m in fetched) {
        map['${m.idMessage}'] = m;
      }

      // Sort tăng dần theo thời gian (fallback epoch nếu null)
      final merged = map.values.toList()
        ..sort((a, b) {
          final ad = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ad.compareTo(bd);
        });

      state = AsyncValue.data(merged);
    } catch (e, st) {
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
  }) {
    final current = state.value ?? <ChatGetMessageRedis>[];

    final temp = ChatGetMessageRedis(
      0, '', '', idGroup,
      idMessage: DateTime.now().millisecondsSinceEpoch.toString(), // id tạm âm
      idSender: idSender,
      content: content,
      replyToID: null,
      dateSent: DateTime.now(),
      statusMess: 0,        // 0 = sending (tùy mapping của bạn)
      typeMessage: 1,
      fullNameUser: fullNameUser,
      replyToContent: null,
      fileName: null,
      fileNameCode: null,
    );

    state = AsyncValue.data([...current, temp]);
  }

  /// 🧹 Xóa danh sách tin nhắn (khi rời phòng chat)
  void clearMessages() {
    state = const AsyncValue.data([]);
  }
}
