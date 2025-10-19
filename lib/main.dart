import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/checkin_local_source.dart';
import 'domain/checkin_manager.dart';
import 'presentation/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prepare your dependencies
  final checkInLocalSource = CheckInLocalSourceImpl();
  final checkInManager = CheckInManager(checkInLocalSource);

  // Wait until the initial data finishes loading
  await checkInManager.loadInitialData();

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
