import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_contain.dart';
import '../../data/dtos/create_group_request_dto.dart';
import '../../domain/entities/chat_user.dart';
import '../providers/chat_groups_notifier.dart';
import '../providers/chat_users_notifier.dart';
import '../providers/create_group_providers.dart';


class CreateGroupMockupScreen extends ConsumerStatefulWidget {
  const CreateGroupMockupScreen({super.key});

  @override
  ConsumerState<CreateGroupMockupScreen> createState() =>
      _CreateGroupMockupScreenState();
}

class _CreateGroupMockupScreenState
    extends ConsumerState<CreateGroupMockupScreen> {
  final groupNameCtl = TextEditingController();
  final searchCtl = TextEditingController();

  XFile? _pickedImage;
  bool _isSubmitting = false;
  int? _currentUserId;

  final Set<int> selectedUsers = {};

  final pastelColors = const [
    Color(0xFFB8E0D2),
    Color(0xFFE8DFF5),
    Color(0xFFFFF6BD),
    Color(0xFFFFD6A5),
    Color(0xFFFFB5A7),
    Color(0xFFCDEAC0),
  ];

  Future<void> _submitCreateGroup() async {
    if (_isSubmitting) return;
    final creds = await getChatCredentials();
    if (creds == null) {
      _toast("Không lấy được thông tin đăng nhập");
      return;
    }

    if (groupNameCtl.text.trim().isEmpty) {
      _toast("Vui lòng nhập tên nhóm");
      return;
    }

    if (selectedUsers.isEmpty) {
      _toast("Vui lòng chọn ít nhất 1 thành viên");
      return;
    }

    setState(() => _isSubmitting = true);


    try {
      final jsonMembers = jsonEncode(
        selectedUsers.map((id) => {"ID_USER": id}).toList(),
      );

      final dto = CreateGroupRequestDTO(
        iddv: creds.iddv,
        sm1:creds.sm1,
        sm2: creds.sm2,
        idGroup: 0,
        groupName: groupNameCtl.text.trim(),
        isGroup: 1,
        idUser: creds.userId,
        jsonMembers: jsonMembers,
        type: 0,
        currentUser: creds.userId,
      );

      /// 🔥 CALL CREATE GROUP
      final createdGroup = await ref
          .read(createGroupNotifierProvider.notifier)
          .create(dto);

      /// ✅ ADD VÀO CHAT LIST
      ref
          .read(chatGroupsNotifierProvider.notifier)
          .addNewGroupFromCreate(createdGroup);

      /// ✅ SET GROUP ĐANG MỞ
      ref
          .read(chatGroupsNotifierProvider.notifier)
          .setCurrentOpenGroup(createdGroup.idGroup);

      /// ✅ NAVIGATE → CHAT
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/chat_screen',
        arguments: {
          "idGroup": createdGroup.idGroup,
          "groupName": createdGroup.groupName,
        },
      );
    } catch (e) {
      debugPrint("❌ Create group error: $e");
      _toast("Tạo nhóm thất bại");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final creds = await getChatCredentials();
    if (mounted) {
      setState(() {
        _currentUserId = creds?.userId;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(chatListUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tạo nhóm mới"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
        const Center(child: Text("Lỗi tải danh sách người dùng")),
        data: (users) {
          final filteredUsers = users.where((u) {
            if (_currentUserId != null && u.id == _currentUserId) {
              return false;
            }
            return u.fullName
                .toLowerCase()
                .contains(searchCtl.text.toLowerCase());
          }).toList();

          return Stack(
            children: [
              _buildContent(filteredUsers),
              _buildBottomButton(
                canSubmit:
                groupNameCtl.text.trim().isNotEmpty &&
                    selectedUsers.isNotEmpty,
              ),
            ],
          );
        },
      ),
    );
  }

  // ======================= CONTENT =======================
  Widget _buildContent(List<ChatUser> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildAvatar()),
          const SizedBox(height: 24),
          _buildGroupNameInput(),
          const SizedBox(height: 14),
          _buildSearchInput(),
          const SizedBox(height: 20),
          _buildUserList(users),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 46,
          backgroundColor: Colors.grey[200],
          backgroundImage:
          _pickedImage != null ? FileImage(File(_pickedImage!.path)) : null,
          child: _pickedImage == null
              ? const Icon(Icons.group, size: 36, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child:
              const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGroupNameInput() {
    return TextField(
      controller: groupNameCtl,
      maxLength: 50,
      decoration: InputDecoration(
        labelText: "Tên nhóm",
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: searchCtl,
      decoration: InputDecoration(
        hintText: "Tìm kiếm thành viên",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildUserList(List<ChatUser> users) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text("Không tìm thấy nhân viên")),
      );
    }

    return Column(
      children: List.generate(users.length, (i) {
        final u = users[i];
        final selected = selectedUsers.contains(u.id);

        return ListTile(
          onTap: () {
            setState(() {
              selected
                  ? selectedUsers.remove(u.id)
                  : selectedUsers.add(u.id);
            });
          },
          leading: CircleAvatar(
            backgroundColor: pastelColors[i % pastelColors.length],
            child: Text(_initials(u.fullName)),
          ),
          title: Text(u.fullName),
          subtitle: Text(u.userName),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selected
                ? const Icon(Icons.check_circle,
                color: Colors.teal, key: ValueKey(1))
                : const SizedBox(width: 24, key: ValueKey(0)),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButton({required bool canSubmit}) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: canSubmit && !_isSubmitting
              ? _submitCreateGroup
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
              : const Text("Tạo nhóm", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    _pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  String _initials(String? name) {
    if (name == null) return "?";

    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";

    final parts = trimmed.split(RegExp(r"\s+"));

    final firstChar = parts.first.isNotEmpty
        ? parts.first[0].toUpperCase()
        : "?";

    if (parts.length == 1) return firstChar;

    final lastChar = parts.last.isNotEmpty
        ? parts.last[0].toUpperCase()
        : "";

    return "$firstChar$lastChar";
  }

  void _toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }


}
