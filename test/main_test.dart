import 'dart:convert';

import 'package:alcohol_record/data/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalMenuItemsNotifier.value = [];
    globalDrinkRecordsNotifier.value = [];
    globalAppSettingsNotifier.value = AppSettings.defaults();
  });

  test('drink records can be updated and deleted', () {
    addDrinkRecord(
      name: 'ビール',
      volume: 350,
      abv: 5,
      recordedAt: DateTime(2026, 6, 20, 20),
    );
    final original = globalDrinkRecordsNotifier.value.single;

    updateDrinkRecord(
      originalRecord: original,
      name: 'ワイン',
      volume: 120,
      abv: 12,
      recordedAt: DateTime(2026, 6, 20, 21),
      memo: '良好',
    );

    final updated = globalDrinkRecordsNotifier.value.single;
    expect(updated['name'], 'ワイン');
    expect(updated['alcoholGrams'], closeTo(11.52, 0.001));
    expect(updated['memo'], '良好');

    deleteDrinkRecord(updated);
    expect(globalDrinkRecordsNotifier.value, isEmpty);
  });

  test('app state persists records and tracking start date', () async {
    final trackingStartedAt = DateTime(2026, 6, 1);
    globalAppSettingsNotifier.value = AppSettings.defaults().copyWith(
      trackingStartedAt: trackingStartedAt,
    );
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.wine_bar_outlined,
        'name': 'ワイン',
        'volume': 120,
        'abv': 12.0,
        'alcoholGrams': 11.52,
        'recordedAt': DateTime(2026, 6, 20, 21),
        'memo': '良好',
      },
    ];

    await persistAppState();
    final prefs = await SharedPreferences.getInstance();
    final storedRecords = jsonDecode(prefs.getString('drinkRecords')!) as List;
    expect(storedRecords, hasLength(1));
    expect(
      jsonDecode(prefs.getString('appSettings')!)['trackingStartedAt'],
      '2026-06-01',
    );

    globalDrinkRecordsNotifier.value = [];
    globalAppSettingsNotifier.value = AppSettings.defaults();
    await loadAppState();

    expect(globalDrinkRecordsNotifier.value.single['name'], 'ワイン');
    expect(
      globalAppSettingsNotifier.value.trackingStartedAt,
      trackingStartedAt,
    );
  });

  test('unsafe setting values are rejected', () {
    final defaults = globalAppSettingsNotifier.value;

    updateWeightKg(999);
    updateDailyGoalGrams(999);
    updateMetabolismFactor(2);
    updateDrinkCostYen(2000000);

    expect(globalAppSettingsNotifier.value.weightKg, defaults.weightKg);
    expect(
      globalAppSettingsNotifier.value.dailyGoalGrams,
      defaults.dailyGoalGrams,
    );
    expect(
      globalAppSettingsNotifier.value.metabolismFactor,
      defaults.metabolismFactor,
    );
    expect(globalAppSettingsNotifier.value.drinkCostYen, defaults.drinkCostYen);
  });
}
