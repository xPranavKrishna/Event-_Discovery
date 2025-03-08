class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime date;
  final String imageUrl;
  final bool isFree;
  final double price;
  final String restrictions;
  final String organizerId;
  final String organizerName;
  final String category;
  final int attendeeCount;
  final List<String> tags;
  final String? contactEmail;
  final String? contactPhone;
  bool isInterested;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.imageUrl,
    required this.isFree,
    required this.price,
    required this.restrictions,
    required this.organizerId,
    required this.organizerName,
    required this.category,
    this.attendeeCount = 0,
    this.tags = const [],
    this.contactEmail,
    this.contactPhone,
    this.isInterested = false,
  });
}
