import 'package:chat_mobile_app/features/chat/data/dtos/chat_update_one_to_group.dart';
import '../../domain/entities/chat_update_one_to_group.dart';

extension ChatUpdateOneToGroupMapper on ChatUpdateOneToGroupItemDto {
  ChatUpdateOneToGroupE toEntity() => ChatUpdateOneToGroupE(
    iddv: iddv,
    sm1: sm1,
    sm2: sm2,
    idGroup: idGroup,
    idUser1: idUser1,
    idUser2: idUser2,
  );
}
