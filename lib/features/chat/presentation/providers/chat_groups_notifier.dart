import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_mobile_app/core/network/dio_client.dart';
import '../../domain/entities/chat_group.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_groups_usecase.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/clients/signalr_client.dart'; // 👈 thêm dòng này

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ChatRepositoryImpl(dio);
});

final getChatGroupsProvider = Provider<GetChatGroupsUseCase>((ref) {
  return GetChatGroupsUseCase(ref.read(chatRepositoryProvider));
});

final chatGroupsNotifierProvider =
StateNotifierProvider<ChatGroupsNotifier, AsyncValue<List<ChatGroup>>>((ref) {
  return ChatGroupsNotifier(ref.read(getChatGroupsProvider));
});

class ChatGroupsNotifier extends StateNotifier<AsyncValue<List<ChatGroup>>> {
  final GetChatGroupsUseCase _usecase;
  ChatGroupsNotifier(this._usecase) : super(const AsyncLoading());

  Future<void> fetch({required int idGroup, required int type}) async {
    state = const AsyncLoading();

    try {
      final groups = await _usecase(idGroup: idGroup, type: type);
      state = AsyncValue.data(groups);

      // ✅ join toàn bộ group ngay sau khi tải về
      if (groups.isNotEmpty) {
        final signalr = SignalRService();
        print("📦 [ChatGroupsNotifier] Joining ${groups.length} groups...");

        for (final g in groups) {
          try {
            await signalr.joinConversation(g.idGroup);
          } catch (e) {
            print("⚠️ join group ${g.idGroup} failed: $e");
          }
        }

        print("🎉 [ChatGroupsNotifier] Joined all groups successfully!");
      } else {
        print("ℹ️ [ChatGroupsNotifier] No groups found to join.");
      }
    } catch (e, st) {
      print("❌ [ChatGroupsNotifier] fetch error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}
