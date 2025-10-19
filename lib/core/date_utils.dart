import 'package:intl/intl.dart';

class AppDateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

    static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

    static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }
}