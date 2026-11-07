import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/streak/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StreakService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('first launch returns 1 Day Streak and highlights today', () async {
      final service = await StreakService.initialize();
      final data = service.getStreakData();

      expect(data.streakDays, 1);
      expect(data.isFirstDay, isTrue);
      expect(data.activeDaysOfWeek.length, 7);

      final todayIdx = DateTime.now().weekday - 1;
      expect(data.activeDaysOfWeek[todayIdx], isTrue);
    });

    test('recordActivityToday persists streak and active days', () async {
      final service = await StreakService.initialize();
      await service.recordActivityToday();

      final data = service.getStreakData();
      expect(data.streakDays, 1);
      final todayIdx = DateTime.now().weekday - 1;
      expect(data.activeDaysOfWeek[todayIdx], isTrue);
    });
  });
}
