import 'dart:io';

final class NotistStoredFlow {
  const NotistStoredFlow({required this.filePath, required this.folderPath});

  final String filePath;
  final String folderPath;
}

abstract interface class NotistProjectStore {
  Future<List<NotistStoredFlow>> listFlows();
  Future<List<String>> listFolderPaths();
  Future<String> allocateFlowPath({String? folderPath});
}

final class NotistLocalProjectStore implements NotistProjectStore {
  NotistLocalProjectStore(this.directoryPath);

  final String directoryPath;

  @override
  Future<List<NotistStoredFlow>> listFlows() async {
    final directory = Directory(directoryPath).absolute;
    await directory.create(recursive: true);
    final flows = await directory
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is File && entity.path.endsWith('.krdf'))
        .map(
          (entity) => NotistStoredFlow(
            filePath: entity.path,
            folderPath: _relativeFolderPath(
              directory,
              File(entity.path).parent,
            ),
          ),
        )
        .toList();
    flows.sort((left, right) => left.filePath.compareTo(right.filePath));
    return flows;
  }

  @override
  Future<List<String>> listFolderPaths() async {
    final directory = Directory(directoryPath).absolute;
    await directory.create(recursive: true);
    final paths = await directory
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is Directory)
        .map((entity) => _relativeFolderPath(directory, Directory(entity.path)))
        .toList();
    paths.sort();
    return paths;
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
    return segments.join('/');
  }

  String _relativeFolderPath(Directory root, Directory folder) {
    if (folder.path == root.path) return '';
    final offset = root.path.endsWith(Platform.pathSeparator)
        ? root.path.length
        : root.path.length + 1;
    return folder.path
        .substring(offset)
        .split(Platform.pathSeparator)
        .join('/');
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
