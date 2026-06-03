import 'package:flutter/material.dart';

// アプリ全体で共有する定番メニューのリスト
// ValueNotifierを使うことで、データが更新されたときに自動で画面を再描画できます
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
