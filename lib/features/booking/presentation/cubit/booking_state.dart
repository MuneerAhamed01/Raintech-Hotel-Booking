import '../../data/models/room.dart';
import '../../booking_logic/stay_dates.dart';

class BookingState {
  const BookingState({
    required this.stay,
    required this.rooms,
    required this.availableRooms,
    required this.today,
  });

  final StayDates stay;
  final List<Room> rooms;
  final List<Room> availableRooms;
  final DateTime today;

  BookingState copyWith({StayDates? stay, List<Room>? availableRooms}) {
    return BookingState(
      stay: stay ?? this.stay,
      rooms: rooms,
      availableRooms: availableRooms ?? this.availableRooms,
      today: today,
    );
  }
}
