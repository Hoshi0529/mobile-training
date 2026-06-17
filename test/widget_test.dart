import 'package:flutter_test/flutter_test.dart';

import 'package:sample/main.dart';

void main() {
  testWidgets('app shows the main shell copy', (tester) async {
    await tester.pumpWidget(const AlcoholRecordApp());

    expect(find.text('アルコールレコード'), findsOneWidget);
    expect(find.text('データ'), findsOneWidget);
    expect(find.text('記録'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
    expect(find.text('新しい記録を追加'), findsOneWidget);
  });
}
