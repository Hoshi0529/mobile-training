import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const _menuItemsKey = 'menuItems';
const _drinkRecordsKey = 'drinkRecords';
const _appSettingsKey = 'appSettings';

class AppSettings {
  const AppSettings({
    required this.weightKg,
    required this.dailyGoalGrams,
    required this.metabolismFactor,
    required this.drinkCostYen,
    required this.restDays,
    required this.scheduledDrinkingDates,
    required this.reminderEnabled,
    required this.trackingStartedAt,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      weightKg: 60,
      dailyGoalGrams: 20,
      metabolismFactor: 1,
      drinkCostYen: 500,
      restDays: const [false, true, true, false, false, false, false],
      scheduledDrinkingDates: const <String>{},
      reminderEnabled: true,
      trackingStartedAt: DateUtils.dateOnly(DateTime.now()),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    DateTime? trackingStartedAtFallback,
  }) {
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
      metabolismFactor: _asDouble(json['metabolismFactor'], fallback: 1),
      drinkCostYen: _asDouble(json['drinkCostYen'], fallback: 500),
      restDays: normalizedRestDays,
      scheduledDrinkingDates: scheduledDates,
      reminderEnabled: json['reminderEnabled'] != false,
      trackingStartedAt:
          DateTime.tryParse(json['trackingStartedAt']?.toString() ?? '') ??
          trackingStartedAtFallback ??
          DateUtils.dateOnly(DateTime.now()),
    );
  }

  final double weightKg;
  final double dailyGoalGrams;
  final double metabolismFactor;
  final double drinkCostYen;
  final List<bool> restDays;
  final Set<String> scheduledDrinkingDates;
  final bool reminderEnabled;
  final DateTime trackingStartedAt;

  double get metabolismGramsPerHour {
    return (weightKg / 12 * metabolismFactor).clamp(1.0, 12.0);
  }

  AppSettings copyWith({
    double? weightKg,
    double? dailyGoalGrams,
    double? metabolismFactor,
    double? drinkCostYen,
    List<bool>? restDays,
    Set<String>? scheduledDrinkingDates,
    bool? reminderEnabled,
    DateTime? trackingStartedAt,
  }) {
    return AppSettings(
      weightKg: weightKg ?? this.weightKg,
      dailyGoalGrams: dailyGoalGrams ?? this.dailyGoalGrams,
      metabolismFactor: metabolismFactor ?? this.metabolismFactor,
      drinkCostYen: drinkCostYen ?? this.drinkCostYen,
      restDays: List<bool>.from(restDays ?? this.restDays),
      scheduledDrinkingDates: Set<String>.from(
        scheduledDrinkingDates ?? this.scheduledDrinkingDates,
      ),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      trackingStartedAt: trackingStartedAt ?? this.trackingStartedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'dailyGoalGrams': dailyGoalGrams,
      'metabolismFactor': metabolismFactor,
      'drinkCostYen': drinkCostYen,
      'restDays': restDays,
      'scheduledDrinkingDates': scheduledDrinkingDates.toList()..sort(),
      'reminderEnabled': reminderEnabled,
      'trackingStartedAt': formatDateKey(trackingStartedAt),
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

final _appStateStore = _AppStateStore();

Future<void> loadAppState() async {
  await _appStateStore.init();
  final prefs = await SharedPreferences.getInstance();

  final rawMenuItems = await _readStoredString(prefs, _menuItemsKey);
  if (rawMenuItems != null) {
    final decoded = _decodeJsonSafely(rawMenuItems);
    if (decoded is List) {
      globalMenuItemsNotifier.value = decoded
          .whereType<Map<String, dynamic>>()
          .map(_deserializeDrinkItem)
          .toList();
    }
  }

  final rawDrinkRecords = await _readStoredString(prefs, _drinkRecordsKey);
  if (rawDrinkRecords != null) {
    final decoded = _decodeJsonSafely(rawDrinkRecords);
    if (decoded is List) {
      globalDrinkRecordsNotifier.value = decoded
          .whereType<Map<String, dynamic>>()
          .map(_deserializeDrinkRecord)
          .toList();
    }
  }

  final rawSettings = await _readStoredString(prefs, _appSettingsKey);
  if (rawSettings != null) {
    final decoded = _decodeJsonSafely(rawSettings);
    if (decoded is Map<String, dynamic>) {
      globalAppSettingsNotifier.value = AppSettings.fromJson(
        decoded,
        trackingStartedAtFallback: _earliestRecordDate(
          globalDrinkRecordsNotifier.value,
        ),
      );
    }
  } else {
    final earliestRecordDate = _earliestRecordDate(
      globalDrinkRecordsNotifier.value,
    );
    if (earliestRecordDate != null) {
      globalAppSettingsNotifier.value = globalAppSettingsNotifier.value
          .copyWith(trackingStartedAt: earliestRecordDate);
      unawaited(_persistAppSettings());
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
  DateTime? recordedAt,
  String? memo,
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
    'recordedAt': recordedAt ?? DateTime.now(),
    'memo': memo?.trim() ?? '',
  });

  globalDrinkRecordsNotifier.value = newList;
  unawaited(_persistDrinkRecords());
}

void updateDrinkRecord({
  required Map<String, dynamic> originalRecord,
  required String name,
  required int volume,
  required double abv,
  required DateTime recordedAt,
  required String memo,
}) {
  final records = List<Map<String, dynamic>>.from(
    globalDrinkRecordsNotifier.value,
  );
  final index = records.indexWhere(
    (record) => identical(record, originalRecord) || record == originalRecord,
  );
  if (index < 0) {
    return;
  }

  records[index] = {
    ...originalRecord,
    'name': name.trim(),
    'volume': volume,
    'abv': abv,
    'alcoholGrams': volume * abv / 100 * 0.8,
    'recordedAt': recordedAt,
    'memo': memo.trim(),
  };
  records.sort(
    (left, right) => (right['recordedAt'] as DateTime).compareTo(
      left['recordedAt'] as DateTime,
    ),
  );
  globalDrinkRecordsNotifier.value = records;
  unawaited(_persistDrinkRecords());
}

void deleteDrinkRecord(Map<String, dynamic> recordToDelete) {
  final records = List<Map<String, dynamic>>.from(
    globalDrinkRecordsNotifier.value,
  );
  records.removeWhere(
    (record) => identical(record, recordToDelete) || record == recordToDelete,
  );
  globalDrinkRecordsNotifier.value = records;
  unawaited(_persistDrinkRecords());
}

void updateAppSettings(AppSettings settings) {
  globalAppSettingsNotifier.value = settings;
  unawaited(_persistAppSettings());
}

void updateWeightKg(double weightKg) {
  if (weightKg <= 0 || weightKg > 500) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(weightKg: weightKg),
  );
}

void updateDailyGoalGrams(double dailyGoalGrams) {
  if (dailyGoalGrams <= 0 || dailyGoalGrams > 500) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(dailyGoalGrams: dailyGoalGrams),
  );
}

