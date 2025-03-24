import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:event_lister/screens/event_details_screen.dart';
import 'package:event_lister/screens/edit_event_screen.dart';

class MyEventsScreen extends StatefulWidget {
  final bool hostedOnly;

  const MyEventsScreen({
    Key? key,
    this.hostedOnly = false,
  }) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<EventModel> _interestedEvents = [];
  List<EventModel> _hostedEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.hostedOnly ? 1 : 0,
    );
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _currentUser?.uid;
      if (userId != null) {
        // CHANGE: Directly query events where this user is in the interestedUsers array
        final interestedEventsSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('interestedUsers', arrayContains: userId)
            .get();

        List<EventModel> interestedEvents = interestedEventsSnapshot.docs
            .map((doc) =>
                EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Load hosted events - this part looks correct
        final hostedEventsSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('organizerId', isEqualTo: userId)
            .get();

        List<EventModel> hostedEvents = hostedEventsSnapshot.docs
            .map((doc) =>
                EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        setState(() {
          _interestedEvents = interestedEvents;
          _hostedEvents = hostedEvents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E43C3),
        elevation: 0,
        title: Text(
          'My Events',
          style: GoogleFonts.albertSans(
            textStyle: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          tabs: const [
            Tab(
                text: 'Interested',
                icon: Icon(Icons.favorite, color: Colors.white)),
            Tab(text: 'Hosting', icon: Icon(Icons.event, color: Colors.white)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5E43C3),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInterestedEventsTab(),
                _buildHostedEventsTab(),
              ],
            ),
      // Floating action button removed
    );
  }

  Widget _buildInterestedEventsTab() {
    if (_interestedEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        message: 'No interested events yet',
        subMessage: 'Discover events and mark them as interested',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF5E43C3),
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _interestedEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_interestedEvents[index], isInterested: true);
        },
      ),
    );
  }

  Widget _buildHostedEventsTab() {
    if (_hostedEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        message: 'You\'re not hosting any events',
        subMessage: 'Create a new event from the home screen',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF5E43C3),
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hostedEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_hostedEvents[index], isHosting: true);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.abel(
              textStyle: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event,
      {bool isInterested = false, bool isHosting = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        ).then((_) => _loadEvents());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? Image.network(
                          event.imageUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/event_placeholder.jpg',
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/event_placeholder.jpg',
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E43C3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.eventType,
                      style: GoogleFonts.albertSans(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isHosting)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.interestedCount} interested',
                            style: GoogleFonts.abel(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: GoogleFonts.albertSans(
                            textStyle: TextStyle(
                              fontSize: 22,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isInterested)
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            // Remove from interested events
                            try {
                              // Get the event document reference
                              final eventRef = FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(event.id);

                              // Update the interestedUsers array to remove this user
                              await eventRef.update({
                                'interestedUsers':
                                    FieldValue.arrayRemove([_currentUser?.uid]),
                                'interestedCount': FieldValue.increment(-1)
                              });

                              setState(() {
                                _interestedEvents
                                    .removeWhere((e) => e.id == event.id);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Removed from interested events',
                                    style: GoogleFonts.aBeeZee(),
                                  ),
                                  backgroundColor: const Color(0xFF5E43C3),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: Unable to remove event',
                                    style: GoogleFonts.aBeeZee(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: const Color(0xFF5E43C3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year} at ${event.eventDate.hour}:${event.eventDate.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.aBeeZee(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: const Color(0xFF5E43C3),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.aBeeZee(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: const Color(0xFF5E43C3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.isFree
                            ? 'Free'
                            : '₹${event.cost.toStringAsFixed(2)}',
                        style: GoogleFonts.abel(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color:
                                event.isFree ? Colors.green : Colors.grey[800],
                            fontWeight: event.isFree
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isHosting)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditEventScreen(event: event),
                              ),
                            ).then((_) => _loadEvents());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E43C3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'Edit',
                            style: GoogleFonts.albertSans(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (isInterested)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Going',
                            style: GoogleFonts.albertSans(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF5E43C3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isHosting)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat(
                              'Views',
                              '${(event.attendeeCount * 1.8).round()}',
                              Icons.visibility),
                          _buildVerticalDivider(),
                          _buildQuickStat('Interested',
                              event.interestedCount.toString(), Icons.favorite),
                          _buildVerticalDivider(),
                          _buildQuickStat(
                              'Going',
                              '${(event.attendeeCount * 0.7).round()}',
                              Icons.check_circle),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF5E43C3),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.albertSans(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.abel(
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
