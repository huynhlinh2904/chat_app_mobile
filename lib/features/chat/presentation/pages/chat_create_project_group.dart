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

  ChatGetUserDuan? selectedProject;
  final Set<int> selectedUserIds = {};

  final pastelColors = const [
    Color(0xFFE8DFF5),
    Color(0xFFFFF6BD),
    Color(0xFFFFD6A5),
    Color(0xFFFFB5A7),
    Color(0xFFB8E0D2),
    Color(0xFFCDEAC0),
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final creds = await getChatCredentials();
    if (creds == null) return;

    ref.read(userByDuanNotifierProvider.notifier).fetch(
      idDv: creds.iddv,
      sm1: creds.sm1,
      sm2: creds.sm2,
      idUser: creds.userId,
      type: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tạo nhóm dự án"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ref.watch(userByDuanNotifierProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Lỗi tải dự án")),
        data: (projects) => Stack(
          children: [
            _buildMainUI(projects),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _buildMainUI(List<ChatGetUserDuan> projects) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          _filledField(groupNameCtl, "Tên nhóm..."),
          const SizedBox(height: 14),
          _filledField(
            searchCtl,
            "Tìm kiếm nhân viên...",
            prefix: const Icon(Icons.search),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Thuộc dự án",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildProjectDropdown(projects),
          const SizedBox(height: 20),
          if (selectedProject != null) _buildEmployeeList(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
          _pickedImage != null ? FileImage(File(_pickedImage!.path)) : null,
          child: _pickedImage == null
              ? const Icon(Icons.camera_alt, size: 32, color: Colors.grey)
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
              child: const Icon(Icons.camera_alt,
                  size: 18, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProjectDropdown(List<ChatGetUserDuan> projects) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChatGetUserDuan>(
          isExpanded: true,
          value: selectedProject,
          hint: const Text("Chọn dự án"),
          items: projects.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(
                p.tenDuAn,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              selectedProject = v;
              selectedUserIds.clear();
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    final users = selectedProject!.users.where((u) {
      return u.fullNameUser
          .toLowerCase()
          .contains(searchCtl.text.toLowerCase());
    }).toList();

    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("Không có nhân viên"),
      );
    }

    return Column(
      children: List.generate(users.length, (i) {
        final u = users[i];
        final selected = selectedUserIds.contains(u.idUser);

        return ListTile(
          onTap: () {
            setState(() {
              selected
                  ? selectedUserIds.remove(u.idUser)
                  : selectedUserIds.add(u.idUser);
            });
          },
          leading: CircleAvatar(
            backgroundColor: pastelColors[i % pastelColors.length],
            child: Text(_initials(u.fullNameUser)),
          ),
          title: Text(u.fullNameUser),
          subtitle: u.chucVu != null ? Text(u.chucVu!) : null,
          trailing: selected
              ? const Icon(Icons.check_circle, color: Colors.teal)
              : null,
        );
      }),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size.fromHeight(54),
        ),
        child: const Text(
          "Tạo nhóm",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ================= ACTION =================

  void _createGroup() {
    debugPrint("Tên nhóm: ${groupNameCtl.text}");
    debugPrint("Dự án: ${selectedProject?.tenDuAn}");
    debugPrint("User IDs: $selectedUserIds");
    debugPrint("Ảnh: ${_pickedImage?.path}");
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  Widget _filledField(
      TextEditingController ctl,
      String hint, {
        Widget? prefix,
        Function(String)? onChanged,
      }) {
    return TextField(
      controller: ctl,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: prefix,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
