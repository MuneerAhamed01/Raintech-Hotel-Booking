/// Calendar-day helpers that ignore clock time and stay stable around DST.
abstract final class DateOnly {
  static DateTime from(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime today([DateTime? now]) => from(now ?? DateTime.now());

  static DateTime addDays(DateTime date, int days) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final shifted = utc.add(Duration(days: days));
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  static int daysBetween(DateTime start, DateTime end) {
    final a = DateTime.utc(start.year, start.month, start.day);
    final b = DateTime.utc(end.year, end.month, end.day);
    return b.difference(a).inDays;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isBefore(DateTime a, DateTime b) =>
      daysBetween(from(a), from(b)) > 0;

  static bool isAfter(DateTime a, DateTime b) =>
      daysBetween(from(a), from(b)) < 0;

  static bool isBeforeOrSame(DateTime a, DateTime b) => !isAfter(a, b);

  static bool isAfterOrSame(DateTime a, DateTime b) => !isBefore(a, b);

  static Iterable<DateTime> eachDay(
    DateTime start,
    DateTime endExclusive,
  ) sync* {
    var current = from(start);
    final last = from(endExclusive);
    while (isBefore(current, last)) {
      yield current;
      current = addDays(current, 1);
    }
  }
}
