import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_mobile_app/core/network/dio_client.dart';
import '../../domain/entities/chat_group.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_groups_usecase.dart';
import '../../data/repositories/chat_repository_impl.dart';

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
    state = await AsyncValue.guard(() => _usecase(idGroup: idGroup, type: type));
  }
}
