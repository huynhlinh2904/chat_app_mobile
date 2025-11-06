import 'package:flutter/material.dart';

class ChatSearchHeader extends StatelessWidget {
  const ChatSearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    this.title = 'Danh sách người dùng',
    this.backgroundColor = const Color(0xFFD9F1EC),
    this.trailing,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String title;
  final Color backgroundColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Tiêu đề =====
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // ===== Ô tìm kiếm + icon ngang hàng =====
          Row(
            children: [
              // Ô tìm kiếm chiếm hết không gian còn lại
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Khoảng cách nhỏ giữa ô và icon
              const SizedBox(width: 10),

              // Icon trailing (ví dụ nút tạo nhóm)
              if (trailing != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: trailing!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
