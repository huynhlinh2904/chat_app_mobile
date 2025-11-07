import 'flutter_secure_storage.dart';

class EndPoint {
  static const apiService ='http://10.0.2.2:5003';
  static const chatHubUrl = '$apiService/ChatHub';
  //static const apiService = 'https://api.megacde.vn/buildapi';
  static const loginUrl = '$apiService/api/Authenticate/Login';
  static const chatListUserAPI = '$apiService/api/Chat/CHAT_get_DMNhanVien';
  static const groupChatUrl = '$apiService/api/Chat/CHAT_get_CHATGROUPS';
  static const listMessageAPI = '$apiService/api/Chat/CHAT_get_Message';
  static const chatGetMessageRedisAPI = "$apiService/api/Chat/CHAT_get_Message_Redis";
  static const sendMessageAPI = "$apiService/api/Chat/CHAT_update_MESSAGE";
  static const chatUpdateOneToGroupAPI = "$apiService/api/Chat/CHAT_update_OneToGroups";
  static const getUserByDuanUrl = "$apiService/api/Chat/CHAT_get_NV_DUAN";
}

class LinkImage {
  static const defaultAvatar = 'https://i.pravatar.cc/150?img=3';
}

class ChatCredentials {
  final int iddv;
  final int userId;
  final String sm1;
  final String sm2;
  final String? fullNameUser;
  final String? imgAva;


  ChatCredentials({
    required this.iddv,
    required this.userId,
    required this.sm1,
    required this.sm2,
    this.fullNameUser,
    this.imgAva,
  });
}

Future<ChatCredentials?> getChatCredentials() async {
  final iddv = await LocalStorageService.getIDDV();
  final userId = await LocalStorageService.getIDUser();
  final sm1 = await LocalStorageService.getSM1();
  final sm2 = await LocalStorageService.getSM2();
  final fullNameUser = await LocalStorageService.getFullNameUser();
  final imgAva = await LocalStorageService.getAvatarUrl();


  if ([iddv, userId, sm1, sm2].any((e) => e == null)) return null;

  return ChatCredentials(
    iddv: iddv!,
    userId: userId!,
    sm1: sm1!,
    sm2: sm2!,
    fullNameUser: fullNameUser,
    imgAva: imgAva,
  );
}
