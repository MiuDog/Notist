import 'package:flutter/foundation.dart';

import '../krepis/krepis_editor_controller.dart';
import '../markdown/notist_markdown_file_source.dart';
import 'notist_flow_document.dart';
import 'notist_project_store.dart';

typedef NotistFlowDocumentLoader =
    Future<NotistFlowDocument> Function(String filePath, String initialTitle);
typedef NotistMarkdownFlowImporter =
    Future<NotistFlowDocument> Function(
      String filePath,
      String markdown,
      String initialTitle,
    );

enum NotistProjectLoadState { idle, loading, ready, failed }

final class NotistProjectController extends ChangeNotifier {
  NotistProjectController({
    required this.store,
    required this.loader,
    this.markdownImporter,
    this.markdownFileReader = NotistMarkdownFileSourceReader.read,
  });

  factory NotistProjectController.local({required String directoryPath}) {
    return NotistProjectController(
      store: NotistLocalProjectStore(directoryPath),
      loader: _loadWithKrepis,
      markdownImporter: _importWithKrepis,
    );
  }

  final NotistProjectStore store;
  final NotistFlowDocumentLoader loader;
  final NotistMarkdownFlowImporter? markdownImporter;
  final NotistMarkdownFileReader markdownFileReader;
  final List<NotistFlowDocument> _documents = [];
  final List<String> _folderPaths = [];
  Future<void>? _loadOperation;
  Future<void>? _createOperation;

  NotistProjectLoadState state = NotistProjectLoadState.idle;
  Object? error;
  Object? createError;
  String? selectedRootId;
  String? selectedFolderPath;

  List<NotistFlowDocument> get documents => List.unmodifiable(_documents);
  List<String> get folderPaths => List.unmodifiable(_folderPaths);
  bool get isCreating => _createOperation != null;

  NotistFlowDocument? get selectedDocument {
    final rootId = selectedRootId;
    if (rootId == null) return null;
    for (final document in _documents) {
      if (document.rootId == rootId) return document;
    }
    return null;
  }

  Future<void> load() {
    final creating = _createOperation;
    if (creating != null) return creating;
    final loading = _loadOperation;
    if (loading != null) return loading;

    late final Future<void> operation;
    operation = _performLoad().whenComplete(() {
      if (identical(_loadOperation, operation)) _loadOperation = null;
    });
    _loadOperation = operation;
    return operation;
  }

  Future<void> createFlow({String title = ''}) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;

    late final Future<void> operation;
    operation = _performCreate(title).whenComplete(() {
      if (identical(_createOperation, operation)) _createOperation = null;
      notifyListeners();
    });
    _createOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> importMarkdownAsFlow(
    String markdown, {
    String initialTitle = '未命名 Flow',
  }) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;

    late final Future<void> operation;
    operation = _performMarkdownImport(markdown, initialTitle).whenComplete(() {
      if (identical(_createOperation, operation)) _createOperation = null;
      notifyListeners();
    });
    _createOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> importMarkdownFile(String sourcePath) async {
    try {
      final source = await markdownFileReader(sourcePath);
      await importMarkdownAsFlow(source.markdown, initialTitle: source.title);
    } catch (caught) {
      createError = caught;
      notifyListeners();
    }
  }

  Future<void> _performLoad() async {
    state = NotistProjectLoadState.loading;
    error = null;
    createError = null;
    notifyListeners();
    try {
      final folderPaths = await store.listFolderPaths();
      final loaded = <NotistFlowDocument>[];
      for (final flow in await store.listFlows()) {
        final projection = await loader(flow.filePath, '');
        final document = projection.withFolderPath(flow.folderPath);
        _rejectDuplicateRoot(loaded, document);
        loaded.add(document);
      }
      _folderPaths
        ..clear()
        ..addAll(folderPaths);
      _documents
        ..clear()
        ..addAll(loaded);
      selectedRootId = _documents.isEmpty ? null : _documents.first.rootId;
      selectedFolderPath = null;
      state = NotistProjectLoadState.ready;
    } catch (caught) {
      error = caught;
      state = NotistProjectLoadState.failed;
    }
    notifyListeners();
  }

