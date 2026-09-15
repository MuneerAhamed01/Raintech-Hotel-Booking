class Room {
  const Room({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.maxGuests,
  });

  final String id;
  final String name;
  final int pricePerNight;
  final int maxGuests;
}
