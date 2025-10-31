import 'package:chat_mobile_app/core/constants/app_contain.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'dart:async';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  late HubConnection hubConnection;
  final _messageStreamController = StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageStreamController.stream;

  Future<void> initConnection() async {
    hubConnection = HubConnectionBuilder()
        .withUrl(
      EndPoint.chatHubUrl,
      options: HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect() // ✅ tự động reconnect
        .build();



    // Lắng nghe sự kiện từ server
    hubConnection.on("ReceiveMessage", (args) {
      final message = args != null && args.isNotEmpty ? args[1].toString() : '';
      _messageStreamController.add(message);
    });

    // Các event kết nối
    hubConnection.onclose(({error}) {
      print("🔴 Connection closed: $error");
      _tryReconnect();
    });

    hubConnection.onreconnecting(({error}) {
      print("🟠 Reconnecting... $error");
    });

    hubConnection.onreconnected(({connectionId}) {
      print("🟢 Reconnected! connectionId=$connectionId");
    });

    await _startConnection();
  }

  Future<void> _startConnection() async {
    while (hubConnection.state != HubConnectionState.Connected) {
      try {
        await hubConnection.start();
        print("✅ Connected to SignalR [${hubConnection.connectionId}]");
      } catch (e) {
        print("❌ Connection failed, retrying in 5s: $e");
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> _tryReconnect() async {
    // chỉ gọi reconnect nếu chưa kết nối
    if (hubConnection.state != HubConnectionState.Connected) {
      print("🔁 Attempting manual reconnect...");
      await _startConnection();
    }
  }

  Future<void> stop() async {
    await hubConnection.stop();
    await _messageStreamController.close();
    print("🛑 SignalR stopped");
  }
}
