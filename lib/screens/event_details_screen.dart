import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_lister/models/event_model.dart';
import 'package:maps_launcher/maps_launcher.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? Image.network(
                      event.imageUrl!,
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
                        event.eventType,
                        const Color(0xFF5E43C3).withOpacity(0.2),
                        const Color(0xFF5E43C3),
                      ),
                      const SizedBox(width: 10),
                      _buildTag(
                        event.isFree
                            ? 'Free'
                            : 'Paid: \$${event.cost?.toStringAsFixed(2)}',
                        event.isFree
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        event.isFree ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Event Name
                  Text(
                    event.name,
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
                    DateFormat('EEEE, MMM dd, yyyy').format(event.eventDate),
                  ),

                  const SizedBox(height: 5),

                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    DateFormat('h:mm a').format(event.eventDate),
                  ),

                  const SizedBox(height: 5),

                  _buildInfoRow(
                    Icons.timelapse,
                    'Duration',
                    event.eventDuration,
                  ),

                  const SizedBox(height: 20),

                  // Location with Map Option
                  _buildLocationSection(event),

                  const SizedBox(height: 20),

                  // Registration Info
                  _buildRegistrationSection(event),

                  const SizedBox(height: 20),

                  // Event Size
                  _buildInfoRow(
                    Icons.people,
                    'Event Size',
                    event.eventSize,
                  ),

                  const SizedBox(height: 20),

                  // Target Audience
                  _buildTargetAudienceSection(event),

                  const SizedBox(height: 20),

                  // Description Section
                  _buildSectionTitle('About This Event'),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: GoogleFonts.aBeeZee(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Posted Date
                  Text(
                    'Posted on ${DateFormat('MMM dd, yyyy').format(event.createdAt)}',
                    style: GoogleFonts.aBeeZee(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
      bottomNavigationBar: event.requiresRegistration
          ? Container(
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
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement registration logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration feature coming soon!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E43C3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  event.isFree ? 'Register Now' : 'Buy Tickets',
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
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
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
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
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.location,
                    style: GoogleFonts.aBeeZee(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
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
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
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
                    ),
                  ),
                ),
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
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                audience,
                style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
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
