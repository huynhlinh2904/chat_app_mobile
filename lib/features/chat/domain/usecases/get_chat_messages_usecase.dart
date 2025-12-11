import '../../../../core/utils/utils.dart';
import '../entities/chat_get_message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;
  GetChatMessagesUseCase(this.repository);

  Future<List<ChatGetMessage>> call({
    required int idGroup,
    String? dateOlder,
    int? limit = 10,
    required int type,
  }) {
    final formattedDate = dateOlder ?? ChatUtils.tomorrowSqlDate(); // ví dụ: '2099-01-01'
    return repository.getMessages(
      idGroup: idGroup,
      dateOlder: formattedDate,
      type: type,
    );
  }
}