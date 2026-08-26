import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/project/notist_flow_document.dart';
import 'package:notist/src/project/notist_project_controller.dart';
import 'package:notist/src/project/notist_project_store.dart';

Widget buildGoldenEditor(BuildContext context, String filePath) {
  return Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.all(context.klp.space.loose),
      child: const KlpText('asdasd', role: KlpTextRole.editor),
    ),
  );
}

void main() {
  testWidgets('matches the Notist desktop main visual', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final projectController = NotistProjectController(
      store: const _GoldenProjectStore(),
      loader: (path, initialTitle) async => switch (path) {
        'asdasd.krdf' => const NotistFlowDocument(
          rootId: 'flow-asdasd',
          title: 'asdasd',
          filePath: 'asdasd.krdf',
          blockCount: 1,
        ),
        _ => const NotistFlowDocument(
          rootId: 'flow-untitled',
          title: '',
          filePath: 'untitled.krdf',
          blockCount: 0,
        ),
      },
    );
    addTearDown(projectController.dispose);

    await tester.pumpWidget(
      NotistApp(
        flowEditorBuilder: buildGoldenEditor,
        projectController: projectController,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(NotistApp),
      matchesGoldenFile('goldens/notist_main_visual.png'),
    );
  });
}

final class _GoldenProjectStore implements NotistProjectStore {
  const _GoldenProjectStore();

  @override
  Future<String> allocateFlowPath({String? folderPath}) async => 'new.krdf';

  @override
  Future<List<String>> listFolderPaths() async => const [];

  @override
  Future<List<NotistStoredFlow>> listFlows() async => const [
    NotistStoredFlow(filePath: 'asdasd.krdf', folderPath: ''),
    NotistStoredFlow(filePath: 'untitled.krdf', folderPath: ''),
  ];
}
