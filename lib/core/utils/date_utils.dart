import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime getDayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime getDayEnd(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime getWeekStart(DateTime date) {
    final daysFromMonday = (date.weekday - 1) % 7;
    return getDayStart(date.subtract(Duration(days: daysFromMonday)));
  }

  static DateTime getMonthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static int minutesBetween(DateTime from, DateTime to) =>
      to.difference(from).inMinutes;

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String formatTimeOfDay(int hour, int minute) {
    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }

  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatDayName(DateTime date) => DateFormat('EEE').format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static List<DateTime> getLast7Days() {
    final today = getDayStart(DateTime.now());
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  static List<DateTime> getLast30Days() {
    final today = getDayStart(DateTime.now());
    return List.generate(30, (i) => today.subtract(Duration(days: 29 - i)));
  }

  static List<DateTime> getWeekDays(DateTime weekStart) =>
      List.generate(7, (i) => weekStart.add(Duration(days: i)));
}
