// lib/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../domain/checkin_manager.dart';
import '../core/date_utils.dart' as app_utils; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Helper to show a snackbar message
  void _showSnackbar(BuildContext context, String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper to format the date
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  // Helper to format the time
  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // 1. CONSUME STATE
    final manager = context.watch<CheckInManager>();
    final hasCheckedIn = manager.hasCheckedInToday();
    final latestCheckIn = manager.checkInDates.isNotEmpty ? manager.checkInDates.first : null;
    final currentStreak = manager.currentStreak;

    // 2. HISTORY DATA PREP
    const int historyDays = 30;
    final today = DateTime.now();
    List<DateTime> historyList = [];
    for (int i = 0; i < historyDays; i++) {
      // Create a list of the last 30 calendar days
      historyList.add(today.subtract(Duration(days: i)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        elevation: 0,
      ),
      body: ListView( // Use a simple ListView for the entire scrollable content
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // ------------------------------------------------------------------
          // 1. CHECK-IN CARD (Status, Streak, Button)
          // ------------------------------------------------------------------
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // STREAK DISPLAY
                  Text(
                    '🔥 Current Streak: $currentStreak Days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  // STATUS TEXT
                  Text(
                    hasCheckedIn ? '🎉 Checked In Today!' : '⏳ Waiting for Check-In',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasCheckedIn ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // CHECK-IN TIME
                  if (hasCheckedIn && latestCheckIn != null)
                    Text(
                      'Time: ${_formatTime(latestCheckIn)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 25),

                  // CHECK-IN BUTTON
                  ElevatedButton.icon(
                    onPressed: hasCheckedIn
                        ? null // Disable button if already checked in
                        : () async {
                            final checkInTime = await context.read<CheckInManager>().checkIn();
                            if (checkInTime != null) {
                              _showSnackbar(context, 'Check-In Successful!', isSuccess: true);
                            }
                          },
                    icon: const Icon(Icons.done_all),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        hasCheckedIn ? 'CHECKED IN' : 'CHECK IN NOW',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCheckedIn ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // ------------------------------------------------------------------
          // 2. HISTORY TITLE
          // ------------------------------------------------------------------
          Text(
            'Check-In History (Last $historyDays Days)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),

          // ------------------------------------------------------------------
          // 3. HISTORY LIST
          // ------------------------------------------------------------------
          // Use the historyList generated above to render the 30-day view
          ...historyList.map((historyDay) {
            // Find if a check-in exists for this calendar day
            final checkInForDay = manager.checkInDates.cast<DateTime?>().firstWhere(
              // Use the AppDateUtils to compare days reliably
              (date) => DateUtils.isSameDay(date!, historyDay),
              orElse: () => null,
            );
            final isCheckedIn = checkInForDay != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: ListTile(
                title: Text(
                  _formatDate(historyDay),
                  style: TextStyle(fontWeight: isCheckedIn ? FontWeight.bold : FontWeight.normal),
                ),
                subtitle: Text(
                  isCheckedIn
                      ? 'Checked In at ${_formatTime(checkInForDay!)}'
                      : 'Missed Day ❌',
                  style: TextStyle(
                    color: isCheckedIn ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                leading: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.cancel,
                  color: isCheckedIn ? Colors.green : Colors.red,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}