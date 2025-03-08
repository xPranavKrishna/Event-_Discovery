import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/theme/app_theme.dart';
import 'package:event_lister/models/event.dart';
import 'package:event_lister/screens/create_event_screen.dart';
import 'package:event_lister/screens/profile_screen.dart';
import 'package:event_lister/screens/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isLocationEnabled = false;
  Position? _currentPosition;
  double _filterDistance = 10.0; // Default 10km
  List<Event> _events = [];
  List<Event> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    // In a real app, this would load from Firebase
    // Simulated data for demo purposes
    setState(() {
      _events = [
        Event(
          id: '1',
          title: 'Summer Music Festival',
          description:
              'Enjoy 3 days of amazing live music performances by top artists',
          location: 'Central Park',
          latitude: 40.785091,
          longitude: -73.968285,
          date: DateTime.now().add(const Duration(days: 5)),
          imageUrl: 'assets/images/music_festival.jpg',
          isFree: false,
          price: 49.99,
          restrictions: '18+ only',
          organizerId: 'org1',
          organizerName: 'City Events',
          category: 'Festival', // 🎵 Music Festival
        ),
        Event(
          id: '2',
          title: 'Tech Conference 2025',
          description: 'Learn about the latest innovations in technology',
          location: 'Convention Center',
          latitude: 40.758896,
          longitude: -73.985130,
          date: DateTime.now().add(const Duration(days: 10)),
          imageUrl: 'assets/images/tech_conf.jpg',
          isFree: false,
          price: 199.99,
          restrictions: 'Registration required',
          organizerId: 'org2',
          organizerName: 'TechMinds',
          category: 'Workshop', // 💻 Tech Conference
        ),
        Event(
          id: '3',
          title: 'Community Cleanup',
          description:
              'Join us to clean up the local beach and make a difference',
          location: 'Sunset Beach',
          latitude: 40.742054,
          longitude: -73.935242,
          date: DateTime.now().add(const Duration(days: 2)),
          imageUrl: 'assets/images/cleanup.jpg',
          isFree: true,
          price: 0,
          restrictions: 'Bring your own gloves',
          organizerId: 'org3',
          organizerName: 'Green Earth',
          category: 'Community Service', // 🌍 Cleanup Drive
        ),
        Event(
          id: '4',
          title: 'Food & Wine Festival',
          description:
              'Sample dishes from top chefs and wines from around the world',
          location: 'Downtown Square',
          latitude: 40.712776,
          longitude: -74.005974,
          date: DateTime.now().add(const Duration(days: 15)),
          imageUrl: 'assets/images/food_fest.jpg',
          isFree: false,
          price: 65.00,
          restrictions: '21+ only',
          organizerId: 'org4',
          organizerName: 'Taste of the City',
          category: 'Festival', // 🍷 Food Festival
        ),
        Event(
          id: '5',
          title: 'Yoga in the Park',
          description: 'Outdoor yoga session for all skill levels',
          location: 'Riverside Park',
          latitude: 40.800258,
          longitude: -73.972340,
          date: DateTime.now().add(const Duration(days: 3)),
          imageUrl: 'assets/images/yoga.jpg',
          isFree: true,
          price: 0,
          restrictions: 'Bring your own mat',
          organizerId: 'org5',
          organizerName: 'Mindful Living',
          category: 'Health & Wellness', // 🧘 Yoga Event
        ),
      ];
      _filteredEvents = List.from(_events);
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      if (_isLocationEnabled) {
        _filterEventsByLocation();
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _toggleLocationFilter(bool value) {
    setState(() {
      _isLocationEnabled = value;
      if (value) {
        if (_currentPosition != null) {
          _filterEventsByLocation();
        } else {
          _getCurrentLocation();
        }
      } else {
        _filterEventsBySearchOnly();
      }
    });
  }

  void _filterEventsByLocation() {
    if (_currentPosition == null) return;

    setState(() {
      _filteredEvents = _events.where((event) {
        double distanceInKm = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              event.latitude,
              event.longitude,
            ) /
            1000; // Convert to km

        return distanceInKm <= _filterDistance;
      }).toList();

      // Also apply search if active
      if (_searchQuery.isNotEmpty) {
        _filteredEvents = _filteredEvents
            .where((event) =>
                event.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                event.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterEventsBySearchOnly() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredEvents = List.from(_events);
      } else {
        _filteredEvents = _events
            .where((event) =>
                event.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                event.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
      if (_isLocationEnabled) {
        _filterEventsByLocation();
      } else {
        _filterEventsBySearchOnly();
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      // Navigate to create event screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateEventScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      // Navigate to profile screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildLocationFilter(),
            Expanded(
              child: _buildEventsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF800020),
      elevation: 0,
      title: Text(
        'EventSphere',
        style: GoogleFonts.londrinaSolid(
          textStyle: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Show notifications
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: GoogleFonts.londrinaSolid(
            textStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF800020)),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _filterEventsBySearchOnly();
                    });
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: GoogleFonts.londrinaSolid(
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
            _searchQuery = value;
            if (_isLocationEnabled) {
              _filterEventsByLocation();
            } else {
              _filterEventsBySearchOnly();
            }
          });
        },
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: const Color(0xFF800020),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Show events nearby',
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          Switch(
            value: _isLocationEnabled,
            onChanged: _toggleLocationFilter,
            activeColor: const Color(0xFF800020),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.londrinaSolid(
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLocationEnabled
                  ? 'Try increasing the distance or changing your search'
                  : 'Try a different search term',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Overlay
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/event_placeholder.jpg', // Fallback to placeholder
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        event.title,
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? Colors.green
                            : const Color(0xFF800020),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.isFree
                            ? 'FREE'
                            : '\$${event.price.toStringAsFixed(2)}',
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
                ],
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF800020),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.date.day}/${event.date.month}/${event.date.year}',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFF800020),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.description,
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailScreen(event: event),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          'Details',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF800020),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 14,
            ),
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF800020),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              label: 'Create',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
