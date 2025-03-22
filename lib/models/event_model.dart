import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final String eventType;
  final String eventSize;
  final String eventDuration;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String location;
  final String? locationLink;
  final bool requiresRegistration;
  final String? registrationLink;
  final List<String> targetAudience;
  final bool isFree;
  final double cost;
  final String creatorId;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final int attendeeCount;
  final List<String> interestedUsers;
  final int interestedCount;
  // New host fields
  final String hostName;
  final String hostPhone;
  final String hostEmail;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.eventType,
    required this.eventSize,
    required this.eventDuration,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    this.locationLink,
    required this.requiresRegistration,
    this.registrationLink,
    required this.targetAudience,
    required this.isFree,
    this.cost = 0.0,
    required this.creatorId,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.attendeeCount = 0,
    this.interestedUsers = const [],
    this.interestedCount = 0,
    required this.hostName,
    required this.hostPhone,
    required this.hostEmail,
  });

  // Convert Firestore document to EventModel
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse timeString back to TimeOfDay
    String timeString = data['eventTime'] ?? '12:00';
    List<String> timeParts = timeString.split(':');
    TimeOfDay eventTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      eventType: data['eventType'] ?? '',
      eventSize: data['eventSize'] ?? '',
      eventDuration: data['eventDuration'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventTime: eventTime,
      location: data['location'] ?? '',
      locationLink: data['locationLink'],
      requiresRegistration: data['requiresRegistration'] ?? false,
      registrationLink: data['registrationLink'],
      targetAudience: List<String>.from(data['targetAudience'] ?? []),
      isFree: data['isFree'] ?? true,
      cost: data['price']?.toDouble() ?? 0.0,
      creatorId: data['organizerId'] ?? '',
      imageUrl: data['imageUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      attendeeCount: data['attendeeCount'] ?? 0,
      interestedUsers: List<String>.from(data['interestedUsers'] ?? []),
      interestedCount: data['interestedCount'] ?? 0,
      hostName: data['hostName'] ?? '',
      hostPhone: data['hostPhone'] ?? '',
      hostEmail: data['hostEmail'] ?? '',
    );
  }

  // For compatibility with existing code
  factory EventModel.fromMap(Map<String, dynamic> data, String docId) {
    // Parse timeString back to TimeOfDay
    String timeString = data['eventTime'] ?? '12:00';
    List<String> timeParts = timeString.split(':');
    TimeOfDay eventTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return EventModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      eventType: data['eventType'] ?? '',
      eventSize: data['eventSize'] ?? '',
      eventDuration: data['eventDuration'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventTime: eventTime,
      location: data['location'] ?? '',
      locationLink: data['locationLink'],
      requiresRegistration: data['requiresRegistration'] ?? false,
      registrationLink: data['registrationLink'],
      targetAudience: List<String>.from(data['targetAudience'] ?? []),
      isFree: data['isFree'] ?? true,
      cost: data['price']?.toDouble() ?? 0.0,
      creatorId: data['organizerId'] ?? '',
      imageUrl: data['imageUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      attendeeCount: data['attendeeCount'] ?? 0,
      interestedUsers: List<String>.from(data['interestedUsers'] ?? []),
      interestedCount: data['interestedCount'] ?? 0,
      hostName: data['hostName'] ?? '',
      hostPhone: data['hostPhone'] ?? '',
      hostEmail: data['hostEmail'] ?? '',
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
      'eventTime': '${eventTime.hour}:${eventTime.minute}',
      'location': location,
      'locationLink': locationLink,
      'requiresRegistration': requiresRegistration,
      'registrationLink': registrationLink,
      'targetAudience': targetAudience,
      'isFree': isFree,
      'price': cost,
      'organizerId': creatorId,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'attendeeCount': attendeeCount,
      'interestedUsers': interestedUsers,
      'interestedCount': interestedCount,
      'hostName': hostName,
      'hostPhone': hostPhone,
      'hostEmail': hostEmail,
    };
  }

  // Helper method to check if a user is interested in this event
  bool isUserInterested(String userId) {
    return interestedUsers.contains(userId);
  }
}
