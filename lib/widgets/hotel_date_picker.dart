import 'package:flutter/material.dart';

import '../features/booking/data/models/room.dart';
import '../features/booking/booking_logic/booking_rules.dart';
import '../features/booking/booking_logic/room_availability.dart';
import '../features/booking/booking_logic/stay_dates.dart';
import '../theme/booking_colors.dart';
import 'hotel_calendar/hotel_calendar.dart';
import 'stay_date_format.dart';

Future<StayDates?> showHotelDatePicker(
  BuildContext context, {
  required StayDates initialStay,
  required List<Room> rooms,
  required DateTime today,
  required StayField focus,
}) {
  return showModalBottomSheet<StayDates>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.92,
        child: HotelDatePicker(
          initialStay: initialStay,
          rooms: rooms,
          today: today,
          focus: focus,
        ),
      );
    },
  );
}

class HotelDatePicker extends StatefulWidget {
  const HotelDatePicker({
    super.key,
    required this.initialStay,
    required this.rooms,
    required this.today,
    required this.focus,
  });

  final StayDates initialStay;
  final List<Room> rooms;
  final DateTime today;
  final StayField focus;

  @override
  State<HotelDatePicker> createState() => _HotelDatePickerState();
}

class _HotelDatePickerState extends State<HotelDatePicker> {
  late DateSelection _selection;

  @override
  void initState() {
    super.initState();
    _selection = DateSelection.fromDates(
      start: widget.initialStay.checkIn,
      end: widget.initialStay.checkOut,
      pickingEnd: widget.focus == StayField.checkOut,
    );
  }

  bool _isEnabled(DateTime day) {
    return CalendarAvailability.isSelectable(
      day: day,
      selection: _selection,
      today: widget.today,
      constraints: BookingRules.calendar,
      canStartOn: (date) => RoomAvailability.canCheckInOn(widget.rooms, date),
      canCompleteOn: (start, end) =>
          RoomAvailability.canCheckOutOn(widget.rooms, start, end),
    );
  }

  void _onCalendarSelection(DateSelection selection) {
    if (_sameSelection(selection, _selection)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sameSelection(selection, _selection)) return;
      setState(() => _selection = selection);
    });
  }

  bool _sameSelection(DateSelection a, DateSelection b) {
    return _sameDay(a.checkIn, b.checkIn) && _sameDay(a.checkOut, b.checkOut);
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return DateOnly.isSameDay(a, b);
  }

  StayDates? _stayFromSelection() {
    final nights = _selection.nights;
    if (nights == null || !BookingRules.isNightCountAllowed(nights)) {
      return null;
    }
    return StayDates(
      checkIn: _selection.checkIn!,
      checkOut: _selection.checkOut!,
    );
  }

  void _apply() {
    final stay = _stayFromSelection();
    if (stay == null) return;
    Navigator.of(context).pop(stay);
  }

  @override
  Widget build(BuildContext context) {
    final stay = _stayFromSelection();
    final availableCount = stay == null
        ? null
        : RoomAvailability.availableCount(widget.rooms, stay);

    return Material(
      color: BookingColors.cream,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BookingColors.creamDark,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: BookingColors.ink,
                ),
                const Expanded(
                  child: Text(
                    'Select dates',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BookingColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _SelectionSummary(selection: _selection),
          ),
          Expanded(
            child: HotelCalendar(
              selection: _selection,
              today: widget.today,
              isDayEnabled: _isEnabled,
              onSelectionChanged: _onCalendarSelection,
              constraints: BookingRules.calendar,
            ),
          ),
          const _CalendarLegend(),
          _PickerFooter(
            selection: _selection,
            availableCount: availableCount,
            onApply: stay == null ? null : _apply,
          ),
        ],
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.selection});

  final DateSelection selection;

  @override
  Widget build(BuildContext context) {
    final pickingOut = selection.isPickingCheckOut;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BookingColors.creamDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'CHECK-IN',
              date: selection.checkIn,
              highlighted: !pickingOut,
            ),
          ),
          Container(width: 1, height: 52, color: BookingColors.creamDark),
          Expanded(
            child: _SummaryTile(
              label: 'CHECK-OUT',
              date: selection.checkOut,
              highlighted: pickingOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.date,
    required this.highlighted,
  });

  final String label;
  final DateTime? date;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? BookingColors.goldSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? BookingColors.navy : BookingColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date == null ? 'Select date' : StayDateFormat.dayMonth(date!),
            style: TextStyle(
              color: date == null ? BookingColors.muted : BookingColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            date == null ? 'Add a date' : StayDateFormat.weekday(date!),
            style: const TextStyle(color: BookingColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          _LegendDot(color: BookingColors.navy, label: 'Selected'),
          _LegendDot(color: BookingColors.gold, label: 'In stay'),
          _LegendDot(color: BookingColors.soldOut, label: 'Unavailable'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: BookingColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _PickerFooter extends StatelessWidget {
  const _PickerFooter({
    required this.selection,
    required this.availableCount,
    required this.onApply,
  });

  final DateSelection selection;
  final int? availableCount;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final nights = selection.nights;
    final String title;
    final String subtitle;

    if (selection.checkIn == null) {
      title = 'Choose check-in';
      subtitle = 'Then pick a check-out morning';
    } else if (selection.checkOut == null) {
      title = 'Choose check-out';
      subtitle = 'Minimum 1 night · maximum 30 nights';
    } else {
      title = StayDateFormat.nightsLabel(nights!);
      if (availableCount == 0) {
        subtitle = 'No rooms for this stay. Try other dates.';
      } else {
        subtitle =
            '$availableCount ${availableCount == 1 ? 'room' : 'rooms'} available';
      }
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: BookingColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: availableCount == 0
                            ? const Color(0xFF9B4A3C)
                            : BookingColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: BookingColors.navy,
                  disabledBackgroundColor: BookingColors.creamDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Apply dates'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
