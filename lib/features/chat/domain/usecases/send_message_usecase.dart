import '../entities/chat_send_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<List<ChatSendMessage>> call({
    required int idGroup,
    required String idMessage,
    required String content,
    required int type,
    String? replyToID,
    String? replyToContent,
  }) {
    return repository.sendMessage(
      idGroup: idGroup,
      idMessage: idMessage,
      content: content,
      type: type,
      replyToID: replyToID,
      replyToContent: replyToContent,
    );
  }
}
