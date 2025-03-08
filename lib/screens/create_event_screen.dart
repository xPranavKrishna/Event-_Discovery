import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:event_lister/models/event.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isFree = false;
  bool _isUploading = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  File? _imageFile;
  String _selectedCategory = 'Music';
  final List<String> _categories = [
    'Music',
    'Technology',
    'Community',
    'Food & Drink',
    'Sports',
    'Arts',
    'Business',
    'Education',
    'Health',
    'Other'
  ];

  MapController _mapController = MapController();
  LatLng _mapCenter = LatLng(40.7128, -74.0060); // Default to NYC

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _restrictionsController.dispose();
    _tagsController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _mapCenter = LatLng(_latitude, _longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF800020),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF800020),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final String fileName = 'events/${Uuid().v4()}.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(_imageFile!);
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Upload image if selected
        String imageUrl = 'assets/images/event_placeholder.jpg';
        if (_imageFile != null) {
          final uploadedUrl = await _uploadImage();
          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
          }
        }

        // Get current user
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          _showErrorDialog('You must be logged in to create an event');
          setState(() {
            _isUploading = false;
          });
          return;
        }

        // Parse tags
        List<String> tags = [];
        if (_tagsController.text.isNotEmpty) {
          tags = _tagsController.text
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }

        // Create event object
        final String eventId = Uuid().v4();
        final Event newEvent = Event(
          id: eventId,
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          latitude: _latitude,
          longitude: _longitude,
          date: _selectedDate,
          imageUrl: imageUrl,
          isFree: _isFree,
          price: _isFree ? 0.0 : double.parse(_priceController.text),
          restrictions: _restrictionsController.text,
          organizerId: currentUser.uid,
          organizerName: currentUser.displayName ?? 'Anonymous',
          category: _selectedCategory,
          tags: tags,
          contactEmail:
              _emailController.text.isEmpty ? null : _emailController.text,
          contactPhone:
              _phoneController.text.isEmpty ? null : _phoneController.text,
          attendeeCount: 0,
          isInterested: false,
        );

        // Save to Firestore
        await FirebaseFirestore.instance.collection('events').doc(eventId).set({
          'id': newEvent.id,
          'title': newEvent.title,
          'description': newEvent.description,
          'location': newEvent.location,
          'latitude': newEvent.latitude,
          'longitude': newEvent.longitude,
          'date': newEvent.date,
          'imageUrl': newEvent.imageUrl,
          'isFree': newEvent.isFree,
          'price': newEvent.price,
          'restrictions': newEvent.restrictions,
          'organizerId': newEvent.organizerId,
          'organizerName': newEvent.organizerName,
          'category': newEvent.category,
          'attendeeCount': newEvent.attendeeCount,
          'tags': newEvent.tags,
          'contactEmail': newEvent.contactEmail,
          'contactPhone': newEvent.contactPhone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event created successfully!',
              style: GoogleFonts.londrinaSolid(
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error creating event: $e');
        _showErrorDialog('Failed to create event: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(fontSize: 22, color: Color(0xFF800020)),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.londrinaSolid(
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF800020),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateLocationFromMap(LatLng tappedPoint) {
    setState(() {
      _latitude = tappedPoint.latitude;
      _longitude = tappedPoint.longitude;
      _mapCenter = tappedPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        elevation: 0,
        title: Text(
          'Create Event',
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUploading
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Event Details'),
                      _buildImagePicker(),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Event Title',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Event Description',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildTagsField(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Date & Time'),
                      _buildDateTimePicker(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Location'),
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location Name',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMapPicker(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Pricing & Requirements'),
                      _buildPricingSwitch(),
                      if (!_isFree) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _priceController,
                          label: 'Price (\$)',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (!_isFree) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              try {
                                double.parse(value);
                              } catch (e) {
                                return 'Please enter a valid price';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _restrictionsController,
                        label: 'Restrictions or Requirements',
                        icon: Icons.warning_amber,
                        helperText:
                            'e.g., "18+ only", "Bring your own equipment"',
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Contact Information'),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Contact Email (Optional)',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final bool emailValid = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value);
                            if (!emailValid) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Contact Phone (Optional)',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF800020)),
          ),
          const SizedBox(height: 24),
          Text(
            'Creating your event...',
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 24,
                color: Color(0xFF800020),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(
            color: Color(0xFF800020),
            thickness: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.londrinaSolid(
          textStyle: TextStyle(color: Colors.grey[700], fontSize: 18),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF800020)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF800020), width: 2),
        ),
        helperText: helperText,
        helperStyle: GoogleFonts.londrinaSolid(
          textStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
      style: GoogleFonts.londrinaSolid(
        textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey),
            image: _imageFile != null
                ? DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Event Image',
                      style: GoogleFonts.londrinaSolid(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF800020),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date and Time',
                  style: GoogleFonts.londrinaSolid(
                    textStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy – h:mm a').format(_selectedDate),
                  style: GoogleFonts.londrinaSolid(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF800020),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select location on the map',
          style: GoogleFonts.londrinaSolid(
            textStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _mapCenter, // Use `initialCenter` instead of `center`
                initialZoom: 14.0, // Use `initialZoom` instead of `zoom`
                onTap: (tapPosition, point) => _updateLocationFromMap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _mapCenter,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF800020),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Coordinates: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
          style: GoogleFonts.londrinaSolid(
            textStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: const Color(0xFF800020),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'This is a free event',
              style: GoogleFonts.londrinaSolid(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          Switch(
            value: _isFree,
            onChanged: (value) {
              setState(() {
                _isFree = value;
                if (value) {
                  _priceController.text = '0.0';
                }
              });
            },
            activeColor: const Color(0xFF800020),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF800020)),
          iconSize: 24,
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(value),
                    color: const Color(0xFF800020),
                  ),
                  const SizedBox(width: 16),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Music':
        return Icons.music_note;
      case 'Technology':
        return Icons.computer;
      case 'Community':
        return Icons.people;
      case 'Food & Drink':
        return Icons.restaurant;
      case 'Sports':
        return Icons.sports;
      case 'Arts':
        return Icons.palette;
      case 'Business':
        return Icons.business_center;
      case 'Education':
        return Icons.school;
      case 'Health':
        return Icons.favorite;
      default:
        return Icons.event;
    }
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _tagsController,
          label: 'Tags (comma separated)',
          icon: Icons.tag,
          helperText: 'e.g., "music, outdoor, family-friendly"',
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Create Event',
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
