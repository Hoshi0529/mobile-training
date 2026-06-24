import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alcohol_record/data/menu.dart';
import 'package:alcohol_record/screens/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalAppSettingsNotifier.value = AppSettings.defaults();
  });

  tearDown(() {
    globalDrinkRecordsNotifier.value = [];
  });

  testWidgets('record screen shows weekly alcohol and calorie charts', (
    tester,
  ) async {
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'ビール',
        'volume': 500,
        'abv': 5.0,
        'alcoholGrams': 20.0,
        'recordedAt': DateTime.now(),
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RecordScreen())),
    );

    expect(find.text('記録'), findsOneWidget);
    expect(find.text('週間'), findsOneWidget);
    expect(find.text('月間'), findsOneWidget);
    expect(find.text('アルコール量'), findsOneWidget);
    expect(find.text('20.0'), findsOneWidget);
    expect(find.text('g'), findsOneWidget);
    expect(find.text('休肝日達成'), findsOneWidget);
    expect(find.text('目標超過'), findsOneWidget);

    await tester.tap(find.text('カロリー'));
    await tester.pumpAndSettle();

    expect(find.text('170'), findsOneWidget);
    expect(find.text('kcal'), findsOneWidget);
  });

  testWidgets('record screen shows monthly calendar with drinking days', (
    tester,
  ) async {
    final now = DateTime.now();
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'ビール',
        'volume': 500,
        'abv': 5.0,
        'alcoholGrams': 20.0,
        'recordedAt': now,
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RecordScreen())),
    );

    await tester.tap(find.text('月間'));
    await tester.pumpAndSettle();

    expect(find.text('${now.month}月 ${now.year}'), findsOneWidget);
    expect(find.text('飲酒日'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);
    expect(find.text(now.day.toString()), findsAtLeastNWidgets(1));
    expect(find.text('月間推移'), findsOneWidget);
    expect(find.text('休肝日達成'), findsOneWidget);
    expect(find.text('目標超過'), findsOneWidget);
  });

  testWidgets('opens a day detail and deletes a past record', (tester) async {
    final now = DateTime.now();
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': '削除対象',
        'volume': 350,
        'abv': 5.0,
        'alcoholGrams': 14.0,
        'recordedAt': now,
        'memo': '少し眠い',
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RecordScreen())),
    );
    await tester.tap(find.text('月間'));
    await tester.pumpAndSettle();
    final dayFinder = find.text(now.day.toString()).first;
    await tester.ensureVisible(dayFinder);
    await tester.pumpAndSettle();
    await tester.tap(dayFinder);
    await tester.pumpAndSettle();

    expect(
      find.text('${now.year}年${now.month}月${now.day}日の記録'),
      findsOneWidget,
    );
    expect(find.text('削除対象'), findsOneWidget);
    expect(find.text('少し眠い'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '削除'));
    await tester.pumpAndSettle();

    expect(globalDrinkRecordsNotifier.value, isEmpty);
  });
}
