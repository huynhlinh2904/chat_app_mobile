import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_send_messages_state.dart';

/// ✅ Provider khai báo bên ngoài class (đúng chuẩn Riverpod)
final chatSendMessagesProvider =
StateNotifierProvider<ChatSendMessagesNotifier, ChatSendMessagesState>((ref) {
  final repo = ChatRepositoryImpl(ref.read(dioProvider));
  return ChatSendMessagesNotifier(repo);
});

class ChatSendMessagesNotifier extends StateNotifier<ChatSendMessagesState> {
  final ChatRepository _repo;

  ChatSendMessagesNotifier(this._repo) : super(const ChatSendIdle());

  Future<void> sendMessage({
    required int idGroup,
    required String idMessage,
    required String content,
    required int type,
    required int typeMessage,
    required int idSender,
    required String? replyToID,
    required String? replyToContent,
    required String fullNameUser,

    required WidgetRef ref,
  }) async {
    try {
      state = const ChatSendLoading();

      // Gửi API
      final response = await _repo.sendMessage(
        idGroup: idGroup,
        idMessage: idMessage,
        content: content,
        replyToID: replyToID,
        replyToContent: replyToContent,
        type: type,
      );

      if (response.isNotEmpty) {
        final realMsg = response.first;

        // Cập nhật message tạm bằng message thật
        // ref
        //     .read(chatMessageProvider.notifier)
        //     .replaceTempWithServerMessage(realMsg);

        state = ChatSendSuccess(response);
      }
    } catch (e) {
      state = ChatSendError(e.toString());
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) state = const ChatSendIdle();
      });
    }
  }
}
