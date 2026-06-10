import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample/data/menu.dart';
import 'package:sample/screens/setting.dart';

void main() {
  final originalMenuItems = List<Map<String, dynamic>>.from(
    globalMenuItemsNotifier.value,
  );

  tearDown(() {
    globalMenuItemsNotifier.value = List<Map<String, dynamic>>.from(
      originalMenuItems,
    );
  });

  testWidgets('adds a custom menu item from settings', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SettingScreen())),
    );

    await tester.ensureVisible(find.text('追加'));
    await tester.tap(find.text('追加'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'ハイボール');
    await tester.enterText(find.byType(TextField).at(3), '350');
    await tester.enterText(find.byType(TextField).at(4), '7');

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('ハイボール'), findsOneWidget);
    expect(
      globalMenuItemsNotifier.value.any((item) => item['name'] == 'ハイボール'),
      isTrue,
    );
  });

  testWidgets('edits a custom menu item from settings', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    globalMenuItemsNotifier.value = [
      {
        'icon': Icons.sports_bar_outlined,
        'name': 'Original',
        'volume': 350,
        'abv': 5.0,
      },
    ];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SettingScreen())),
    );

    await tester.ensureVisible(find.text('Original'));
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    final dialogFields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(dialogFields.at(0), 'Edited');
    await tester.enterText(dialogFields.at(1), '500');
    await tester.enterText(dialogFields.at(2), '8');

    await tester.tap(find.text('更新'));
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsOneWidget);
    expect(find.text('Original'), findsNothing);
    expect(globalMenuItemsNotifier.value, hasLength(1));
    expect(globalMenuItemsNotifier.value.single['name'], 'Edited');
    expect(globalMenuItemsNotifier.value.single['volume'], 500);
    expect(globalMenuItemsNotifier.value.single['abv'], 8.0);
  });
}
