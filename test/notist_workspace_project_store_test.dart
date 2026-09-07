/// Notist 專案模組。

library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/project/notist_workspace_project_store.dart';

void main() {
  late Directory workspaceDirectory;
  late NotistLocalWorkspaceProjectStore store;

  setUp(() async {
    workspaceDirectory = await Directory.systemTemp.createTemp(
      'notist-workspace-project-store-',
    );
    store = NotistLocalWorkspaceProjectStore(workspaceDirectory.path);
  });

  tearDown(() async {
    if (await workspaceDirectory.exists()) {
      await workspaceDirectory.delete(recursive: true);
    }
  });

  test('lists root project plus visible project folders only', () async {
    final normalProject = Directory(
      '${workspaceDirectory.path}${Platform.pathSeparator}研究',
    );
    final dotProject = Directory(
      '${workspaceDirectory.path}${Platform.pathSeparator}.git',
    );
    final buildProject = Directory(
      '${workspaceDirectory.path}${Platform.pathSeparator}build',
    );
    final hiddenProject = Directory(
      '${workspaceDirectory.path}${Platform.pathSeparator}.hidden',
    );
    await normalProject.create();
    await dotProject.create();
    await buildProject.create();
    await hiddenProject.create();

    final projects = await store.listProjects();
    final names = projects.map((entry) => entry.name).toList();

    expect(names, contains('根目錄專案'));
    expect(names, contains('研究'));
    expect(names, isNot(contains('.git')));
    expect(names, isNot(contains('build')));
    expect(names, isNot(contains('.hidden')));
  });

  test('deletes non-root project and skips unknown delete safely', () async {
    final created = await store.createProject('專案A');
    expect(await Directory(created.path).exists(), isTrue);

    await store.deleteProject('專案A');
    expect(await Directory(created.path).exists(), isFalse);

    await store.deleteProject('不存在的專案');
    expect(
      await Directory(
        '${workspaceDirectory.path}${Platform.pathSeparator}不存在的專案',
      ).exists(),
      isFalse,
    );
  });

  test(
    'rejects reserved folders as project names and delete targets',
    () async {
      await expectLater(store.createProject('build'), throwsStateError);
      await expectLater(store.createProject('.hidden'), throwsStateError);

      final buildDirectory = Directory(
        '${workspaceDirectory.path}${Platform.pathSeparator}build',
      );
      await buildDirectory.create();

      await expectLater(store.deleteProject('build'), throwsStateError);
      expect(await buildDirectory.exists(), isTrue);
    },
  );

  test('moves active project to root before deleting it', () async {
    final created = await store.createProject('專案A');
    await store.saveActiveProjectPath(created.path);

    await store.deleteProject(created.name);

    expect(
      await store.loadActiveProjectPath(),
      workspaceDirectory.absolute.path,
    );
  });
}
