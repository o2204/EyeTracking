import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/profile_menu_item.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you are experiencing any issues or have questions, please reach out to us using the options below.',
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ProfileMenuItem(
              icon: Icons.chat,
              title: 'WhatsApp Contact',
              trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
              onTap: () => _launchUrl("https://wa.me/201009880994"),
            ),
            ProfileMenuItem(
              icon: Icons.email,
              title: 'Email Support',
              trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
              onTap: () => _launchUrl("mailto:o.atef35251@gmail.com"),
            ),
            const SizedBox(height: 32),
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ExpansionTile(
              title: Text('How does the eye tracking work?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('The application uses the front-facing camera to track your eye movements in real-time. It calibrates to your specific iris metrics to detect focal points on the screen.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('How do I redo calibration?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Currently, you can rerun setup from the main settings menu or directly from the smart home dashboard.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
