import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../krepis/krepis_editor_controller.dart';
import '../krepis/notist_flow_editor.dart';
import '../krepis/notist_local_save_projection.dart';
import '../assets/notist_assets_page.dart';
import '../assistant/notist_assistant_page.dart';
import '../journal/notist_journals_page.dart';
import '../project/notist_project_controller.dart';
import '../search/notist_quick_search_page.dart';
import '../shell/notist_stage_zone.dart';
import '../shell/notist_session_state.dart';
import '../shell/notist_workspace_destination.dart';
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
    this.zone = NotistStageZone.document,
    this.destination = NotistWorkspaceDestination.journals,
    this.startupBehavior = NotistStartupBehavior.restoreLast,
    this.onStartupBehaviorChanged,
    this.onDocumentOpen,
  });

  /// Stage 目前該顯示文件還是入口畫面。
  final NotistStageZone zone;

  /// [zone] 為 destination 時要顯示哪一個入口。
  final NotistWorkspaceDestination destination;

  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final NotistProjectController? projectController;
  final VoidCallback? onImportMarkdownFile;
  final NotistStartupBehavior startupBehavior;
  final ValueChanged<NotistStartupBehavior>? onStartupBehaviorChanged;
  final ValueChanged<String>? onDocumentOpen;

  @override
  Widget build(BuildContext context) {
    if (zone == NotistStageZone.destination) {
      return _buildDestination();
    }

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
      startupBehavior: startupBehavior,
      onStartupBehaviorChanged: onStartupBehaviorChanged,
    );
  }

  /// 三個入口畫面。
  ///
  /// 資料一律由外部給——這裡不編造內容。沒有資料時各畫面自己顯示空狀態，
  /// 那比塞假資料誠實：假資料會讓人以為功能已經接上了。
  Widget _buildDestination() {
    switch (destination) {
      case NotistWorkspaceDestination.search:
        return NotistQuickSearchPage(
          documents: projectController?.documents ?? const [],
          onOpen: onDocumentOpen ?? (_) {},
        );
      case NotistWorkspaceDestination.journals:
        final now = DateTime.now();
        return NotistJournalsPage(
          month: DateTime(now.year, now.month),
          monthLabel: '${now.year} 年 ${now.month} 月',
          summaryLabel: '',
          weekdayLabels: const ['一', '二', '三', '四', '五', '六', '日'],
          previousMonthLabel: '上個月',
          nextMonthLabel: '下個月',
          today: now,
        );
      case NotistWorkspaceDestination.ai:
        return const NotistAssistantPage(
          placeholder: '問一個關於這則筆記或整個專案的問題',
          sendLabel: '送出',
          attachLabel: '附加',
          scopeTags: ['這則筆記', '整個專案'],
        );
      case NotistWorkspaceDestination.assets:
        return const NotistAssetsPage(
          sortLabel: '排序',
          sortOptions: {
            'recent': '最近',
            'name': '名稱',
            'size': '大小',
            'kind': '類型',
          },
          selectedSortId: 'recent',
          summaryLabel: '',
        );
    }
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
    required this.startupBehavior,
    required this.onStartupBehaviorChanged,
  });

  final String flowPath;
  final String? flowTitle;
  final int? initialBlockCount;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final NotistProjectController? projectController;
  final VoidCallback? onImportMarkdownFile;
  final NotistStartupBehavior startupBehavior;
  final ValueChanged<NotistStartupBehavior>? onStartupBehaviorChanged;

  @override
  State<_NotistProjectStageSession> createState() =>
      _NotistProjectStageSessionState();
}

class _NotistProjectStageSessionState
    extends State<_NotistProjectStageSession> {
  final NotistLocalSaveController _saveProjection = NotistLocalSaveController();
  late int? _blockCount = widget.initialBlockCount;
  var _mode = NotistFlowStageMode.edit;
  var _undoHistoryEvicted = false;
  var _stylusDetected = false;
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
              KlpMenuItemData(
                label:
                    widget.startupBehavior == NotistStartupBehavior.restoreLast
                    ? '啟動時使用初始狀態'
                    : '啟動時保留上次狀態',
                icon: KlpIcons.settings,
                onPressed: _toggleStartupBehavior,
              ),
            ],
            child: NotistFlowStageActions(
              mode: _mode,
              enabled: widget.flowPath.isNotEmpty,
              showModeToggle: !_stylusDetected,
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
                    inkEnabled: _mode == NotistFlowStageMode.ink,
                    onStylusDetected: _handleStylusDetected,
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
            undoHistoryEvicted: _undoHistoryEvicted,
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

  void _handleStylusDetected() {
    if (!_stylusDetected && mounted) setState(() => _stylusDetected = true);
  }

  void _toggleStartupBehavior() {
    final next = widget.startupBehavior == NotistStartupBehavior.restoreLast
        ? NotistStartupBehavior.initial
        : NotistStartupBehavior.restoreLast;
    widget.onStartupBehaviorChanged?.call(next);
  }

  void _handleProjection(KrepisEditorSnapshot snapshot) {
    if (mounted &&
        (_blockCount != snapshot.blockCount ||
            _undoHistoryEvicted != snapshot.undoHistoryEvicted)) {
      setState(() {
        _blockCount = snapshot.blockCount;
        _undoHistoryEvicted = snapshot.undoHistoryEvicted;
      });
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
