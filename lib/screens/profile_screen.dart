import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/screens/my_events_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _navigateToMyEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyEventsScreen(),
      ),
    );
  }

  void _navigateToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUsScreen(),
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
            style: GoogleFonts.aBeeZee(
              textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.aBeeZee(
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
                style: GoogleFonts.aBeeZee(
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
                backgroundColor: const Color(0xFF5E43C3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.aBeeZee(
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
        backgroundColor: const Color(0xFF5E43C3),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.albertSans(
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
                color: Color(0xFF5E43C3),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  _buildMenuOptions(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5E43C3),
        borderRadius: BorderRadius.only(
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
              GestureDetector(
                onTap: () {
                  // Handle image change directly here
                  // You would add code to pick an image and upload to Firebase
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    color: Colors.white, // Background color for the icon
                  ),
                  child: const Icon(
                    Icons
                        .person, // Using person icon instead of placeholder image
                    size: 80,
                    color: Color(0xFF5E43C3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle image change
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF5E43C3),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _displayName,
            style: GoogleFonts.albertSans(
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
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
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
            icon: Icons.contact_mail,
            title: 'Contact Us',
            onTap: _navigateToContactUs,
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
              color: isDestructive ? Colors.red : const Color(0xFF5E43C3),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.aBeeZee(
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

// Simple Contact Us Screen
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  // Function to launch email app
  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Handle error - if unable to launch email app
      debugPrint('Could not launch $emailLaunchUri');
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
          'Contact Us',
          style: GoogleFonts.albertSans(
            textStyle: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: GoogleFonts.albertSans(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Have questions or feedback? Reach out to us at:',
                      style: GoogleFonts.aBeeZee(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: const Color(0xFF5E43C3),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Launch email app with the specified email
                            _launchEmail('eventhorizon.connect@gmail.com');
                          },
                          child: Text(
                            'eventhorizon.connect@gmail.com',
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF5E43C3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Our team will get back to you as soon as possible. Thank you for using GatherUp!',
                      style: GoogleFonts.aBeeZee(
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
      ),
    );
  }
}
