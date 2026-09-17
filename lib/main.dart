import 'package:flutter/material.dart';

import 'theme/booking_colors.dart';
import 'features/booking/presentation/view/booking_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: BookingColors.theme(),
      home: const BookingPage(),
    );
  }
}
