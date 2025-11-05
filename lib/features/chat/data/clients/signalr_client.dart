import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:chat_mobile_app/core/constants/app_contain.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  late HubConnection hubConnection;
  final _eventStream = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventStream.stream;

  bool isConnected = false;

  Future<void> initConnection(String token) async {
    hubConnection = HubConnectionBuilder()
        .withUrl(
      EndPoint.chatHubUrl,
      options: HttpConnectionOptions(
        accessTokenFactory: () async => token,
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect()
        .build();

    // 🔹 Đăng ký các event từ server
    _registerHandlers();

    // 🔹 Lắng nghe trạng thái kết nối
    hubConnection.onreconnecting(({error}) {
      isConnected = false;
      print('🟠 Reconnecting... $error');
    });

    hubConnection.onreconnected(({connectionId}) async {
      isConnected = true;
      print('🟢 Reconnected! $connectionId');
      await _rejoinConversations();
      _eventStream.add({'type': 'reconnected'});
    });

    hubConnection.onclose(({error}) {
      isConnected = false;
      print('🔴 Connection closed: $error');
      _tryReconnect();
    });

    await _startConnection();
  }

  Future<void> _startConnection() async {
    while (hubConnection.state != HubConnectionState.Connected) {
      try {
        await hubConnection.start();
        isConnected = true;
        print("Connected to SignalR [${hubConnection.connectionId}]");
      } catch (e) {
        print("Connection failed, retrying in 5s: $e");
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> _tryReconnect() async {
    if (hubConnection.state != HubConnectionState.Connected) {
      print("Attempting manual reconnect...");
      await _startConnection();
    }
  }

  /// 🔸 Các event SignalR giống bản Web
  void _registerHandlers() {
    hubConnection.on("ReceiveMessage", (args) {
      final message = args?.first;
      _eventStream.add({'type': 'ReceiveMessage', 'data': message});
    });

    hubConnection.on("UserStatusChanged", (args) {
      _eventStream.add({
        'type': 'UserStatusChanged',
        'userId': args?[0],
        'isOnline': args?[1],
      });
    });

    hubConnection.on("ReceiveOnlineUsers", (args) {
      _eventStream.add({'type': 'ReceiveOnlineUsers', 'data': args?[0]});
    });

    hubConnection.on("GroupUpdated", (args) {
      _eventStream.add({'type': 'GroupUpdated', 'data': args});
    });

    hubConnection.on("MessageDeleted", (args) {
      _eventStream.add({'type': 'MessageDeleted', 'data': args});
    });

    hubConnection.on("NewGroupCreated", (args) {
      _eventStream.add({'type': 'NewGroupCreated', 'data': args});
    });

    hubConnection.on("RemovedFromGroup", (args) {
      _eventStream.add({'type': 'RemovedFromGroup', 'data': args});
    });
  }

  /// 🔹 Join lại tất cả nhóm khi reconnect
  Future<void> _rejoinConversations() async {
    // giả sử bạn có service lưu cache groupId
    final allGroups = await _loadCachedGroups();
    for (final group in allGroups) {
      try {
        await hubConnection.invoke("JoinConversation", args: [group.id]);
      } catch (err) {
        print("Lỗi khi join lại nhóm ${group.id}: $err");
      }
    }
  }

  Future<List<dynamic>> _loadCachedGroups() async {
    // TODO: lấy danh sách group đã tham gia từ local storage
    return [];
  }

  Future<void> sendMessage(int groupId, String text) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke("SendMessage", args: [groupId, text]);
    } else {
      print("⚠️ Cannot send message: disconnected");
    }
  }

  Future<void> stop() async {
    await hubConnection.stop();
    await _eventStream.close();
    print("🛑 SignalR stopped");
  }
}
