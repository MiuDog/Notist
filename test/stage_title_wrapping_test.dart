/// Notist 專案模組。

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/stage/notist_stage.dart';

void main() {
  testWidgets('Notist uses the KLP panel header for the Stage title', (
    tester,
  ) async {
    await tester.pumpWidget(
      const KlpApp(
        showWindowHeader: false,
        home: NotistStage(
          flowFilePath: '',
          projectDirectoryPath: r'D:\Projects\Notist',
          projectController: null,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(KlpPanelHeader), findsOneWidget);
    expect(find.text(r'D:\Projects\Notist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
