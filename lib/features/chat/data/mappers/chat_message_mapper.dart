import '../../domain/entities/chat_get_message.dart';
import '../dtos/chat_message_response_dto.dart';


String _s(dynamic v) => v?.toString() ?? '';
extension ChatMessageMapper on ChatGetMessageItemDto {
  ChatGetMessage toEntity() => ChatGetMessage(
    iddv, sm1, sm2, idGroup,
    idMessage: _s(idMessage),
    idSender: idSender,
    content: content ?? '',
    replyToID: _s(replyToID),
    dateSent: dateSent,
    statusMess: statusMess,
    typeMessage: typeMessage,
    fileSend: fileSend,
    fullNameUser: fullNameUser ?? '',
    avatarImg: avatarImg,
    replyToContent: replyToContent,
    fileName: fileName,
    fileNameCode: fileNameCode,
  );
}
