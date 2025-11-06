import 'package:chat_mobile_app/core/constants/flutter_secure_storage.dart';

import '../../features/chat/data/clients/signalr_client.dart';

class AppInitializer {
  static Future<void> init() async{
    final token = await LocalStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      await _initSignalR(token);

    }
  }

  static Future<void> _initSignalR(String token) async {
    final signalR = SignalRService();

    try {
      await signalR.initConnection(token);
      print('🟢 [AppInitializer] SignalR connected automatically!');
    } catch (e) {
      print('🔴 [AppInitializer] SignalR init failed: $e');
    }
  }
}