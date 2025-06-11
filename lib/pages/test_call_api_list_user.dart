import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class ChatUserListPage extends StatefulWidget {
  final int conversationId;

  const ChatUserListPage({super.key, required this.conversationId});

  @override
  State<ChatUserListPage> createState() => _ChatUserListPageState();
}

class _ChatUserListPageState extends State<ChatUserListPage> {
  late Future<ChatMembersResponse?> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = UserRepository().getUsersByConversation(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thành viên đoạn chat')),
      body: FutureBuilder<ChatMembersResponse?>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final members = snapshot.data?.members ?? [];

          if (members.isEmpty) {
            return const Center(child: Text('Không có thành viên.'));
          }

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final user = members[index];
              return ListTile(
                leading: user.avatar != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://your-base-url.com/uploads/${user.avatar}',
                  ),
                )
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.fullName),
                subtitle: Text(user.isAdmin ? 'Quản trị viên' : 'Thành viên'),
              );
            },
          );
        },
      ),
    );
  }
}
