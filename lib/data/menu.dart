import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _menuItemsKey = 'menuItems';
const _drinkRecordsKey = 'drinkRecords';
const _appSettingsKey = 'appSettings';

class AppSettings {
  const AppSettings({
    required this.weightKg,
    required this.dailyGoalGrams,
    required this.restDays,
    required this.scheduledDrinkingDates,
    required this.reminderEnabled,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      weightKg: 60,
      dailyGoalGrams: 20,
      restDays: [false, true, true, false, false, false, false],
      scheduledDrinkingDates: <String>{},
      reminderEnabled: true,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawRestDays = json['restDays'];
    final restDays = rawRestDays is List
        ? rawRestDays.map((value) => value == true).toList()
        : AppSettings.defaults().restDays;
    final normalizedRestDays = List<bool>.generate(
      7,
      (index) => index < restDays.length ? restDays[index] : false,
    );

    final rawScheduledDates = json['scheduledDrinkingDates'];
    final scheduledDates = rawScheduledDates is List
        ? rawScheduledDates.map((value) => value.toString()).toSet()
        : <String>{};

    return AppSettings(
      weightKg: _asDouble(json['weightKg'], fallback: 60),
      dailyGoalGrams: _asDouble(json['dailyGoalGrams'], fallback: 20),
      restDays: normalizedRestDays,
      scheduledDrinkingDates: scheduledDates,
      reminderEnabled: json['reminderEnabled'] != false,
    );
  }

  final double weightKg;
  final double dailyGoalGrams;
  final List<bool> restDays;
  final Set<String> scheduledDrinkingDates;
  final bool reminderEnabled;

  double get metabolismGramsPerHour {
    return (weightKg / 12).clamp(1.0, 12.0);
  }

  AppSettings copyWith({
    double? weightKg,
    double? dailyGoalGrams,
    List<bool>? restDays,
    Set<String>? scheduledDrinkingDates,
    bool? reminderEnabled,
  }) {
    return AppSettings(
      weightKg: weightKg ?? this.weightKg,
      dailyGoalGrams: dailyGoalGrams ?? this.dailyGoalGrams,
      restDays: List<bool>.from(restDays ?? this.restDays),
      scheduledDrinkingDates: Set<String>.from(
        scheduledDrinkingDates ?? this.scheduledDrinkingDates,
      ),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'dailyGoalGrams': dailyGoalGrams,
      'restDays': restDays,
      'scheduledDrinkingDates': scheduledDrinkingDates.toList()..sort(),
      'reminderEnabled': reminderEnabled,
    };
  }
}

final ValueNotifier<List<Map<String, dynamic>>> globalMenuItemsNotifier =
    ValueNotifier(_defaultMenuItems());

final ValueNotifier<List<Map<String, dynamic>>> globalDrinkRecordsNotifier =
    ValueNotifier([]);

final ValueNotifier<AppSettings> globalAppSettingsNotifier = ValueNotifier(
  AppSettings.defaults(),
);

Future<void> loadAppState() async {
  final prefs = await SharedPreferences.getInstance();

  final rawMenuItems = prefs.getString(_menuItemsKey);
  if (rawMenuItems != null) {
    final decoded = jsonDecode(rawMenuItems);
    if (decoded is List) {
      globalMenuItemsNotifier.value = decoded
          .whereType<Map<String, dynamic>>()
          .map(_deserializeDrinkItem)
          .toList();
    }
  }

  final rawDrinkRecords = prefs.getString(_drinkRecordsKey);
  if (rawDrinkRecords != null) {
    final decoded = jsonDecode(rawDrinkRecords);
    if (decoded is List) {
      globalDrinkRecordsNotifier.value = decoded
          .whereType<Map<String, dynamic>>()
          .map(_deserializeDrinkRecord)
          .toList();
    }
  }

  final rawSettings = prefs.getString(_appSettingsKey);
  if (rawSettings != null) {
    final decoded = jsonDecode(rawSettings);
    if (decoded is Map<String, dynamic>) {
      globalAppSettingsNotifier.value = AppSettings.fromJson(decoded);
    }
  }
}

void saveMenuItems(List<Map<String, dynamic>> menuItems) {
  globalMenuItemsNotifier.value = List<Map<String, dynamic>>.from(menuItems);
  unawaited(_persistMenuItems());
}

void addDrinkRecord({
  required String name,
  required int volume,
  required double abv,
  IconData icon = Icons.local_drink_outlined,
}) {
  final newList = List<Map<String, dynamic>>.from(
    globalDrinkRecordsNotifier.value,
  );

  newList.insert(0, {
    'icon': icon,
    'name': name,
    'volume': volume,
    'abv': abv,
    'alcoholGrams': volume * abv / 100 * 0.8,
    'recordedAt': DateTime.now(),
  });

  globalDrinkRecordsNotifier.value = newList;
  unawaited(_persistDrinkRecords());
}

void updateAppSettings(AppSettings settings) {
  globalAppSettingsNotifier.value = settings;
  unawaited(_persistAppSettings());
}

void updateWeightKg(double weightKg) {
  if (weightKg <= 0) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(weightKg: weightKg),
  );
}

