import '../../domain/entities/chat_user.dart';
import '../dtos/chat_user_response_dto.dart';

extension ChatUserItemMapper on ChatUserItemDto {
  ChatUser toEntity() => ChatUser(
    id: idUser,
    userName: userName,
    fullName: fullName.isNotEmpty ? fullName : userName,
    email: email.isEmpty ? null : email,
    phone: sdt.isEmpty ? null : sdt,
    address: address.isEmpty ? null : address,
    gender: gioiTinh,
    departmentId: idPbPa,
  );
}
