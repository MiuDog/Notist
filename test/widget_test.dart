/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/shell/notist_workbench.dart';

void main() {
  testWidgets('NotistApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();

    expect(
      find.byType(NotistWorkbench),
      findsOneWidget,
      reason: 'NotistWorkbench should be rendered',
    );
    expect(
      find.byType(KlpWindowHeader),
      findsOneWidget,
      reason: 'KlpApp shell banner should be rendered',
    );
    expect(
      find.byKey(const ValueKey('notist-app-icon')),
      findsOneWidget,
      reason: 'KlpApp shell banner should include the Notist icon',
    );
  });

  testWidgets('startup path failure is projected instead of crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NotistApp(startupError: StateError('LOCALAPPDATA unavailable')),
    );
    await tester.pump();

    expect(find.byType(NotistWorkbench), findsNothing);
    expect(find.text('無法開啟本機專案'), findsOneWidget);
    expect(find.byType(KlpErrorState), findsOneWidget);
  });
}
