import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/create_group_request_dto.dart';
import '../../domain/entities/chat_create_group_entity.dart';
import 'chat_groups_notifier.dart';

final createGroupProvider = FutureProvider.family<List<ChatCreateGroupEntity>, CreateGroupRequestDTO>(
      (ref, dto) async {
    final repo = ref.read(chatRepositoryProvider);
    return await repo.createGroup(dto);
  },
);
