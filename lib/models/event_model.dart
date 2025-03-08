import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final String eventType;
  final String eventSize;
  final String eventDuration;
  final DateTime eventDate;
  final String location;
  final String? locationLink;
  final bool requiresRegistration;
  final List<String> targetAudience;
  final bool isFree;
  final double? cost;
  final String creatorId;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.eventType,
    required this.eventSize,
    required this.eventDuration,
    required this.eventDate,
    required this.location,
    this.locationLink,
    required this.requiresRegistration,
    required this.targetAudience,
    required this.isFree,
    this.cost,
    required this.creatorId,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  // Convert Firestore document to EventModel
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      eventType: data['eventType'] ?? '',
      eventSize: data['eventSize'] ?? '',
      eventDuration: data['eventDuration'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      locationLink: data['locationLink'],
      requiresRegistration: data['requiresRegistration'] ?? false,
      targetAudience: List<String>.from(data['targetAudience'] ?? []),
      isFree: data['isFree'] ?? true,
      cost: data['cost']?.toDouble(),
      creatorId: data['creatorId'] ?? '',
      imageUrl: data['imageUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert EventModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'eventType': eventType,
      'eventSize': eventSize,
      'eventDuration': eventDuration,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'locationLink': locationLink,
      'requiresRegistration': requiresRegistration,
      'targetAudience': targetAudience,
      'isFree': isFree,
      'cost': cost,
      'creatorId': creatorId,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
