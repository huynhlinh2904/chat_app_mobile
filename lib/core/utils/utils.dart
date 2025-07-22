import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUtils {
  /// Format hiển thị thời gian như: "14:30" hoặc "Hôm nay", "Hôm qua"
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return DateFormat.EEEE('vi').format(dateTime); // Thứ Hai, Ba,...
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Hiển thị kiểu thời gian "5 phút trước", "2 giờ trước"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s trước';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    return '${diff.inDays} ngày trước';
  }

  /// Tạo conversation ID theo 2 user ID, để đảm bảo duy nhất
  static String generateConversationId(String uid1, String uid2) {
    return (uid1.hashCode <= uid2.hashCode)
        ? '$uid1-$uid2'
        : '$uid2-$uid1';
  }

  /// Hiển thị SnackBar thông báo
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Kiểm tra xem người dùng đang typing hay không
  static bool isTyping(String text) {
    return text.trim().isNotEmpty;
  }

  /// Ẩn bàn phím
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}