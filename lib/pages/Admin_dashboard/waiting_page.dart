// lib/screens/waiting_page.dart

import 'package:flutter/material.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for Approval')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              '⏳ Your quiz has been submitted.\nWaiting for admin approval...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
