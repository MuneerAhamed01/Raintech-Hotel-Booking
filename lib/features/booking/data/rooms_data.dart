import '../presentation/widgets/hotel_calendar/utils/date_only.dart';
import 'models/room.dart';

/// Demo inventory. Unavailable nights are offsets from [today] so the
/// sample stays realistic as the calendar moves.
List<Room> sampleRooms({DateTime? now}) {
  final today = DateOnly.today(now);
  return [
    Room(
      id: 'R101',
      name: 'Deluxe Room',
      pricePerNight: 3500,
      maxGuests: 2,
      unavailableNights: [
        ..._nights(today, startOffset: 3, count: 3),
        ..._nights(today, startOffset: 18, count: 2),
      ],
    ),
    Room(
      id: 'R102',
      name: 'Deluxe Room',
      pricePerNight: 3500,
      maxGuests: 2,
      unavailableNights: [
        ..._nights(today, startOffset: 0, count: 1),
        ..._nights(today, startOffset: 10, count: 4),
      ],
    ),
    Room(
      id: 'R201',
      name: 'Executive Suite',
      pricePerNight: 5800,
      maxGuests: 3,
      unavailableNights: [..._nights(today, startOffset: 7, count: 4)],
    ),
    Room(
      id: 'R202',
      name: 'Executive Suite',
      pricePerNight: 5800,
      maxGuests: 3,
    ),
    Room(
      id: 'R301',
      name: 'Family Room',
      pricePerNight: 4200,
      maxGuests: 4,
      unavailableNights: [
        ..._nights(today, startOffset: 1, count: 5),
        ..._nights(today, startOffset: 25, count: 3),
      ],
    ),
  ];
}

List<DateTime> _nights(
  DateTime today, {
  required int startOffset,
  required int count,
}) {
  return [
    for (var i = 0; i < count; i++) DateOnly.addDays(today, startOffset + i),
  ];
}
