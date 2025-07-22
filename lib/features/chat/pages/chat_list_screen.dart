import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> users = const [
    {
      'name': 'Nguyễn Văn A',
      'lastMessage': 'Hẹn gặp bạn lúc 10h nhé!',
      'time': '09:45',
      'avatarUrl': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Trần Thị B',
      'lastMessage': 'Cảm ơn bạn nhiều!',
      'time': '08:30',
      'avatarUrl': 'https://i.pravatar.cc/150?img=2',
    },
  ];

  final List<Map<String, dynamic>> groups = const [
    {
      'groupName': 'Team Dự án A',
      'lastMessage': 'Đã cập nhật tài liệu.',
      'time': 'Hôm qua',
      'avatarUrl': 'https://i.pravatar.cc/150?img=10',
    },
    {
      'groupName': 'Phòng Kinh doanh',
      'lastMessage': 'Họp lúc 2h chiều nhé.',
      'time': '09:00',
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // rebuild để hiển thị/hide FAB
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['avatarUrl']),
          ),
          title: Text(user['name']),
          subtitle: Text(user['lastMessage']),
          trailing: Text(user['time'], style: const TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.pushNamed(context, '/chat_screen');
          },
        );
      },
    );
  }

  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(group['avatarUrl']),
          ),
          title: Text(group['groupName']),
          subtitle: Text(group['lastMessage']),
          trailing: Text(group['time'], style: const TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.pushNamed(context, '/chat_screen');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách trò chuyện'),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Người dùng'),
            Tab(text: 'Nhóm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(),
          _buildGroupList(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_group');
        },
        child: const Icon(Icons.group_add),
        tooltip: 'Tạo nhóm mới',
      )
          : null,
    );
  }
}
