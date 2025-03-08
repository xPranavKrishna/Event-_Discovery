import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/theme/app_theme.dart';
import 'package:event_lister/models/event.dart';
import 'package:event_lister/screens/edit_profile_screen.dart';
import 'package:event_lister/screens/my_events_screen.dart';
import 'package:event_lister/screens/event_detail_screen.dart';
import 'package:event_lister/screens/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String _displayName = '';
  String _email = '';
  String _bio = 'Event enthusiast and community builder';
  String _location = 'New York, NY';
  String _profileImage = 'assets/images/profile_placeholder.jpg';
  int _hostedEventsCount = 0;
  int _attendedEventsCount = 0;
  List<Event> _upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserEvents();
  }

  Future<void> _loadUserData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, fetch from Firebase
    setState(() {
      _isLoading = false;
      _displayName = _currentUser?.displayName ?? 'John Doe';
      _email = _currentUser?.email ?? 'john.doe@example.com';
    });
  }

  Future<void> _loadUserEvents() async {
    // In a real app, fetch from Firebase
    // This is just mock data
    setState(() {
      _hostedEventsCount = 2;
      _attendedEventsCount = 5;
      _upcomingEvents = [
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
          organizerName: _displayName,
          category: 'Workshop',
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
        ),
      ];
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          displayName: _displayName,
          email: _email,
          bio: _bio,
          location: _location,
          profileImage: _profileImage,
        ),
      ),
    ).then((updatedData) {
      if (updatedData != null) {
        setState(() {
          _displayName = updatedData['displayName'];
          _email = updatedData['email'];
          _bio = updatedData['bio'];
          _location = updatedData['location'];
          _profileImage = updatedData['profileImage'];
        });
      }
    });
  }

  void _navigateToMyEvents({bool hostedOnly = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEventsScreen(
          hostedOnly: hostedOnly,
        ),
      ),
    );
  }

  void _navigateToHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.londrinaSolid(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logout functionality
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.londrinaSolid(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  _buildStatsSection(),
                  _buildUpcomingEvents(),
                  _buildMenuOptions(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: AssetImage(_profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _navigateToEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _displayName,
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _email,
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _bio,
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                _location,
                style: GoogleFonts.londrinaSolid(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              minimumSize: const Size(160, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Edit Profile',
              style: GoogleFonts.londrinaSolid(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToMyEvents(hostedOnly: true),
              child: Column(
                children: [
                  Text(
                    _hostedEventsCount.toString(),
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 28,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Hosted',
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToMyEvents(),
              child: Column(
                children: [
                  Text(
                    _attendedEventsCount.toString(),
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 28,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Attended',
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToMyEvents(),
              child: Column(
                children: [
                  Text(
                    (_hostedEventsCount + _attendedEventsCount).toString(),
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 28,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Total',
                    style: GoogleFonts.londrinaSolid(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events',
                style: GoogleFonts.londrinaSolid(
                  textStyle: TextStyle(
                    fontSize: 22,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _navigateToMyEvents,
                child: Text(
                  'See All',
                  style: GoogleFonts.londrinaSolid(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _upcomingEvents.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'No upcoming events',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = _upcomingEvents[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailScreen(event: event),
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
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.asset(
                                'assets/images/event_placeholder.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: GoogleFonts.londrinaSolid(
                                        textStyle: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${event.date.day}/${event.date.month}/${event.date.year}',
                                          style: GoogleFonts.londrinaSolid(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
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
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.organizerId == _currentUser?.uid
                                              ? 'You are hosting'
                                              : 'Attending',
                                          style: GoogleFonts.londrinaSolid(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: event.organizerId ==
                                                      _currentUser?.uid
                                                  ? AppTheme.primaryColor
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          _buildMenuOption(
            icon: Icons.event,
            title: 'My Events',
            onTap: _navigateToMyEvents,
          ),
          const Divider(height: 1),
          _buildMenuOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: _navigateToHelpSupport,
          ),
          const Divider(height: 1),
          _buildMenuOption(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.londrinaSolid(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: isDestructive ? Colors.red : Colors.grey[800],
                ),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
