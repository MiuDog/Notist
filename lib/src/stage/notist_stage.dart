import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../krepis/krepis_editor_controller.dart';
import '../krepis/notist_flow_editor.dart';
import '../krepis/notist_local_save_projection.dart';
import '../project/notist_project_controller.dart';
import 'notist_flow_stage_actions.dart';
import 'notist_project_page.dart';
import 'notist_stage_identity_header.dart';

/// Notist 的單一 Flow Stage。
class NotistStage extends StatelessWidget {
  const NotistStage({
    super.key,
    required this.flowFilePath,
    this.flowEditorBuilder,
    this.projectController,
    this.onImportMarkdownFile,
  });

  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final NotistProjectController? projectController;
  final VoidCallback? onImportMarkdownFile;

  @override
  Widget build(BuildContext context) {
    final selectedFlow = projectController?.selectedDocument;
    final flowPath = selectedFlow?.filePath ?? flowFilePath;

    return _NotistProjectStageSession(
      key: ValueKey(flowPath),
      flowPath: flowPath,
      flowTitle: selectedFlow?.title,
      initialBlockCount: selectedFlow?.blockCount,
      flowEditorBuilder: flowEditorBuilder,
      projectController: projectController,
      onImportMarkdownFile: onImportMarkdownFile,
    );
  }
}

class _NotistProjectStageSession extends StatefulWidget {
  const _NotistProjectStageSession({
    super.key,
    required this.flowPath,
    required this.flowTitle,
    required this.initialBlockCount,
    required this.flowEditorBuilder,
    required this.projectController,
    required this.onImportMarkdownFile,
  });

  final String flowPath;
  final String? flowTitle;
  final int? initialBlockCount;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final NotistProjectController? projectController;
  final VoidCallback? onImportMarkdownFile;

  @override
  State<_NotistProjectStageSession> createState() =>
      _NotistProjectStageSessionState();
}

class _NotistProjectStageSessionState
    extends State<_NotistProjectStageSession> {
  final NotistLocalSaveController _saveProjection = NotistLocalSaveController();
  late int? _blockCount = widget.initialBlockCount;
  var _mode = NotistFlowStageMode.edit;
  final KlpContextMenuController _pageMenuController =
      KlpContextMenuController();

  @override
  void didUpdateWidget(covariant _NotistProjectStageSession oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBlockCount != widget.initialBlockCount) {
      _blockCount = widget.initialBlockCount;
    }
  }

  @override
  void dispose() {
    _saveProjection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projectController;
    final isLoading = project?.state == NotistProjectLoadState.loading;
    final canCreate = project != null && !isLoading && !project.isCreating;

    return KlpStageFrame(
      header: NotistStageIdentityHeader(
        title: widget.flowTitle == null || widget.flowTitle!.isEmpty
            ? '未命名 Flow'
            : widget.flowTitle!,
        actions: [
          KlpContextMenu(
            controller: _pageMenuController,
            label: 'Flow 動作',
            items: [
              KlpMenuItemData(
                label: '匯入 Markdown',
                icon: KlpIcons.clipboard,
                enabled: widget.onImportMarkdownFile != null,
                onPressed: widget.onImportMarkdownFile ?? () {},
              ),
            ],
            child: NotistFlowStageActions(
              mode: _mode,
              enabled: widget.flowPath.isNotEmpty,
              onModeChanged: (mode) => setState(() => _mode = mode),
              onPageMenu: _openPageMenu,
            ),
          ),
        ],
      ),
      content: isLoading
          ? const Center(child: KlpLoadingState(label: '正在載入 Flow 專案'))
          : NotistProjectPage(
              filePath: widget.flowPath,
              onCreate: canCreate ? project.createFlow : null,
              editorBuilder:
                  widget.flowEditorBuilder ??
                  (context, filePath) => NotistFlowEditor(
                    key: ValueKey(filePath),
                    filePath: filePath,
                    saveProjection: _saveProjection,
                    onProjectionChanged: _handleProjection,
                  ),
            ),
      status: SizedBox(
        key: const ValueKey('workspace-status-slot'),
        child: ValueListenableBuilder(
          valueListenable: _saveProjection,
          builder: (context, state, child) => NotistLocalSaveStatus(
            state: state,
            blockCount: widget.flowPath.isEmpty ? null : _blockCount,
            onRetry: _saveProjection.retry == null ? null : _retrySave,
          ),
        ),
      ),
    );
  }

  void _openPageMenu() {
    final size = MediaQuery.sizeOf(context);
    _pageMenuController.openAt(
      Offset(size.width, context.klp.space.controlHeight),
    );
  }

  void _handleProjection(KrepisEditorSnapshot snapshot) {
    if (mounted && _blockCount != snapshot.blockCount) {
      setState(() => _blockCount = snapshot.blockCount);
    }
    widget.projectController?.updateProjection(
      rootId: snapshot.rootId,
      title: snapshot.title,
      blockCount: snapshot.blockCount,
    );
  }

  void _retrySave() {
    try {
      _saveProjection.retry?.call();
    } catch (error) {
      if (kDebugMode) debugPrint('Notist 無法重試本機測試暫存：$error');
    }
  }
}
