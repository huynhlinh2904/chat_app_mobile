import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'features/auth/pages/login.dart';
import 'features/auth/pages/slash_screen.dart';
import 'features/chat/pages/chat_screen.dart';
import 'features/chat/pages/main_navigation_menu.dart';
import 'features/auth/pages/profile_screen.dart';



void main() {
  runApp(
      ProviderScope(
        child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const ChatLoginPage_DEV(),
        '/chat_screen': (context) => const ChatScreen(),
        '/main_navigation_menu': (context) => MainNavigationScreen(),
        '/profile_screen': (context) => ProfileScreen(),
      }
    );
  }
}

