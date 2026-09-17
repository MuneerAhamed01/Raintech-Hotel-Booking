import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/room.dart';
import '../../data/rooms_data.dart';
import '../../../../widgets/hotel_calendar/utils/date_only.dart';
import '../../booking_logic/room_availability.dart';
import '../../booking_logic/stay_dates.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({List<Room>? rooms, DateTime? now})
    : this._(
        List<Room>.unmodifiable(rooms ?? sampleRooms(now: now)),
        DateOnly.today(now),
      );

  BookingCubit._(this._rooms, DateTime today)
    : super(_initialState(_rooms, today));

  final List<Room> _rooms;

  static BookingState _initialState(List<Room> rooms, DateTime today) {
    final stay = StayDates.defaultStay(now: today);
    return BookingState(
      stay: stay,
      rooms: rooms,
      availableRooms: RoomAvailability.availableRooms(rooms, stay),
      today: today,
    );
  }

  void applyStay(StayDates stay) {
    if (stay == state.stay) return;
    emit(
      state.copyWith(
        stay: stay,
        availableRooms: RoomAvailability.availableRooms(_rooms, stay),
      ),
    );
  }
}
