import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:uuid/uuid.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _costController = TextEditingController();

  // Form values
  String _eventType = 'Festival';
  String _eventSize = 'Small';
  String _eventDuration = 'Few hours';
  DateTime _eventDate = DateTime.now();
  bool _requiresRegistration = false;
  List<String> _targetAudience = ['General'];
  bool _isFree = true;

  // Location data
  double? _latitude;
  double? _longitude;

  // Loading state
  bool _isLoading = false;

  // Available options for form dropdowns
  final List<String> _eventTypes = [
    'Festival',
    'Workshop',
    'Concert',
    'Sports'
  ];
  final List<String> _eventSizes = ['Small', 'Medium', 'Large'];
  final List<String> _eventDurations = [
    'Few hours',
    'Half day',
    'Full day',
    'Multiple days'
  ];
  final List<String> _audienceOptions = [
    'General',
    'Adults',
    'Children',
    'Seniors',
    'Professional'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _locationLinkController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = "Current Location Selected";
        _isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final String fileName = 'event_images/${Uuid().v4()}.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(_selectedImage!);
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save event to Firestore
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      String? imageUrl = await _uploadImage();

      // Get current user ID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You need to be logged in to create an event')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create event object
      final event = EventModel(
        id: '', // Will be assigned by Firestore
        name: _nameController.text,
        description: _descriptionController.text,
        eventType: _eventType,
        eventSize: _eventSize,
        eventDuration: _eventDuration,
        eventDate: _eventDate,
        location: _locationController.text,
        locationLink: _locationLinkController.text.isEmpty
            ? null
            : _locationLinkController.text,
        requiresRegistration: _requiresRegistration,
        targetAudience: _targetAudience,
        isFree: _isFree,
        cost: _isFree ? null : double.tryParse(_costController.text) ?? 0,
        creatorId: userId,
        imageUrl: imageUrl,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .add(event.toFirestore());

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')));
      Navigator.pop(context);
    } catch (e) {
      print("Error saving event: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creating event: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Event',
          style: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Basic Information
                    _buildSectionTitle('1', 'Basic information'),
                    const SizedBox(height: 15),

                    // Event Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Name of event',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Event Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Event Description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // 2. Event Type & Details
                    _buildSectionTitle('2', 'Event type & details'),
                    const SizedBox(height: 15),

                    // Event Type
                    Text(
                      'Event Type',
                      style: GoogleFonts.aBeeZee(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: _eventTypes
                          .map((type) => ChoiceChip(
                                label: Text(type),
                                selected: _eventType == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _eventType = type;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: const Color(0xFF5E43C3),
                                labelStyle: TextStyle(
                                  color: _eventType == type
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Event Size
                    Text(
                      'Event Size',
                      style: GoogleFonts.aBeeZee(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: _eventSizes
                          .map((size) => ChoiceChip(
                                label: Text(size),
                                selected: _eventSize == size,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _eventSize = size;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: const Color(0xFF5E43C3),
                                labelStyle: TextStyle(
                                  color: _eventSize == size
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Event Duration
                    Text(
                      'Event Duration',
                      style: GoogleFonts.aBeeZee(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: _eventDurations
                          .map((duration) => ChoiceChip(
                                label: Text(duration),
                                selected: _eventDuration == duration,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _eventDuration = duration;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: const Color(0xFF5E43C3),
                                labelStyle: TextStyle(
                                  color: _eventDuration == duration
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),

                    // 3. Venue & Time
                    _buildSectionTitle('3', 'Venue & time'),
                    const SizedBox(height: 15),

                    // Event Date
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Event Date',
                              style: GoogleFonts.aBeeZee(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('MM/dd/yyyy').format(_eventDate),
                              style: GoogleFonts.aBeeZee(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event Location
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Event Location',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: _getCurrentLocation,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an event location';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Location Link
                    TextFormField(
                      controller: _locationLinkController,
                      decoration: InputDecoration(
                        hintText: 'Location Link',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 4. Registration & Additional Details
                    _buildSectionTitle(
                        '4', 'Registration & Additional Details'),
                    const SizedBox(height: 15),

                    // Required Registration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Required Registration',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: _requiresRegistration,
                          onChanged: (value) {
                            setState(() {
                              _requiresRegistration = value;
                            });
                          },
                          activeColor: const Color(0xFF5E43C3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Target Audience
                    Text(
                      'Target Audience',
                      style: GoogleFonts.aBeeZee(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: _audienceOptions
                          .map((audience) => FilterChip(
                                label: Text(audience),
                                selected: _targetAudience.contains(audience),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _targetAudience.add(audience);
                                    } else {
                                      _targetAudience.remove(audience);
                                    }
                                  });
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: const Color(0xFF5E43C3),
                                labelStyle: TextStyle(
                                  color: _targetAudience.contains(audience)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Event Cost
                    Text(
                      'Event Cost',
                      style: GoogleFonts.aBeeZee(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: _isFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _isFree = value!;
                            });
                          },
                          activeColor: const Color(0xFF5E43C3),
                        ),
                        Text(
                          'Free',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Radio(
                          value: false,
                          groupValue: _isFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _isFree = value!;
                            });
                          },
                          activeColor: const Color(0xFF5E43C3),
                        ),
                        Text(
                          'Paid',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!_isFree)
                      TextFormField(
                        controller: _costController,
                        decoration: InputDecoration(
                          hintText: 'Cost',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!_isFree && (value == null || value.isEmpty)) {
                            return 'Please enter the event cost';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E43C3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Create Event',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.aBeeZee(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
