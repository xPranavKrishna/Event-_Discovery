import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isInterested = false;
  int _interestedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterestedStatus();
  }

  Future<void> _fetchInterestedStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _interestedCount = widget.event.interestedCount;
          _isLoading = false;
        });
        return;
      }

      // Get event document
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();

      if (!eventDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get the list of interested users
      final data = eventDoc.data() as Map<String, dynamic>;
      final List<String> interestedUsers =
          List<String>.from(data['interestedUsers'] ?? []);
      final int interestedCount =
          data['interestedCount'] ?? interestedUsers.length;

      setState(() {
        _isInterested = interestedUsers.contains(userId);
        _interestedCount = interestedCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching interested status: $e');
      setState(() {
        _interestedCount = widget.event.interestedCount;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInterested() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to mark interest in events'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Reference to the event document
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      // Update the interested status
      if (_isInterested) {
        // Remove interest
        await eventRef.update({
          'interestedUsers': FieldValue.arrayRemove([userId]),
          'interestedCount': FieldValue.increment(-1),
        });
        setState(() {
          _isInterested = false;
          _interestedCount--;
        });
      } else {
        // Add interest
        await eventRef.update({
          'interestedUsers': FieldValue.arrayUnion([userId]),
          'interestedCount': FieldValue.increment(1),
        });
        setState(() {
          _isInterested = true;
          _interestedCount++;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error toggling interested status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update interested status'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchRegistrationLink() async {
    if (widget.event.registrationLink == null ||
        widget.event.registrationLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration link not available'),
        ),
      );
      return;
    }

    try {
      if (await canLaunch(widget.event.registrationLink!)) {
        await launch(widget.event.registrationLink!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch registration link'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error launching registration link'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF5E43C3),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl != null &&
                      widget.event.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.event.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Type & Free/Paid Tags
                  Row(
                    children: [
                      _buildTag(
                        widget.event.eventType,
                        const Color(0xFF5E43C3).withOpacity(0.2),
                        const Color(0xFF5E43C3),
                      ),
                      const SizedBox(width: 10),
                      _buildTag(
                        widget.event.isFree
                            ? 'Free'
                            : 'Paid: ₹${widget.event.cost.toStringAsFixed(2)}',
                        widget.event.isFree
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        widget.event.isFree ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Event Name
                  Text(
                    widget.event.name,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Date, Time, and Duration
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date & Time',
                    DateFormat('EEEE, MMM dd, yyyy')
                        .format(widget.event.eventDate),
                  ),

                  const SizedBox(height: 5),

                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    DateFormat('h:mm a').format(widget.event.eventDate),
                  ),

                  const SizedBox(height: 5),

                  _buildInfoRow(
                    Icons.timelapse,
                    'Duration',
                    widget.event.eventDuration,
                  ),

                  const SizedBox(height: 20),

                  // Location with Map Option
                  _buildLocationSection(widget.event),

                  const SizedBox(height: 20),

                  // Registration Info
                  _buildRegistrationSection(widget.event),

                  const SizedBox(height: 20),

                  // Host Information - New Section
                  _buildHostSection(widget.event),

                  const SizedBox(height: 20),

                  // Event Size
                  _buildInfoRow(
                    Icons.people,
                    'Event Size',
                    widget.event.eventSize,
                  ),

                  const SizedBox(height: 20),

                  // Target Audience
                  _buildTargetAudienceSection(widget.event),

                  const SizedBox(height: 20),

                  // Description Section
                  _buildSectionTitle('About This Event'),
                  const SizedBox(height: 10),
                  Text(
                    widget.event.description,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Posted Date
                  Text(
                    'Posted on ${DateFormat('MMM dd, yyyy').format(widget.event.createdAt)}',
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                    color: Color(0xFF5E43C3),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$_interestedCount interested',
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  // Interested Button
                  Expanded(
                    flex: widget.event.requiresRegistration &&
                            widget.event.registrationLink != null &&
                            widget.event.registrationLink!.isNotEmpty
                        ? 1
                        : 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _toggleInterested,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isInterested
                            ? Colors.grey[300]
                            : const Color(0xFF5E43C3),
                        foregroundColor:
                            _isInterested ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isInterested
                                      ? Icons.check
                                      : Icons.star_border,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isInterested ? 'Interested' : 'Interested',
                                  style: GoogleFonts.aBeeZee(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF5E43C3),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.aBeeZee(
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLocationSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on,
              size: 18,
              color: Color(0xFF5E43C3),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.location,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Location Actions
        Row(
          children: [
            if (event.locationLink != null && event.locationLink!.isNotEmpty)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (await canLaunch(event.locationLink!)) {
                      await launch(event.locationLink!);
                    }
                  },
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Open Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E43C3),
                    side: const BorderSide(color: Color(0xFF5E43C3)),
                  ),
                ),
              ),
            if (event.locationLink != null &&
                event.locationLink!.isNotEmpty &&
                event.latitude != null &&
                event.longitude != null)
              const SizedBox(width: 10),
            if (event.latitude != null && event.longitude != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    MapsLauncher.launchCoordinates(
                      event.latitude!,
                      event.longitude!,
                      event.location,
                    );
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View Map'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E43C3),
                    side: const BorderSide(color: Color(0xFF5E43C3)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Updated Registration Section with Registration Link
  Widget _buildRegistrationSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              event.requiresRegistration
                  ? Icons.how_to_reg
                  : Icons.event_available,
              size: 18,
              color: const Color(0xFF5E43C3),
            ),
            const SizedBox(width: 10),
            Text(
              'Registration',
              style: GoogleFonts.aBeeZee(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                event.requiresRegistration ? Icons.check_circle : Icons.info,
                color: event.requiresRegistration ? Colors.green : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.requiresRegistration
                      ? event.isFree
                          ? 'Registration required to attend this event'
                          : 'Tickets required to attend this event'
                      : 'No registration required. Just show up!',
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Registration Link - Display only if event requires registration and link exists
        if (event.requiresRegistration &&
            event.registrationLink != null &&
            event.registrationLink!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                if (await canLaunch(event.registrationLink!)) {
                  await launch(event.registrationLink!);
                }
              },
              icon: const Icon(Icons.link, size: 16),
              label: const Text('Registration Link'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
            ),
          ),
      ],
    );
  }

  // New Host Section
  Widget _buildHostSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Host'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 18,
                    color: Color(0xFF5E43C3),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    event.hostName,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email,
                    size: 16,
                    color: Color(0xFF5E43C3),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: event.hostEmail,
                        );
                        if (await canLaunch(emailUri.toString())) {
                          await launch(emailUri.toString());
                        }
                      },
                      child: Text(
                        event.hostEmail,
                        style: GoogleFonts.aBeeZee(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5E43C3),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: Color(0xFF5E43C3),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final Uri telUri = Uri(
                        scheme: 'tel',
                        path: event.hostPhone,
                      );
                      if (await canLaunch(telUri.toString())) {
                        await launch(telUri.toString());
                      }
                    },
                    child: Text(
                      event.hostPhone,
                      style: GoogleFonts.aBeeZee(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5E43C3),
                          decoration: TextDecoration.underline,
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
    );
  }

  Widget _buildTargetAudienceSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.group,
              size: 18,
              color: Color(0xFF5E43C3),
            ),
            const SizedBox(width: 10),
            Text(
              'Target Audience',
              style: GoogleFonts.aBeeZee(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.targetAudience.map((audience) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                audience,
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
