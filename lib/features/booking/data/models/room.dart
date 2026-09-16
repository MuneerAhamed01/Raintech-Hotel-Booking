class Room {
  const Room({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.maxGuests,
    this.unavailableNights = const [],
  });

  final String id;
  final String name;
  final int pricePerNight;
  final int maxGuests;

  /// Nights this room cannot be occupied (existing bookings or blocks).
  /// Checkout on a listed morning is still allowed; that night is not occupied.
  final List<DateTime> unavailableNights;
}
