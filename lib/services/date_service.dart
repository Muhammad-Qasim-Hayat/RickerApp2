import 'package:intl/intl.dart';

class DateService {
  static String fullDate(String stringDate) {
    return format(DateFormat.YEAR_NUM_MONTH_DAY, parse(stringDate));
  }

  static String fullDateAndTime(String stringDate) {
    return format('dd/MM/y HH:mm', parse(stringDate));
  }

  static String humanWeek(String stringDate) {
    return format(DateFormat.WEEKDAY, parse(stringDate));
  }

  static String humanAbbrWeek(String stringDate) {
    return format(DateFormat.ABBR_WEEKDAY, parse(stringDate));
  }

  static String minutes(String stringDate) {
    return format('Hm', parse(stringDate));
  }

  static String format(String pattern, DateTime parsedDate) {
    return DateFormat(pattern).format(parsedDate);
  }

  static DateTime parse(String stringDate) {
    return DateTime.parse(stringDate).toLocal();
  }

  static Duration diffFromNow(String stringDate) {
    return DateTime.now().difference(parse(stringDate));
  }

  static String utcDate(DateTime date) {
    return format('yyyy-MM-dd', date);
  }
}
