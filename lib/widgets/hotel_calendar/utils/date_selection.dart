import 'date_only.dart';

/// In-progress start / end date selection for the hotel calendar widget.
///
/// Taps follow range-picking behavior:
/// - No dates, or both dates set: tap starts a new start date.
/// - Start only: a later date becomes the end; same or earlier
///   date starts a new range.
class DateSelection {
  const DateSelection({this.checkIn, this.checkOut});

  /// [pickingEnd] keeps [start] and waits for a check-out tap.
  factory DateSelection.fromDates({
    required DateTime start,
    DateTime? end,
    bool pickingEnd = false,
  }) {
    final startDay = DateOnly.from(start);
    if (pickingEnd || end == null) {
      return DateSelection(checkIn: startDay);
    }
    return DateSelection(checkIn: startDay, checkOut: DateOnly.from(end));
  }

  final DateTime? checkIn;
  final DateTime? checkOut;

  bool get isComplete => checkIn != null && checkOut != null;

  bool get isPickingCheckOut => checkIn != null && checkOut == null;

  int? get nights {
    if (!isComplete) return null;
    return DateOnly.daysBetween(checkIn!, checkOut!);
  }

  DateSelection tap(DateTime day) {
    final selected = DateOnly.from(day);
    if (checkIn == null || checkOut != null) {
      return DateSelection(checkIn: selected);
    }
    if (!DateOnly.isAfter(selected, checkIn!)) {
      return DateSelection(checkIn: selected);
    }
    return DateSelection(checkIn: checkIn, checkOut: selected);
  }
}
