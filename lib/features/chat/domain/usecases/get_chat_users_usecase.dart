import '../entities/chat_user.dart';
import '../repositories/chat_repository.dart';

class GetChatUsersUseCase {
  final ChatRepository repository;
  GetChatUsersUseCase(this.repository);

  Future<List<ChatUser>> call({required int type}) {
    return repository.getUsers(type: type);
  }
}
