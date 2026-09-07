/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

typedef NotistFlowEditorBuilder =
    Widget Function(BuildContext context, String filePath);

class NotistProjectPage extends StatelessWidget {
  const NotistProjectPage({
    super.key,
    required this.filePath,
    required this.editorBuilder,
    this.onCreate,
  });

  final String filePath;
  final NotistFlowEditorBuilder editorBuilder;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    if (filePath.isEmpty) {
      return Center(
        key: const ValueKey('workspace-project-page'),
        child: KlpEmptyState(
          icon: KlpIcons.folder,
          title: '尚無 Flow',
          message: '建立 Flow 後，內容會顯示在這裡。',
          action: onCreate == null
              ? null
              : KlpButton(label: '新增 Flow', onPressed: onCreate),
        ),
      );
    }
    return SizedBox.expand(
      key: const ValueKey('workspace-project-page'),
      child: editorBuilder(context, filePath),
    );
  }
}
