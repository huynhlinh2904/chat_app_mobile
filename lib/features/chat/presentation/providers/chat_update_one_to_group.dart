import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../chat/domain/usecases/chat_update_one_to_group_usecase.dart';

final chatUpdateOneToGroupUseCaseProvider = Provider<ChatUpdateOneToGroupUseCase>((ref) {
  final dio = ref.read(dioProvider);
  final repo = ChatRepositoryImpl(dio);
  return ChatUpdateOneToGroupUseCase(repo);
});