import 'package:flutter/material.dart';

import '../../../core/widgets/message_bubble.dart';
import '../../../core/widgets/typing_indicator.dart';






class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': DateTime.now(),
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'text': 'Tin nhắn trả lời từ hệ thống',
            'isMe': false,
            'time': DateTime.now(),
            'avatarUrl': 'https://i.pravatar.cc/150?img=12',
          });
        });
      });
    });

    _messageController.clear();
    setState(() {
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAME GROUP // USER'),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              Navigator.pushNamed(context, '/profile_screen');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return const TypingIndicator();
                }

                final reversedIndex =
                    _messages.length - 1 - (index - (_isTyping ? 1 : 0));
                final msg = _messages[reversedIndex];
                return MessageBubble(
                  text: msg['text'],
                  isMe: msg['isMe'],
                  time: msg['time'],
                  avatarUrl: msg['avatarUrl'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (val) =>
                        setState(() => _isTyping = val.isNotEmpty),
                    decoration: const InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
