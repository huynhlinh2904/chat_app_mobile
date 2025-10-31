import 'package:flutter/material.dart';
import '../../features/chat/domain/entities/chat_user.dart';
import 'chat_user_tile.dart';

class ChatUsersListView extends StatelessWidget {
  const ChatUsersListView({
    super.key,
    required this.users,
    required this.onUserTap,
    required this.query,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
  });

  final List<ChatUser> users;
  final void Function(ChatUser) onUserTap;
  final String query;
  final ScrollController? controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(users, query);
    return Scrollbar(
      controller: controller,
      interactive: true,
      radius: const Radius.circular(12),
      thickness: 6,
      child: ListView.separated(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: filtered.length,
        cacheExtent: 1000,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final u = filtered[index];
          final seed = ( u.id ?? index);
          return ChatUserTile(
            user: u,
            colorSeed: seed,
            onTap: () => onUserTap(u),
          );
        },
      ),
    );
  }

  List<ChatUser> _filter(List<ChatUser> users, String q) {
    if (q.isEmpty) return users;
    final lower = q.toLowerCase();
    return users.where((u) {
      final n = u.fullName.toLowerCase();
      final un = u.userName.toLowerCase();
      final em = (u.email ?? '').toLowerCase();
      return n.contains(lower) || un.contains(lower) || em.contains(lower);
    }).toList(growable: false);
  }
}