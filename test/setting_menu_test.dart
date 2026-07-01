import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alcohol_record/data/menu.dart';
import 'package:alcohol_record/screens/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final originalMenuItems = List<Map<String, dynamic>>.from(
    globalMenuItemsNotifier.value,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalAppSettingsNotifier.value = AppSettings.defaults();
  });

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

    final dialogFields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(dialogFields.at(0), 'ハイボール');
    await tester.enterText(dialogFields.at(1), '350');
    await tester.enterText(dialogFields.at(2), '7');

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

  testWidgets('updates settings values and scheduled drinking dates', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SettingScreen())),
    );

    await tester.enterText(find.byType(TextField).at(0), '72');
    await tester.enterText(find.byType(TextField).at(1), '0.8');
    await tester.enterText(find.byType(TextField).at(2), '15');
    await tester.enterText(find.byType(TextField).at(3), '650');

    expect(globalAppSettingsNotifier.value.weightKg, 72);
    expect(globalAppSettingsNotifier.value.metabolismFactor, 0.8);
    expect(globalAppSettingsNotifier.value.dailyGoalGrams, 15);
    expect(globalAppSettingsNotifier.value.drinkCostYen, 650);

    await tester.tap(find.text('日').first);
    await tester.pumpAndSettle();

    expect(globalAppSettingsNotifier.value.restDays.first, isTrue);

    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(globalAppSettingsNotifier.value.reminderEnabled, isFalse);

    final today = DateUtils.dateOnly(DateTime.now());
    final todayCell = find.byKey(
      ValueKey('schedule-date-${formatDateKey(today)}'),
    );
    await tester.ensureVisible(todayCell);
    await tester.tap(todayCell);
    await tester.pumpAndSettle();

    expect(
      globalAppSettingsNotifier.value.scheduledDrinkingDates,
      contains(formatDateKey(today)),
    );
  });
}
