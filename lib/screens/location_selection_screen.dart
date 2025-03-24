import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// Location result model to store more detailed information
class LocationResult {
  final String displayName;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  LocationResult({
    required this.displayName,
    this.placeId,
    this.latitude,
    this.longitude,
  });
}

class LocationSelectionScreen extends StatefulWidget {
  final String currentLocation;
  final Function(String, double?, double?) onLocationSelected;

  const LocationSelectionScreen({
    Key? key,
    required this.currentLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<String> _popularCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow'
  ];
  List<String> _recentLocations = [];
  List<LocationResult> _searchResults = [];
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load recent locations from shared preferences or local storage
  Future<void> _loadRecentLocations() async {
    // Ideally, load from shared preferences
    // For demo purposes, we'll use some static values
    setState(() {
      _recentLocations = [widget.currentLocation];
      if (widget.currentLocation != 'Unknown Location' &&
          !_popularCities.contains(widget.currentLocation)) {
        _recentLocations.add(widget.currentLocation);
      }
    });
  }

  // Save a location to recent locations
  Future<void> _saveLocationToRecent(String location) async {
    if (location.isNotEmpty &&
        location != 'Unknown Location' &&
        !_recentLocations.contains(location)) {
      setState(() {
        _recentLocations.insert(0, location);
        if (_recentLocations.length > 5) {
          _recentLocations.removeLast();
        }
      });
      // Save to shared preferences in a real implementation
    }
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission permanently denied'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "Unknown Location";

        _saveLocationToRecent(location);
        widget.onLocationSelected(
            location, position.latitude, position.longitude);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Updated: Search for locations using OpenCage Geocoder API
  Future<void> _searchLocations(String query) async {
    setState(() {
      _searchError = null;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiKey = dotenv.env['OPENCAGE_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        throw Exception('OpenCage API key not configured');
      }

      // Make API request to OpenCage
      final response = await http.get(
        Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=$query&key=$apiKey&limit=10',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the API returned successfully
        if (data['status']?['code'] != 200) {
          throw Exception(
              'API Error: ${data['status']?['code']} - ${data['status']?['message'] ?? 'Unknown error'}');
        }

        List<LocationResult> results = [];

        if (data['results'] != null) {
          for (var result in data['results']) {
            // Extract formatted display name directly without using unused components variable
            String displayName = result['formatted'] ?? 'Unknown Location';

            // Extract coordinates
            final geometry = result['geometry'];
            final double? lat = geometry != null ? geometry['lat'] : null;
            final double? lng = geometry != null ? geometry['lng'] : null;

            results.add(LocationResult(
              displayName: displayName,
              placeId: result['annotations']
                  ?['geohash'], // Using geohash as a unique identifier
              latitude: lat,
              longitude: lng,
            ));
          }
        }

        setState(() {
          _searchResults = results;
          // Show a message if no results found
          if (results.isEmpty) {
            _searchError = 'No locations found for "$query"';
          }
        });
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _searchError = 'Error searching locations: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching locations: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Simplified: No need for separate details call with OpenCage as we get all data in one request
  // Instead, we'll implement a reverse geocoding method if needed
  Future<LocationResult> _reverseGeocode(
      double latitude, double longitude) async {
    final String apiKey = dotenv.env['OPENCAGE_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('OpenCage API key not configured');
    }

    final response = await http.get(
      Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey&no_annotations=1',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status']?['code'] != 200) {
        throw Exception(
            'API Error: ${data['status']?['code']} - ${data['status']?['message'] ?? 'Unknown error'}');
      }

      if (data['results'] != null && data['results'].isNotEmpty) {
        final result = data['results'][0];
        String displayName = result['formatted'] ?? 'Unknown Location';

        return LocationResult(
          displayName: displayName,
          placeId: result['annotations']?['geohash'],
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        return LocationResult(
          displayName: 'Location at $latitude, $longitude',
          latitude: latitude,
          longitude: longitude,
        );
      }
    } else {
      throw Exception('Failed to reverse geocode: ${response.statusCode}');
    }
  }

  // Select a location and return to previous screen
  void _selectLocation(String location, {double? latitude, double? longitude}) {
    _saveLocationToRecent(location);
    widget.onLocationSelected(location, latitude, longitude);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for any location...',
                  hintStyle: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _searchError = null;
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                onChanged: _searchLocations,
              ),
            ),

            // Use Current Location Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: _getCurrentLocation,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF5E43C3)),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: Color(0xFF5E43C3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Use Current Location',
                        style: GoogleFonts.aBeeZee(
                          textStyle: const TextStyle(
                            color: Color(0xFF5E43C3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5E43C3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Show search results or recent/popular locations
            Expanded(
              child: Container(
                color: Colors.white,
                child: _isLoading && _searchResults.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isNotEmpty
                        ? _buildLocationList(
                            'Search Results',
                            _searchResults,
                          )
                        : _searchError != null
                            ? Center(
                                child: Text(
                                  _searchError!,
                                  style: GoogleFonts.aBeeZee(
                                    textStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_recentLocations.isNotEmpty)
                                      _buildLocationList(
                                        'Recent Locations',
                                        _recentLocations,
                                      ),
                                    _buildLocationList(
                                      'Popular Cities in India',
                                      _popularCities,
                                    ),
                                  ],
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to handle both simple strings and LocationResult objects
  Widget _buildLocationList(String title, List<dynamic> locations) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              title,
              style: GoogleFonts.aBeeZee(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final String displayText = location is LocationResult
                  ? location.displayName
                  : location.toString();

              String? subtitle;
              if (location is LocationResult) {
                if (location.latitude != null && location.longitude != null) {
                  subtitle =
                      'Lat: ${location.latitude?.toStringAsFixed(4)}, Lng: ${location.longitude?.toStringAsFixed(4)}';
                }
              }

              return Container(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    displayText,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  subtitle: subtitle != null
                      ? Text(
                          subtitle,
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : null,
                  onTap: () async {
                    if (location is LocationResult) {
                      _selectLocation(
                        location.displayName,
                        latitude: location.latitude,
                        longitude: location.longitude,
                      );
                    } else {
                      // For simple strings like popular cities, we need to geocode them
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        // Search for the location to get coordinates
                        final response = await http.get(
                          Uri.parse(
                            'https://api.opencagedata.com/geocode/v1/json?q=${location.toString()}&key=${dotenv.env['OPENCAGE_API_KEY'] ?? ''}&limit=1',
                          ),
                        );

                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          if (data['results'] != null &&
                              data['results'].isNotEmpty) {
                            final result = data['results'][0];
                            final geometry = result['geometry'];

                            _selectLocation(
                              location.toString(),
                              latitude: geometry?['lat'],
                              longitude: geometry?['lng'],
                            );
                          } else {
                            _selectLocation(location.toString());
                          }
                        } else {
                          _selectLocation(location.toString());
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error getting coordinates: ${e.toString()}')),
                        );
                        _selectLocation(location.toString());
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
