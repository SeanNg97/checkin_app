import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/checkin_manager.dart';
import '../../core/date_utils.dart';

class CheckInCard extends StatelessWidget {
  const CheckInCard({super.key});

  void _showSnackbar(BuildContext context, String message, {bool isSuccess = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn = context.select<CheckInManager, bool>((m) => m.hasCheckedInToday());
    final latestCheckIn = context.select<CheckInManager, DateTime?>(
      (m) => m.checkInDates.isNotEmpty ? m.checkInDates.first : null,
    );
    final currentStreak = context.select<CheckInManager, int>((m) => m.currentStreak);

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasCheckedIn ? '✅ Checked In Today!' : '⏳ Waiting for Check-In',
              style: titleStyle,
            ),
            const SizedBox(height: 8),
            if (hasCheckedIn && latestCheckIn != null)
              Text(
                'Time: ${AppDateUtils.formatTime(latestCheckIn)}',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: hasCheckedIn
                  ? null
                  : () async {
                      final checkInTime = await context.read<CheckInManager>().checkIn();
                      if (checkInTime != null) {
                        _showSnackbar(context, 'Check-In Successful!');
                      }
                    },
              icon: const Icon(Icons.done_all),
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text(
                  hasCheckedIn ? 'CHECKED IN' : 'CHECK IN NOW',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasCheckedIn ? Colors.grey.shade300 : Colors.white,
                foregroundColor: hasCheckedIn ? Colors.black54 : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Streak: $currentStreak Days',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
