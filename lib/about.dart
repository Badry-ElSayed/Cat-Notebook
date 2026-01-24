import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// App Logo
            CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('images/logo.png'),
              // backgroundColor: Colors.green.shade100,
              // child: const Icon(Icons.note_alt, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 12),

            const Text(
              'Cat Notebook',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Simple & Secure Note Taking',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// About App
            _buildCard(
              title: 'About the App',
              icon: Icons.info_outline,
              child: const Text(
                'Cat Notebook App helps you write, organize, and save your notes easily. '
                'Your notes are stored securely and accessible anytime.',
                style: TextStyle(height: 1.5),
              ),
            ),

            /// Features
            _buildCard(
              title: 'Features',
              icon: Icons.star_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _FeatureItem('Add, edit and delete notes'),
                  _FeatureItem('Cloud sync using Firebase'),
                  _FeatureItem('Colorful notes'),
                  _FeatureItem('Clean & simple UI'),
                  _FeatureItem('Dark mode support'),
                ],
              ),
            ),

            /// Developer
            _buildCard(
              title: 'Developer',
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Badry Sayed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Flutter Developer'),
                ],
              ),
            ),

            /// Contact
            _buildCard(
              title: 'Contact Us',
              icon: Icons.contact_mail_outlined,
              child: Column(
                children: [
                  ListTile(
                    title: Text('badrysayed88@email.com'),
                    leading: FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.green,
                    ),
                  ),
                  ListTile(
                    title: Text('GitHub'),
                    leading: FaIcon(
                      FontAwesomeIcons.github,
                      color: Colors.green,
                    ),
                    onTap: () {
                      launchURL("https://github.com/Badry-ElSayed");
                    },
                  ),
                  ListTile(
                    title: Text('LinkedIn'),
                    leading: FaIcon(
                      FontAwesomeIcons.linkedin,
                      color: Colors.green,
                    ),
                    onTap: () async {
                      await launchURL(
                        'https://www.linkedin.com/in/badry-elsayed-794062337/',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
