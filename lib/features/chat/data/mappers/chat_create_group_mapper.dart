import 'package:chat_mobile_app/features/chat/domain/entities/chat_create_group_entity.dart';
import '../dtos/create_group_response_dto.dart';

extension ChatCreateGroupItemMapper on ChatCreateGroupItemDTO {
  ChatCreateGroupEntity toEntity() => ChatCreateGroupEntity(
    iddv: iddv,
    sm1: sm1,
    sm2: sm2,
    idGroup: idGroup,
    groupName: groupName,
  );
}
