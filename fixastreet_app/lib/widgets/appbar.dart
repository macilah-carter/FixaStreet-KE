import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: const Text(
          'Fix A Street\n Community reporting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page or show notifications
            },
          ),
        ],
      );
  }
}