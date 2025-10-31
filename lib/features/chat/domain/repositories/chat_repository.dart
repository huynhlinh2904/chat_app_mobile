import 'package:chat_mobile_app/features/chat/data/dtos/chat_update_one_to_group.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message_redis.dart';


import '../entities/chat_group.dart';
import '../entities/chat_get_message.dart';
import '../entities/chat_send_message.dart';
import '../entities/chat_update_one_to_group.dart';
import '../entities/chat_user.dart';

abstract class ChatRepository {
  Future<List<ChatGroup>> getGroups({required int idGroup, required int type});
  Future<List<ChatUser>> getUsers({required int type});
  Future<List<ChatGetMessage>> getMessages({required int idGroup, required String dateOlder, required int type,});
  Future<List<ChatGetMessageRedis>> getMessageRedis({required int idGroup});
  Future<List<ChatSendMessage>> sendMessage({required int idGroup, required String content, required int type, int? replyToID, String? replyToContent, required String idMessage,});
  Future<int?> getMessageIdByUuid(String uuid) async {return null;}
  Future<List<ChatUpdateOneToGroupE>> chatUpdateOneToGroup({required int idGroup, required int idSender, required int idReceive, int type = 0,  });
}
