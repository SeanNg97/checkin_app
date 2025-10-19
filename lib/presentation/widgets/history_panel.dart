import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/checkin_manager.dart';
import '../../core/date_utils.dart';

class HistoryPanel extends StatelessWidget {
  final int days;
  const HistoryPanel({super.key, this.days = 30});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CheckInManager>();
    final today = DateTime.now();

    final List<DateTime> historyList = List.generate(
      days,
      (i) => today.subtract(Duration(days: i)),
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check-In History (Last $days Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
            ),
            const SizedBox(height: 4),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // History list
            Expanded(
              child: ListView.separated(
                itemCount: historyList.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final historyDay = historyList[index];
                  final checkInForDay = manager.checkInDates
                      .cast<DateTime?>()
                      .firstWhere(
                        (date) => AppDateUtils.isSameDay(date!, historyDay),
                        orElse: () => null,
                      );
                  final isCheckedIn = checkInForDay != null;

                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Icon(
                      isCheckedIn ? Icons.check_circle : Icons.cancel,
                      color: isCheckedIn ? Colors.green : Colors.redAccent,
                      size: 28,
                    ),
                    title: Text(
                      AppDateUtils.formatFullDate(historyDay),
                      style: TextStyle(
                        fontWeight:
                            isCheckedIn ? FontWeight.w600 : FontWeight.normal,
                        color: isCheckedIn
                            ? Colors.blueGrey.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                    subtitle: Text(
                      isCheckedIn
                          ? 'Checked in at ${AppDateUtils.formatTime(checkInForDay)}'
                          : 'Missed Day ❌',
                      style: TextStyle(
                        color: isCheckedIn
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
