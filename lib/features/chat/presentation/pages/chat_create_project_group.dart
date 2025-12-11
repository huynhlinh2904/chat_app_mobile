import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateProjectGroupScreen extends StatefulWidget {
  const CreateProjectGroupScreen({super.key});

  @override
  State<CreateProjectGroupScreen> createState() => _CreateProjectGroupScreenState();
}

class _CreateProjectGroupScreenState extends State<CreateProjectGroupScreen> {
  final TextEditingController groupNameCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();

  XFile? _pickedImage;

  String? selectedProject;
  final Set<String> selectedEmployees = {};

  /// Mock danh sách dự án + nhân viên (KHÔNG GỌI API)
  final List<Map<String, dynamic>> mockProjects = [
    {
      "project": "Dự án A - Xây dựng",
      "employees": [
        "Nguyễn Văn A",
        "Trần Thị B",
        "Lê Hoàng C",
      ]
    },
    {
      "project": "Dự án B - Điện lực",
      "employees": [
        "Phạm Quốc D",
        "Đỗ Hải E",
        "Trương Minh F",
      ]
    },
    {
      "project": "Dự án C - Hạ tầng",
      "employees": [
        "Nguyễn Văn K",
        "Lê Minh H",
      ]
    }
  ];

  final List<Color> pastelColors = [
    Color(0xFFE8DFF5),
    Color(0xFFFFF6BD),
    Color(0xFFFFD6A5),
    Color(0xFFFFB5A7),
    Color(0xFFB8E0D2),
    Color(0xFFCDEAC0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tạo nhóm dự án",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: Stack(
        children: [
          _buildMainUI(),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI CONTENT
  // ------------------------------------------------------------
  Widget _buildMainUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        children: [
          // Avatar nhóm
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade200,
              child: _pickedImage == null
                  ? Icon(Icons.camera_alt, size: 32, color: Colors.grey)
                  : ClipOval(
                child: Image.file(
                  File(_pickedImage!.path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Tên nhóm
          _filledField(groupNameCtl, "Tên nhóm..."),

          SizedBox(height: 14),

          // Search
          _filledField(
            searchCtl,
            "Tìm kiếm nhân viên...",
            prefix: Icon(Icons.search, color: Colors.grey),
            onChanged: (_) => setState(() {}),
          ),

          SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Thuộc dự án",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 12),

          _buildProjectDropdown(),

          SizedBox(height: 20),

          if (selectedProject != null) _buildEmployeeList(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DROPDOWN DỰ ÁN (MOCK)
  // ------------------------------------------------------------
  Widget _buildProjectDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedProject,
          hint: Text("Chọn dự án"),
          items: mockProjects.map((p) {
            return DropdownMenuItem(
              value: p["project"] as String,
              child: Text(
                p["project"],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedProject = v),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPLOYEE LIST UI (MOCK)
  // ------------------------------------------------------------
  Widget _buildEmployeeList() {
    final project = mockProjects.firstWhere((p) => p["project"] == selectedProject);
    final employees = (project["employees"] as List<String>)
        .where((e) => e.toLowerCase().contains(searchCtl.text.toLowerCase()))
        .toList();

    return Column(
      children: List.generate(employees.length, (i) {
        final emp = employees[i];
        final isSelected = selectedEmployees.contains(emp);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                isSelected ? selectedEmployees.remove(emp) : selectedEmployees.add(emp);
              });
            },
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey.shade300,
                  width: isSelected ? 1.3 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: pastelColors[i % pastelColors.length],
                    child: Icon(Icons.person, color: Colors.black87),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      emp,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

                  _circleCheck(isSelected),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ------------------------------------------------------------
  // CHECKBOX TRÒN
  // ------------------------------------------------------------
  Widget _circleCheck(bool active) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? Colors.teal : Colors.grey.shade400,
          width: active ? 2 : 1.3,
        ),
        color: active ? Colors.teal : Colors.transparent,
      ),
      child: active
          ? Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }

  // ------------------------------------------------------------
  // FILLED INPUT
  // ------------------------------------------------------------
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM BUTTON
  // ------------------------------------------------------------
  Widget _buildBottomButton() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: _createGroup,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }

  // ------------------------------------------------------------
  // PICK IMAGE
  // ------------------------------------------------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  // ------------------------------------------------------------
  // ACTION CREATE
  // ------------------------------------------------------------
  void _createGroup() {
    debugPrint("Tên nhóm: ${groupNameCtl.text}");
    debugPrint("Dự án chọn: $selectedProject");
    debugPrint("Nhân viên: $selectedEmployees");
    debugPrint("Ảnh nhóm: ${_pickedImage?.path}");
  }
}
