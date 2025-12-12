import 'dart:convert';

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

  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final exp = payload["exp"];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
  /// Format DateTime theo chuẩn SQL (yyyy-MM-dd HH:mm:ss)
  static String formatSqlDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}:${twoDigits(date.second)}';
  }
  static String formatTime(DateTime? dt) {
    if (dt == null) return "";

    final now = DateTime.now();
    final diff = now.difference(dt);

    // Dưới 1 phút
    if (diff.inSeconds < 60) {
      return "Vừa xong";
    }

    // Dưới 60 phút
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    }

    // Dưới 24 giờ
    if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    }

    // Dưới 7 ngày
    if (diff.inDays < 7) {
      return "${diff.inDays} ngày trước";
    }

    // Lớn hơn 7 ngày → hiển thị ngày gửi
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}";
  }


  /// Trả về thời gian của ngày hôm sau (chuẩn SQL)
  static String tomorrowSqlDate() {
    return formatSqlDate(DateTime.now().add(const Duration(days: 1)));
  }


}