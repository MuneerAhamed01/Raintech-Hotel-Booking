import '../data/models/room.dart';
import '../presentation/widgets/hotel_calendar/utils/date_only.dart';
import 'booking_rules.dart';
import 'stay_dates.dart';

/// Booking-side availability: which rooms can host a stay.
abstract final class RoomAvailability {
  static bool isNightUnavailable(Room room, DateTime night) {
    final day = DateOnly.from(night);
    return room.unavailableNights.any(
      (booked) => DateOnly.isSameDay(booked, day),
    );
  }

  static bool isStayAvailable(Room room, StayDates stay) {
    for (final night in stay.occupiedNights) {
      if (isNightUnavailable(room, night)) return false;
    }
    return true;
  }

  static List<Room> availableRooms(List<Room> rooms, StayDates stay) => rooms
      .where((room) => isStayAvailable(room, stay))
      .toList(growable: false);

  static bool canCheckInOn(List<Room> rooms, DateTime day) =>
      rooms.any((room) => !isNightUnavailable(room, day));

  /// Checkout morning [checkOut] is valid when at least one room can host
  /// every occupied night in `[checkIn, checkOut)`.
  static bool canCheckOutOn(
    List<Room> rooms,
    DateTime checkIn,
    DateTime checkOut,
  ) {
    if (!DateOnly.isAfter(checkOut, checkIn)) return false;
    final nights = DateOnly.daysBetween(checkIn, checkOut);
    if (!BookingRules.isNightCountAllowed(nights)) return false;
    final stay = StayDates(checkIn: checkIn, checkOut: checkOut);
    return rooms.any((room) => isStayAvailable(room, stay));
  }

  static bool isNightSoldOut(List<Room> rooms, DateTime night) =>
      rooms.isNotEmpty &&
      rooms.every((room) => isNightUnavailable(room, night));

  static int availableCount(List<Room> rooms, StayDates stay) =>
      availableRooms(rooms, stay).length;
}
