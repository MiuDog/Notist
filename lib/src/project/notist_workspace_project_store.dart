/// Notist 專案模組。

library;

import 'dart:io';
import 'dart:convert';

final class NotistWorkspaceProjectEntry {
  const NotistWorkspaceProjectEntry({
    required this.name,
    required this.path,
    this.isRoot = false,
  });

  final String name;
  final String path;
  final bool isRoot;
}

abstract interface class NotistWorkspaceProjectStore {
  Future<List<NotistWorkspaceProjectEntry>> listProjects();
  Future<NotistWorkspaceProjectEntry> createProject(String name);
  Future<void> deleteProject(String name);
  Future<String?> loadActiveProjectPath();
  Future<void> saveActiveProjectPath(String path);
}

final class NotistLocalWorkspaceProjectStore
    implements NotistWorkspaceProjectStore {
  const NotistLocalWorkspaceProjectStore(this.rootPath);

  final String rootPath;
  static const String _configFileName = '.notist-workspace-session.json';
  static const String _activeProjectKey = 'activeProjectPath';
  static const Set<String> _ignoredFolderNames = <String>{
    'build',
    '.git',
    '.github',
    '.idea',
    '.vscode',
    '.dart_tool',
  };

  static const _rootProjectName = '根目錄專案';

  @override
  Future<List<NotistWorkspaceProjectEntry>> listProjects() async {
    final root = Directory(rootPath).absolute;
    await root.create(recursive: true);

    final entries = <NotistWorkspaceProjectEntry>[
      NotistWorkspaceProjectEntry(
        name: _rootProjectName,
        path: root.path,
        isRoot: true,
      ),
      for (final entity
          in await root
              .list(followLinks: false)
              .where((entity) => entity is Directory)
              .map((entity) => _directoryName(entity.path))
              .where((name) => !_isIgnoredWorkspaceFolder(name))
              .toList())
        NotistWorkspaceProjectEntry(
          name: entity,
          path: '${root.path}${Platform.pathSeparator}$entity',
        ),
    ];
    entries.sort((left, right) => left.name.compareTo(right.name));
    return entries;
  }

  @override
  Future<NotistWorkspaceProjectEntry> createProject(String name) async {
    final root = Directory(rootPath).absolute;
    await root.create(recursive: true);
    final sanitized = _sanitizeName(name);
    if (sanitized == _rootProjectName) {
      throw StateError('專案名稱「$_rootProjectName」為系統保留名稱');
    }
    if (_isIgnoredWorkspaceFolder(sanitized)) {
      throw StateError('專案名稱「$sanitized」為系統保留名稱');
    }

    final path = '${root.path}${Platform.pathSeparator}$sanitized';
    final directory = Directory(path);
    if (await directory.exists()) {
      throw StateError('專案「$sanitized」已存在');
    }

    await directory.create(recursive: true);
    return NotistWorkspaceProjectEntry(name: sanitized, path: directory.path);
  }

  @override
  Future<void> deleteProject(String name) async {
    final root = Directory(rootPath).absolute;
    final sanitized = _sanitizeName(name);
    if (sanitized == _rootProjectName) {
      throw StateError('不能刪除根目錄專案');
    }
    if (_isIgnoredWorkspaceFolder(sanitized)) {
      throw StateError('不能刪除系統保留資料夾');
    }

    final project = Directory(
      '${root.path}${Platform.pathSeparator}$sanitized',
    );
    if (!await project.exists()) return;

    // 刪除目前專案前先切換到根目錄，避免重啟時指向不存在的資料夾。
    final activePath = await loadActiveProjectPath();
    final wasActive = activePath != null && _samePath(activePath, project.path);
    if (wasActive) await saveActiveProjectPath(root.path);

    try {
      await project.delete(recursive: true);
    } catch (_) {
      // 刪除失敗時恢復原本的選取專案，讓記憶體與磁碟投影維持一致。
      if (wasActive) await saveActiveProjectPath(project.path);
      rethrow;
    }
  }

  @override
  Future<String?> loadActiveProjectPath() async {
    final root = Directory(rootPath).absolute;
    final configFile = _configFileFor(root);
    if (!await configFile.exists()) return null;

    final raw = await configFile.readAsString();
    final Object? data;
    try {
      data = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (data is! Map<String, Object?>) {
      return null;
    }

    final path = data[_activeProjectKey];
    if (path is! String || path.trim().isEmpty) return null;

    final normalized = _normalizeProjectPath(root, path);
    final candidate = Directory(normalized);
    if (!await candidate.exists()) return null;
    try {
      await _verifyInsideProject(root, candidate);
    } catch (_) {
      return null;
    }
    return normalized;
  }

  @override
  Future<void> saveActiveProjectPath(String path) async {
    final root = Directory(rootPath).absolute;
    final normalized = _normalizeProjectPath(root, path);
    final directory = Directory(normalized);
    if (!await directory.exists()) {
      throw StateError('專案路徑不存在，無法設為目前專案');
    }
    await _verifyInsideProject(root, directory);

    final configFile = _configFileFor(root);
    await configFile.parent.create(recursive: true);
    final temporary = File('${configFile.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({_activeProjectKey: normalized}),
      flush: true,
    );
    if (await configFile.exists()) await configFile.delete();
    await temporary.rename(configFile.path);
  }

  File _configFileFor(Directory root) {
    return File('${root.path}${Platform.pathSeparator}$_configFileName');
  }

  String _sanitizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('專案名稱不能是空白');
    }
    if (RegExp(r'[\\/:*?"<>|]').hasMatch(trimmed)) {
      throw StateError('專案名稱含有無效字元');
    }
    if (trimmed == '.' || trimmed == '..') {
      throw StateError('專案名稱不能是系統保留名稱');
    }
    if (trimmed.contains('/') || trimmed.contains('\\')) {
      throw StateError('專案名稱不能包含路徑分隔符號');
    }
    return trimmed;
  }

  String _directoryName(String path) {
    if (path.isEmpty) return path;
    final normalized = path.replaceAll('\\', '/');
    final separator = normalized.lastIndexOf('/');
    return separator < 0 ? path : normalized.substring(separator + 1);
  }

  bool _isIgnoredWorkspaceFolder(String folderName) {
    if (folderName.isEmpty) return true;
    final trimmed = folderName.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.startsWith('.')) return true;
    final lower = trimmed.toLowerCase();
    return _ignoredFolderNames.contains(lower);
  }

  bool _samePath(String left, String right) {
    if (Platform.isWindows) return left.toLowerCase() == right.toLowerCase();
    return left == right;
  }

  String _normalizeProjectPath(Directory root, String projectPath) {
    final candidate = Directory(projectPath).absolute;
    return candidate.path;
  }

  Future<void> _verifyInsideProject(Directory root, Directory directory) async {
    final resolvedRoot = await root.resolveSymbolicLinks();
    final resolvedDirectory = await directory.resolveSymbolicLinks();
    final rootPrefix = resolvedRoot.endsWith(Platform.pathSeparator)
        ? resolvedRoot
        : '$resolvedRoot${Platform.pathSeparator}';
    final rootComparison = Platform.isWindows
        ? rootPrefix.toLowerCase()
        : rootPrefix;
    final directoryComparison = Platform.isWindows
        ? resolvedDirectory.toLowerCase()
        : resolvedDirectory;

    final exactRoot = Platform.isWindows
        ? resolvedRoot.toLowerCase()
        : resolvedRoot;
    if (directoryComparison != exactRoot &&
        !directoryComparison.startsWith(rootComparison)) {
      throw StateError('專案路徑必須位於目前根目錄之內');
    }
  }
}
