/// Date utility functions extracted from home_screen
/// Eliminates hardcoded date logic in presentation layer
class DateHelpers {
  DateHelpers._(); // Private constructor

  /// Get Turkish month name
  static String getTurkishMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  /// Get Turkish day name
  static String getTurkishDayName(int weekday) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[weekday - 1];
  }

  /// Format date as "DD MMMM YYYY, DayName"
  static String formatTurkishDate(DateTime date) {
    return '${date.day} ${getTurkishMonthName(date.month)} ${date.year}, ${getTurkishDayName(date.weekday)}';
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get first day of month (1 = Monday, 7 = Sunday)
  static int getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }
}
