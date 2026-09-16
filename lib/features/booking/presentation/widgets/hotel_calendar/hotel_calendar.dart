import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../theme/booking_colors.dart';
import 'utils/calendar_availability.dart';
import 'utils/date_only.dart';
import 'utils/date_selection.dart';

export 'utils/calendar_availability.dart';
export 'utils/calendar_date_format.dart';
export 'utils/date_only.dart';
export 'utils/date_selection.dart';

/// Hotel-styled wrapper around Syncfusion [SfDateRangePicker].
class HotelCalendar extends StatefulWidget {
  const HotelCalendar({
    super.key,
    required this.selection,
    required this.today,
    required this.isDayEnabled,
    required this.onSelectionChanged,
    this.constraints = const CalendarConstraints(),
  });

  final DateSelection selection;
  final DateTime today;
  final bool Function(DateTime day) isDayEnabled;
  final ValueChanged<DateSelection> onSelectionChanged;
  final CalendarConstraints constraints;

  @override
  State<HotelCalendar> createState() => _HotelCalendarState();
}

class _HotelCalendarState extends State<HotelCalendar> {
  final DateRangePickerController _controller = DateRangePickerController();
  bool _suppressSelectionCallback = false;

  @override
  void initState() {
    super.initState();
    _syncController(widget.selection);
  }

  @override
  void didUpdateWidget(covariant HotelCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameSelection(oldWidget.selection, widget.selection)) {
      _syncController(widget.selection);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(DateSelection selection) {
    if (_sameRange(_controller.selectedRange, selection)) return;
    _suppressSelectionCallback = true;
    _controller.selectedRange = PickerDateRange(
      selection.checkIn,
      selection.checkOut,
    );
    _suppressSelectionCallback = false;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (_suppressSelectionCallback) return;

    final value = args.value;
    if (value is! PickerDateRange || value.startDate == null) return;

    var next = _selectionFromRange(value);
    if (next.checkOut != null && !widget.isDayEnabled(next.checkOut!)) {
      next = DateSelection(checkIn: next.checkIn);
      _syncController(next);
    }

    if (_sameSelection(next, widget.selection)) return;
    widget.onSelectionChanged(next);
  }

  DateSelection _selectionFromRange(PickerDateRange range) {
    final start = DateOnly.from(range.startDate!);
    final end = range.endDate == null ? null : DateOnly.from(range.endDate!);
    if (end == null || DateOnly.isSameDay(start, end)) {
      return DateSelection(checkIn: start);
    }
    if (DateOnly.isBefore(end, start)) {
      return DateSelection(checkIn: end, checkOut: start);
    }
    return DateSelection(checkIn: start, checkOut: end);
  }

  bool _sameSelection(DateSelection a, DateSelection b) =>
      _sameDay(a.checkIn, b.checkIn) && _sameDay(a.checkOut, b.checkOut);

  bool _sameRange(PickerDateRange? range, DateSelection selection) =>
      _sameDay(range?.startDate, selection.checkIn) &&
      _sameDay(range?.endDate, selection.checkOut);

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return DateOnly.isSameDay(a, b);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateOnly.from(widget.today);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SfDateRangePicker(
        controller: _controller,
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.range,
        navigationDirection: DateRangePickerNavigationDirection.horizontal,
        navigationMode: DateRangePickerNavigationMode.snap,
        enablePastDates: false,
        showNavigationArrow: true,
        minDate: today,
        maxDate: widget.constraints.lastCheckOut(today),
        initialDisplayDate: widget.selection.checkIn ?? today,
        backgroundColor: Colors.transparent,
        headerHeight: 48,
        headerStyle: const DateRangePickerHeaderStyle(
          backgroundColor: Colors.transparent,
          textAlign: TextAlign.left,
          textStyle: TextStyle(
            color: BookingColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
          viewHeaderHeight: 36,
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            backgroundColor: Colors.transparent,
            textStyle: TextStyle(
              color: BookingColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: const TextStyle(
            color: BookingColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          todayTextStyle: const TextStyle(
            color: BookingColors.gold,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          disabledDatesTextStyle: const TextStyle(
            color: BookingColors.soldOut,
            fontSize: 13,
            decoration: TextDecoration.lineThrough,
          ),
          todayCellDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BookingColors.gold, width: 1.4),
          ),
        ),
        selectionShape: DateRangePickerSelectionShape.circle,
        startRangeSelectionColor: BookingColors.navy,
        endRangeSelectionColor: BookingColors.navy,
        rangeSelectionColor: BookingColors.goldSoft,
        selectionTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        rangeTextStyle: const TextStyle(
          color: BookingColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        selectableDayPredicate: widget.isDayEnabled,
        onSelectionChanged: _onSelectionChanged,
      ),
    );
  }
}
