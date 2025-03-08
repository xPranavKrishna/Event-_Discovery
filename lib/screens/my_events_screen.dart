import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/theme/app_theme.dart';
import 'package:event_lister/models/event.dart';
import 'package:event_lister/screens/event_detail_screen.dart';

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
  List<Event> _interestedEvents = [];
  List<Event> _hostedEvents = [];

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
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, fetch from Firebase
    // This is just mock data
    setState(() {
      _interestedEvents = [
        Event(
          id: '1',
          title: 'Tech Conference 2025',
          description:
              'The biggest tech event of the year with keynotes from industry leaders',
          location: 'Convention Center',
          latitude: 40.712776,
          longitude: -74.005974,
          date: DateTime.now().add(const Duration(days: 15)),
          imageUrl: 'assets/images/tech_conf.jpg',
          isFree: false,
          price: 49.99,
          restrictions: 'Registration required',
          organizerId: 'org1',
          organizerName: 'Tech Events Inc.',
          category: 'Conference',
          attendeeCount: 352,
          tags: ['Tech', 'Networking', 'Innovation'],
          isInterested: true,
        ),
        Event(
          id: '2',
          title: 'Jazz in the Park',
          description: 'An evening of smooth jazz under the stars',
          location: 'Central Park',
          latitude: 40.785091,
          longitude: -73.968285,
          date: DateTime.now().add(const Duration(days: 5)),
          imageUrl: 'assets/images/jazz.jpg',
          isFree: true,
          price: 0,
          restrictions: 'No alcohol',
          organizerId: 'org2',
          organizerName: 'City Events',
          category: 'Music',
          attendeeCount: 189,
          tags: ['Music', 'Outdoor', 'Jazz'],
          isInterested: true,
        ),
        Event(
          id: '7',
          title: 'Book Club Meeting',
          description: 'Discussion on "The Great Gatsby"',
          location: 'Local Library',
          latitude: 40.758896,
          longitude: -73.985130,
          date: DateTime.now().add(const Duration(days: 7)),
          imageUrl: 'assets/images/book_club.jpg',
          isFree: true,
          price: 0,
          restrictions: 'Please read the book beforehand',
          organizerId: 'org7',
          organizerName: 'Literature Lovers',
          category: 'Book Club',
          attendeeCount: 24,
          tags: ['Books', 'Discussion', 'Literature'],
          isInterested: true,
        ),
      ];

      _hostedEvents = [
        Event(
          id: '5',
          title: 'Cooking Workshop',
          description: 'Learn to cook Italian pasta from scratch',
          location: 'Culinary Institute',
          latitude: 40.718796,
          longitude: -74.001239,
          date: DateTime.now().add(const Duration(days: 10)),
          imageUrl: 'assets/images/cooking.jpg',
          isFree: false,
          price: 35.00,
          restrictions: 'Ingredients provided',
          organizerId: _currentUser?.uid ?? 'user1',
          organizerName: 'Your Name',
          category: 'Workshop',
          attendeeCount: 18,
          tags: ['Cooking', 'Italian', 'Food'],
        ),
        Event(
          id: '6',
          title: 'Photography Workshop',
          description: 'Learn the basics of photography and composition',
          location: 'Downtown Art Center',
          latitude: 40.712776,
          longitude: -74.005974,
          date: DateTime.now().add(const Duration(days: 1)),
          imageUrl: 'assets/images/photography.jpg',
          isFree: false,
          price: 25.00,
          restrictions: 'Bring your own camera',
          organizerId: _currentUser?.uid ?? 'user1',
          organizerName: 'Your Name',
          category: 'Workshop',
          attendeeCount: 12,
          tags: ['Photography', 'Art', 'Workshop'],
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'My Events',
          style: GoogleFonts.londrinaSolid(
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
          labelStyle: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 18,
            ),
          ),
          tabs: const [
            Tab(text: 'Interested', icon: Icon(Icons.favorite)),
            Tab(text: 'Hosting', icon: Icon(Icons.event)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInterestedEventsTab(),
                _buildHostedEventsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Create Event functionality coming soon!',
                style: GoogleFonts.londrinaSolid(),
              ),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
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
      color: AppTheme.primaryColor,
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
        subMessage: 'Tap the "+" button to create a new event',
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
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
            style: GoogleFonts.londrinaSolid(
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
            style: GoogleFonts.londrinaSolid(
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

  Widget _buildEventCard(Event event,
      {bool isInterested = false, bool isHosting = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
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
                  child: Image.asset(
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
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
                      style: GoogleFonts.londrinaSolid(
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
                            '${event.attendeeCount} interested',
                            style: GoogleFonts.londrinaSolid(
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
                          event.title,
                          style: GoogleFonts.londrinaSolid(
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
                          icon: Icon(
                            event.isInterested
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                event.isInterested ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              event.isInterested = !event.isInterested;
                              // In a real app, update this in Firebase
                            });
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
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.date.day}/${event.date.month}/${event.date.year} at ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.londrinaSolid(
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
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.londrinaSolid(
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
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.isFree
                            ? 'Free'
                            : '\$${event.price.toStringAsFixed(2)}',
                        style: GoogleFonts.londrinaSolid(
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Manage',
                            style: GoogleFonts.londrinaSolid(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (isInterested && event.isInterested)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Going',
                            style: GoogleFonts.londrinaSolid(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
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
                          _buildQuickStat('Views', '324', Icons.visibility),
                          _buildVerticalDivider(),
                          _buildQuickStat('Interested',
                              event.attendeeCount.toString(), Icons.favorite),
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
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.londrinaSolid(
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
          style: GoogleFonts.londrinaSolid(
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
