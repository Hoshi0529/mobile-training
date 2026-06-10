import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample/data/menu.dart';
import 'package:sample/screens/add.dart';

void main() {
  final originalMenuItems = List<Map<String, dynamic>>.from(
    globalMenuItemsNotifier.value,
  );

  tearDown(() {
    globalMenuItemsNotifier.value = List<Map<String, dynamic>>.from(
      originalMenuItems,
    );
    globalDrinkRecordsNotifier.value = [];
  });

  testWidgets('manual form records a drink without adding a menu item', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddScreen())),
    );

    await tester.tap(find.text('手入力'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '日本酒');
    await tester.enterText(find.byType(TextFormField).at(1), '180');
    await tester.enterText(find.byType(TextFormField).at(2), '15');

    await tester.tap(find.text('記録する'));
    await tester.pumpAndSettle();

    expect(globalMenuItemsNotifier.value, hasLength(originalMenuItems.length));
    expect(globalDrinkRecordsNotifier.value, hasLength(1));

    final record = globalDrinkRecordsNotifier.value.single;
    expect(record['name'], '日本酒');
    expect(record['volume'], 180);
    expect(record['abv'], 15.0);
    expect(record['alcoholGrams'], closeTo(21.6, 0.01));
  });
}