void updateDailyGoalGrams(double dailyGoalGrams) {
  if (dailyGoalGrams <= 0) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(dailyGoalGrams: dailyGoalGrams),
  );
}

void updateRestDay(int index, bool value) {
  if (index < 0 || index >= 7) {
    return;
  }
  final restDays = List<bool>.from(globalAppSettingsNotifier.value.restDays);
  restDays[index] = value;
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(restDays: restDays),
  );
}

void updateReminderEnabled(bool enabled) {
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(reminderEnabled: enabled),
  );
}

void toggleScheduledDrinkingDate(DateTime date) {
  final dateKey = formatDateKey(date);
  final dates = Set<String>.from(
    globalAppSettingsNotifier.value.scheduledDrinkingDates,
  );
  if (!dates.add(dateKey)) {
    dates.remove(dateKey);
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(scheduledDrinkingDates: dates),
  );
}

bool isScheduledDrinkingDate(DateTime date) {
  return globalAppSettingsNotifier.value.scheduledDrinkingDates.contains(
    formatDateKey(date),
  );
}

bool isRestDay(DateTime date, AppSettings settings) {
  return settings.restDays[_weekdayToRestDayIndex(date)];
}

String formatDateKey(DateTime date) {
  final normalized = DateUtils.dateOnly(date);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime parseDateKey(String dateKey) {
  return DateTime.parse(dateKey);
}

int _weekdayToRestDayIndex(DateTime date) {
  return date.weekday % 7;
}

Future<void> _persistMenuItems() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(
    globalMenuItemsNotifier.value.map(_serializeDrinkItem).toList(),
  );
  await prefs.setString(_menuItemsKey, encoded);
}

Future<void> _persistDrinkRecords() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(
    globalDrinkRecordsNotifier.value.map(_serializeDrinkRecord).toList(),
  );
  await prefs.setString(_drinkRecordsKey, encoded);
}

Future<void> _persistAppSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _appSettingsKey,
    jsonEncode(globalAppSettingsNotifier.value.toJson()),
  );
}

List<Map<String, dynamic>> _defaultMenuItems() {
  return [
    {
      'icon': Icons.sports_bar_outlined,
      'name': 'ビール（中ジョッキ）',
      'volume': 500,
      'abv': 5.0,
    },
    {
      'icon': Icons.local_drink_outlined,
      'name': 'チューハイ（缶）',
      'volume': 350,
      'abv': 5.0,
    },
    {
      'icon': Icons.wine_bar_outlined,
      'name': 'ワイン（グラス）',
      'volume': 120,
      'abv': 12.0,
    },
    {
      'icon': Icons.local_drink_outlined,
      'name': 'ストロング系（缶）',
      'volume': 500,
      'abv': 9.0,
    },
  ];
}

Map<String, dynamic> _serializeDrinkItem(Map<String, dynamic> item) {
  return {
    'icon': _serializeIcon(item['icon']),
    'name': item['name'],
    'volume': item['volume'],
    'abv': item['abv'],
  };
}

Map<String, dynamic> _serializeDrinkRecord(Map<String, dynamic> record) {
  return {
    ..._serializeDrinkItem(record),
    'alcoholGrams': record['alcoholGrams'],
    'recordedAt': (record['recordedAt'] as DateTime).toIso8601String(),
  };
}

Map<String, dynamic> _deserializeDrinkItem(Map<String, dynamic> item) {
  return {
    'icon': _deserializeIcon(item['icon']),
    'name': item['name'].toString(),
    'volume': _asInt(item['volume'], fallback: 0),
    'abv': _asDouble(item['abv'], fallback: 0),
  };
}

Map<String, dynamic> _deserializeDrinkRecord(Map<String, dynamic> record) {
  return {
    ..._deserializeDrinkItem(record),
    'alcoholGrams': _asDouble(record['alcoholGrams'], fallback: 0),
    'recordedAt':
        DateTime.tryParse(record['recordedAt'].toString()) ?? DateTime.now(),
  };
}

Map<String, dynamic> _serializeIcon(dynamic value) {
  final icon = value is IconData ? value : Icons.local_drink_outlined;
  return {
    'codePoint': icon.codePoint,
    'fontFamily': icon.fontFamily,
    'fontPackage': icon.fontPackage,
    'matchTextDirection': icon.matchTextDirection,
  };
}

IconData _deserializeIcon(dynamic value) {
  if (value is! Map) {
    return Icons.local_drink_outlined;
  }
  return IconData(
    _asInt(value['codePoint'], fallback: Icons.local_drink_outlined.codePoint),
    fontFamily: value['fontFamily']?.toString(),
    fontPackage: value['fontPackage']?.toString(),
    matchTextDirection: value['matchTextDirection'] == true,
  );
}

double _asDouble(dynamic value, {required double fallback}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? fallback;
}

int _asInt(dynamic value, {required int fallback}) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString()) ?? fallback;
}
