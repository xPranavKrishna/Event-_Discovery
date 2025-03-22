import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_lister/models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _eventsCollection => _firestore.collection('events');

  // Toggle user interest in an event
  Future<void> toggleEventInterest(
      String eventId, String userId, bool isInterested) async {
    final eventRef = _eventsCollection.doc(eventId);

    if (isInterested) {
      // Add user to interested list and increment count
      return eventRef.update({
        'interestedUsers': FieldValue.arrayUnion([userId]),
        'interestedCount': FieldValue.increment(1)
      });
    } else {
      // Remove user from interested list and decrement count
      return eventRef.update({
        'interestedUsers': FieldValue.arrayRemove([userId]),
        'interestedCount': FieldValue.increment(-1)
      });
    }
  }

  // Get a single event
  Future<EventModel?> getEvent(String eventId) async {
    final docSnapshot = await _eventsCollection.doc(eventId).get();
    if (!docSnapshot.exists) return null;
    return EventModel.fromFirestore(docSnapshot);
  }

  // Get all events
  Stream<List<EventModel>> getEvents() {
    return _eventsCollection.orderBy('eventDate').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Add additional methods as needed for your app
}
