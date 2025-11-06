import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/chat_search_header.dart';
import '../../../../core/widgets/soft_avatar.dart';
import '../../domain/entities/chat_group.dart';
import '../providers/chat_groups_notifier.dart';
import 'package:chat_mobile_app/core/constants/app_contain.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  Timer? _debounce;
  String _query = '';
  int? _currentUserID;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));

    // tải danh sách group
    Future.microtask(() =>
        ref.read(chatGroupsNotifierProvider.notifier).fetch(idGroup: 0, type: 2));

    // lấy thông tin user đăng nhập
    Future.microtask(() async {
      final creds = await getChatCredentials();
      if (!mounted) return;
      setState(() {
        _currentUserID = creds?.userId; // dùng ID để xác định người hiện tại
      });
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _debounce?.cancel();
    _searchCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(chatGroupsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.pushNamed(context, '/create_group'),
      //   tooltip: 'Tạo nhóm mới',
      //   child: const Icon(Icons.group_add),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            /// ===== Header + Search =====
            ChatSearchHeader(
              title: 'Danh sách trò chuyện',
              controller: _searchCtl,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 220), () {
                  setState(() => _query = v.trim());
                });
              },
              trailing: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Tạo nhóm mới',
                    onPressed: () async {
                      final RenderBox button = context.findRenderObject() as RenderBox;
                      final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject() as RenderBox;

                      // 📍 Lấy vị trí icon trên màn hình
                      final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
                      final Size size = button.size;

                      // 📍 Tính vị trí popup: ngay bên dưới icon
                      final RelativeRect positionBelow = RelativeRect.fromLTRB(
                        position.dx,
                        position.dy + size.height + 4, // khoảng cách 4px dưới icon
                        overlay.size.width - position.dx - size.width,
                        0,
                      );

                      final selected = await showMenu<String>(
                        context: context,
                        position: positionBelow,
                        color: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        items: [
                          const PopupMenuItem<String>(
                            value: 'group',
                            child: ListTile(
                              leading: Icon(Icons.group, color: Colors.deepPurple),
                              title: Text('Tạo nhóm'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'project',
                            child: ListTile(
                              leading: Icon(Icons.business_center, color: Colors.blue),
                              title: Text('Tạo nhóm dự án'),
                            ),
                          ),
                        ],
                      );

                      if (selected == 'group') {
                        Navigator.pushNamed(context, '/create_group');
                      } else if (selected == 'project') {
                        Navigator.pushNamed(context, '/create_project_group');
                      }
                    },
                  );
                },
              ),
            ),

            /// ===== Tabs =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: 'Nhóm'),
                    Tab(text: 'Nhóm dự án'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            /// ===== Nội dung =====
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  groupsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                    data: (groups) => ChatGroupsListView(
                      groups: groups,
                      query: _query,
                      currentUserId: _currentUserID,
                      controller: _scrollCtl,
                      onTapGroup: (g) => Navigator.pushNamed(
                        context,
                        '/chat_screen',
                        arguments: {
                          'idGroup': g.idGroup,
                          'groupName': displayName(g, _currentUserID),
                        },
                      ),
                    ),
                  ),
                  const Center(child: Text('Chưa có nhóm dự án')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ====== Reusable widgets for Groups ======

class ChatGroupsListView extends StatelessWidget {
  const ChatGroupsListView({
    super.key,
    required this.groups,
    required this.query,
    required this.onTapGroup,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
    this.currentUserId,
  });

  final List<ChatGroup> groups;
  final String query;
  final void Function(ChatGroup) onTapGroup;
  final ScrollController? controller;
  final EdgeInsets padding;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(groups, query, currentUserId);
    if (filtered.isEmpty) {
      return const Center(child: Text('Không có nhóm nào'));
    }
    return Scrollbar(
      controller: controller,
      interactive: true,
      radius: const Radius.circular(12),
      thickness: 6,
      child: ListView.separated(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: padding.copyWith(bottom: padding.bottom + 100),
        cacheExtent: 1000,
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => ChatGroupTile(
          group: filtered[i],
          colorSeed: filtered[i].idGroup,
          currentUserId: currentUserId,
          onTap: () => onTapGroup(filtered[i]),
        ),
      ),
    );
  }

  List<ChatGroup> _filter(List<ChatGroup> groups, String q, int? curId) {
    if (q.isEmpty) return groups;
    final s = q.toLowerCase();
    return groups.where((g) {
      final name = displayName(g, curId).toLowerCase();
      final last = (g.lastMessage ?? '').toLowerCase();
      return name.contains(s) || last.contains(s);
    }).toList(growable: false);
  }
}

class ChatGroupTile extends StatelessWidget {
  const ChatGroupTile({
    super.key,
    required this.group,
    required this.onTap,
    required this.colorSeed,
    required this.currentUserId,
  });

  final ChatGroup group;
  final VoidCallback onTap;
  final int colorSeed;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    final title = displayName(group, currentUserId);
    final subtitle = group.lastMessage ?? '';
    final url = (group.avatarImg?.isNotEmpty ?? false)
        ? 'https://your-image-base-url/${group.avatarImg}'
        : null;
    final unread = group.unreadCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x11000000)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ClipOval(
                  child: url != null
                      ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackAvatar(title),
                  )
                      : _fallbackAvatar(title),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread > 0) const SizedBox(width: 8),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(String title) => SoftAvatar(
    url: null,
    seed: colorSeed,
    initials: _initials(title),
    size: 44,
  );

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'G';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

/// ====== Helper: Tên hiển thị cho group / 1-1 ======
String displayName(ChatGroup g, int? currentUserId) {
  String safe(String? s) => (s == null || s.trim().isEmpty) ? 'Không tên' : s.trim();

  // Nếu là nhóm
  if (g.isGroup == 1) return safe(g.groupName);

  // Nếu là chat 1:1
  final id1 = g.idUser1;
  final id2 = g.idUser2;

  // Nếu biết user hiện tại
  if (currentUserId != null) {
    if (currentUserId == id1) return safe(g.userName2);
    if (currentUserId == id2) return safe(g.userName1);
  }

  // Nếu không trùng ID nào (dữ liệu lỗi hoặc currentUserId chưa set)
  // => fallback: ưu tiên userName2 trước
  return safe(g.userName2 ?? g.userName1);
}

