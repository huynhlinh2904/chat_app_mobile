import 'package:flutter/material.dart';
import '../../features/chat/domain/entities/chat_user.dart';
import 'soft_avatar.dart';

class ChatUserTile extends StatelessWidget {
  const ChatUserTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.colorSeed,
  });

  final ChatUser user;
  final VoidCallback onTap;
  final int colorSeed;

  @override
  Widget build(BuildContext context) {
    final title = user.fullName.isNotEmpty ? user.fullName : 'Không tên';
    final subtitle = user.email ?? '';
    final url = user.userName.isNotEmpty ? 'https://your-image-base-url/${user.userName}' : null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x11000000)),
          ),
          child: Row(
            children: [
              SoftAvatar(url: url, seed: colorSeed, initials: _initials(title)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
