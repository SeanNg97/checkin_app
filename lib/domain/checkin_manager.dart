import 'package:flutter/foundation.dart';
import '../data/checkin_local_source.dart';
import '../core/date_utils.dart';

class CheckInManager extends ChangeNotifier {
  final CheckInLocalSource _localSource;
  List<DateTime> _checkInDates = [];
  
  // Expose data via getters
  List<DateTime> get checkInDates => _checkInDates;

  // Constructor with dependency injection (senior TDD practice)
  CheckInManager(this._localSource) {
    _loadCheckInDates();
  }

    Future<void> loadInitialData() async {
    await _loadCheckInDates();
  }
  
  // --- Data Loading ---
  Future<void> _loadCheckInDates() async {
    _checkInDates = await _localSource.getCheckInDates();
    // Ensure data is sorted newest-first upon loading
    _checkInDates.sort((a, b) => b.compareTo(a));
    notifyListeners();
  }

    // History without today's check-in
  List<DateTime> get checkInHistory {
    final today = DateTime.now();
    return _checkInDates
        .where((date) => !AppDateUtils.isSameDay(date, today))
        .toList();
  }
  
  bool hasCheckedInToday() {
    final today = DateTime.now();
    return _checkInDates.any((date) => AppDateUtils.isSameDay(date, today));
  }

  Future<DateTime?> checkIn() async {
    if (hasCheckedInToday()) {
      return null;
    }

    final now = DateTime.now();
    _checkInDates.insert(0, now); // Add to the start (newest first)

    await _localSource.saveCheckInDates(_checkInDates);
    notifyListeners();

    return now;
  }
  
  // --- Streak Calculation Logic
  int get currentStreak {
    if (_checkInDates.isEmpty) {
      return 0;
    }

    // Use a set to get unique calendar days (midnight timestamp)
    final uniqueCheckInDays = _checkInDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort newest-first

    int streak = 0;
    DateTime expectedDay = DateTime.now();

    // Check if the latest day in the list is NOT today, and NOT yesterday.
    // This allows the streak to be calculated correctly even if today is missed.
    if (!AppDateUtils.isSameDay(uniqueCheckInDays.first, DateTime.now())) {
      // If the latest check-in day is not today, the streak calculation must
      // start from that last check-in day backwards.
      // Or, more simply: if today is missed, the streak ends yesterday.
      expectedDay = DateTime.now().subtract(const Duration(days: 1));
    }
    
    // Normalize to midnight for consistent comparison
    expectedDay = DateTime(expectedDay.year, expectedDay.month, expectedDay.day);

    for (final checkedDay in uniqueCheckInDays) {
      final normalizedCheckedDay = DateTime(checkedDay.year, checkedDay.month, checkedDay.day);
      
      if (AppDateUtils.isSameDay(normalizedCheckedDay, expectedDay)) {
        streak++;
        // Move to the previous day
        expectedDay = expectedDay.subtract(const Duration(days: 1));
      } else if (normalizedCheckedDay.isBefore(expectedDay)) {
        // Gap detected, streak broken
        break;
      }
    }

    return streak;
  }
}