import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/usecases/get_chat_users_usecase.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../../core/network/dio_client.dart';

final chatListUserProvider = StateNotifierProvider<ChatListUserNotifier, AsyncValue<List<ChatUser>>>(
      (ref) {
    final dio = ref.read(dioProvider);
    final repo = ChatRepositoryImpl(dio);
    final usecase = GetChatUsersUseCase(repo);
    return ChatListUserNotifier(usecase);
  },
);

class ChatListUserNotifier extends StateNotifier<AsyncValue<List<ChatUser>>> {
  final GetChatUsersUseCase _usecase;

  ChatListUserNotifier(this._usecase) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers({int type = 3}) async {
    try {
      state = const AsyncValue.loading();
      final users = await _usecase.call(type: type);
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
