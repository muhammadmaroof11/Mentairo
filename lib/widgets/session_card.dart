import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String status;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$date · $time', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: status == 'Upcoming'
                      ? Colors.deepPurple.shade100
                      : Colors.grey.shade300,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: onTap,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
