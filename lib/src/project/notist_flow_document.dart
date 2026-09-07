/// Notist 專案模組。

library;

final class NotistFlowDocument {
  const NotistFlowDocument({
    required this.rootId,
    required this.title,
    required this.filePath,
    this.folderPath = '',
    this.isPinned = false,
    this.blockCount = 0,
  });

  final String rootId;
  final String title;
  final String filePath;
  final String folderPath;
  final bool isPinned;
  final int blockCount;

  NotistFlowDocument withProjection({
    required String title,
    required int blockCount,
  }) {
    return NotistFlowDocument(
      rootId: rootId,
      title: title,
      filePath: filePath,
      folderPath: folderPath,
      isPinned: isPinned,
      blockCount: blockCount,
    );
  }

  NotistFlowDocument withFolderPath(String nextFolderPath) {
    return NotistFlowDocument(
      rootId: rootId,
      title: title,
      filePath: filePath,
      folderPath: nextFolderPath,
      isPinned: isPinned,
      blockCount: blockCount,
    );
  }
}
