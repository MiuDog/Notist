import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_flow_document.dart';
import '../project/notist_project_controller.dart';

/// Notist FileExplorer 的產品投影。
///
/// 所有視覺節點都由 Kallopis 組合；本元件只處理 Flow、資料夾與貼上 intent。
class NotistSidebarExplorer extends StatefulWidget {
  const NotistSidebarExplorer({
    super.key,
    required this.controller,
    this.onDocumentSelected,
  });

  final NotistProjectController? controller;
  final ValueChanged<String>? onDocumentSelected;

  @override
  State<NotistSidebarExplorer> createState() => _NotistSidebarExplorerState();
}

class _NotistSidebarExplorerState extends State<NotistSidebarExplorer> {
  static const _folderIdPrefix = 'notist-folder:';
  final FocusNode _focusNode = FocusNode(debugLabel: 'Notist Explorer');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.controller;
    if (project == null) return _buildUnavailable(context);
    if (project.state == NotistProjectLoadState.loading) {
      return const KlpLoadingState(label: '正在載入 Flow');
    }
    if (project.state == NotistProjectLoadState.failed) {
      return KlpErrorState(
        title: '無法載入 Flow 專案',
        message: '${project.error}',
        retryLabel: '重試',
        onRetry: project.load,
      );
    }

    final content = project.documents.isEmpty && project.folderPaths.isEmpty
        ? KlpEmptyState(
            icon: KlpIcons.folder,
            title: '尚無 Flow',
            message: '建立第一個 Flow 後即可開始筆記。',
            action: KlpButton(
              label: project.isCreating ? '正在建立 Flow' : '新增 Flow',
              onPressed: project.isCreating ? null : project.createFlow,
            ),
          )
        : KlpFileExplorer(
            sections: _buildSections(project),
            selectedId: switch (project.selectedFolderPath) {
              final folderPath? => '$_folderIdPrefix$folderPath',
              null => project.selectedRootId,
            },
            onItemSelected: (id) => _selectExplorerItem(project, id),
          );

    final createError = project.createError;
    final body = createError == null
        ? content
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.klp.space.base),
                child: KlpInlineNotice(
                  title: '建立 Flow 失敗',
                  message: '$createError',
                  tone: KlpFeedbackTone.danger,
                  action: KlpButton(
                    label: '重試',
                    onPressed: project.isCreating ? null : project.createFlow,
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
          _pasteAsFlow(project);
        },
      },
      child: Focus(
        focusNode: _focusNode,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _focusNode.requestFocus(),
          child: body,
        ),
      ),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return Stack(
      children: [
        const KlpFileExplorer(
          sections: [],
          emptyStateSections: [
            KlpFileExplorerSection(id: 'pinned', title: '釘選'),
            KlpFileExplorerSection(id: 'notes', title: '筆記'),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: const KlpEmptyState(
              icon: KlpIcons.folder,
              title: '尚無 Flow',
              message: '建立第一個 Flow 後即可開始筆記。',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pasteAsFlow(NotistProjectController project) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final markdown = clipboard?.text;
    if (markdown == null || markdown.isEmpty) return;
    await project.importMarkdownAsFlow(markdown);
  }

  void _selectExplorerItem(NotistProjectController project, String id) {
    if (id.startsWith(_folderIdPrefix)) {
      project.selectFolder(id.substring(_folderIdPrefix.length));
      return;
    }
    project.select(id);
    widget.onDocumentSelected?.call(id);
  }

  List<KlpFileExplorerSection> _buildSections(NotistProjectController project) {
    final selectedRootId = project.selectedRootId;
    final pinned = project.documents
        .where((document) => document.rootId == selectedRootId)
        .toList(growable: false);
    final notes = project.documents
        .where((document) => document.rootId != selectedRootId)
        .toList(growable: false);

    return [
      KlpFileExplorerSection(
        id: 'pinned',
        title: '釘選',
        items: [for (final document in pinned) _itemFor(document)],
      ),
      // 「筆記」不掛 trailing 動作按鈕。
      //
      // 先前這裡有一顆 `folderPlus` 圖示、行為卻是 `createFlow` 的按鈕：
      // 圖示畫的是「新增資料夾」，實際做的是「新增 Flow」，兩者不一致，
      // 而且這顆按鈕從未被指定過。建立 Flow 的入口保留在空狀態與 Stage 的 onCreate。
      KlpFileExplorerSection(
        id: 'notes',
        title: '筆記',
        items: [
          ..._folderItems(project, notes, ''),
          for (final document in notes.where(
            (document) => document.folderPath.isEmpty,
          ))
            _itemFor(document),
        ],
      ),
    ];
  }

  List<KlpFileExplorerItem> _folderItems(
    NotistProjectController project,
    List<NotistFlowDocument> documents,
    String parentPath,
  ) {
    final folders = project.folderPaths.where(
      (folderPath) => _parentFolderPath(folderPath) == parentPath,
    );
    return [
      for (final folderPath in folders)
        KlpFileExplorerItem(
          id: '$_folderIdPrefix$folderPath',
          label: _folderLabel(folderPath),
          icon: KlpIcons.folder,
          children: [
            ..._folderItems(project, documents, folderPath),
            for (final document in documents.where(
              (document) => document.folderPath == folderPath,
            ))
              _itemFor(document),
          ],
        ),
    ];
  }

  String _parentFolderPath(String folderPath) {
    final separator = folderPath.lastIndexOf('/');
    return separator < 0 ? '' : folderPath.substring(0, separator);
  }

  String _folderLabel(String folderPath) {
    final separator = folderPath.lastIndexOf('/');
    return separator < 0 ? folderPath : folderPath.substring(separator + 1);
  }

  KlpFileExplorerItem _itemFor(NotistFlowDocument document) {
    return KlpFileExplorerItem(
      id: document.rootId,
      label: document.title.isEmpty ? '未命名 Flow' : document.title,
      icon: KlpIcons.edit,
    );
  }
}
