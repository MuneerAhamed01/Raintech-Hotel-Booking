import '../../../widgets/hotel_calendar/utils/calendar_availability.dart';
import '../../../widgets/hotel_calendar/utils/date_only.dart';

/// Booking stay constraints, backed by the shared calendar widget rules.
abstract final class BookingRules {
  static const calendar = CalendarConstraints();

  static int get minNights => calendar.minNights;
  static int get maxNights => calendar.maxNights;
  static int get maxAdvanceDays => calendar.maxAdvanceDays;

  static DateTime earliestCheckIn(DateTime today) => DateOnly.from(today);

  static DateTime lastCheckOut(DateTime today) => calendar.lastCheckOut(today);

  static DateTime lastCheckIn(DateTime today) => calendar.lastCheckIn(today);

  static bool isNightCountAllowed(int nights) =>
      calendar.isNightCountAllowed(nights);
}
