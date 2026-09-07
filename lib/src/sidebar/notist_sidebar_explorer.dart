/// Notist 專案模組。

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kallopis/kallopis.dart';

import '../components/note/notist_note_file_explorer.dart';
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
    this.scrollController,
  });

  final NotistProjectController? controller;
  final ValueChanged<String>? onDocumentSelected;
  final ScrollController? scrollController;

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

    // 步驟 1：先處理 controller 不存在、載入中、失敗的狀態。
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

    // 步驟 2：在無資料時顯示空白建立入口；有資料則顯示 explorer。
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
        : NotistNoteFileExplorer(
            scrollController: widget.scrollController,
            sections: _buildSections(project),
            selectedId: switch (project.selectedFolderPath) {
              final folderPath? => '$_folderIdPrefix$folderPath',
              null => project.selectedRootId,
            },
            onItemSelected: (id) => _selectExplorerItem(project, id),
          );

    // 步驟 3：有建立、刪除錯誤時追加警示列，但不中斷 Explorer 主內容。
    final createError = project.createError;
    final createFolderError = project.createFolderError;
    final deleteFolderError = project.deleteFolderError;
    final renameFolderError = project.renameFolderError;
    final deleteError = project.deleteError;
    final moveError = project.moveError;
    Widget body = content;
    if (createError != null ||
        createFolderError != null ||
        deleteFolderError != null ||
        renameFolderError != null ||
        deleteError != null ||
        moveError != null) {
      final items = <Widget>[];
      if (createError != null) {
        items.add(
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
        );
      }
      if (createFolderError != null) {
        items.add(
          Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: KlpInlineNotice(
              title: '建立資料夾失敗',
              message: '$createFolderError',
              tone: KlpFeedbackTone.danger,
            ),
          ),
        );
      }
      if (deleteFolderError != null) {
        items.add(
          Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: KlpInlineNotice(
              title: '刪除資料夾失敗',
              message: '$deleteFolderError',
              tone: KlpFeedbackTone.danger,
            ),
          ),
        );
      }
      if (renameFolderError != null) {
        items.add(
          Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: KlpInlineNotice(
              title: '改名資料夾失敗',
              message: '$renameFolderError',
              tone: KlpFeedbackTone.danger,
            ),
          ),
        );
      }
      if (deleteError != null) {
        items.add(
          Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: KlpInlineNotice(
              title: '刪除筆記失敗',
              message: '$deleteError',
              tone: KlpFeedbackTone.danger,
            ),
          ),
        );
      }
      if (moveError != null) {
        items.add(
          Padding(
            padding: EdgeInsets.all(context.klp.space.base),
            child: KlpInlineNotice(
              title: '移動失敗',
              message: '$moveError',
              tone: KlpFeedbackTone.danger,
            ),
          ),
        );
      }
      body = Column(
        children: [
          ...items,
          Expanded(child: content),
        ],
      );
    }

    // 步驟 4：集中綁定貼上快捷鍵並確保焦點管理。
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
        NotistNoteFileExplorer(
          scrollController: widget.scrollController,
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
    final pinned = project.documents
        .where((document) => project.pinnedRootIds.contains(document.rootId))
        .toList(growable: false);

    // 步驟 1：先輸出「釘選」，再輸出一般「筆記」群組。
    final notes = project.documents
        .where((document) => !project.pinnedRootIds.contains(document.rootId))
        .toList(growable: false);

    return [
      KlpFileExplorerSection(
        id: 'pinned',
        title: '釘選',
        items: [for (final document in pinned) _itemFor(document, project)],
      ),
      KlpFileExplorerSection(
        id: 'notes',
        title: '筆記',
        items: [
          ..._folderItems(project, notes, ''),
          for (final document in notes.where(
            (document) => document.folderPath.isEmpty,
          ))
            _itemFor(document, project),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KlpIconButton(
                icon: KlpIcons.pencil,
                label: '改名',
                tone: KlpIconButtonTone.inline,
                onPressed:
                    project.isCreating ||
                        project.isCreatingFolder ||
                        project.isDeleting ||
                        project.isMoving
                    ? null
                    : () => unawaited(_renameFolder(project, folderPath)),
              ),
              KlpIconButton(
                icon: KlpIcons.trash,
                label: '刪除資料夾',
                tone: KlpIconButtonTone.inline,
                onPressed:
                    project.isCreating ||
                        project.isCreatingFolder ||
                        project.isDeleting ||
                        project.isMoving
                    ? null
                    : () => unawaited(_deleteFolder(project, folderPath)),
              ),
            ],
          ),
          children: [
            ..._folderItems(project, documents, folderPath),
            for (final document in documents.where(
              (document) => document.folderPath == folderPath,
            ))
              _itemFor(document, project),
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

  KlpFileExplorerItem _itemFor(
    NotistFlowDocument document,
    NotistProjectController project,
  ) {
    final isPinned = project.pinnedRootIds.contains(document.rootId);
    return KlpFileExplorerItem(
      id: document.rootId,
      label: document.title.isEmpty ? '未命名 Flow' : document.title,
      icon: KlpIcons.edit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KlpIconButton(
            icon: KlpIcons.bookmark,
            label: isPinned ? '取消釘選' : '釘選',
            tone: KlpIconButtonTone.inline,
            onPressed:
                project.isCreating || project.isDeleting || project.isMoving
                ? null
                : () => unawaited(project.setPin(document.rootId, !isPinned)),
          ),
          KlpIconButton(
            icon: KlpIcons.folder,
            label: '移到資料夾',
            tone: KlpIconButtonTone.inline,
            onPressed:
                project.isCreating || project.isDeleting || project.isMoving
                ? null
                : () => unawaited(_moveDocument(project, document)),
          ),
          KlpIconButton(
            icon: KlpIcons.trash,
            label: '刪除',
            tone: KlpIconButtonTone.inline,
            onPressed:
                project.isCreating || project.isDeleting || project.isMoving
                ? null
                : () => unawaited(_deleteDocument(project, document)),
          ),
        ],
      ),
    );
  }

  Future<void> _moveDocument(
    NotistProjectController project,
    NotistFlowDocument document,
  ) async {
    final targetFolder = await _selectMoveFolder(project, document.folderPath);
    if (targetFolder == null) return;
    if (targetFolder == document.folderPath) return;

    await project.moveFlow(
      document.rootId,
      targetFolder.isEmpty ? null : targetFolder,
    );
  }

  Future<String?> _selectMoveFolder(
    NotistProjectController project,
    String currentFolder,
  ) async {
    final folders = <String>['', ...project.folderPaths];
    var selected = currentFolder;
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('移動筆記到資料夾'),
          content: SizedBox(
            width: 360,
            height: 260,
            child: StatefulBuilder(
              builder: (context, setState) {
                return RadioGroup<String>(
                  groupValue: selected,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selected = value;
                    });
                  },
                  child: ListView(
                    children: [
                      for (final folderPath in folders)
                        RadioListTile<String>(
                          value: folderPath,
                          title: Text(folderPath.isEmpty ? '根資料夾' : folderPath),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: const Text('移動'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFolder(
    NotistProjectController project,
    String folderPath,
  ) async {
    final controller = TextEditingController(text: folderPath);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('改名資料夾'),
          content: SizedBox(
            width: 360,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: '新資料夾名稱'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
    if (newName == null || newName.isEmpty) return;
    await project.renameFolder(folderPath, newName);
  }

  Future<void> _deleteDocument(
    NotistProjectController project,
    NotistFlowDocument document,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('確定要刪除「${document.title}」嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    await project.deleteFlow(document.rootId);
    if (!mounted) return;
    if (project.selectedRootId == document.rootId &&
        project.documents.isNotEmpty) {
      _selectExplorerItem(project, project.documents.first.rootId);
    }
  }

  Future<void> _deleteFolder(
    NotistProjectController project,
    String folderPath,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認刪除資料夾'),
          content: Text('確定要刪除「$folderPath」嗎？此操作無法還原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await project.deleteFolder(folderPath);
  }
}
