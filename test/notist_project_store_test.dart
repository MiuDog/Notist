import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/project/notist_project_store.dart';

void main() {
  late Directory projectDirectory;
  late NotistLocalProjectStore store;

  setUp(() async {
    projectDirectory = await Directory.systemTemp.createTemp(
      'notist-project-store-',
    );
    store = NotistLocalProjectStore(projectDirectory.path);
  });

  tearDown(() async {
    if (await projectDirectory.exists()) {
      await projectDirectory.delete(recursive: true);
    }
  });

  test('lists nested Flow locations and project folders', () async {
    final nested = Directory(
      '${projectDirectory.path}${Platform.pathSeparator}研究'
      '${Platform.pathSeparator}草稿',
    );
    await nested.create(recursive: true);
    await File(
      '${projectDirectory.path}${Platform.pathSeparator}root.krdf',
    ).writeAsString('root');
    await File(
      '${nested.path}${Platform.pathSeparator}nested.krdf',
    ).writeAsString('nested');

    final flows = await store.listFlows();

    expect(await store.listFolderPaths(), ['研究', '研究/草稿']);
    expect(
      flows.map((flow) => flow.folderPath),
      containsAll(<String>['', '研究/草稿']),
    );
    expect(
      flows.map((flow) => flow.filePath),
      containsAll(<String>[
        '${projectDirectory.path}${Platform.pathSeparator}root.krdf',
        '${nested.path}${Platform.pathSeparator}nested.krdf',
      ]),
    );
  });

  test('allocates in the selected existing folder', () async {
    final folder = Directory(
      '${projectDirectory.path}${Platform.pathSeparator}研究',
    );
    await folder.create();

    final path = await store.allocateFlowPath(folderPath: '研究');

    expect(File(path).parent.path, folder.path);
  });

  test('allocates at project root without a selected folder', () async {
    final path = await store.allocateFlowPath();

    expect(File(path).parent.path, projectDirectory.path);
  });

  test('rejects traversal and unknown folders', () async {
    await expectLater(
      store.allocateFlowPath(folderPath: '../outside'),
      throwsArgumentError,
    );
    await expectLater(
      store.allocateFlowPath(folderPath: '不存在'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
