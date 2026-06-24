import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alcohol_record/data/menu.dart';
import 'package:alcohol_record/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalAppSettingsNotifier.value = AppSettings.defaults();
  });

  tearDown(() {
    globalDrinkRecordsNotifier.value = [];
  });

  testWidgets('home shows today records and summary values', (tester) async {
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'ビール（中ジョッキ）',
        'volume': 500,
        'abv': 5.0,
        'alcoholGrams': 20.0,
        'recordedAt': DateTime.now(),
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeScreen())),
    );

    expect(find.text('分解完了の推定まで'), findsOneWidget);
    expect(find.text('推定残存アルコール量'), findsOneWidget);
    expect(find.textContaining('この表示だけで運転可否を判断せず'), findsOneWidget);
    expect(find.text('今日の記録'), findsOneWidget);
    expect(find.text('ビール（中ジョッキ）'), findsOneWidget);
    expect(find.text('20.0g'), findsOneWidget);
    expect(find.text('170 kcal'), findsOneWidget);
  });
}
