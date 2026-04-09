import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text('About SmartNews')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Developer'),
            trailing: Text('Dhanya'),
          ),
          const ListTile(
            title: Text('Contact Email'),
            trailing: Text('support@smartnews.com'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Rate the app'),
          ),
        ],
      ),
    );
  }
}
