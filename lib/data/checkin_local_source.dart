import 'package:shared_preferences/shared_preferences.dart';

abstract class CheckInLocalSource {
  Future<List<DateTime>> getCheckInDates();
  Future<void> saveCheckInDates(List<DateTime> dates);
}

class CheckInLocalSourceImpl implements CheckInLocalSource {
  static const _checkInKey = 'checkInDates';

  @override
  Future<List<DateTime>> getCheckInDates() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? dateStrings = prefs.getStringList(_checkInKey);

    if (dateStrings == null) {
      return [];
    }
    
    // Convert strings to DateTime and filter out any parsing errors
    return dateStrings
        .map((s) => DateTime.tryParse(s))
        .whereType<DateTime>()
        .toList();
  }

  @override
  Future<void> saveCheckInDates(List<DateTime> dates) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert DateTime objects to ISO 8601 strings for storage
    final List<String> dateStrings =
        dates.map((date) => date.toIso8601String()).toList();
    await prefs.setStringList(_checkInKey, dateStrings);
  }
}