import '../repositories/chat_repository.dart';

class GetMessageIdByUuidUseCase {
  final ChatRepository _repo;
  GetMessageIdByUuidUseCase(this._repo);

  Future<int?> call(String uuid) => _repo.getMessageIdByUuid(uuid);
}
