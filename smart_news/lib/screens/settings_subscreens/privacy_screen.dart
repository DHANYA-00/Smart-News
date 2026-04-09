import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Data policy goes here.'),
      ),
    );
  }
}
