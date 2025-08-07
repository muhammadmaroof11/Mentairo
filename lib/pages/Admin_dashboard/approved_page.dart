// lib/screens/approved_page.dart

import 'package:flutter/material.dart';

class ApprovedPage extends StatelessWidget {
  const ApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approved')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 64, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                '✅ Congratulations!\nYou have been approved by the admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.login),
                label: const Text('Go to Login Page', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              )
            ],
          ),
        ),
      ),
    );
  }
}
