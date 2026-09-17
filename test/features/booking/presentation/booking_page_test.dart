import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rain_tech/features/booking/data/models/room.dart';
import 'package:rain_tech/features/booking/booking_logic/stay_dates.dart';
import 'package:rain_tech/theme/booking_colors.dart';
import 'package:rain_tech/features/booking/presentation/view/booking_page.dart';
import 'package:rain_tech/widgets/hotel_date_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() {
  final today = DateTime(2026, 9, 16);

  Widget app({DateTime? now}) {
    return MaterialApp(
      theme: BookingColors.theme(),
      home: BookingPage(now: now ?? today),
    );
  }

  testWidgets('booking page shows check-in and check-out in the app bar', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    expect(find.text('CHECK-IN'), findsOneWidget);
    expect(find.text('CHECK-OUT'), findsOneWidget);
    expect(find.text('Book a stay'), findsOneWidget);
    expect(find.text('16 Sep'), findsOneWidget);
    expect(find.text('17 Sep'), findsOneWidget);
  });

  testWidgets('tapping check-in opens the Syncfusion date picker', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    await tester.tap(find.text('CHECK-IN'));
    await tester.pumpAndSettle();

    expect(find.text('Select dates'), findsOneWidget);
    expect(find.byType(SfDateRangePicker), findsOneWidget);
    expect(find.text('Apply dates'), findsOneWidget);
  });

  testWidgets('apply is disabled while waiting for checkout', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: BookingColors.theme(),
        home: Scaffold(
          body: HotelDatePicker(
            initialStay: StayDates.defaultStay(now: today),
            rooms: const [
              Room(id: 'R1', name: 'Open', pricePerNight: 1000, maxGuests: 2),
            ],
            today: today,
            focus: StayField.checkOut,
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Apply dates'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('apply is enabled when both stay dates are set', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: BookingColors.theme(),
        home: Scaffold(
          body: HotelDatePicker(
            initialStay: StayDates.defaultStay(now: today),
            rooms: const [
              Room(id: 'R1', name: 'Open', pricePerNight: 1000, maxGuests: 2),
            ],
            today: today,
            focus: StayField.checkIn,
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Apply dates'),
    );
    expect(button.onPressed, isNotNull);
  });
}
