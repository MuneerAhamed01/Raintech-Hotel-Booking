# RainTech Hotel Booking

A Flutter hotel booking screen. Guests pick check-in and check-out dates, see rooms that are free for that stay, and get nights plus total price before they book.

Room data is local sample inventory — no API or backend.

## Features

- Room list with price per night and guest capacity
- Check-in / check-out calendar with stay rules
- Night count and total price (nights × price per night)
- Date validation: no past check-in, check-out after check-in
- Rooms already booked for the selected dates are hidden
- Unit tests for stay dates, availability, and price calculation

## Stack

| Layer | Choice |
| --- | --- |
| App | Flutter (Dart 3.13+) |
| State | Cubit (`flutter_bloc`) |
| Calendar | Syncfusion DateRangePicker |
| Tests | `flutter_test` |

Logic lives under `lib/features/booking/booking_logic/`. UI and state live under `lib/features/booking/presentation/`. Shared calendar widgets live under `lib/widgets/`.

## Run

```bash
flutter pub get
flutter run
```

```bash
flutter test
```
