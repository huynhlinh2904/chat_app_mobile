import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/providers/login_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar + tên
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            child: Text(
              '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có tên',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
           'user@example.com',
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 30),
          const Divider(thickness: 1),

          // Danh sách thông tin
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                ListTile(
                  leading: const Icon(Icons.badge, color: Colors.blue),
                  title: const Text('Mã nhân viên'),
                  subtitle: Text('N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.green),
                  title: const Text('Phòng ban'),
                  subtitle: Text('Chưa cập nhật'),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),

                // Nút đăng xuất
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xác nhận đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Huỷ'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(loginNotifierProvider.notifier).logout(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
