import 'date_only.dart';
import 'date_selection.dart';

/// Window and stay-length limits for a reusable hotel calendar.
class CalendarConstraints {
  const CalendarConstraints({
    this.minNights = 1,
    this.maxNights = 30,
    this.maxAdvanceDays = 365,
  });

  final int minNights;
  final int maxNights;
  final int maxAdvanceDays;

  DateTime lastCheckOut(DateTime today) =>
      DateOnly.addDays(DateOnly.from(today), maxAdvanceDays);

  DateTime lastCheckIn(DateTime today) =>
      DateOnly.addDays(lastCheckOut(today), -minNights);

  bool isNightCountAllowed(int nights) =>
      nights >= minNights && nights <= maxNights;
}

/// Which calendar days can be tapped, independent of a product domain.
///
/// Pass [canStartOn] / [canCompleteOn] from the host feature (rooms,
/// flights, cars, and so on).
abstract final class CalendarAvailability {
  static bool isSelectable({
    required DateTime day,
    required DateSelection selection,
    required DateTime today,
    CalendarConstraints constraints = const CalendarConstraints(),
    required bool Function(DateTime day) canStartOn,
    required bool Function(DateTime start, DateTime end) canCompleteOn,
  }) {
    final selected = DateOnly.from(day);
    final todayDate = DateOnly.from(today);

    if (DateOnly.isBefore(selected, todayDate)) return false;

    if (selection.isPickingCheckOut) {
      return _canTapWhilePickingCheckOut(
        selected: selected,
        checkIn: selection.checkIn!,
        today: todayDate,
        constraints: constraints,
        canStartOn: canStartOn,
        canCompleteOn: canCompleteOn,
      );
    }

    return _canTapAsCheckIn(selected, todayDate, constraints, canStartOn);
  }

  static bool _canTapAsCheckIn(
    DateTime selected,
    DateTime today,
    CalendarConstraints constraints,
    bool Function(DateTime day) canStartOn,
  ) {
    if (DateOnly.isAfter(selected, constraints.lastCheckIn(today))) {
      return false;
    }
    return canStartOn(selected);
  }

  static bool _canTapWhilePickingCheckOut({
    required DateTime selected,
    required DateTime checkIn,
    required DateTime today,
    required CalendarConstraints constraints,
    required bool Function(DateTime day) canStartOn,
    required bool Function(DateTime start, DateTime end) canCompleteOn,
  }) {
    if (DateOnly.isSameDay(selected, checkIn)) return false;

    if (DateOnly.isBefore(selected, checkIn)) {
      return _canTapAsCheckIn(selected, today, constraints, canStartOn);
    }

    if (DateOnly.isAfter(selected, constraints.lastCheckOut(today))) {
      return false;
    }

    final nights = DateOnly.daysBetween(checkIn, selected);
    if (!constraints.isNightCountAllowed(nights)) return false;

    return canCompleteOn(checkIn, selected);
  }
}
