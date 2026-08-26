import 'dart:convert';
import 'dart:io';

final class NotistMarkdownFileSource {
  const NotistMarkdownFileSource({
    required this.filePath,
    required this.title,
    required this.markdown,
  });

  final String filePath;
  final String title;
  final String markdown;
}

typedef NotistMarkdownFileReader =
    Future<NotistMarkdownFileSource> Function(String filePath);

abstract final class NotistMarkdownFileSourceReader {
  static const int maxByteCount = 8 * 1024 * 1024;

  static Future<NotistMarkdownFileSource> read(String filePath) async {
    final file = File(filePath);
    final type = await FileSystemEntity.type(file.path, followLinks: true);
    if (type != FileSystemEntityType.file) {
      throw FileSystemException('Markdown 來源不是一般檔案', file.path);
    }
    final title = _titleFromPath(file.path);
    final byteCount = await file.length();
    if (byteCount > maxByteCount) {
      throw FileSystemException('Markdown 來源超過 8 MiB', file.path);
    }

    // 來源檔只讀取一次，嚴格 UTF-8 解碼，不以 replacement character 掩蓋壞資料。
    final bytes = await file.readAsBytes();
    final markdown = utf8.decode(bytes, allowMalformed: false);
    return NotistMarkdownFileSource(
      filePath: file.path,
      title: title,
      markdown: markdown.startsWith('\uFEFF')
          ? markdown.substring(1)
          : markdown,
    );
  }

  static String _titleFromPath(String filePath) {
    final name = filePath.split(RegExp(r'[\\/]')).last;
    if (!name.toLowerCase().endsWith('.md') || name.length <= 3) {
      throw ArgumentError.value(filePath, 'filePath', '必須是具名 .md 檔案');
    }
    return name.substring(0, name.length - 3);
  }
}
