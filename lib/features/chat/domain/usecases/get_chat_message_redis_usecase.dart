
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message_redis.dart';

import '../repositories/chat_repository.dart';

class GetChatMessageRedisUsecase {
  final ChatRepository repository;
  GetChatMessageRedisUsecase(this.repository);

  Future<List<ChatGetMessageRedis>> call({
    required int idGroup,
  }) {
    return repository.getMessageRedis(
      idGroup: idGroup,
    );
  }
}