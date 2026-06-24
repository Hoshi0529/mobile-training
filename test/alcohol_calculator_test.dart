import 'package:alcohol_record/services/alcohol_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('multiple drinks share one continuous metabolism timeline', () {
    final estimate = calculateAlcoholEstimate(
      records: [
        {'alcoholGrams': 20.0, 'recordedAt': DateTime(2026, 6, 20, 20)},
        {'alcoholGrams': 20.0, 'recordedAt': DateTime(2026, 6, 20, 21)},
      ],
      metabolismGramsPerHour: 10,
      at: DateTime(2026, 6, 20, 22),
    );

    expect(estimate.remainingGrams, closeTo(20, 0.001));
    expect(estimate.minutesUntilClear, 120);
    expect(estimate.clearAt, DateTime(2026, 6, 21));
  });

  test('future records do not affect the current estimate', () {
    final estimate = calculateAlcoholEstimate(
      records: [
        {'alcoholGrams': 20.0, 'recordedAt': DateTime(2026, 6, 20, 21)},
      ],
      metabolismGramsPerHour: 10,
      at: DateTime(2026, 6, 20, 20),
    );

    expect(estimate.remainingGrams, 0);
    expect(estimate.minutesUntilClear, 0);
  });

  test('sober streak counts completed tracked days only', () {
    final streak = calculateSoberStreak(
      records: [
        {'alcoholGrams': 10.0, 'recordedAt': DateTime(2026, 6, 20, 19)},
      ],
      trackingStartedAt: DateTime(2026, 6, 20),
      at: DateTime(2026, 6, 24, 12),
    );

    expect(streak, 3);
  });

  test('new users do not start with an artificial 365-day streak', () {
    final streak = calculateSoberStreak(
      records: const [],
      trackingStartedAt: DateTime(2026, 6, 24),
      at: DateTime(2026, 6, 24, 12),
    );

    expect(streak, 0);
  });
}
