import '../entities/chat_get_user_duan.dart';
import '../repositories/chat_repository.dart';

class GetUserByDuanUseCase {
  final ChatRepository _repo;

  GetUserByDuanUseCase(this._repo);

  Future<List<ChatGetUserDuan>> call({
    required int idDv,
    required String sm1,
    required String sm2,
    required int idUser,
    required int type,
  }) {
    return _repo.getUserByDuan(
      idDv: idDv,
      sm1: sm1,
      sm2: sm2,
      idUser: idUser,
      type: type,
    );
  }
}
