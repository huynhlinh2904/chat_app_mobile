import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    /// Load group list
    Future.microtask(() {
      ref.read(chatGroupsNotifierProvider.notifier).fetch(idGroup: 0, type: 2);
    });

    /// Load current user
    Future.microtask(() async {
      final creds = await getChatCredentials();
      if (!mounted) return;
      setState(() => _currentUserID = creds?.userId);
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
      body: SafeArea(
        child: Column(
          children: [
            /// =========================== HEADER ===========================
            ChatSearchHeader(
              title: "Danh sách trò chuyện",
              controller: _searchCtl,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 220), () {
                  setState(() => _query = v.trim());
                });
              },
              trailing: _buildCreateButton(context),
            ),

            /// =========================== TABS ===========================
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tab,
                  indicatorColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: "Nhóm"),
                    Tab(text: "Nhóm dự án"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// =========================== TAB CONTENT ===========================
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  groupsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                    data: (groups) => ChatGroupsListView(
                      groups: groups,
                      query: _query,
                      controller: _scrollCtl,
                      currentUserId: _currentUserID,
                      onTapGroup: (g) {
                        Navigator.pushNamed(
                          context,
                          '/chat_screen',
                          arguments: {
                            'idGroup': g.idGroup,
                            'groupName': displayName(g, _currentUserID),
                          },
                        );
                      },
                    ),
                  ),
                  const Center(child: Text("Chưa có nhóm dự án")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Popup menu create group
  Widget _buildCreateButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add, color: Colors.white),
      onPressed: () async {
        final selected = await showMenu<String>(
          context: context,
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          position: const RelativeRect.fromLTRB(200, 80, 16, 0),
          items: const [
            PopupMenuItem(
              value: "group",
              child: ListTile(
                leading: Icon(Icons.group, color: Colors.deepPurple),
                title: Text("Tạo nhóm"),
              ),
            ),
            PopupMenuItem(
              value: "project",
              child: ListTile(
                leading: Icon(Icons.business_center, color: Colors.blue),
                title: Text("Tạo nhóm dự án"),
              ),
            ),
          ],
        );

        if (selected == "group") {
          Navigator.pushNamed(context, "/chat_create_group");
        } else if (selected == "project") {
          Navigator.pushNamed(context, "/chat_create_project_group");
        }
      },
    );
  }
}

class ChatGroupsListView extends StatelessWidget {
  const ChatGroupsListView({
    super.key,
    required this.groups,
    required this.query,
    required this.onTapGroup,
    required this.currentUserId,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
  });

  final List<ChatGroup> groups;
  final String query;
  final int? currentUserId;
  final ScrollController? controller;
  final EdgeInsets padding;
  final void Function(ChatGroup) onTapGroup;

  @override
  Widget build(BuildContext context) {
    final filtered = _filterGroups(groups);

    if (filtered.isEmpty) {
      return const Center(child: Text("Không có nhóm nào"));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: ListView.separated(
        key: ValueKey(filtered.length),
        controller: controller,
        padding: padding,
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          return ChatGroupTile(
            group: filtered[i],
            currentUserId: currentUserId,
            colorSeed: filtered[i].idGroup,
            onTap: () => onTapGroup(filtered[i]),
          );
        },
      ),
    );
  }

  List<ChatGroup> _filterGroups(List<ChatGroup> groups) {
    if (query.isEmpty) return groups;
    final s = query.toLowerCase();

    return groups.where((g) {
      final name = displayName(g, currentUserId).toLowerCase();
      final last = g.lastMessage?.toLowerCase() ?? "";
      return name.contains(s) || last.contains(s);
    }).toList();
  }
}

class ChatGroupTile extends StatefulWidget {
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
  State<ChatGroupTile> createState() => _ChatGroupTileState();
}

class _ChatGroupTileState extends State<ChatGroupTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final title = displayName(widget.group, widget.currentUserId);
    final subtitle = widget.group.lastMessage ?? "";
    final time = widget.group.lastMessage ?? "";
    final url = (widget.group.avatarImg?.isNotEmpty ?? false)
        ? "https://your-base-url/${widget.group.avatarImg}"
        : null;
    final unread = widget.group.unreadCount;

    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),

        /// CARD
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(0, 3),
                color: Color(0x11000000),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ====================== Avatar ======================
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: url != null
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => SoftAvatar(
                            url: null,
                            initials: title.toInitials(),
                            seed: widget.colorSeed,
                            size: 54,
                          ),
                        )
                      : SoftAvatar(
                          url: null,
                          initials: title.toInitials(),
                          seed: widget.colorSeed,
                          size: 54,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              /// ====================== Name + Message ======================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- Title ---
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: unread > 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// --- Subtitle ---
                    Text(
                      subtitle.isEmpty ? "Bắt đầu cuộc trò chuyện" : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: unread > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// ====================== Time + Badge + Arrow ======================
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// Timestamp
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Badge chưa đọc
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            unread > 99 ? "99+" : "$unread",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(width: 10),

                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension InitialsExt on String {
  String toInitials() {
    final parts = trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "G";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

String displayName(ChatGroup g, int? currentUserId) {
  String safe(String? s) =>
      (s == null || s.trim().isEmpty) ? "Không tên" : s.trim();

  if (g.isGroup == 1) return safe(g.groupName);

  final id1 = g.idUser1;
  final id2 = g.idUser2;
  final name1 = safe(g.userName1);
  final name2 = safe(g.userName2);

  if (currentUserId == id1) return name2;
  if (currentUserId == id2) return name1;

  return name2.isNotEmpty ? name2 : name1;
}
