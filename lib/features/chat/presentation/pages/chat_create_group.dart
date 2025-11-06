import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/chat_user.dart';
import '../providers/chat_users_notifier.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();
  XFile? _pickedImage;

  final Set<int> selectedUserIds = {};

  final List<Color> _avatarColors = [
    const Color(0xFF81C784), // xanh lá nhạt
    const Color(0xFF64B5F6), // xanh dương nhạt
    const Color(0xFFFFB74D), // cam nhạt
    const Color(0xFFBA68C8), // tím nhạt
    const Color(0xFFE57373), // đỏ nhạt
    const Color(0xFF4DB6AC), // teal mint
    const Color(0xFFFFD54F), // vàng nhạt
    const Color(0xFFA1887F), // nâu nhạt
    const Color(0xFF90A4AE), // xám xanh
    const Color(0xFFF06292), // hồng nhạt
  ];

  @override
  Widget build(BuildContext context) {
    final chatListState = ref.watch(chatListUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        title: const Text('Tạo nhóm'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: Colors.white,
            tooltip: 'Tạo nhóm',
            onPressed: _createGroup,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Nhập tên nhóm & tìm kiếm ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: groupNameCtl,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên nhóm...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchCtl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Tìm kiếm nhân viên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Danh sách nhân viên',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: chatListState.when(
                  data: (users) => _buildUserList(users),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Lỗi tải danh sách: $err')),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Ảnh nhóm (tùy chọn)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[400]!),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _pickedImage != null
                          ? Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                      )
                          : const Center(
                        child: Icon(Icons.image,
                            color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: const Icon(Icons.upload),
                    label: const Text('Chọn ảnh'),
                  ),
                  if (_pickedImage != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      tooltip: 'Xóa ảnh',
                      onPressed: () => setState(() => _pickedImage = null),
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _createGroup,
                    child: const Text('Tạo nhóm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Danh sách user với hiệu ứng & nhiều màu avatar ---
  Widget _buildUserList(List<ChatUser> users) {
    final query = searchCtl.text.toLowerCase();
    final filtered = users
        .where((u) =>
    (u.fullName?.toLowerCase().contains(query) ?? false) ||
        (u.email?.toLowerCase().contains(query) ?? false))
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('Không tìm thấy nhân viên nào'),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: ListView.separated(
        key: ValueKey(filtered.length),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = filtered[index];
          final selected = selectedUserIds.contains(user.id);
          final initials = _getInitials(user.fullName ?? user.userName ?? '');
          final colorSeed =
              (user.id ?? user.fullName.hashCode) % _avatarColors.length;
          final bgColor = _avatarColors[colorSeed];

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: selected ? 1.03 : 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(scale),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.teal.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: child,
            ),
            child: CheckboxListTile(
              value: selected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedUserIds.add(user.id ?? 0);
                  } else {
                    selectedUserIds.remove(user.id);
                  }
                });
                Feedback.forTap(context);
              },
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: bgColor,
                      child: initials.isNotEmpty
                          ? Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user.fullName?.isNotEmpty == true
                          ? user.fullName!
                          : (user.userName ?? 'Không tên'),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  /// --- Hàm lấy ký tự đầu từ tên ---
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// --- Bottom sheet chọn ảnh ---
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.teal),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final image =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final image =
                  await picker.pickImage(source: ImageSource.camera);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// --- Tạo nhóm ---
  void _createGroup() {
    if (groupNameCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhóm')),
      );
      return;
    }

    debugPrint('Tên nhóm: ${groupNameCtl.text}');
    debugPrint('Thành viên: $selectedUserIds');
    debugPrint('Ảnh nhóm: ${_pickedImage?.path ?? 'Không chọn'}');
    Navigator.pop(context);
  }
}
