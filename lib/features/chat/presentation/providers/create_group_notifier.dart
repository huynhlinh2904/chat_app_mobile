import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_chat_group_usecase.dart';
import '../../domain/entities/chat_create_group_entity.dart';
import '../../data/dtos/create_group_request_dto.dart';


class CreateGroupNotifier
    extends StateNotifier<AsyncValue<ChatCreateGroupEntity?>> {
  final CreateChatGroupUseCase _useCase;

  CreateGroupNotifier(this._useCase)
      : super(const AsyncData(null));

  Future<ChatCreateGroupEntity> create(CreateGroupRequestDTO dto) async {
    state = const AsyncLoading();
    try {
      final result = await _useCase(dto);

      if (result.isEmpty) {
        throw Exception("Create group failed");
      }

      final created = result.first;
      state = AsyncData(created);
      return created;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
