/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:io';

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
  static const String _notesStateFileName = '.notist-notes-session.json';
  static const String _pinnedRootIdsKey = 'pinnedRootIds';

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
  final Set<String> _pinnedRootIds = {};
  Future<void>? _loadOperation;
  Future<void>? _createOperation;
  Future<void>? _createFolderOperation;
  Future<void>? _deleteOperation;
  Future<void>? _deleteFolderOperation;
  Future<void>? _renameFolderOperation;
  Future<void>? _moveOperation;

  NotistProjectLoadState state = NotistProjectLoadState.idle;
  Object? error;
  Object? createError;
  Object? createFolderError;
  Object? deleteFolderError;
  Object? renameFolderError;
  Object? deleteError;
  Object? setPinError;
  Object? moveError;
  String? selectedRootId;
  String? selectedFolderPath;

  List<NotistFlowDocument> get documents => List.unmodifiable(_documents);
  List<String> get folderPaths => List.unmodifiable(_folderPaths);
  Set<String> get pinnedRootIds => Set.unmodifiable(_pinnedRootIds);
  bool get isCreating => _createOperation != null;
  bool get isCreatingFolder =>
      _createFolderOperation != null ||
      _deleteFolderOperation != null ||
      _renameFolderOperation != null;
  bool get isDeletingFolder => _deleteFolderOperation != null;
  bool get isRenamingFolder => _renameFolderOperation != null;
  bool get isDeleting => _deleteOperation != null;
  bool get isMoving => _moveOperation != null;

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
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;

    late final Future<void> operation;
    operation = _performCreate(title).whenComplete(() {
      if (identical(_createOperation, operation)) _createOperation = null;
      notifyListeners();
    });
    _createOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> deleteFlow(String rootId) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performDelete(rootId).whenComplete(() {
      if (identical(_deleteOperation, operation)) _deleteOperation = null;
      notifyListeners();
    });
    _deleteOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> setPin(String rootId, bool isPinned) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performSetPin(rootId, isPinned).whenComplete(() {
      notifyListeners();
    });
    notifyListeners();
    return operation;
  }

  Future<void> moveFlow(String rootId, String? folderPath) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performMove(rootId, folderPath).whenComplete(() {
      if (identical(_moveOperation, operation)) _moveOperation = null;
      notifyListeners();
    });
    _moveOperation = operation;
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
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

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
    createFolderError = null;
    renameFolderError = null;
    deleteFolderError = null;
    deleteError = null;
    setPinError = null;
    moveError = null;
    notifyListeners();
    try {
      final folderPaths = await store.listFolderPaths();
      final pinnedRootIds = await _loadPinnedRootIds();
      final loaded = <NotistFlowDocument>[];
      for (final flow in await store.listFlows()) {
        final projection = await loader(flow.filePath, '');
        final document = NotistFlowDocument(
          rootId: projection.rootId,
          title: projection.title,
          filePath: projection.filePath,
          folderPath: flow.folderPath,
          isPinned: pinnedRootIds.contains(projection.rootId),
          blockCount: projection.blockCount,
        );
        _rejectDuplicateRoot(loaded, document);
        loaded.add(document);
      }
      _folderPaths
        ..clear()
        ..addAll(folderPaths);
      _documents
        ..clear()
        ..addAll(loaded);
      _pinnedRootIds
        ..clear()
        ..addAll(pinnedRootIds);
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
    if (selectedFolderPath != null &&
        !_folderPaths.contains(selectedFolderPath)) {
      selectedFolderPath = null;
    }
    createError = null;
    try {
      final folderPath = selectedFolderPath;
      final path = await store.allocateFlowPath(folderPath: folderPath);
      final projection = await loader(path, title);
      final document = NotistFlowDocument(
        rootId: projection.rootId,
        title: projection.title,
        filePath: projection.filePath,
        folderPath: folderPath ?? '',
        blockCount: projection.blockCount,
      );
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
    if (selectedFolderPath != null &&
        !_folderPaths.contains(selectedFolderPath)) {
      selectedFolderPath = null;
    }
    createError = null;
    try {
      final importer = markdownImporter;
      if (importer == null) {
        throw UnsupportedError('此專案尚未提供 Markdown Flow 匯入');
      }
      final folderPath = selectedFolderPath;
      final path = await store.allocateFlowPath(folderPath: folderPath);
      final projection = await importer(path, markdown, initialTitle);
      final document = NotistFlowDocument(
        rootId: projection.rootId,
        title: projection.title,
        filePath: projection.filePath,
        folderPath: folderPath ?? '',
        blockCount: projection.blockCount,
      );
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

  Future<void> _performDelete(String rootId) async {
    deleteError = null;
    final documentsSnapshot = List.of(_documents);
    final pinnedRootIdsSnapshot = Set<String>.of(_pinnedRootIds);
    final selectedRootIdSnapshot = selectedRootId;
    final selectedFolderPathSnapshot = selectedFolderPath;
    String? backupPath;
    String? deletedFilePath;

    try {
      final index = _documents.indexWhere(
        (document) => document.rootId == rootId,
      );
      if (index < 0) {
        throw ArgumentError.value(rootId, 'rootId', '專案中不存在此 Flow');
      }

      final document = _documents[index];
      deletedFilePath = document.filePath;
      final file = File(document.filePath);
      if (await file.exists()) {
        backupPath =
            '${document.filePath}.delete-${DateTime.now().microsecondsSinceEpoch}.bak';
        await file.rename(backupPath);
      }
      _documents.removeAt(index);
      _pinnedRootIds.remove(rootId);
      await _savePinnedRootIds();
      if (selectedRootId == rootId) {
        selectedRootId = _documents.isEmpty ? null : _documents.first.rootId;
        selectedFolderPath = null;
      }

      state = NotistProjectLoadState.ready;
      error = null;
      deleteError = null;
      if (backupPath != null) {
        try {
          await File(backupPath).delete();
        } catch (_) {
          // 備份已完成持久化後，清理失敗不影響主流程完成
        }
      }
    } catch (caught) {
      if (backupPath != null) {
        final backup = File(backupPath);
        if (await backup.exists()) {
          final destinationPath = deletedFilePath;
          try {
            if (destinationPath == null) return;
            await backup.rename(destinationPath);
          } catch (_) {
            // 回復實作保留原檔，不因還原失敗拋出第二個錯誤
            try {
              if (destinationPath == null) return;
              final original = File(destinationPath);
              if (!await original.exists()) {
                await backup.copy(destinationPath);
              }
              await backup.delete();
            } catch (_) {
              // 回復實作保留原檔，不因還原失敗拋出第二個錯誤
            }
          }
        }
      }
      _documents
        ..clear()
        ..addAll(documentsSnapshot);
      _pinnedRootIds
        ..clear()
        ..addAll(pinnedRootIdsSnapshot);
      selectedRootId = selectedRootIdSnapshot;
      selectedFolderPath = selectedFolderPathSnapshot;
      deleteError = caught;
    }
  }

  Future<void> _performSetPin(String rootId, bool isPinned) async {
    setPinError = null;
    final documentsSnapshot = List.of(_documents);
    final pinnedRootIdsSnapshot = Set<String>.of(_pinnedRootIds);
    try {
      final index = _documents.indexWhere(
        (document) => document.rootId == rootId,
      );
      if (index < 0) {
        throw ArgumentError.value(rootId, 'rootId', '專案中不存在此 Flow');
      }

      final current = _documents[index];
      if (current.isPinned == isPinned) {
        setPinError = null;
        return;
      }

      final next = NotistFlowDocument(
        rootId: current.rootId,
        title: current.title,
        filePath: current.filePath,
        folderPath: current.folderPath,
        isPinned: isPinned,
        blockCount: current.blockCount,
      );
      _documents[index] = next;
      if (isPinned) {
        _pinnedRootIds.add(rootId);
      } else {
        _pinnedRootIds.remove(rootId);
      }

      await _savePinnedRootIds();
      state = NotistProjectLoadState.ready;
      error = null;
    } catch (caught) {
      _documents
        ..clear()
        ..addAll(documentsSnapshot);
      _pinnedRootIds
        ..clear()
        ..addAll(pinnedRootIdsSnapshot);
      setPinError = caught;
    }
  }

  Future<void> _performMove(String rootId, String? folderPath) async {
    moveError = null;
    final documentsSnapshot = List.of(_documents);
    final selectedRootIdSnapshot = selectedRootId;
    final selectedFolderPathSnapshot = selectedFolderPath;
    String? originalPath;
    String? destinationPath;
    try {
      final index = _documents.indexWhere(
        (document) => document.rootId == rootId,
      );
      if (index < 0) {
        throw ArgumentError.value(rootId, 'rootId', '專案中不存在此 Flow');
      }

      final target = folderPath ?? '';
      if (target.isNotEmpty && !_folderPaths.contains(target)) {
        throw ArgumentError.value(target, 'folderPath', '目標資料夾不存在');
      }

      final current = _documents[index];
      if (current.folderPath == target) {
        moveError = null;
        return;
      }

      final destinationDirectory = target.isEmpty
          ? Directory(store.directoryPath)
          : Directory(
              '${store.directoryPath}${Platform.pathSeparator}'
              '${target.replaceAll('/', Platform.pathSeparator)}',
            );
      final fileName = current.filePath.replaceAll(r'\', '/').split('/').last;
      final destination = File(
        '${destinationDirectory.path}${Platform.pathSeparator}$fileName',
      );

      if (!await destinationDirectory.exists()) {
        throw StateError('目標資料夾不存在：${destinationDirectory.path}');
      }
      if (await destination.exists()) {
        throw StateError('目標位置已有同名筆記：$fileName');
      }

      originalPath = current.filePath;
      destinationPath = destination.path;
      await File(current.filePath).rename(destination.path);
      _documents[index] = NotistFlowDocument(
        rootId: current.rootId,
        title: current.title,
        filePath: destination.path,
        folderPath: target,
        isPinned: current.isPinned,
        blockCount: current.blockCount,
      );

      state = NotistProjectLoadState.ready;
      error = null;
    } catch (caught) {
      if (destinationPath != null && originalPath != null) {
        try {
          final movedFile = File(destinationPath);
          if (await movedFile.exists()) {
            await movedFile.rename(originalPath);
          }
        } catch (_) {
          // 回復還原失敗不改變錯誤訊息來源。
        }
      }
      _documents
        ..clear()
        ..addAll(documentsSnapshot);
      selectedRootId = selectedRootIdSnapshot;
      selectedFolderPath = selectedFolderPathSnapshot;
      moveError = caught;
    }
  }

  Future<void> createFolder(String folderName) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performCreateFolder(folderName).whenComplete(() {
      if (identical(_createFolderOperation, operation)) {
        _createFolderOperation = null;
      }
      notifyListeners();
    });
    _createFolderOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> deleteFolder(String folderPath) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performDeleteFolder(folderPath).whenComplete(() {
      if (identical(_deleteFolderOperation, operation)) {
        _deleteFolderOperation = null;
      }
      notifyListeners();
    });
    _deleteFolderOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> renameFolder(String folderPath, String newFolderName) {
    final loading = _loadOperation;
    if (loading != null) return loading;
    final creating = _createOperation;
    if (creating != null) return creating;
    final creatingFolder = _createFolderOperation;
    if (creatingFolder != null) return creatingFolder;
    final deletingFolder = _deleteFolderOperation;
    if (deletingFolder != null) return deletingFolder;
    final renamingFolder = _renameFolderOperation;
    if (renamingFolder != null) return renamingFolder;
    final deleting = _deleteOperation;
    if (deleting != null) return deleting;
    final moving = _moveOperation;
    if (moving != null) return moving;

    late final Future<void> operation;
    operation = _performRenameFolder(folderPath, newFolderName).whenComplete(
      () {
        if (identical(_renameFolderOperation, operation)) {
          _renameFolderOperation = null;
        }
        notifyListeners();
      },
    );
    _renameFolderOperation = operation;
    notifyListeners();
    return operation;
  }

  Future<void> _performCreateFolder(String folderName) async {
    createFolderError = null;
    try {
      final normalized = _normalizeFolderName(folderName);
      final path = '${store.directoryPath}${Platform.pathSeparator}$normalized';
      final directory = Directory(path);
      if (await directory.exists()) {
        throw StateError('資料夾「$normalized」已存在');
      }
      await directory.create(recursive: false);
      if (!_folderPaths.contains(normalized)) {
        _folderPaths.add(normalized);
        _folderPaths.sort();
      }
      selectedFolderPath = normalized;
      createFolderError = null;
      state = NotistProjectLoadState.ready;
      error = null;
    } catch (caught) {
      createFolderError = caught;
    }
  }

  Future<void> _performRenameFolder(
    String folderPath,
    String newFolderName,
  ) async {
    renameFolderError = null;
    try {
      final trimmedOld = folderPath.trim();
      if (trimmedOld.isEmpty) {
        throw ArgumentError.value(folderPath, 'folderPath', '資料夾路徑不能是空白');
      }
      if (!_folderPaths.contains(trimmedOld)) {
        throw ArgumentError.value(folderPath, 'folderPath', '資料夾不存在');
      }
      final normalizedNew = _normalizeFolderName(newFolderName);
      if (trimmedOld == normalizedNew) {
        return;
      }
      if (_folderPaths.contains(normalizedNew)) {
        throw StateError('目標名稱「$normalizedNew」已存在');
      }

      final source = Directory(
        '${store.directoryPath}${Platform.pathSeparator}$trimmedOld',
      );
      final target = Directory(
        '${store.directoryPath}${Platform.pathSeparator}$normalizedNew',
      );
      if (!await source.exists()) {
        _folderPaths.remove(trimmedOld);
        throw StateError('資料夾「$trimmedOld」不存在');
      }
      if (await target.exists()) {
        throw StateError('目標名稱「$normalizedNew」已存在');
      }

      await source.rename(target.path);
      _folderPaths.remove(trimmedOld);
      _folderPaths.add(normalizedNew);
      _folderPaths.sort();
      for (var i = 0; i < _documents.length; i++) {
        final document = _documents[i];
        if (document.folderPath == trimmedOld) {
          _documents[i] = NotistFlowDocument(
            rootId: document.rootId,
            title: document.title,
            filePath: document.filePath,
            folderPath: normalizedNew,
            isPinned: document.isPinned,
            blockCount: document.blockCount,
          );
        }
      }
      if (selectedFolderPath == trimmedOld) {
        selectedFolderPath = normalizedNew;
      }

      error = null;
    } catch (caught) {
      renameFolderError = caught;
    }
  }

  Future<void> _performDeleteFolder(String folderPath) async {
    deleteFolderError = null;
    renameFolderError = null;
    try {
      final trimmed = folderPath.trim();
      if (!_folderPaths.contains(trimmed)) {
        throw ArgumentError.value(folderPath, 'folderPath', '資料夾不存在');
      }
      if (_documents.any((document) => document.folderPath == trimmed)) {
        throw StateError('資料夾「$trimmed」仍有筆記，請先移出後再刪除');
      }
      final directory = Directory(
        '${store.directoryPath}${Platform.pathSeparator}$trimmed',
      );
      if (!await directory.exists()) {
        _folderPaths.remove(trimmed);
        throw StateError('資料夾「$trimmed」不存在');
      }
      await directory.delete();
      _folderPaths.remove(trimmed);
      if (selectedFolderPath == trimmed) {
        selectedFolderPath = null;
      }
    } catch (caught) {
      deleteFolderError = caught;
    } finally {
      if (deleteFolderError == null) {
        error = null;
      }
    }
  }

  String _normalizeFolderName(String folderName) {
    final trimmed = folderName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(folderName, 'folderName', '資料夾名稱不能是空白');
    }
    if (trimmed == '.' || trimmed == '..') {
      throw ArgumentError.value(folderName, 'folderName', '資料夾名稱不能使用系統保留名稱');
    }
    if (trimmed.contains('/') || trimmed.contains('\\')) {
      throw ArgumentError.value(folderName, 'folderName', '資料夾名稱不能包含目錄分隔符');
    }
    if (trimmed.startsWith('.') && trimmed.endsWith('.')) {
      throw ArgumentError.value(folderName, 'folderName', '資料夾名稱不能為隱藏資料夾');
    }
    if (trimmed.isEmpty || RegExp(r'[\\/:*?"<>|]').hasMatch(trimmed)) {
      throw ArgumentError.value(folderName, 'folderName', '資料夾名稱包含無效字元');
    }
    return trimmed;
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

  Future<Set<String>> _loadPinnedRootIds() async {
    final file = File(
      '${store.directoryPath}${Platform.pathSeparator}$_notesStateFileName',
    );
    if (!await file.exists()) return {};
    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is! Map<String, Object?>) return {};

      final list = data[_pinnedRootIdsKey];
      if (list is! List) return {};
      final values = <String>{};
      for (final value in list) {
        if (value is String && value.isNotEmpty) values.add(value);
      }
      return values;
    } catch (_) {
      return {};
    }
  }

  Future<void> _savePinnedRootIds() async {
    final file = File(
      '${store.directoryPath}${Platform.pathSeparator}$_notesStateFileName',
    );
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    try {
      await temporary.writeAsString(
        jsonEncode({_pinnedRootIdsKey: _pinnedRootIds.toList()}),
        flush: true,
      );
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
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
