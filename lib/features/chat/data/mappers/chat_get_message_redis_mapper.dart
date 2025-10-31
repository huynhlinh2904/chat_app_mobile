import 'package:chat_mobile_app/features/chat/data/dtos/chat_get_message_redis_response_dto.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message_redis.dart';

extension ChatGetMessageRedisMapper on ChatGetMessageRedisItemDto {
  ChatGetMessageRedis toEntity() => ChatGetMessageRedis(
    iddv, sm1, sm2, idGroup,
    idMessage: idMessage,
    idSender: idSender,
    content: content ?? '',
    replyToID: replyToID,
    dateSent: dateSent,
    statusMess: statusMess,
    typeMessage: typeMessage,
    fullNameUser: fullNameUser ?? '',
    replyToContent: replyToContent,
    fileName: fileName,
    fileNameCode: fileNameCode,
  );
}
