import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample/data/menu.dart';
import 'package:sample/screens/home.dart';

void main() {
  tearDown(() {
    globalDrinkRecordsNotifier.value = [];
  });

  testWidgets('home shows today records and summary values', (tester) async {
    globalDrinkRecordsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'ビール (中ジョッキ)',
        'volume': 500,
        'abv': 5.0,
        'alcoholGrams': 20.0,
        'recordedAt': DateTime.now(),
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeScreen())),
    );

    expect(find.text('運転可能目安まで'), findsOneWidget);
    expect(find.text('現在の体内アルコール量'), findsOneWidget);
    expect(find.text('今日の記録'), findsOneWidget);
    expect(find.text('ビール (中ジョッキ)'), findsOneWidget);
    expect(find.text('20.0g'), findsOneWidget);
    expect(find.text('170 kcal'), findsOneWidget);
  });
}
