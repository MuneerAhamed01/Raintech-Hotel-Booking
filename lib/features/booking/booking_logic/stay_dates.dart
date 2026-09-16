import '../presentation/widgets/hotel_calendar/utils/date_only.dart';
import 'booking_rules.dart';

/// A confirmed hotel stay: nights occupied are [checkIn, checkOut).
class StayDates {
  factory StayDates({required DateTime checkIn, required DateTime checkOut}) {
    final inDate = DateOnly.from(checkIn);
    final outDate = DateOnly.from(checkOut);
    final nights = DateOnly.daysBetween(inDate, outDate);
    if (!BookingRules.isNightCountAllowed(nights)) {
      throw ArgumentError(
        'Stay must be ${BookingRules.minNights}–${BookingRules.maxNights} nights, got $nights',
      );
    }
    return StayDates._(inDate, outDate);
  }

  factory StayDates.defaultStay({DateTime? now}) {
    final checkIn = DateOnly.today(now);
    return StayDates(
      checkIn: checkIn,
      checkOut: DateOnly.addDays(checkIn, BookingRules.minNights),
    );
  }

  const StayDates._(this.checkIn, this.checkOut);

  final DateTime checkIn;
  final DateTime checkOut;

  int get nights => DateOnly.daysBetween(checkIn, checkOut);

  /// Nights the guest occupies the room (checkout morning is not occupied).
  Iterable<DateTime> get occupiedNights => DateOnly.eachDay(checkIn, checkOut);

  @override
  bool operator ==(Object other) =>
      other is StayDates &&
      DateOnly.isSameDay(checkIn, other.checkIn) &&
      DateOnly.isSameDay(checkOut, other.checkOut);

  @override
  int get hashCode => Object.hash(checkIn, checkOut);
}

enum StayField { checkIn, checkOut }
