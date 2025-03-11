import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:event_lister/screens/create_event_screen.dart';
import 'package:event_lister/screens/profile_screen.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:event_lister/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = "Unknown Location";
  String _selectedCategory = "All";
  bool _isLoading = true;
  bool _isLocationPermissionDenied = false;
  List<EventModel> _events = [];
  final searchController = TextEditingController();
  final double _searchRadius = 10.0; // 10km radius
  Position? _userPosition;

  // List of available categories
  final List<String> _categories = [
    "All",
    "Festival",
    "Workshop",
    "Concert",
    "Sports"
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Show a dialog to explain why location permission is needed
  Future<void> _showLocationPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Permission',
            style: GoogleFonts.aBeeZee(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Gatherup needs location access to show you nearby events. Without location permission, you may not see all available events in your area.',
                  style: GoogleFonts.aBeeZee(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Continue without location',
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLocationPermissionDenied = true;
                  _isLoading = false;
                });
                fetchEvents();
              },
            ),
            TextButton(
              child: Text(
                'Grant permission',
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    color: Color(0xFF5E43C3),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
            ),
          ],
        );
      },
    );
  }

  // Open app settings to allow the user to enable location permissions
  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Please enable location permission in settings and come back'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true; // Set loading to true while requesting permission
    });

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      setState(() {
        _isLocationPermissionDenied = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location permission denied. Some features will be limited.'),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _determinePosition,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      fetchEvents();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationPermissionDenied = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location permission permanently denied. Please enable in settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: _openAppSettings,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      fetchEvents();
    } else {
      // Permission granted, get position
      _getCurrentPosition();
    }
  }

  // Get current position after permission is granted
  Future<void> _getCurrentPosition() async {
    try {
      // Set loading state to true
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _userPosition = position;
        _isLocationPermissionDenied = false;
      });

      // Add geocoding to get the location name
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _currentLocation = place.locality ??
                place.subAdministrativeArea ??
                place.administrativeArea ??
                "Unknown Location";
          });
        }
      } catch (e) {
        print('Error getting location name: $e');
        // Keep the default location name if geocoding fails
      }

      fetchEvents();
    } catch (e) {
      print('Error getting position: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
      fetchEvents();
    }
  }

  // Get user's current position
  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                  'Please enable location services to see nearby events.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isLocationPermissionDenied = true;
                    });
                    fetchEvents();
                  },
                ),
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openLocationSettings();
                    // Check again after returning from settings
                    if (mounted) {
                      _determinePosition();
                    }
                  },
                ),
              ],
            );
          },
        );
      }
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show dialog explaining why we need location
      _showLocationPermissionDialog();
      return;
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationPermissionDenied = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location permissions permanently denied. Please enable them in settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: _openAppSettings,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      fetchEvents();
      return;
    }

    // Permission is granted, get position
    _getCurrentPosition();
  }

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all events
      QuerySnapshot eventSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      List<EventModel> events = [];

      for (var doc in eventSnapshot.docs) {
        EventModel event = EventModel.fromFirestore(doc);

        // If user position is available and event has location, filter by distance
        if (_userPosition != null &&
            event.latitude != null &&
            event.longitude != null) {
          double distance = Geolocator.distanceBetween(
                _userPosition!.latitude,
                _userPosition!.longitude,
                event.latitude!,
                event.longitude!,
              ) /
              1000; // Convert to kilometers

          // Only add events within the search radius
          if (distance <= _searchRadius) {
            events.add(event);
          }
        } else {
          // If no location data available (either user or event), add it anyway
          events.add(event);
        }
      }

      if (!mounted) return;

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching events: ${e.toString()}')),
      );
    }
  }

  // Filter events by category
  List<EventModel> getFilteredEvents() {
    if (_selectedCategory == "All") {
      return _events;
    } else {
      return _events
          .where((event) => event.eventType == _selectedCategory)
          .toList();
    }
  }

  // Search events by name
  List<EventModel> getSearchedEvents(List<EventModel> filteredEvents) {
    final String searchTerm = searchController.text.toLowerCase().trim();
    if (searchTerm.isEmpty) {
      return filteredEvents;
    } else {
      return filteredEvents
          .where((event) =>
              event.name.toLowerCase().contains(searchTerm) ||
              (event.description.toLowerCase().contains(searchTerm)))
          .toList();
    }
  }

  // Refresh location and events
  void _refreshLocation() {
    if (_isLocationPermissionDenied) {
      _determinePosition(); // This will trigger the permission flow
    } else {
      // Just refresh current location without triggering full permission flow
      _getCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = getFilteredEvents();
    final searchedEvents = getSearchedEvents(filteredEvents);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with Logo and Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Text(
                    'Gatherup',
                    style: GoogleFonts.lobsterTwo(
                      textStyle: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF5E43C3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Location
                  InkWell(
                    onTap: _refreshLocation,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isLocationPermissionDenied
                            ? Colors.red.withOpacity(0.1)
                            : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLocationPermissionDenied
                                ? Icons.location_disabled
                                : Icons.location_on,
                            size: 20,
                            color: _isLocationPermissionDenied
                                ? Colors.red
                                : const Color(0xFF5E43C3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentLocation,
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: _isLocationPermissionDenied
                                    ? Colors.red
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.refresh,
                            size: 14,
                            color: _isLocationPermissionDenied
                                ? Colors.red
                                : const Color(0xFF5E43C3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location permission banner when denied
            if (_isLocationPermissionDenied)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Location permission is required to see nearby events. Some events may not be shown.',
                        style: GoogleFonts.aBeeZee(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _determinePosition,
                      child: Text(
                        'Enable',
                        style: GoogleFonts.aBeeZee(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Events...',
                  hintStyle: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(
                      0xFFF1F0F5), // Background color inside input box
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(70), // Rounded input box
                    borderSide: BorderSide.none, // No border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(70),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(70),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Category Filters
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: _selectedCategory == _categories[index],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = _categories[index];
                          });
                        }
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFF5E43C3),
                      labelStyle: TextStyle(
                        color: _selectedCategory == _categories[index]
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Events List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Color(0xFF5E43C3),
                    ))
                  : searchedEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.event_busy,
                                size: 70,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No events found',
                                style: GoogleFonts.aBeeZee(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _isLocationPermissionDenied
                                    ? 'Enable location to see more events'
                                    : 'Try changing filters or be the first to create one!',
                                style: GoogleFonts.aBeeZee(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // REDUCED BUTTON SIZE HERE
                              ElevatedButton(
                                onPressed: _refreshLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5E43C3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  minimumSize: const Size(120, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        _isLocationPermissionDenied
                                            ? Icons.location_on
                                            : Icons.refresh,
                                        color: Colors.white,
                                        size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isLocationPermissionDenied
                                          ? 'Enable Location'
                                          : 'Refresh',
                                      style: GoogleFonts.aBeeZee(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchedEvents.length,
                          padding: const EdgeInsets.all(20),
                          itemBuilder: (context, index) {
                            return EventCard(event: searchedEvents[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        // Updated container with the matching background color
        color: const Color(0xFFF2F2F2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomAppBar(
              elevation: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, size: 30),
                      color: const Color(0xFF5E43C3),
                      onPressed: () {
                        // Already on home page
                      },
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventScreen(),
                          ),
                        ).then((_) =>
                            fetchEvents()); // Refresh events after returning
                      },
                      backgroundColor: const Color(0xFF5E43C3),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, size: 30),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // This container ensures background extends below the navigation bar
            // Updated the color to match the bottom navigation color
            Container(
              height: MediaQuery.of(context).padding.bottom,
              color: const Color(0xFFF2F2F2),
            )
          ],
        ),
      ),
    );
  }
}
