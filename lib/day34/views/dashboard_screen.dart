import 'package:flutter/material.dart';

class DashboardPageDay34 extends StatefulWidget {
  const DashboardPageDay34({super.key});

  @override
  State<DashboardPageDay34> createState() => _DashboardPageDay34State();
}

class _DashboardPageDay34State extends State<DashboardPageDay34> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF312E81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            "DASHBOARD DAY 34",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
