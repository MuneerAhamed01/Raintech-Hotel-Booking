import 'package:flutter_test/flutter_test.dart';
import 'package:rain_tech/features/booking/data/models/room.dart';
import 'package:rain_tech/features/booking/data/rooms_data.dart';
import 'package:rain_tech/features/booking/booking_logic/booking_rules.dart';
import 'package:rain_tech/features/booking/booking_logic/room_availability.dart';
import 'package:rain_tech/features/booking/booking_logic/stay_dates.dart';
import 'package:rain_tech/widgets/hotel_calendar/hotel_calendar.dart';
import 'package:rain_tech/features/booking/presentation/cubit/booking_cubit.dart';

void main() {
  final today = DateTime(2026, 9, 16);

  DateTime day(int offset) => DateOnly.addDays(today, offset);

  Room room({required String id, List<int> unavailable = const []}) {
    return Room(
      id: id,
      name: id,
      pricePerNight: 1000,
      maxGuests: 2,
      unavailableNights: [for (final offset in unavailable) day(offset)],
    );
  }

  group('DateOnly', () {
    test('strips time and compares calendar days', () {
      final morning = DateTime(2026, 9, 16, 8, 30);
      final night = DateTime(2026, 9, 16, 23, 59);
      expect(DateOnly.isSameDay(morning, night), isTrue);
      expect(DateOnly.daysBetween(morning, DateTime(2026, 9, 18, 1)), 2);
    });

    test('addDays crosses months, years, and leap days', () {
      expect(DateOnly.addDays(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 1));
      expect(DateOnly.addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(DateOnly.addDays(DateTime(2028, 2, 28), 1), DateTime(2028, 2, 29));
      expect(DateOnly.addDays(DateTime(2027, 2, 28), 1), DateTime(2027, 3, 1));
    });
  });

  group('StayDates', () {
    test('counts occupied nights and excludes checkout morning', () {
      final stay = StayDates(checkIn: today, checkOut: day(2));
      expect(stay.nights, 2);
      expect(stay.occupiedNights, [today, day(1)]);
    });

    test('rejects same-day and overlong stays', () {
      expect(
        () => StayDates(checkIn: today, checkOut: today),
        throwsArgumentError,
      );
      expect(
        () => StayDates(checkIn: today, checkOut: day(31)),
        throwsArgumentError,
      );
    });

    test('default stay is tonight through tomorrow', () {
      final stay = StayDates.defaultStay(now: today);
      expect(stay.checkIn, today);
      expect(stay.checkOut, day(1));
    });
  });

  group('DateSelection', () {
    test('first tap is check-in, later tap is check-out', () {
      var selection = const DateSelection();
      selection = selection.tap(today);
      expect(selection.checkIn, today);
      expect(selection.checkOut, isNull);

      selection = selection.tap(day(3));
      expect(selection.checkIn, today);
      expect(selection.checkOut, day(3));
      expect(selection.nights, 3);
    });

    test('tapping the same or an earlier day restarts check-in', () {
      var selection = DateSelection(checkIn: day(2));
      selection = selection.tap(day(2));
      expect(selection.checkIn, day(2));
      expect(selection.checkOut, isNull);

      selection = DateSelection(checkIn: day(4)).tap(day(1));
      expect(selection.checkIn, day(1));
      expect(selection.checkOut, isNull);
    });

    test('tapping after a complete stay starts a new check-in', () {
      final selection = DateSelection(
        checkIn: today,
        checkOut: day(2),
      ).tap(day(5));
      expect(selection.checkIn, day(5));
      expect(selection.checkOut, isNull);
    });

    test('checkout focus keeps check-in and waits for checkout', () {
      final selection = DateSelection.fromDates(
        start: today,
        end: day(2),
        pickingEnd: true,
      );
      expect(selection.isPickingCheckOut, isTrue);
      expect(selection.checkIn, today);
      expect(selection.checkOut, isNull);
    });
  });

  group('RoomAvailability', () {
    test('checkout morning on an unavailable night is still allowed', () {
      final deluxe = room(id: 'A', unavailable: [2]);
      final stay = StayDates(checkIn: today, checkOut: day(2));
      expect(RoomAvailability.isStayAvailable(deluxe, stay), isTrue);
      expect(
        RoomAvailability.isStayAvailable(
          deluxe,
          StayDates(checkIn: today, checkOut: day(3)),
        ),
        isFalse,
      );
    });

    test('a stay is available when any room can host every occupied night', () {
      final rooms = [
        room(id: 'A', unavailable: [1]),
        room(id: 'B', unavailable: [3]),
      ];
      final stay = StayDates(checkIn: today, checkOut: day(3));
      expect(
        RoomAvailability.availableRooms(rooms, stay).map((room) => room.id),
        ['B'],
      );
    });

    test('a night is sold out only when every room is blocked', () {
      final rooms = [
        room(id: 'A', unavailable: [1]),
        room(id: 'B'),
      ];
      expect(RoomAvailability.isNightSoldOut(rooms, day(1)), isFalse);
      expect(
        RoomAvailability.isNightSoldOut([
          room(id: 'A', unavailable: [1]),
          room(id: 'B', unavailable: [1]),
        ], day(1)),
        isTrue,
      );
    });
  });

  group('CalendarAvailability', () {
    bool selectable(
      DateTime date, {
      required DateSelection selection,
      required List<Room> rooms,
    }) {
      return CalendarAvailability.isSelectable(
        day: date,
        selection: selection,
        today: today,
        canStartOn: (day) => RoomAvailability.canCheckInOn(rooms, day),
        canCompleteOn: (start, end) =>
            RoomAvailability.canCheckOutOn(rooms, start, end),
      );
    }

    test(
      'blocks past dates and the last day that cannot fit a 1-night stay',
      () {
        final rooms = [room(id: 'open')];
        const selection = DateSelection();
        expect(
          selectable(day(-1), selection: selection, rooms: rooms),
          isFalse,
        );
        expect(selectable(today, selection: selection, rooms: rooms), isTrue);
        expect(
          selectable(
            BookingRules.lastCheckIn(today),
            selection: selection,
            rooms: rooms,
          ),
          isTrue,
        );
        expect(
          selectable(
            BookingRules.lastCheckOut(today),
            selection: selection,
            rooms: rooms,
          ),
          isFalse,
        );
      },
    );

    test('cannot check out on the check-in day', () {
      final rooms = [room(id: 'open')];
      final selection = DateSelection(checkIn: today);
      expect(selectable(today, selection: selection, rooms: rooms), isFalse);
      expect(selectable(day(1), selection: selection, rooms: rooms), isTrue);
    });

    test('cannot exceed the maximum stay length', () {
      final rooms = [room(id: 'open')];
      final selection = DateSelection(checkIn: today);
      expect(selectable(day(30), selection: selection, rooms: rooms), isTrue);
      expect(selectable(day(31), selection: selection, rooms: rooms), isFalse);
    });

    test('sold-out check-in nights are disabled', () {
      final rooms = [
        room(id: 'A', unavailable: [2]),
        room(id: 'B', unavailable: [2]),
      ];
      const selection = DateSelection();
      expect(selectable(day(2), selection: selection, rooms: rooms), isFalse);
      expect(selectable(today, selection: selection, rooms: rooms), isTrue);
    });

    test('checkout is disabled when no room can cover the whole stay', () {
      final rooms = [
        room(id: 'A', unavailable: [2]),
        room(id: 'B', unavailable: [2]),
      ];
      final selection = DateSelection(checkIn: today);
      expect(selectable(day(2), selection: selection, rooms: rooms), isTrue);
      expect(selectable(day(3), selection: selection, rooms: rooms), isFalse);
    });

    test('an earlier date while picking checkout can restart as check-in', () {
      final rooms = [room(id: 'open')];
      final selection = DateSelection(checkIn: day(4));
      expect(selectable(day(1), selection: selection, rooms: rooms), isTrue);
    });

    test('nothing is selectable without rooms', () {
      expect(
        selectable(today, selection: const DateSelection(), rooms: const []),
        isFalse,
      );
    });
  });

  group('sample rooms and cubit', () {
    test('default tonight stay hides rooms booked for tonight', () {
      final rooms = sampleRooms(now: today);
      final cubit = BookingCubit(rooms: rooms, now: today);
      final ids = cubit.state.availableRooms.map((room) => room.id).toList();

      expect(ids, isNot(contains('R102')));
      expect(ids, containsAll(['R101', 'R201', 'R202', 'R301']));
    });

    test('applying a stay re-filters rooms against unavailable nights', () {
      final cubit = BookingCubit(
        rooms: sampleRooms(now: today),
        now: today,
      );
      cubit.applyStay(StayDates(checkIn: day(1), checkOut: day(6)));
      final ids = cubit.state.availableRooms.map((room) => room.id).toList();

      expect(ids, containsAll(['R102', 'R201', 'R202']));
      expect(ids, isNot(contains('R101')));
      expect(ids, isNot(contains('R301')));
    });
  });
}
