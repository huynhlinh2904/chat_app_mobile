import 'package:chat_mobile_app/features/chat/data/mappers/redis_to_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_get_message.dart';
import 'chat_get_message_redis_notifier.dart';
import 'chat_messages_notifier.dart';             // DB: AsyncValue<List<ChatGetMessage>>

final combinedMessagesProvider =
Provider<AsyncValue<List<ChatGetMessage>>>((ref) {
  final db = ref.watch(chatMessageProvider);              // AsyncValue<List<ChatGetMessage>>
  final redis = ref.watch(chatGetMessageRedisProvider);    // AsyncValue<List<ChatGetMessageRedis>>

  List<ChatGetMessage> dedupeSort(
      List<ChatGetMessage> dbMessages,
      List<ChatGetMessage> redisMessages,
      ) {
    final map = <String, ChatGetMessage>{};

    // ⚙️ Ưu tiên Redis nếu trùng idMessage
    for (final msg in dbMessages) {
      final key = msg.idMessage?.toString() ?? '';
      if (key.isNotEmpty) {
        map[key] = msg;
      }
    }

    for (final msg in redisMessages) {
      final key = msg.idMessage?.toString() ?? '';
      if (key.isNotEmpty) {
        map[key] = msg; // ghi đè nếu trùng ID
      }
    }

    final list = map.values.toList()
      ..sort((a, b) {
        final da = a.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.dateSent ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });

    return list;
  }


  // Ưu tiên hiển thị được “một phần” khi một nguồn loading
  return db.when(
    loading: () {
      return redis.when(
        data: (r) => AsyncValue.data(r.map((e) => e.toChatGetMessage()).toList()),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    },
    error: (e, st) => AsyncValue.error(e, st),
    data: (dbList) {
      return redis.when(
        loading: () => AsyncValue.data(dbList), // show DB trước
        error: (e, st) => AsyncValue.error(e, st),
        data: (r) {
          final fromRedis = r.map((e) => e.toChatGetMessage()).toList();
          final merged = dedupeSort(dbList, fromRedis);
          return AsyncValue.data(merged);
        },
      );
    },
  );
});
