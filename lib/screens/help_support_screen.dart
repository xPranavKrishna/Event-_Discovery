import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_lister/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'eventhorizon.connect@gmail.com',
      queryParameters: {
        'subject': 'Support Request - Event Lister App',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      // Handle error
      debugPrint('Error launching email: $e');
    }
  }

  Future<void> _openFAQDetails(
      BuildContext context, String title, String content) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.londrinaSolid(
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.londrinaSolid(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
          'Help & Support',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildHelpSection(
                'Frequently Asked Questions', _buildFAQs(context)),
            _buildHelpSection('Contact Us', _buildContactOptions()),
            _buildHelpSection('About Event Lister', _buildAboutSection()),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            'How can we help you?',
            style: GoogleFonts.londrinaSolid(
              textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Find answers to common questions or reach out to our team for assistance',
              style: GoogleFonts.londrinaSolid(
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title,
              style: GoogleFonts.londrinaSolid(
                textStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildFAQs(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I create an event?',
        'answer':
            'To create a new event, navigate to the home screen and tap on the "+" button located at the bottom of the screen. This will take you to the event creation form where you can fill in all the details about your event, including title, description, date, time, location, and more. Once you\'ve filled in all the required information, tap "Create Event" to publish your event.'
      },
      {
        'question': 'How do I join an event?',
        'answer':
            'To join an event, find an event you\'re interested in on the Discover screen or through the search function. Open the event details by tapping on it, then scroll down and tap the "Join Event" button. You\'ll receive a confirmation and the event will be added to your list of events you\'re attending.'
      },
      {
        'question': 'Can I edit or cancel my event?',
        'answer':
            'Yes, you can edit or cancel events that you\'ve created. Go to your profile page, tap on "My Events," then select the event you want to modify. On the event details screen, you\'ll find options to edit or cancel the event. Please note that if people have already joined your event, they will be notified of any changes or cancellations.'
      },
      {
        'question': 'How do I update my profile?',
        'answer':
            'To update your profile information, go to your profile page by tapping on the profile icon in the bottom navigation bar. Then tap on the "Edit Profile" button. Here you can change your display name, bio, location, and profile picture. After making your changes, tap "Save" to update your profile.'
      },
      {
        'question': 'Is there a limit to how many events I can create?',
        'answer':
            'Currently, there is no limit to the number of events you can create with our standard account. However, we recommend creating events only when you\'re committed to hosting them to maintain a quality experience for all users.'
      },
    ];

    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
        ),
        itemBuilder: (context, index) {
          return _buildFAQItem(
            context,
            faqs[index]['question'] ?? '',
            faqs[index]['answer'] ?? '',
          );
        },
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return InkWell(
      onTap: () => _openFAQDetails(context, question, answer),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question,
                style: GoogleFonts.londrinaSolid(
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
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

  Widget _buildContactOptions() {
    return Container(
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
          InkWell(
            onTap: _launchEmail,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'eventhorizon.connect@gmail.com',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () {
              // This would typically open an in-app chat or feedback form
              // For now, we'll show a dialog
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Send Feedback',
                    style: GoogleFonts.londrinaSolid(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  content: Text(
                    'This feature is coming soon! Please use email support for now.',
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
                        'OK',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.feedback_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Feedback',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help us improve the app',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () {
              // This would open a help center or knowledge base
              // For now, we'll show a dialog
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Help Center',
                    style: GoogleFonts.londrinaSolid(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  content: Text(
                    'Our detailed help center is coming soon! Please check back later.',
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
                        'OK',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.help_center_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help Center',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Browse our knowledge base',
                          style: GoogleFonts.londrinaSolid(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.event,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Lister',
                      style: GoogleFonts.londrinaSolid(
                        textStyle: TextStyle(
                          fontSize: 22,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: GoogleFonts.londrinaSolid(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Event Lister connects people through shared experiences. Our platform makes it easy to discover, create, and join events in your community.',
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAboutButton(
                icon: Icons.star_border,
                label: 'Rate App',
                onTap: () {
                  // This would open the app store for rating
                  showDialog(
                    context: navigatorKey.currentContext!,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Rate App',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Text(
                        'This feature will open your app store. Not implemented in this demo.',
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
                            'OK',
                            style: GoogleFonts.londrinaSolid(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
              _buildAboutButton(
                icon: Icons.share_outlined,
                label: 'Share App',
                onTap: () {
                  // This would open the share dialog
                  showDialog(
                    context: navigatorKey.currentContext!,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Share App',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Text(
                        'This feature will open your device\'s share dialog. Not implemented in this demo.',
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
                            'OK',
                            style: GoogleFonts.londrinaSolid(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
              _buildAboutButton(
                icon: Icons.description_outlined,
                label: 'Terms',
                onTap: () {
                  // This would open the terms and conditions
                  showDialog(
                    context: navigatorKey.currentContext!,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Text(
                        'Our terms and conditions would appear here. Not implemented in this demo.',
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
                            'OK',
                            style: GoogleFonts.londrinaSolid(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.londrinaSolid(
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this at top level in your main.dart file or in a separate globals.dart file
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
