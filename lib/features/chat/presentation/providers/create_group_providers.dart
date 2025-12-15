import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_create_group_entity.dart';
import '../../domain/usecases/create_chat_group_usecase.dart';
import 'chat_groups_notifier.dart';
import 'create_group_notifier.dart';


final createChatGroupUseCaseProvider =
Provider<CreateChatGroupUseCase>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return CreateChatGroupUseCase(repo);
});


final createGroupNotifierProvider =
StateNotifierProvider<CreateGroupNotifier, AsyncValue<ChatCreateGroupEntity?>>(
      (ref) {
    return CreateGroupNotifier(
      ref.read(createChatGroupUseCaseProvider),
    );
  },
);
