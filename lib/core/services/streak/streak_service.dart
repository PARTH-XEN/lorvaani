import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model representing user streak state
class StreakData {
  final int streakDays;
  final List<bool> activeDaysOfWeek; // Mon..Sun (length 7)
  final bool isFirstDay;

  const StreakData({
    required this.streakDays,
    required this.activeDaysOfWeek,
    this.isFirstDay = false,
  });
}

/// Service managing dynamic, date-based user study streaks.
class StreakService {
  static const _streakDaysPref = 'lorvani_streak_days';
  static const _lastActiveDatePref = 'lorvani_streak_last_date';
  static const _activeDaysPref = 'lorvani_streak_active_days_week';

  final SharedPreferences? _prefs;

  StreakService([this._prefs]);

  static Future<StreakService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StreakService(prefs);
  }

  /// Calculates the current streak and weekly activity status based on real calendar dates.
  StreakData getStreakData() {
    final now = DateTime.now();
    final todayWeekdayIndex = now.weekday - 1; // 0 = Mon, 6 = Sun

    final storedLastDate = _prefs?.getString(_lastActiveDatePref);
    final storedStreak = _prefs?.getInt(_streakDaysPref);

    // Default 7-day week representation (Mon..Sun)
    List<bool> activeDays = List.filled(7, false);

    // First time opening the app!
    if (storedLastDate == null || storedStreak == null) {
      activeDays[todayWeekdayIndex] = true;
      return StreakData(
        streakDays: 1,
        activeDaysOfWeek: activeDays,
        isFirstDay: true,
      );
    }

    // Parse last active date
    final parts = storedLastDate.split('-');
    if (parts.length != 3) {
      activeDays[todayWeekdayIndex] = true;
      return StreakData(streakDays: 1, activeDaysOfWeek: activeDays, isFirstDay: true);
    }

    final lastDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final todayDate = DateTime(now.year, now.month, now.day);
    final diffDays = todayDate.difference(lastDate).inDays;

    int currentStreak = storedStreak;

    // Load active days stored for current week
    final storedWeekDays = _prefs?.getStringList(_activeDaysPref);
    if (storedWeekDays != null && storedWeekDays.length == 7) {
      activeDays = storedWeekDays.map((e) => e == '1').toList();
    }

    if (diffDays == 0) {
      // Opened already today
      activeDays[todayWeekdayIndex] = true;
    } else if (diffDays == 1) {
      // Consecutive day! Streak continues
      currentStreak += 1;
      activeDays[todayWeekdayIndex] = true;
    } else {
      // Missed one or more days: reset to 1
      currentStreak = 1;
      activeDays = List.filled(7, false);
      activeDays[todayWeekdayIndex] = true;
    }

    return StreakData(
      streakDays: currentStreak,
      activeDaysOfWeek: activeDays,
      isFirstDay: currentStreak == 1 && diffDays != 0,
    );
  }

  /// Record activity for today and persist state.
  Future<void> recordActivityToday() async {
    if (_prefs == null) return;
    final data = getStreakData();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _prefs.setInt(_streakDaysPref, data.streakDays);
    await _prefs.setString(_lastActiveDatePref, todayStr);
    await _prefs.setStringList(
      _activeDaysPref,
      data.activeDaysOfWeek.map((b) => b ? '1' : '0').toList(),
    );
  }
}

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

final streakDataProvider = Provider<StreakData>((ref) {
  final service = ref.watch(streakServiceProvider);
  return service.getStreakData();
});
