/// Notist 專案模組。

library;

import 'dart:io';

final class NotistStoredFlow {
  const NotistStoredFlow({required this.filePath, required this.folderPath});

  final String filePath;
  final String folderPath;
}

abstract interface class NotistProjectStore {
  String get directoryPath;
  Future<List<NotistStoredFlow>> listFlows();
  Future<List<String>> listFolderPaths();
  Future<String> allocateFlowPath({String? folderPath});
}

final class NotistLocalProjectStore implements NotistProjectStore {
  NotistLocalProjectStore(this.directoryPath);

  @override
  final String directoryPath;

  @override
  Future<List<NotistStoredFlow>> listFlows() async {
    final directory = Directory(directoryPath).absolute;
    await directory.create(recursive: true);
    final flowEntities = <NotistStoredFlow>[];

    final rootEntries = await directory.list(followLinks: false).toList();
    for (final entity in rootEntries) {
      if (entity is File && entity.path.endsWith('.krdf')) {
        flowEntities.add(
          NotistStoredFlow(filePath: entity.path, folderPath: ''),
        );
      }
    }

    final folderEntries = await directory
        .list(followLinks: false)
        .where((entity) => entity is Directory)
        .toList();
    for (final entity in folderEntries) {
      final directoryName = _directoryName(entity.path);
      if (directoryName.startsWith('.')) continue;

      final folder = Directory(entity.path);
      final flowsInFolder = await folder
          .list(followLinks: false)
          .where(
            (nested) =>
                nested is File &&
                nested.path.endsWith('.krdf') &&
                nested.existsSync(),
          )
          .map(
            (nested) => NotistStoredFlow(
              filePath: nested.path,
              folderPath: directoryName,
            ),
          )
          .toList();
      flowEntities.addAll(flowsInFolder);
    }

    flowEntities.sort((left, right) => left.filePath.compareTo(right.filePath));
    return flowEntities;
  }

  @override
  Future<List<String>> listFolderPaths() async {
    final directory = Directory(directoryPath).absolute;
    await directory.create(recursive: true);
    final paths = await directory
        .list(followLinks: false)
        .where((entity) => entity is Directory)
        .map((entity) => _directoryName(entity.path))
        .where((name) => name.isNotEmpty && !name.startsWith('.'))
        .toList();
    final singleLayer = <String>[];
    for (final path in paths) {
      if (!path.contains('/')) {
        singleLayer.add(path);
      }
    }
    singleLayer.sort();
    return singleLayer;
  }

  @override
  Future<String> allocateFlowPath({String? folderPath}) async {
    final root = Directory(directoryPath).absolute;
    await root.create(recursive: true);
    final normalizedFolder = _normalizeFolderPath(folderPath);
    final directory = normalizedFolder.isEmpty
        ? root
        : Directory(
            [
              root.path,
              ...normalizedFolder.split('/'),
            ].join(Platform.pathSeparator),
          );
    if (!await directory.exists()) {
      throw FileSystemException('專案資料夾不存在', directory.path);
    }
    await _verifyInsideProject(root, directory);
    final seed = DateTime.now().microsecondsSinceEpoch;
    var suffix = 0;
    while (true) {
      final discriminator = suffix == 0 ? '$seed' : '$seed-$suffix';
      final path =
          '${directory.path}${Platform.pathSeparator}flow-$discriminator.krdf';
      if (!File(path).existsSync()) return path;
      suffix += 1;
    }
  }

  String _directoryName(String path) {
    final index = path.lastIndexOf(Platform.pathSeparator);
    if (index >= 0) return path.substring(index + 1);
    return path;
  }

  String _normalizeFolderPath(String? folderPath) {
    if (folderPath == null || folderPath.isEmpty) return '';
    if (folderPath.startsWith('/') ||
        folderPath.startsWith(r'\') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(folderPath)) {
      throw ArgumentError.value(folderPath, 'folderPath', '必須是專案內相對路徑');
    }
    final segments = folderPath.split(RegExp(r'[\\/]'));
    if (segments.any(
      (segment) => segment.isEmpty || segment == '.' || segment == '..',
    )) {
      throw ArgumentError.value(folderPath, 'folderPath', '不得離開專案根目錄');
    }
    if (segments.length != 1) {
      throw ArgumentError.value(folderPath, 'folderPath', '目前僅支援單層資料夾');
    }
    return segments.join('/');
  }

  Future<void> _verifyInsideProject(Directory root, Directory folder) async {
    final resolvedRoot = await root.resolveSymbolicLinks();
    final resolvedFolder = await folder.resolveSymbolicLinks();
    final rootPrefix = resolvedRoot.endsWith(Platform.pathSeparator)
        ? resolvedRoot
        : '$resolvedRoot${Platform.pathSeparator}';
    final rootComparison = Platform.isWindows
        ? rootPrefix.toLowerCase()
        : rootPrefix;
    final folderComparison = Platform.isWindows
        ? resolvedFolder.toLowerCase()
        : resolvedFolder;
    final exactRoot = Platform.isWindows
        ? resolvedRoot.toLowerCase()
        : resolvedRoot;
    if (folderComparison != exactRoot &&
        !folderComparison.startsWith(rootComparison)) {
      throw ArgumentError.value(folder.path, 'folderPath', '不得離開專案根目錄');
    }
  }
}
