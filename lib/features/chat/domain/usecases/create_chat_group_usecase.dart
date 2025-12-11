import 'package:chat_mobile_app/features/chat/domain/entities/chat_create_group_entity.dart';
import '../repositories/chat_repository.dart';
import '../../data/dtos/create_group_request_dto.dart';

class CreateChatGroupUseCase {
  final ChatRepository repository;

  CreateChatGroupUseCase(this.repository);

  Future<List<ChatCreateGroupEntity>> call(CreateGroupRequestDTO dto) {
    return repository.createGroup(dto);
  }
}
