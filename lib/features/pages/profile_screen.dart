import 'package:chat_mobile_app/core/constants/app_contain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/providers/login_notifier.dart';
import '../auth/presentation/providers/current_user_provider.dart';
import '../chat/presentation/providers/chat_credentials_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final credsAsync = ref.watch(chatCredentialsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: credsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải credentials: $e')),
        data: (creds) {
          return userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Lỗi tải dữ liệu user: $e')),
            data: (user) {
              if (user == null || user.isEmpty) {
                return const Center(child: Text('Không tìm thấy thông tin người dùng'));
              }

              // Đọc dữ liệu user
              final fullName = user['FULLNAME_USER'] ?? 'Chưa có tên';
              final avatar = user['IMG_AVA'] ?? '';
              final idUser = user['ID_USER']?.toString() ?? 'N/A';
              final iddv = user['IDDV']?.toString() ?? 'N/A';
              final idpb = user['ID_PB']?.toString() ?? 'N/A';
              final tendv = user['TENDONVI'] ?? 'Chưa cập nhật';
              final tenpb = user['TEN_PB'] ?? 'Chưa cập nhật';
              final sm1 = user['SM1'] ?? '';
              final sm2 = user['SM2'] ?? '';
              final quyen = user['QUYEN'] ?? 'N/A';

              // Avatar + thông tin
              return Column(
                children: [
                  const SizedBox(height: 20),

                  // 🟢 Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: (avatar.isNotEmpty && !avatar.endsWith('/'))
                          ? NetworkImage(
                        avatar.startsWith('http')
                            ? avatar
                            : '${EndPoint.MainHost}/${creds?.sm1}/${creds?.sm2}/USER/IMG/$avatar',
                      )
                          : null,
                      child: (avatar.isEmpty || avatar.endsWith('/'))
                          ? Text(
                        (fullName.isNotEmpty
                            ? fullName.trim().characters.first.toUpperCase()
                            : '?'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    tendv,
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 30),
                  const Divider(thickness: 1),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      children: [
                        const Text(
                          '🧾 Thông tin cơ bản',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.perm_identity, color: Colors.blueAccent),
                          title: const Text('ID User'),
                          subtitle: Text(idUser),
                        ),
                        ListTile(
                          leading: const Icon(Icons.apartment, color: Colors.teal),
                          title: const Text('Đơn vị (TÊN ĐV)'),
                          subtitle: Text(tendv),
                        ),
                        ListTile(
                          leading: const Icon(Icons.work, color: Colors.orange),
                          title: const Text('Phòng ban (TÊN PB)'),
                          subtitle: Text(tenpb),
                        ),
                        ListTile(
                          leading: const Icon(Icons.business_center, color: Colors.indigo),
                          title: const Text('ID Phòng ban'),
                          subtitle: Text(idpb),
                        ),
                        ListTile(
                          leading: const Icon(Icons.domain, color: Colors.purple),
                          title: const Text('ID Đơn vị'),
                          subtitle: Text(iddv),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          '⚙️ Thông tin hệ thống',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.key, color: Colors.deepOrange),
                          title: const Text('SM1'),
                          subtitle: Text(sm1),
                        ),
                        ListTile(
                          leading: const Icon(Icons.key_off, color: Colors.deepOrange),
                          title: const Text('SM2'),
                          subtitle: Text(sm2),
                        ),
                        ListTile(
                          leading: const Icon(Icons.verified_user, color: Colors.green),
                          title: const Text('Quyền người dùng'),
                          subtitle: Text(quyen),
                        ),

                        const SizedBox(height: 30),
                        const Divider(thickness: 1),
                        const SizedBox(height: 10),

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
              );
            },
          );
        },
      ),
    );
  }
}