  Future<void> _performCreate(String title) async {
    createError = null;
    try {
      final folderPath = selectedFolderPath;
      final path = await store.allocateFlowPath(folderPath: folderPath);
      final projection = await loader(path, title);
      final document = projection.withFolderPath(folderPath ?? '');
      _rejectDuplicateRoot(_documents, document);
      _documents.add(document);
      selectedRootId = document.rootId;
      selectedFolderPath = null;
      state = NotistProjectLoadState.ready;
      error = null;
    } catch (caught) {
      createError = caught;
    }
  }

  Future<void> _performMarkdownImport(
    String markdown,
    String initialTitle,
  ) async {
    createError = null;
    try {
      final importer = markdownImporter;
      if (importer == null) {
        throw UnsupportedError('此專案尚未提供 Markdown Flow 匯入');
      }
      final folderPath = selectedFolderPath;
      final path = await store.allocateFlowPath(folderPath: folderPath);
      final projection = await importer(path, markdown, initialTitle);
      final document = projection.withFolderPath(folderPath ?? '');
      _rejectDuplicateRoot(_documents, document);
      _documents.add(document);
      selectedRootId = document.rootId;
      selectedFolderPath = null;
      state = NotistProjectLoadState.ready;
      error = null;
    } catch (caught) {
      createError = caught;
    }
  }

  void select(String rootId) {
    if (_documents.every((document) => document.rootId != rootId)) {
      throw ArgumentError.value(rootId, 'rootId', '專案中不存在此 Flow');
    }
    if (selectedRootId == rootId && selectedFolderPath == null) return;
    selectedRootId = rootId;
    selectedFolderPath = null;
    notifyListeners();
  }

  void selectFolder(String folderPath) {
    if (!_folderPaths.contains(folderPath)) {
      throw ArgumentError.value(folderPath, 'folderPath', '專案中不存在此資料夾');
    }
    if (selectedFolderPath == folderPath) return;
    selectedFolderPath = folderPath;
    notifyListeners();
  }

  void updateProjection({
    required String rootId,
    required String title,
    int? blockCount,
  }) {
    final index = _documents.indexWhere(
      (document) => document.rootId == rootId,
    );
    if (index < 0) return;

    final current = _documents[index];
    final nextBlockCount = blockCount ?? current.blockCount;
    if (current.title == title && current.blockCount == nextBlockCount) return;

    _documents[index] = current.withProjection(
      title: title,
      blockCount: nextBlockCount,
    );
    notifyListeners();
  }

  void _rejectDuplicateRoot(
    List<NotistFlowDocument> existing,
    NotistFlowDocument candidate,
  ) {
    if (existing.every((document) => document.rootId != candidate.rootId)) {
      return;
    }

    throw StateError('Flow rootId 重複：${candidate.rootId}');
  }

  static Future<NotistFlowDocument> _loadWithKrepis(
    String filePath,
    String initialTitle,
  ) async {
    // 透過 Krepis 開啟並驗證檔案，避免由檔名猜測文件身分或標題。
    final authority = await KrepisEditorController.open(
      KrepisEditorOpenRequest(filePath: filePath, initialText: initialTitle),
    );
    try {
      final snapshot = authority.snapshot;
      if (snapshot == null) throw StateError('Krepis 未提供 Flow 文件投影');
      return NotistFlowDocument(
        rootId: snapshot.rootId,
        title: snapshot.title,
        filePath: filePath,
        blockCount: snapshot.blockCount,
      );
    } finally {
      authority.dispose();
    }
  }

  static Future<NotistFlowDocument> _importWithKrepis(
    String filePath,
    String markdown,
    String initialTitle,
  ) async {
    final authority = await KrepisEditorController.open(
      KrepisEditorOpenRequest(
        filePath: filePath,
        initialText: initialTitle,
        saveOnCreate: false,
      ),
    );
    try {
      authority.importMarkdown(
        markdown,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      final snapshot = authority.snapshot;
      if (snapshot == null) throw StateError('Krepis 未提供 Flow 文件投影');
      return NotistFlowDocument(
        rootId: snapshot.rootId,
        title: snapshot.title,
        filePath: filePath,
        blockCount: snapshot.blockCount,
      );
    } finally {
      authority.dispose();
    }
  }
}
