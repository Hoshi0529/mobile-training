import 'package:flutter/material.dart';

// アプリ全体で共有する定番メニューのリスト。
final ValueNotifier<List<Map<String, dynamic>>> globalMenuItemsNotifier =
    ValueNotifier([
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'ビール (中ジョッキ)',
        'volume': 500,
        'abv': 5.0,
      },
      {
        'icon': Icons.local_drink_outlined,
        'name': 'チューハイ (缶)',
        'volume': 350,
        'abv': 5.0,
      },
      {
        'icon': Icons.wine_bar_outlined,
        'name': 'ワイン (グラス)',
        'volume': 120,
        'abv': 12.0,
      },
      {
        'icon': Icons.local_drink_outlined,
        'name': 'ストロング系 (缶)',
        'volume': 500,
        'abv': 9.0,
      },
    ]);

// アプリ全体で共有する飲酒記録のリスト。
final ValueNotifier<List<Map<String, dynamic>>> globalDrinkRecordsNotifier =
    ValueNotifier([]);

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
}
