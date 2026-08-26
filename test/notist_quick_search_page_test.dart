import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/project/notist_flow_document.dart';
import 'package:notist/src/search/notist_quick_search_page.dart';

void main() {
  testWidgets('searches stable Flow metadata and opens the selected root', (
    tester,
  ) async {
    String? openedRootId;
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpAppScreen(
          child: NotistQuickSearchPage(
            documents: const [
              NotistFlowDocument(
                rootId: 'root-spec',
                title: '工程規格',
                filePath: r'C:\project\spec.krdf',
                folderPath: 'docs',
              ),
              NotistFlowDocument(
                rootId: 'root-journal',
                title: '課堂筆記',
                filePath: r'C:\project\journal.krdf',
              ),
            ],
            onOpen: (rootId) => openedRootId = rootId,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '規格');
    await tester.pump();
    expect(find.text('工程規格'), findsOneWidget);
    expect(find.text('課堂筆記'), findsNothing);

    await tester.tap(find.text('工程規格'));
    expect(openedRootId, 'root-spec');
  });
}
