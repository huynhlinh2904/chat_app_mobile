import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/get_message_id_by_uuid_usecase.dart';

final getMessageIdByUuidUseCaseProvider = Provider<GetMessageIdByUuidUseCase>((ref) {
  final dio = ref.read(dioProvider);
  final repo = ChatRepositoryImpl(dio);
  return GetMessageIdByUuidUseCase(repo);
});