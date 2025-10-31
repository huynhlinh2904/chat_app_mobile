import '../entities/chat_group.dart';
import '../repositories/chat_repository.dart';

class GetChatGroupsUseCase {
  final ChatRepository repo;
  const GetChatGroupsUseCase(this.repo);

  Future<List<ChatGroup>> call({required int idGroup, required int type}) {
    return repo.getGroups(idGroup: idGroup, type: type);
  }
}


