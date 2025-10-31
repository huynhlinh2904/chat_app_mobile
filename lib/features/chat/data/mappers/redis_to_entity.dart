import '../../domain/entities/chat_get_message.dart';
import '../../domain/entities/chat_get_message_redis.dart';

extension RedisToEntity on ChatGetMessageRedis {
  ChatGetMessage toChatGetMessage() => ChatGetMessage(
    iddv, sm1, sm2, idGroup,
    idMessage: idMessage,           // 🔸 kiểu String
    idSender: idSender,
    content: content,
    replyToID: replyToID,           // 🔸 kiểu String?
    dateSent: dateSent,
    statusMess: statusMess,
    typeMessage: typeMessage,
    fileSend: null,                 // map theo model của bạn (nếu có)
    fullNameUser: fullNameUser,
    avatarImg: null,                // map theo model của bạn (nếu có)
    replyToContent: replyToContent,
    fileName: fileName,
    fileNameCode: fileNameCode,
  );
}