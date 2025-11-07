import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_get_user_duan.dart';
import '../../domain/usecases/get_user_by_duan_usecase.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../../core/network/dio_client.dart';

final chatRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return ChatRepositoryImpl(dio);
});

final getUserByDuanProvider = Provider((ref) {
  return GetUserByDuanUseCase(ref.read(chatRepositoryProvider));
});

final userByDuanNotifierProvider =
StateNotifierProvider<UserByDuanNotifier, AsyncValue<List<ChatGetUserDuan>>>(
      (ref) => UserByDuanNotifier(ref.read(getUserByDuanProvider)),
);

class UserByDuanNotifier extends StateNotifier<AsyncValue<List<ChatGetUserDuan>>> {
  final GetUserByDuanUseCase _useCase;

  UserByDuanNotifier(this._useCase) : super(const AsyncLoading());

  Future<void> fetch({
    required int idDv,
    required String sm1,
    required String sm2,
    required int idUser,
    required int type,
  }) async {
    state = const AsyncLoading();
    try {
      final data = await _useCase(
        idDv: idDv,
        sm1: sm1,
        sm2: sm2,
        idUser: idUser,
        type: type,
      );
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
