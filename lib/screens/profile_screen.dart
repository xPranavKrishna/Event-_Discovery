import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/screens/my_events_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, fetch user data from Firebase
      // This includes getting the profile image URL if it exists
      if (_currentUser != null) {
        setState(() {
          _displayName = _currentUser!.displayName ?? 'John Doe';
          _email = _currentUser!.email ?? 'john.doe@example.com';
          _profileImageUrl = _currentUser!.photoURL;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      // Add a slight delay to make the loading feel more natural
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a modal bottom sheet with options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF5E43C3)),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1000,
                    maxHeight: 1000,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    _uploadImageToFirebase(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF5E43C3)),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1000,
                    maxHeight: 1000,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    _uploadImageToFirebase(File(photo.path));
                  }
                },
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Current Photo',
                    style: GoogleFonts.aBeeZee(
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeCurrentProfilePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    if (_currentUser == null) {
      _showErrorSnackBar('You must be logged in to upload a profile picture.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final fileName =
          'profile_${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      // Upload file to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Show upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: $progress%');
      });

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // Update the user's profile with the new image URL
      await _currentUser!.updatePhotoURL(downloadUrl);

      // Update local state
      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploading = false;
      });

      _showSuccessSnackBar('Profile picture updated successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Failed to upload image: ${e.toString()}');
      debugPrint('Error uploading image: $e');
    }
  }

  Future<void> _removeCurrentProfilePhoto() async {
    if (_currentUser == null || _profileImageUrl == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Extract the file path from the URL to delete from storage
      final Uri uri = Uri.parse(_profileImageUrl!);
      final String imagePath = uri.pathSegments.last;

      // Create a reference to the image in Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(imagePath);

      // Delete the image from Firebase Storage
      await storageRef.delete();

      // Update the user's profile to remove the photo URL
      await _currentUser!.updatePhotoURL(null);

      // Update local state
      setState(() {
        _profileImageUrl = null;
        _isUploading = false;
      });

      _showSuccessSnackBar('Profile picture removed successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Failed to remove profile picture: ${e.toString()}');
      debugPrint('Error removing profile picture: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.aBeeZee(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.aBeeZee(),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
              // Profile Image
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    color: Colors.white,
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF5E43C3),
                        )
                      : _profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF5E43C3),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Color(0xFF5E43C3),
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 80,
                              color: Color(0xFF5E43C3),
                            ),
                ),
              ),
              // Camera icon overlay
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
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

// Updated ContactUsScreen with white background and improved email functionality
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  // Function to launch email app
  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Handle error - if unable to launch email app
        debugPrint('Could not launch $emailLaunchUri');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
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
              color: Colors.white, // Explicitly setting white color
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
                    InkWell(
                      onTap: () {
                        // Launch email app with the specified email
                        _launchEmail('eventhorizon.connect@gmail.com');
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email,
                            color: Color(0xFF5E43C3),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'eventhorizon.connect@gmail.com',
                            style: GoogleFonts.aBeeZee(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5E43C3),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
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
