import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();
  XFile? _pickedImage;

  final List<String> employees = [
    'Administrator',
    'Nguyễn B',
    'Nguyễn C',
    'Giám sát Công trình',
    'Nguyễn D',
    'Nguyễn E',
    'Nguyễn F',
  ];

  final Set<String> selectedEmployees = {};

  @override
  Widget build(BuildContext context) {
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
                'Danh sách nhân viên',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(child: _buildEmployeeList()),

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
                        child:
                        Icon(Icons.image, color: Colors.grey, size: 32),
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
    );
  }

  /// --- Danh sách nhân viên có animation ---
  Widget _buildEmployeeList() {
    final query = searchCtl.text.toLowerCase();
    final filtered =
    employees.where((e) => e.toLowerCase().contains(query)).toList();

    final employeeList = filtered.isEmpty
        ? const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text('Không tìm thấy nhân viên nào'),
      ),
    )
        : ListView.separated(
      key: ValueKey(filtered.length),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final name = filtered[index];
        final selected = selectedEmployees.contains(name);

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
                  selectedEmployees.add(name);
                } else {
                  selectedEmployees.remove(name);
                }
              });
              Feedback.forTap(context); // ✅ rung nhẹ khi tick
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
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
        );
      },
    );

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
      child: employeeList,
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
                  final ImagePicker picker = ImagePicker();
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
                  final ImagePicker picker = ImagePicker();
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
    debugPrint('Thành viên: $selectedEmployees');
    debugPrint('Ảnh nhóm: ${_pickedImage?.path ?? 'Không chọn'}');
    Navigator.pop(context);
  }
}
