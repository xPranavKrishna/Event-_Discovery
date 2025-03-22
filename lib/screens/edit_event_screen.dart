import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:uuid/uuid.dart';
import 'package:event_lister/theme/app_theme.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _existingImageUrl;

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _locationLinkController;
  late final TextEditingController _costController;
  late final TextEditingController _registrationLinkController;
  late final TextEditingController _hostNameController;
  late final TextEditingController _hostPhoneController;
  late final TextEditingController _hostEmailController;

  // Form values
  late String _eventType;
  late String _eventSize;
  late String _eventDuration;
  late DateTime _eventDate;
  late TimeOfDay _eventTime;
  late bool _requiresRegistration;
  late List<String> _targetAudience;
  late bool _isFree;

  // Location data
  double? _latitude;
  double? _longitude;

  // Loading state
  bool _isLoading = false;
  bool _imageChanged = false;

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
    'Students',
    'Professional'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing event data
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _locationLinkController =
        TextEditingController(text: widget.event.locationLink ?? '');
    _costController = TextEditingController(
        text: widget.event.isFree ? '' : widget.event.cost.toString());

    // Initialize form values
    _eventType = widget.event.eventType;
    _eventSize = widget.event.eventSize;
    _eventDuration = widget.event.eventDuration;
    _eventDate = widget.event.eventDate;
    _requiresRegistration = widget.event.requiresRegistration;
    _targetAudience = List<String>.from(widget.event.targetAudience);
    _isFree = widget.event.isFree;

    // Initialize location data
    _latitude = widget.event.latitude;
    _longitude = widget.event.longitude;

    // Initialize existing image URL
    _existingImageUrl = widget.event.imageUrl;

    // Initialize new fields
    _eventTime = widget.event.eventTime;
    if (widget.event.registrationLink != null) {
      _registrationLinkController.text = widget.event.registrationLink!;
    }
    _hostNameController.text = widget.event.hostName;
    _hostPhoneController.text = widget.event.hostPhone;
    _hostEmailController.text = widget.event.hostEmail;
  }

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
        _imageChanged = true;
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
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Use reverse geocoding to get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Format address with available components
          String address = '';

          if (place.street != null && place.street!.isNotEmpty) {
            address += place.street!;
          }

          if (place.locality != null && place.locality!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.locality!;
          }

          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.subAdministrativeArea!;
          }

          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.administrativeArea!;
          }

          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            if (address.isNotEmpty) address += ' ';
            address += place.postalCode!;
          }

          setState(() {
            _locationController.text =
                address.isNotEmpty ? address : "Current Location";
            _isLoading = false;
          });
        } else {
          setState(() {
            _locationController.text =
                "Location Found (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error getting place name: $e");
        setState(() {
          _locationController.text =
              "Location Found (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload image to Firebase Storage if changed
  Future<String?> _uploadImage() async {
    if (!_imageChanged) return _existingImageUrl;
    if (_selectedImage == null) return _existingImageUrl;

    try {
      final String fileName = 'event_images/${Uuid().v4()}.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(_selectedImage!);
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return _existingImageUrl;
    }
  }

  // Update event in Firestore
  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      String? imageUrl = await _uploadImage();

      // Update event object
      final updatedEvent = EventModel(
        id: widget.event.id,
        name: _nameController.text,
        description: _descriptionController.text,
        eventType: _eventType,
        eventSize: _eventSize,
        eventDuration: _eventDuration,
        eventDate: _eventDate,
        eventTime: _eventTime, // Add event time
        location: _locationController.text,
        locationLink: _locationLinkController.text.isEmpty
            ? null
            : _locationLinkController.text,
        requiresRegistration: _requiresRegistration,
        registrationLink: _requiresRegistration
            ? _registrationLinkController.text
            : null, // Add registration link
        targetAudience: _targetAudience,
        isFree: _isFree,
        cost: _isFree ? 0 : (double.tryParse(_costController.text) ?? 0),
        creatorId: widget.event.creatorId,
        imageUrl: imageUrl,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: widget.event.createdAt,
        hostName: _hostNameController.text, // Add host name
        hostPhone: _hostPhoneController.text, // Add host phone
        hostEmail: _hostEmailController.text, // Add host email
      );

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update(updatedEvent.toFirestore());

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      print("Error updating event: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating event: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Event',
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ))
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
                            : _existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _existingImageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: AppTheme.primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Update Event Image',
                                          style: GoogleFonts.aBeeZee(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
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
                        hintStyle: GoogleFonts.aBeeZee(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.aBeeZee(
                        color: Colors.black,
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
                        hintStyle: GoogleFonts.aBeeZee(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.aBeeZee(
                        color: Colors.black,
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
                          color: Colors.black,
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
                                selectedColor: AppTheme.primaryColor,
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
                          color: Colors.black,
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
                                selectedColor: AppTheme.primaryColor,
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
                          color: Colors.black,
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
                                selectedColor: AppTheme.primaryColor,
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
                              hintStyle: GoogleFonts.aBeeZee(
                                color: Colors.grey[600],
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.my_location,
                                  color: AppTheme.primaryColor,
                                ),
                                onPressed: _getCurrentLocation,
                              ),
                            ),
                            style: GoogleFonts.aBeeZee(
                              color: Colors.black,
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
                        hintStyle: GoogleFonts.aBeeZee(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.aBeeZee(
                        color: Colors.black,
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
                              color: Colors.black,
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
                          activeColor: AppTheme.primaryColor,
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
                          color: Colors.black,
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
                                selectedColor: AppTheme.primaryColor,
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.black,
                          ),
                          child: Radio(
                            value: true,
                            groupValue: _isFree,
                            onChanged: (bool? value) {
                              setState(() {
                                _isFree = value!;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                        ),
                        Text(
                          'Free',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.black,
                          ),
                          child: Radio(
                            value: false,
                            groupValue: _isFree,
                            onChanged: (bool? value) {
                              setState(() {
                                _isFree = value!;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                        ),
                        Text(
                          'Paid',
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
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
                          hintStyle: GoogleFonts.aBeeZee(
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Colors.grey,
                          ),
                        ),
                        style: GoogleFonts.aBeeZee(
                          color: Colors.black,
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

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Update Event',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.londrinaSolid(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
