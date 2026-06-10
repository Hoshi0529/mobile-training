import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample/data/menu.dart';
import 'package:sample/screens/record.dart';

void main() {
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
    expect(find.text(now.day.toString()), findsOneWidget);
    expect(find.text('休肝日達成'), findsOneWidget);
    expect(find.text('目標超過'), findsOneWidget);
  });
}
