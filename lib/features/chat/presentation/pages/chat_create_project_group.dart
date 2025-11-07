import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_contain.dart';
import '../../domain/entities/chat_get_user_duan.dart';
import '../providers/get_user_by_duan_notifier.dart';

class CreateProjectGroupScreen extends ConsumerStatefulWidget {
  const CreateProjectGroupScreen({super.key});

  @override
  ConsumerState<CreateProjectGroupScreen> createState() =>
      _CreateProjectGroupScreenState();
}

class _CreateProjectGroupScreenState
    extends ConsumerState<CreateProjectGroupScreen> {
  final TextEditingController groupNameCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();

  XFile? _pickedImage;
  String? selectedProject;
  final Set<String> selectedEmployees = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // 🔹 Lấy thông tin xác thực lưu local
      final creds = await getChatCredentials();
      if (creds == null) {
        debugPrint('⚠️ Không tìm thấy thông tin xác thực');
        return;
      }

      // 🔹 Gọi API lấy danh sách người dùng theo dự án
      ref.read(userByDuanNotifierProvider.notifier).fetch(
        idDv: creds.iddv,
        sm1: creds.sm1,
        sm2: creds.sm2,
        idUser: creds.userId,
        type: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userByDuanState = ref.watch(userByDuanNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        title: const Text('Tạo nhóm dự án'),
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
      body: userByDuanState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('❌ Lỗi tải dữ liệu: $err',
              style: const TextStyle(color: Colors.red)),
        ),
        data: (projects) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Nhập tên nhóm + Tìm kiếm ---
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
                              horizontal: 12, vertical: 10),
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
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  'Danh sách nhân viên dự án',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),

                /// --- Danh sách dự án thật ---
                Expanded(child: _buildEmployeeListFromApi(projects)),

                const SizedBox(height: 16),

                /// --- Ảnh nhóm ---
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
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                /// --- Nút hành động ---
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
                            horizontal: 24, vertical: 12),
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
      ),
    );
  }

  /// --- Build danh sách dự án và nhân viên thật từ API ---
  Widget _buildEmployeeListFromApi(List<ChatGetUserDuan> projects) {
    final query = searchCtl.text.toLowerCase();
    final projectList = projects.map((p) => p.tenDuAn).toList();

    final projectDropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Chọn dự án'),
          value: selectedProject,
          items: projectList.map((project) {
            return DropdownMenuItem(
              value: project,
              child: Row(
                children: [
                  const Icon(Icons.home, color: Colors.teal, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(project,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedProject = value),
        ),
      ),
    );

    if (selectedProject == null) {
      return Column(
        children: [
          projectDropdown,
          const SizedBox(height: 20),
          const Text('Vui lòng chọn dự án để hiển thị danh sách nhân viên'),
        ],
      );
    }

    final selectedProjectData =
    projects.firstWhere((p) => p.tenDuAn == selectedProject);
    final employees = selectedProjectData.users
        .where((u) => u.fullNameUser.toLowerCase().contains(query))
        .toList();

    if (employees.isEmpty) {
      return Column(
        children: [
          projectDropdown,
          const SizedBox(height: 20),
          const Text('Không tìm thấy nhân viên nào'),
        ],
      );
    }

    return Column(
      children: [
        projectDropdown,
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: employees.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final emp = employees[i];
              final selected = selectedEmployees.contains(emp.fullNameUser);

              return CheckboxListTile(
                value: selected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedEmployees.add(emp.fullNameUser);
                    } else {
                      selectedEmployees.remove(emp.fullNameUser);
                    }
                  });
                },
                title: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEAEAEA),
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(emp.fullNameUser,
                          style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              );
            },
          ),
        ),
      ],
    );
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
                  final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _pickedImage = image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() => _pickedImage = image);
                  }
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
    debugPrint('Dự án: $selectedProject');
    debugPrint('Thành viên: $selectedEmployees');
    debugPrint('Ảnh nhóm: ${_pickedImage?.path ?? 'Không chọn'}');
    Navigator.pop(context);
  }
}
