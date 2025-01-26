import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  static String getRelativeDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = date.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours;

    if (days > 0) {
      return 'متبقي $days ${days == 1 ? 'يوم' : 'أيام'}';
    } else if (days < 0) {
      return 'متأخر ${-days} ${-days == 1 ? 'يوم' : 'أيام'}';
    } else if (hours > 0) {
      return 'متبقي $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (hours < 0) {
      return 'متأخر ${-hours} ${-hours == 1 ? 'ساعة' : 'ساعات'}';
    } else {
      return 'الآن';
    }
  }
}