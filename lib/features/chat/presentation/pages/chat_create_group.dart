import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupMockupScreen extends StatefulWidget {
  const CreateGroupMockupScreen({super.key});

  @override
  State<CreateGroupMockupScreen> createState() => _CreateGroupMockupScreenState();
}

class _CreateGroupMockupScreenState extends State<CreateGroupMockupScreen> {
  final TextEditingController groupNameCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();

  XFile? _pickedImage;

  final Set<int> selectedUsers = {};

  final List<Color> pastelColors = [
    Color(0xFFB8E0D2),
    Color(0xFFE8DFF5),
    Color(0xFFFFF6BD),
    Color(0xFFFFD6A5),
    Color(0xFFFFB5A7),
    Color(0xFFCDEAC0),
  ];

  // Mock data
  final List<Map<String, dynamic>> mockUsers = [
    {"id": 1, "name": "Giám sát Công trình", "role": "GS1"},
    {"id": 2, "name": "Kế hoạch vật tư", "role": "KHVT"},
    {"id": 3, "name": "Giám sát 1", "role": "GS"},
    {"id": 4, "name": "Nguyễn huỳnh trực Anh Lanh", "role": "NVVH"},
    {"id": 5, "name": "Đồng Nguyên", "role": "DN"},
    {"id": 6, "name": "Lê tân", "role": "LT"},
    {"id": 7, "name": "Bác sĩ A", "role": "BS"},
    {"id": 8, "name": "Phòng khám 1", "role": "PK1"},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = mockUsers.where((u) {
      return u["name"].toLowerCase().contains(searchCtl.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: Text(
          "Tạo nhóm mới",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: Stack(
        children: [
          _buildContent(filteredUsers),

          // ==== NÚT TẠO NHÓM CỐ ĐỊNH DƯỚI ====
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                ),
              ),
              child: Center(
                child: Text(
                  "Tạo nhóm",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(List filteredUsers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===== AVATAR LỚN  =====
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[200],
              child: _pickedImage == null
                  ? Icon(Icons.camera_alt_rounded, size: 32, color: Colors.grey)
                  : ClipOval(
                child: Image.file(File(_pickedImage!.path), width: 90, height: 90, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== INPUT: TÊN NHÓM (FIILLED GRAY) =====
          _filledInput(
            controller: groupNameCtl,
            hint: "Nhập tên nhóm...",
          ),

          const SizedBox(height: 14),

          // ===== INPUT SEARCH =====
          _filledInput(
            controller: searchCtl,
            hint: "Tìm kiếm nhân viên...",
            prefix: Icon(Icons.search, color: Colors.grey),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 22),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Danh sách nhân viên",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),

          const SizedBox(height: 12),

          // ===== LIST USER MỚI =====
          Column(
            children: List.generate(filteredUsers.length, (i) {
              final u = filteredUsers[i];
              final selected = selectedUsers.contains(u["id"]);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      selected
                          ? selectedUsers.remove(u["id"])
                          : selectedUsers.add(u["id"]);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.teal : Colors.grey.shade300,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: pastelColors[i % pastelColors.length],
                          child: Text(
                            _initials(u["name"]),
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u["name"],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(u["role"],
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
                        ),

                        // Checkbox tròn
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? Colors.teal : Colors.grey.shade400,
                              width: 2,
                            ),
                            color: selected ? Colors.teal : Colors.transparent,
                          ),
                          child: selected
                              ? Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filledInput({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: hint,
        prefixIcon: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    _pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }
}
