import 'package:chat_mobile_app/core/constants/flutter_secure_storage.dart';
import 'package:chat_mobile_app/features/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import '../chat/data/clients/signalr_client.dart';
import '../chat/presentation/pages/chat_list_group_screen.dart';
import '../chat/presentation/pages/chat_list_user_screen.dart';
import 'explore_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatListScreen(),  // Tab Tin nhắn
    const ChatListUserScreen(),   // Tab Cá nhân
    //const MenuScreen(),
    const ProfileScreen(),// Tab Menu
    const ChatExploreSimpleScreen(),   // Tab Khám phá
  ];

  @override
  void initState() {
    super.initState();
    _initSignalr();
  }

  Future<void> _initSignalr() async{
    final token = await LocalStorageService.getToken();;
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ hoặc trống");
    }
    await SignalRService().initConnection(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Bạn bè',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
        ],
      ),
    );
  }
}
