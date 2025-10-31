import '../../domain/entities/chat_send_message.dart';
import '../dtos/chat_send_message_dto.dart';

extension ChatSendMessageMapper on ChatSendMessageItemDto {
  ChatSendMessage toEntity() => ChatSendMessage(
    idGroup: idGroup,
    idMessage: idMessage,
    idSender: idSender,
    fullNameUser: fullNameUser,
    content: content,
    replyToID: replyToID,
    replyToContent: replyToContent,
    dateSent: dateSent,
    typeMessage: typeMessage,
  );
}
