// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:signalr_netcore/http_connection_options.dart';
// import 'package:signalr_netcore/hub_connection.dart';
// import 'package:signalr_netcore/hub_connection_builder.dart';
// import 'package:signalr_netcore/itransport.dart';
//
// final signalRProvider = Provider<SignalRService>((ref) {
//   final service = SignalRService();
//   service.connect();
//   ref.onDispose(() => service.disconnect());
//   return service;
// });
//
// class SignalRService {
//   late HubConnection _hubConnection;
//
//   final _messageController = StreamController<ChatMessage>.broadcast();
//
//   Stream<ChatMessage> get messageStream => _messageController.stream;
//
//   void connect() {
//     _hubConnection = HubConnectionBuilder()
//         .withUrl('https://yourserver.com/chatHub?group=group123',
//         options: HttpConnectionOptions(
//           transport: HttpTransportType.WebSockets,
//         ))
//         .build();
//
//     _hubConnection.on("ReceiveMessage", (args) {
//       final groupId = args![0] as String;
//       final user = args[1] as String;
//       final message = args[2] as String;
//       _messageController.add(ChatMessage(user: user, content: message));
//     });
//
//     _hubConnection.start();
//   }
//
//   void disconnect() {
//     _hubConnection.stop();
//   }
//
//   void sendMessage(String groupId, String user, String content) {
//     _hubConnection.invoke("SendMessage", args: [groupId, user, content]);
//   }
// }
