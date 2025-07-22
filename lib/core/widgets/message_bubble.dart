import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime time;
  final String avatarUrl;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat.Hm().format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 240),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.deepPurple : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if (isMe)
              const SizedBox(width: 8),
            if (isMe)
              CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
          ],
        ),
      ),
    );
  }
}