void updateMetabolismFactor(double metabolismFactor) {
  if (metabolismFactor < 0.5 || metabolismFactor > 1.5) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(
      metabolismFactor: metabolismFactor,
    ),
  );
}

void updateDrinkCostYen(double drinkCostYen) {
  if (drinkCostYen < 0 || drinkCostYen > 1000000) {
    return;
  }
  updateAppSettings(
    globalAppSettingsNotifier.value.copyWith(drinkCostYen: drinkCostYen),
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
  final encoded = jsonEncode(
    globalMenuItemsNotifier.value.map(_serializeDrinkItem).toList(),
  );
  await _writeStoredString(_menuItemsKey, encoded);
}

Future<void> _persistDrinkRecords() async {
  final encoded = jsonEncode(
    globalDrinkRecordsNotifier.value.map(_serializeDrinkRecord).toList(),
  );
  await _writeStoredString(_drinkRecordsKey, encoded);
}

Future<void> _persistAppSettings() async {
  await _writeStoredString(
    _appSettingsKey,
    jsonEncode(globalAppSettingsNotifier.value.toJson()),
  );
}

Future<void> persistAppState() async {
  await Future.wait([
    _persistMenuItems(),
    _persistDrinkRecords(),
    _persistAppSettings(),
  ]);
}

Future<String?> _readStoredString(SharedPreferences prefs, String key) async {
  final dbValue = await _appStateStore.getString(key);
  if (dbValue != null) {
    return dbValue;
  }

  final prefsValue = prefs.getString(key);
  if (prefsValue != null) {
    unawaited(_appStateStore.setString(key, prefsValue));
  }
  return prefsValue;
}

Future<void> _writeStoredString(String key, String value) async {
  await _appStateStore.setString(key, value);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

class _AppStateStore {
  Database? _db;

  Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      final dbPath = await getDatabasesPath();
      final dbFile = path.join(dbPath, 'alcohol_record.db');
      _db = await openDatabase(
        dbFile,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE app_state (
              state_key TEXT PRIMARY KEY,
              value_text TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (_) {
      _db = null;
    }
  }

  Future<String?> getString(String key) async {
    final db = _db;
    if (db == null) {
      return null;
    }

    try {
      final rows = await db.query(
        'app_state',
        columns: ['value_text'],
        where: 'state_key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return rows.first['value_text']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    final db = _db;
    if (db == null) {
      return;
    }

    try {
      await db.insert('app_state', {
        'state_key': key,
        'value_text': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      // SharedPreferences remains as a fallback if SQLite is unavailable.
    }
  }
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
    'memo': record['memo']?.toString() ?? '',
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
    'memo': record['memo']?.toString() ?? '',
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

DateTime? _earliestRecordDate(List<Map<String, dynamic>> records) {
  DateTime? earliest;
  for (final record in records) {
    final recordedAt = record['recordedAt'];
    if (recordedAt is! DateTime) {
      continue;
    }
    final date = DateUtils.dateOnly(recordedAt);
    if (earliest == null || date.isBefore(earliest)) {
      earliest = date;
    }
  }
  return earliest;
}

dynamic _decodeJsonSafely(String value) {
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}
