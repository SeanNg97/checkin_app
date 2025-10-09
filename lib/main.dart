// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/checkin_local_source.dart';
import 'domain/checkin_manager.dart';
import 'presentation/dashboard_screen.dart';

Future<void> main() async {
  // If your local source is synchronous (in-memory), you don't need `async`.
  // If it needs SharedPreferences (async creation) see the alternative below.
  final checkInLocalSource = CheckInLocalSourceImpl(); // <-- use Impl
  final checkInManager = CheckInManager(checkInLocalSource);

  runApp(
    ChangeNotifierProvider.value(
      value: checkInManager,
      child: const DailyCheckInApp(),
    ),
  );
}

class DailyCheckInApp extends StatelessWidget {
  const DailyCheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
