import 'package:flutter/material.dart';

import '../../data/rooms_data.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a room')),
      body: sampleRooms.isEmpty
          ? const Center(child: Text('No rooms'))
          : ListView.builder(
              itemCount: sampleRooms.length,
              itemBuilder: (context, index) {
                final room = sampleRooms[index];
                return ListTile(
                  title: Text(room.name),
                  subtitle: Text('${room.id}  ·  ₹${room.pricePerNight} / night'),
                );
              },
            ),
    );
  }
}
