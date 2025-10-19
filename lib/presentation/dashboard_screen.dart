// lib/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'widgets/check_in_card.dart';
import 'widgets/history_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        elevation: 0,
      ),
      body: Column(
        children: [
           const CheckInCard(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const HistoryPanel(days: 30),
            ),
          ),
        ],
      ),
    );
  }
}
