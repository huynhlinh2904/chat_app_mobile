import '../dtos/chat_group_response_dto.dart';
import '../../domain/entities/chat_group.dart';

extension ChatGroupDtoMapper on ChatGroupItemDto {
  ChatGroup toEntity() => ChatGroup(
    idGroup   : idGroup,
    groupName : (groupName.isEmpty ? 'Không tên' : groupName),
    avatarImg : avatarImg,
    backgroundImg: backgroundImg,
    isGroup   : isGroup,
    idUser    : idUser,
    createDate: createDate,
    creatorName: creatorName,
    userName1 : userName1,
    userName2 : userName2,
    idUser1   : idUser1,
    idUser2   : idUser2,
    content   : content,
    typeMessage: typeMessage,
    fileSend  : fileSend,
    dateSent  : dateSent,
    idSender  : idSender,
    senderName: senderName,
    idMessage : idMessage,
    dateSort  : dateSort,
    rn        : rn,

    lastMessage: content,
    unreadCount: unreadCount ?? 0,
  );
}
