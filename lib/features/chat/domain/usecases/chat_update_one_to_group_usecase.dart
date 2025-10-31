import '../entities/chat_update_one_to_group.dart';
import '../repositories/chat_repository.dart';

class ChatUpdateOneToGroupUseCase {
  final ChatRepository _repo;
  ChatUpdateOneToGroupUseCase(this._repo);

  Future<List<ChatUpdateOneToGroupE>> call({
    required int idGroup,
    required int idSender,
    required int idReceive,
    int type = 0,
  }) {
    return _repo.chatUpdateOneToGroup(
      idGroup: idGroup,
      idSender: idSender,
      idReceive: idReceive,
      type: type,
    );
  }
}