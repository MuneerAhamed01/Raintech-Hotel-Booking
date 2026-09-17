import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/room.dart';
import '../../booking_logic/stay_dates.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../../../../theme/booking_colors.dart';
import '../../../../widgets/check_in_out_bar.dart';
import '../../../../widgets/hotel_date_picker.dart';
import '../../../../widgets/stay_date_format.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(now: now),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  Future<void> _openPicker(BuildContext context, StayField field) async {
    final cubit = context.read<BookingCubit>();
    final stay = await showHotelDatePicker(
      context,
      initialStay: cubit.state.stay,
      rooms: cubit.state.rooms,
      today: cubit.state.today,
      focus: field,
    );
    if (stay != null && context.mounted) {
      cubit.applyStay(stay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Book a stay'),
            bottom: CheckInOutBar(
              stay: state.stay,
              onFieldTap: (field) => _openPicker(context, field),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StayHint(state: state),
              Expanded(
                child: state.availableRooms.isEmpty
                    ? const _EmptyRooms()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: state.availableRooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _RoomCard(
                            room: state.availableRooms[index],
                            stay: state.stay,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StayHint extends StatelessWidget {
  const _StayHint({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final count = state.availableRooms.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        count == 0
            ? 'No rooms for ${StayDateFormat.nightsLabel(state.stay.nights)}'
            : '$count ${count == 1 ? 'room' : 'rooms'} · ${StayDateFormat.nightsLabel(state.stay.nights)}',
        style: const TextStyle(
          color: BookingColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyRooms extends StatelessWidget {
  const _EmptyRooms();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 42, color: BookingColors.gold),
            SizedBox(height: 12),
            Text(
              'Those dates are fully booked',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BookingColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different check-in or check-out. Rooms that overlap an unavailable night are hidden.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BookingColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.stay});

  final Room room;
  final StayDates stay;

  @override
  Widget build(BuildContext context) {
    final total = room.pricePerNight * stay.nights;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BookingColors.creamDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.name,
                    style: const TextStyle(
                      color: BookingColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '₹${room.pricePerNight}',
                  style: const TextStyle(
                    color: BookingColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${room.id}  ·  Up to ${room.maxGuests} guests  ·  per night',
              style: const TextStyle(color: BookingColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: BookingColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '₹$total total · ${StayDateFormat.nightsLabel(stay.nights)}',
                style: const TextStyle(
                  color: BookingColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
