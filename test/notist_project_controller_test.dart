/// Notist 專案模組。

library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/markdown/notist_markdown_file_source.dart';
import 'package:notist/src/project/notist_flow_document.dart';
import 'package:notist/src/project/notist_project_controller.dart';
import 'package:notist/src/project/notist_project_store.dart';

void main() {
  test(
    'loads two Flow projections and selects the first stable root',
    () async {
      final store = _MemoryProjectStore(['a.krdf', 'b.krdf']);
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-$path',
          title: 'title-$path',
          filePath: path,
        ),
      );

      await controller.load();

      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.map((document) => document.rootId), [
        'root-a.krdf',
        'root-b.krdf',
      ]);
      expect(controller.selectedRootId, 'root-a.krdf');
    },
  );

  test(
    'publishes a new Flow only after the Krepis projection succeeds',
    () async {
      final store = _MemoryProjectStore([]);
      final pending = <String>[];
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async {
          pending.add(initialTitle);
          return NotistFlowDocument(
            rootId: 'root-new',
            title: initialTitle,
            filePath: path,
          );
        },
      );
      await controller.load();

      await controller.createFlow();

      expect(pending, ['']);
      expect(controller.documents.single.rootId, 'root-new');
      expect(controller.selectedRootId, 'root-new');
    },
  );

  test(
    'imports Explorer clipboard Markdown into the selected folder',
    () async {
      final store = _MemoryProjectStore([], folders: ['研究']);
      final imports = <(String, String)>[];
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) => throw UnimplementedError(),
        markdownImporter: (path, markdown, initialTitle) async {
          imports.add((path, markdown));
          return NotistFlowDocument(
            rootId: 'root-imported',
            title: '標題',
            filePath: path,
            folderPath: '研究',
          );
        },
      );
      await controller.load();
      controller.selectFolder('研究');

      await controller.importMarkdownAsFlow('# 標題');

      expect(store.lastAllocatedFolderPath, '研究');
      expect(imports, [('研究/new.krdf', '# 標題')]);
      expect(controller.documents.single.rootId, 'root-imported');
      expect(controller.selectedRootId, 'root-imported');
      expect(controller.selectedFolderPath, isNull);
    },
  );

  test(
    'imports Explorer clipboard Markdown at root without a folder',
    () async {
      final store = _MemoryProjectStore([]);
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) => throw UnimplementedError(),
        markdownImporter: (path, markdown, initialTitle) async =>
            NotistFlowDocument(
              rootId: 'root-imported',
              title: '標題',
              filePath: path,
            ),
      );
      await controller.load();

      await controller.importMarkdownAsFlow('# 標題');

      expect(store.lastAllocatedFolderPath, isNull);
      expect(controller.documents.single.filePath, 'new.krdf');
    },
  );

  test('does not publish an Explorer import that fails', () async {
    final store = _MemoryProjectStore(['a.krdf']);
    final controller = NotistProjectController(
      store: store,
      loader: (path, initialTitle) async => NotistFlowDocument(
        rootId: 'root-a',
        title: '既有 Flow',
        filePath: path,
      ),
      markdownImporter: (path, markdown, initialTitle) async =>
          throw StateError('import failed'),
    );
    await controller.load();

    await controller.importMarkdownAsFlow('# 失敗');

    expect(controller.documents.map((document) => document.rootId), ['root-a']);
    expect(controller.selectedRootId, 'root-a');
    expect(controller.createError, isA<StateError>());
  });

  test('imports a Markdown file with its stem as initial title', () async {
    final capturedTitles = <String>[];
    final controller = NotistProjectController(
      store: _MemoryProjectStore([]),
      loader: (path, initialTitle) => throw UnimplementedError(),
      markdownFileReader: (path) async => const NotistMarkdownFileSource(
        filePath: '研究.md',
        title: '研究',
        markdown: '# 內容',
      ),
      markdownImporter: (path, markdown, initialTitle) async {
        capturedTitles.add(initialTitle);
        return NotistFlowDocument(
          rootId: 'root-file',
          title: initialTitle,
          filePath: path,
        );
      },
    );
    await controller.load();

    await controller.importMarkdownFile('研究.md');

    expect(capturedTitles, ['研究']);
    expect(controller.documents.single.title, '研究');
  });

  test('updates Explorer title from the same root projection', () async {
    final controller = NotistProjectController(
      store: _MemoryProjectStore(['a.krdf']),
      loader: (path, initialTitle) async =>
          NotistFlowDocument(rootId: 'root-a', title: '舊標題', filePath: path),
    );
    await controller.load();

    controller.updateProjection(rootId: 'root-a', title: '新標題');

    expect(controller.documents.single.title, '新標題');
    expect(controller.selectedDocument?.title, '新標題');
  });

  test('coalesces concurrent create requests into one Flow', () async {
    final store = _MemoryProjectStore([]);
    final pending = Completer<NotistFlowDocument>();
    final controller = NotistProjectController(
      store: store,
      loader: (path, initialTitle) => pending.future,
    );
    await controller.load();

    final first = controller.createFlow();
    final second = controller.createFlow();
    expect(controller.isCreating, isTrue);
    expect(store.allocationCount, 1);
    pending.complete(
      const NotistFlowDocument(
        rootId: 'root-new',
        title: '',
        filePath: 'new.krdf',
      ),
    );
    await Future.wait([first, second]);

    expect(controller.documents, hasLength(1));
    expect(controller.isCreating, isFalse);
  });

  test('does not start create while project load is pending', () async {
    final store = _MemoryProjectStore([]);
    final pendingPaths = Completer<List<String>>();
    store.pendingPaths = pendingPaths;
    final controller = NotistProjectController(
      store: store,
      loader: (path, initialTitle) => throw UnimplementedError(),
    );

    final load = controller.load();
    final create = controller.createFlow();
    expect(store.allocationCount, 0);
    pendingPaths.complete([]);
    await Future.wait([load, create]);

    expect(controller.state, NotistProjectLoadState.ready);
  });

  test(
    'projects create loader failure without discarding loaded Flows',
    () async {
      final controller = NotistProjectController(
        store: _MemoryProjectStore(['a.krdf']),
        loader: (path, initialTitle) async {
          if (path == 'new.krdf') throw StateError('save failed');
          return NotistFlowDocument(
            rootId: 'root-a',
            title: '既有 Flow',
            filePath: path,
          );
        },
      );
      await controller.load();

      await controller.createFlow();

      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.single.rootId, 'root-a');
      expect(controller.createError, isA<StateError>());
    },
  );

  test(
    'projects path allocation failure without interrupting ready state',
    () async {
      final store = _MemoryProjectStore(['a.krdf']);
      store.allocationError = StateError('path unavailable');
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-a',
          title: '既有 Flow',
          filePath: path,
        ),
      );
      await controller.load();

      await controller.createFlow();

      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.single.rootId, 'root-a');
      expect(controller.createError, same(store.allocationError));
    },
  );

  test(
    'load failure from stale revision keeps last stable projection',
    () async {
      final store = _MemoryProjectStore(['good.krdf']);
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async {
          if (path == 'stale.krdf') {
            throw StateError('stale revision: 2 -> 3');
          }
          return NotistFlowDocument(
            rootId: 'root-good',
            title: '既有 Flow',
            filePath: path,
          );
        },
      );

      await controller.load();
      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.map((document) => document.rootId), [
        'root-good',
      ]);
      expect(controller.selectedRootId, 'root-good');

      store.paths
        ..clear()
        ..addAll(['good.krdf', 'stale.krdf']);

      await controller.load();

      expect(controller.state, NotistProjectLoadState.failed);
      expect(controller.error, isA<StateError>());
      expect(
        (controller.error as StateError).message,
        contains('stale revision'),
      );
      expect(controller.documents.map((document) => document.rootId), [
        'root-good',
      ]);
      expect(controller.selectedRootId, 'root-good');
    },
  );

  test('load failure from corrupt source keeps previous documents', () async {
    final store = _MemoryProjectStore(['good.krdf']);
    final controller = NotistProjectController(
      store: store,
      loader: (path, initialTitle) async {
        if (path == 'corrupt.krdf') {
          throw FormatException('corrupt krdf payload');
        }
        return NotistFlowDocument(
          rootId: 'root-good',
          title: '既有 Flow',
          filePath: path,
        );
      },
    );

    await controller.load();
    expect(controller.state, NotistProjectLoadState.ready);
    expect(controller.documents.map((document) => document.rootId), [
      'root-good',
    ]);

    store.paths
      ..clear()
      ..addAll(['good.krdf', 'corrupt.krdf']);

    await controller.load();

    expect(controller.state, NotistProjectLoadState.failed);
    expect(controller.error, isA<FormatException>());
    expect(controller.documents.map((document) => document.rootId), [
      'root-good',
    ]);
  });

  test(
    'load failure from missing source keeps prior state available',
    () async {
      final store = _MemoryProjectStore(['good.krdf']);
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async {
          if (path == 'missing.krdf') {
            throw const FileSystemException('source file missing');
          }
          return NotistFlowDocument(
            rootId: 'root-good',
            title: '既有 Flow',
            filePath: path,
          );
        },
      );

      await controller.load();
      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.map((document) => document.rootId), [
        'root-good',
      ]);

      store.paths
        ..clear()
        ..addAll(['good.krdf', 'missing.krdf']);

      await controller.load();

      expect(controller.state, NotistProjectLoadState.failed);
      expect(controller.error, isA<FileSystemException>());
      expect(controller.documents.map((document) => document.rootId), [
        'root-good',
      ]);
    },
  );

  test('loads pin state from persisted session data', () async {
    final projectDirectory = await Directory.systemTemp.createTemp(
      'notist-project-controller-load-pin-state-',
    );
    try {
      final stateFile = File(
        '${projectDirectory.path}${Platform.pathSeparator}.notist-notes-session.json',
      );
      await stateFile.writeAsString('{"pinnedRootIds":["root-a"]}');
      final store = NotistLocalProjectStore(projectDirectory.path);
      final flowPath =
          '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
      await File(flowPath).writeAsString('flow');
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-a',
          title: 'A Flow',
          filePath: path,
        ),
      );

      await controller.load();

      expect(controller.documents.single.isPinned, isTrue);
    } finally {
      if (await projectDirectory.exists()) {
        await projectDirectory.delete(recursive: true);
      }
    }
  });

  test('ignores invalid pin session data and keeps load functional', () async {
    final projectDirectory = await Directory.systemTemp.createTemp(
      'notist-project-controller-load-pin-state-bad-',
    );
    try {
      final stateFile = File(
        '${projectDirectory.path}${Platform.pathSeparator}.notist-notes-session.json',
      );
      await stateFile.writeAsString('{invalid-json}');
      final store = NotistLocalProjectStore(projectDirectory.path);
      final flowPath =
          '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
      await File(flowPath).writeAsString('flow');
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-a',
          title: 'A Flow',
          filePath: path,
        ),
      );

      await controller.load();

      expect(controller.state, NotistProjectLoadState.ready);
      expect(controller.documents.single.isPinned, isFalse);
    } finally {
      if (await projectDirectory.exists()) {
        await projectDirectory.delete(recursive: true);
      }
    }
  });

  test(
    'keeps pin projection and session state on pin persistence failure',
    () async {
      final projectDirectory = await Directory.systemTemp.createTemp(
        'notist-project-controller-setpin-fail-',
      );
      try {
        final flowPath =
            '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
        await File(flowPath).writeAsString('flow');
        final store = NotistLocalProjectStore(projectDirectory.path);
        final controller = NotistProjectController(
          store: store,
          loader: (path, initialTitle) async => NotistFlowDocument(
            rootId: 'root-a',
            title: 'A Flow',
            filePath: path,
          ),
        );

        await controller.load();

        final blockedStateTmp = Directory(
          '${projectDirectory.path}${Platform.pathSeparator}.notist-notes-session.json.tmp',
        );
        await blockedStateTmp.create();

        await controller.setPin('root-a', true);

        expect(controller.setPinError, isA<FileSystemException>());
        expect(controller.documents.single.isPinned, isFalse);
        expect(controller.pinnedRootIds, isEmpty);
        expect(await File(flowPath).exists(), isTrue);
      } finally {
        if (await projectDirectory.exists()) {
          await projectDirectory.delete(recursive: true);
        }
      }
    },
  );

  test('clears stale setPin error on no-op setPin', () async {
    final projectDirectory = await Directory.systemTemp.createTemp(
      'notist-project-controller-setpin-noop-',
    );
    try {
      final flowPath =
          '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
      await File(flowPath).writeAsString('flow');
      final controller = NotistProjectController(
        store: NotistLocalProjectStore(projectDirectory.path),
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-a',
          title: 'A Flow',
          filePath: path,
        ),
      );

      await controller.load();
      await controller.setPin('root-a', true);
      expect(controller.documents.single.isPinned, isTrue);

      final blockedStateTmp = Directory(
        '${projectDirectory.path}${Platform.pathSeparator}.notist-notes-session.json.tmp',
      );
      await blockedStateTmp.create();
      await controller.setPin('root-a', false);
      expect(controller.setPinError, isA<FileSystemException>());

      await controller.setPin('root-a', true);
      expect(controller.setPinError, isNull);
      expect(controller.documents.single.isPinned, isTrue);
    } finally {
      if (await projectDirectory.exists()) {
        await projectDirectory.delete(recursive: true);
      }
    }
  });

  test('keeps documents and file when delete persistence fails', () async {
    final projectDirectory = await Directory.systemTemp.createTemp(
      'notist-project-controller-delete-fail-',
    );
    try {
      final flowPath =
          '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
      await File(flowPath).writeAsString('flow');
      final store = NotistLocalProjectStore(projectDirectory.path);
      final controller = NotistProjectController(
        store: store,
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-a',
          title: 'A Flow',
          filePath: path,
        ),
      );

      await controller.load();

      final blockedStateTmp = Directory(
        '${projectDirectory.path}${Platform.pathSeparator}.notist-notes-session.json.tmp',
      );
      await blockedStateTmp.create();

      await controller.deleteFlow('root-a');

      expect(controller.deleteError, isA<FileSystemException>());
      expect(controller.documents.map((document) => document.rootId), [
        'root-a',
      ]);
      expect(controller.pinnedRootIds, isEmpty);
      expect(await File(flowPath).exists(), isTrue);
    } finally {
      if (await projectDirectory.exists()) {
        await projectDirectory.delete(recursive: true);
      }
    }
  });

  test(
    'keeps projection on move failure and can clear move error on no-op',
    () async {
      final projectDirectory = await Directory.systemTemp.createTemp(
        'notist-project-controller-move-fail-',
      );
      try {
        final flowPath =
            '${projectDirectory.path}${Platform.pathSeparator}root.krdf';
        await File(flowPath).writeAsString('flow');
        final store = NotistLocalProjectStore(projectDirectory.path);
        final controller = NotistProjectController(
          store: store,
          loader: (path, initialTitle) async => NotistFlowDocument(
            rootId: 'root-a',
            title: 'A Flow',
            filePath: path,
          ),
        );

        await controller.load();
        expect(controller.moveError, isNull);

        await controller.moveFlow('root-a', '不存在的資料夾');
        expect(controller.moveError, isA<ArgumentError>());
        expect(controller.documents.single.filePath, flowPath);
        expect(controller.selectedRootId, 'root-a');
        expect(await File(flowPath).exists(), isTrue);

        await controller.moveFlow('root-a', null);
        expect(controller.moveError, isNull);
        expect(controller.documents.single.filePath, flowPath);
      } finally {
        if (await projectDirectory.exists()) {
          await projectDirectory.delete(recursive: true);
        }
      }
    },
  );

  test('rejects duplicate roots before publishing load results', () async {
    final controller = NotistProjectController(
      store: _MemoryProjectStore(['a.krdf', 'b.krdf']),
      loader: (path, initialTitle) async =>
          NotistFlowDocument(rootId: 'duplicate', title: path, filePath: path),
    );

    await controller.load();

    expect(controller.state, NotistProjectLoadState.failed);
    expect(controller.documents, isEmpty);
    expect(controller.error, isA<StateError>());
  });

  test('rejects a newly created duplicate root before publication', () async {
    final controller = NotistProjectController(
      store: _MemoryProjectStore(['a.krdf']),
      loader: (path, initialTitle) async => NotistFlowDocument(
        rootId: 'duplicate',
        title: initialTitle.isEmpty ? '既有 Flow' : initialTitle,
        filePath: path,
      ),
    );
    await controller.load();

    await controller.createFlow();

    expect(controller.documents, hasLength(1));
    expect(controller.createError, isA<StateError>());
  });
}

final class _MemoryProjectStore implements NotistProjectStore {
  _MemoryProjectStore(this.paths, {this.folders = const []});

  @override
  final String directoryPath = '';
  final List<String> paths;
  final List<String> folders;
  Completer<List<String>>? pendingPaths;
  Object? allocationError;
  int allocationCount = 0;
  String? lastAllocatedFolderPath;

  @override
  Future<String> allocateFlowPath({String? folderPath}) async {
    allocationCount += 1;
    lastAllocatedFolderPath = folderPath;
    final caught = allocationError;
    if (caught != null) throw caught;
    return folderPath == null ? 'new.krdf' : '$folderPath/new.krdf';
  }

  @override
  Future<List<String>> listFolderPaths() async => List.of(folders);

  @override
  Future<List<NotistStoredFlow>> listFlows() async {
    final pending = pendingPaths;
    final resolved = pending == null ? List.of(paths) : await pending.future;
    return [
      for (final path in resolved)
        NotistStoredFlow(filePath: path, folderPath: ''),
    ];
  }
}
