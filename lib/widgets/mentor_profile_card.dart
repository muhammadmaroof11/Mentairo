import 'package:flutter/material.dart';

class MentorProfileCard extends StatelessWidget {
  final String name;
  final String bio;
  final VoidCallback? onMessage;
  final VoidCallback? onBook;
  final VoidCallback? onTap;

  const MentorProfileCard({
    super.key,
    required this.name,
    required this.bio,
    this.onMessage,
    this.onBook,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity, // Prevent infinite width error
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(bio, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onMessage != null)
                      ElevatedButton(
                          onPressed: onMessage, child: const Text("Message")),
                    const SizedBox(width: 8),
                    if (onBook != null)
                      ElevatedButton(
                          onPressed: onBook, child: const Text("Book")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
