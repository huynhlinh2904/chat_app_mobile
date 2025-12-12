import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:chat_mobile_app/core/constants/app_contain.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  static final _eventStream = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventStream.stream;

  late HubConnection hubConnection;
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

    _registerHandlers();

    hubConnection.onreconnecting(({error}) {
      isConnected = false;
      print('Reconnecting... $error');
    });

    hubConnection.onreconnected(({connectionId}) async {
      isConnected = true;
      print(' Reconnected! $connectionId');
      await _rejoinConversations();
      _eventStream.add({'type': 'reconnected'});
    });

    hubConnection.onclose(({error}) {
      isConnected = false;
      print(' Connection closed: $error');
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

  void _registerHandlers() {
    hubConnection.on("ReceiveMessage", (args) {
      print("[SignalR] Raw ReceiveMessage args: $args");
      if (args == null || args.isEmpty) {
        print("[SignalR] ReceiveMessage args is null or empty");
        return;
      }

      final message = args.first;
      print(" [SignalR] Parsed first argument: $message (${message.runtimeType})");

      _eventStream.add({
        'type': 'ReceiveMessage',
        'data': message,
      });
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
    hubConnection.on("ReceiveLastMessage", (args) {
      if (args == null || args.isEmpty) return;

      final msg = args.first;

      print("[SignalR] 🔥 ReceiveLastMessage: $msg");

      _eventStream.add({
        'type': 'ReceiveLastMessage',
        'data': msg,
      });
    });


  }



  // Gọi hàm này sau khi mở ChatScreen
  Future<void> joinConversation(int groupId) async {
    try {
      print(" [SignalR] Joining group: $groupId");
      await hubConnection.invoke("JoinConversation", args: [groupId.toString()]);
      print("[SignalR] Joined group $groupId");
    } catch (e) {
      print("[SignalR] JoinConversation error for group $groupId: $e");
    }
  }

  Future<void> _rejoinConversations() async {
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
      print(" Cannot send message: disconnected");
    }
  }

  //KHÔNG ĐƯỢC close eventStream (vì nhiều màn hình lắng nghe)
  Future<void> stop() async {
    await hubConnection.stop();
    print(" SignalR stopped");
  }
}
