import '../../domain/entities/chat_send_message.dart';

/// Trạng thái gửi tin nhắn
sealed class ChatSendMessagesState {
  const ChatSendMessagesState();
}

class ChatSendIdle extends ChatSendMessagesState {
  const ChatSendIdle();
}

class ChatSendLoading extends ChatSendMessagesState {
  const ChatSendLoading();
}

class ChatSendSuccess extends ChatSendMessagesState {
  final List<ChatSendMessage> messages;
  const ChatSendSuccess(this.messages);
}

class ChatSendError extends ChatSendMessagesState {
  final String message;
  const ChatSendError(this.message);
}
