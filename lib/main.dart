import 'package:chat_mobile_app/pages/chat_screen.dart';
import 'package:chat_mobile_app/pages/demo_page.dart';
import 'package:chat_mobile_app/pages/login.dart';
import 'package:chat_mobile_app/pages/main_navigation_menu.dart';
import 'package:chat_mobile_app/pages/profile_screen.dart';
import 'package:chat_mobile_app/pages/signup.dart';
import 'package:flutter/material.dart';

import 'pages/test_call_api_list_user.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatLoginPage(),
        '/signup': (context) => const SignupPage(),
        '/chat_screen': (context) => const ChatScreen(),
        '/main_navigation_menu': (context) => MainNavigationScreen(),
        '/profile_screen': (context) => ProfileScreen(),
      }
    );
  }
}

