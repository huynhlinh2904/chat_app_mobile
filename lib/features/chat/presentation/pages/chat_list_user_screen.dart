import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/chat_search_header.dart';
import '../../../../core/widgets/chat_users_list_view.dart';
import '../../domain/entities/chat_user.dart';
import '../../../../core/constants/app_contain.dart';
import '../providers/chat_update_one_to_group.dart';
import '../providers/chat_users_notifier.dart';
import '../../domain/entities/chat_update_one_to_group.dart';
import 'chat_screen.dart';


class ChatListUserScreen extends ConsumerStatefulWidget {
  const ChatListUserScreen({super.key});

  @override
  ConsumerState<ChatListUserScreen> createState() => _ChatListUserScreenState();
}

class _ChatListUserScreenState extends ConsumerState<ChatListUserScreen> {
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  Timer? _debounce;
  String _query = '';
  int? _currentUserId;
  String? _currentFullName;

  @override
  void initState() {
    super.initState();
    // lấy user hiện tại để lọc chính mình ra khỏi list
    Future.microtask(() async {
      final creds = await getChatCredentials();
      if (!mounted) return;
        setState(() {
          _currentUserId = creds?.userId;
          _currentFullName = creds?.fullNameUser;
        });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('❌ Lỗi: $err')),
          data: (users) {
            // 🔎 Lọc bỏ user hiện tại
            final filtered = _excludeCurrentUser(users);
            return Column(
              children: [
                ChatSearchHeader(
                  controller: _searchCtl,
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 220), () {
                      setState(() => _query = v.trim());
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ChatUsersListView(
                    users: filtered,
                    query: _query,
                    controller: _scrollCtl,
                    onUserTap: (u) => _openChat(context, u),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  List<ChatUser> _excludeCurrentUser(List<ChatUser> users) {
    final id = _currentUserId;
    final name = (_currentFullName ?? '').trim().toLowerCase();

    return users.where((u) {
      // ưu tiên so sánh theo ID (an toàn nhất)
      if (id != null && u.id != null && u.id == id) return false;

      // fallback theo tên khi BE chưa trả id
      if (name.isNotEmpty && u.fullName.trim().toLowerCase() == name) return false;

      return true;
    }).toList(growable: false);
  }

  Future<void> _openChat(BuildContext context, ChatUser user) async {
    final creds = await getChatCredentials();
    if (creds == null) {
      _snack(context, 'Thiếu thông tin xác thực. Vui lòng đăng nhập lại.');
      return;
    }
    final idSender = creds.userId;
    final idReceive = user.id;

    if (idReceive == null) {
      _snack(context, 'Không xác định được người nhận.');
      return;
    }

    _loading(context);
    try {
      final usecase = ref.read(chatUpdateOneToGroupUseCaseProvider);
      final List<ChatUpdateOneToGroupE> result = await usecase(
        idGroup: 0,
        idSender: idSender,
        idReceive: idReceive,
        type: 0,
      );
      if (mounted) Navigator.of(context).pop();

      if (result.isEmpty) {
        _snack(context, 'Không tạo/khởi tạo được phòng chat.');
        return;
      }
      final groupId = result.first.idGroup;
      final groupName = user.fullName.isNotEmpty
          ? user.fullName
          : (user.userName.isNotEmpty ? user.userName : 'Cuộc trò chuyện');

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: RouteSettings(arguments: {
            'idGroup': groupId,
            'groupName': groupName,
          }),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _snack(context, 'Lỗi mở chat: $e');
      }
    }
  }

  void _loading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
