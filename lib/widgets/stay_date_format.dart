import 'hotel_calendar/utils/calendar_date_format.dart';

abstract final class StayDateFormat {
  static const months = CalendarDateFormat.months;
  static const weekdays = CalendarDateFormat.weekdays;
  static const weekdayShort = CalendarDateFormat.weekdayShort;

  static String dayMonth(DateTime date) =>
      '${date.day} ${months[date.month - 1]}';

  static String weekday(DateTime date) => weekdays[date.weekday - 1];

  static String monthYear(DateTime date) => CalendarDateFormat.monthYear(date);

  static String nightsLabel(int nights) =>
      nights == 1 ? '1 night' : '$nights nights';

  static String nightsShort(int nights) => '${nights}N';
}
