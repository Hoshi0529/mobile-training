import 'dart:math' as math;

import 'package:flutter/material.dart';

class AlcoholEstimate {
  const AlcoholEstimate({
    required this.remainingGrams,
    required this.minutesUntilClear,
    required this.clearAt,
  });

  final double remainingGrams;
  final int minutesUntilClear;
  final DateTime clearAt;
}

AlcoholEstimate calculateAlcoholEstimate({
  required List<Map<String, dynamic>> records,
  required double metabolismGramsPerHour,
  DateTime? at,
}) {
  final now = at ?? DateTime.now();
  final rate = math.max(metabolismGramsPerHour, 0.1);
  final chronologicalRecords =
      records.where((record) {
        final recordedAt = record['recordedAt'];
        return recordedAt is DateTime && !recordedAt.isAfter(now);
      }).toList()..sort(
        (left, right) => (left['recordedAt'] as DateTime).compareTo(
          right['recordedAt'] as DateTime,
        ),
      );

  var remaining = 0.0;
  DateTime? previousRecordedAt;

  for (final record in chronologicalRecords) {
    final recordedAt = record['recordedAt'] as DateTime;
    if (previousRecordedAt != null) {
      final elapsedHours =
          recordedAt.difference(previousRecordedAt).inSeconds / 3600;
      remaining = math.max(remaining - (elapsedHours * rate), 0);
    }
    remaining += _asDouble(record['alcoholGrams']);
    previousRecordedAt = recordedAt;
  }

  if (previousRecordedAt != null) {
    final elapsedHours = now.difference(previousRecordedAt).inSeconds / 3600;
    remaining = math.max(remaining - (elapsedHours * rate), 0);
  }

  final minutesUntilClear = remaining <= 0 ? 0 : (remaining / rate * 60).ceil();
  return AlcoholEstimate(
    remainingGrams: remaining,
    minutesUntilClear: minutesUntilClear,
    clearAt: now.add(Duration(minutes: minutesUntilClear)),
  );
}

int calculateSoberStreak({
  required List<Map<String, dynamic>> records,
  required DateTime trackingStartedAt,
  DateTime? at,
}) {
  final today = DateUtils.dateOnly(at ?? DateTime.now());
  final firstTrackedDay = DateUtils.dateOnly(trackingStartedAt);
  var date = today.subtract(const Duration(days: 1));
  var streak = 0;

  while (!date.isBefore(firstTrackedDay)) {
    final hasRecord = records.any((record) {
      final recordedAt = record['recordedAt'];
      return recordedAt is DateTime && DateUtils.isSameDay(recordedAt, date);
    });
    if (hasRecord) {
      break;
    }
    streak++;
    date = date.subtract(const Duration(days: 1));
  }

  return streak;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? 0;
}
