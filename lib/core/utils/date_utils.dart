// lib/core/utils/date_utils.dart

/// Format DateTime theo chuẩn SQL (yyyy-MM-dd HH:mm:ss)
String formatSqlDate(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}:${twoDigits(date.second)}';
}

/// Trả về thời gian của ngày hôm sau (chuẩn SQL)
String tomorrowSqlDate() {
  return formatSqlDate(DateTime.now().add(const Duration(days: 1)));
}
