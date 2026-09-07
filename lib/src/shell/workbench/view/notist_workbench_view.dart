/// Notist Workbench 純畫面組裝。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../../../components/assistant/nts_assistant_panel_record.dart';
import '../../../project/notist_project_controller.dart';
import '../../../screens/notist_assistant_screen.dart';
import '../../../sidebar/notist_sidebar.dart';
import '../../../stage/notist_stage.dart';
import '../../notist_sidebar_mode.dart';
import '../../notist_workbench_controller.dart';
import '../../notist_workbench_surface.dart';
import 'notist_workbench_actions_record.dart';
import 'notist_workbench_view_record.dart';

/// 將 Workbench record 組成 Kallopis Rail、Dock 與 Stage。
final class NotistWorkbenchView extends StatelessWidget {
  const NotistWorkbenchView({
    super.key,
    required this.record,
    required this.actions,
  });

  final NotistWorkbenchViewRecord record;
  final NotistWorkbenchActionsRecord actions;

  @override
  Widget build(BuildContext context) {
    final project = record.projectController;
    final showsNotes = record.state.sidebarMode == NotistSidebarMode.notes;

    return NotistWorkbenchSurface(
      railTop: _buildProjectRail(project),
      railCenter: _buildWorkspaceRail(showsNotes),
      railBottom: _buildActionRail(),
      stage: NotistStage(
        zone: record.state.zone,
        destination: record.state.destination,
        projectDirectoryPath: record.activeProjectPath,
        flowFilePath: record.flowFilePath,
        flowEditorBuilder: record.flowEditorBuilder,
        projectController: project,
        onImportMarkdownFile: actions.onImportMarkdown,
        startupBehavior: record.state.startupBehavior,
        onStartupBehaviorChanged: actions.onStartupBehaviorChanged,
        onDocumentOpen: actions.onOpenDocument,
      ),
      panels: [_buildNavigationPanel(project, showsNotes)],
      layout: record.state.dockLayout,
      onLayoutChanged: actions.onLayoutChanged,
      leftConstraints: NotistWorkbenchController.sideConstraints,
      rightConstraints: NotistWorkbenchController.sideConstraints,
    );
  }

  KlpRailItemGroup _buildProjectRail(NotistProjectController? project) {
    final isIdle =
        project != null &&
        !project.isCreatingFolder &&
        !project.isCreating &&
        !project.isDeleting &&
        !project.isMoving;

    return KlpRailItemGroup(
      id: 'project',
      items: [
        KlpRailMenuEntry(
          id: 'project-menu',
          icon: KlpIcons.folder,
          label: 'Project · ${record.activeProjectName}',
          items: [
            KlpMenuItemData(
              label: '新增 Flow',
              icon: KlpIcons.folderPlus,
              enabled: project != null && !project.isCreating,
              onPressed: actions.onCreateFlow,
            ),
            KlpMenuItemData(
              label: '匯入 Markdown',
              icon: KlpIcons.clipboard,
              enabled: project != null,
              onPressed: actions.onImportMarkdown,
            ),
            KlpMenuItemData(
              label: '新增資料夾',
              icon: KlpIcons.folderPlus,
              enabled: isIdle,
              onPressed: actions.onCreateFolder,
            ),
            KlpMenuItemData(
              label: '刪除目前資料夾',
              icon: KlpIcons.trash,
              enabled: isIdle && project.selectedFolderPath != null,
              onPressed: actions.onDeleteFolder,
            ),
            KlpMenuItemData(
              label: '專案管理',
              icon: KlpIcons.folder,
              enabled: record.canManageProjects,
              onPressed: actions.onOpenProjectManager,
            ),
          ],
        ),
      ],
      isReorderable: false,
    );
  }

  KlpRailItemGroup _buildWorkspaceRail(bool showsNotes) {
    return KlpRailItemGroup(
      id: 'workspace',
      items: [
        KlpRailButtonEntry(
          id: 'notes',
          icon: KlpIcons.clipboard,
          label: 'Notes',
          selected: showsNotes,
          onPressed: actions.onShowNotes,
        ),
        KlpRailButtonEntry(
          id: 'notist-ai',
          icon: KlpIcons.sparkles,
          label: 'Notist AI',
          selected: !showsNotes,
          onPressed: actions.onShowAssistant,
        ),
      ],
      isReorderable: false,
    );
  }

  KlpRailItemGroup _buildActionRail() {
    return KlpRailItemGroup(
      id: 'actions',
      items: [
        KlpRailMenuEntry(
          id: 'account-menu',
          icon: KlpIcons.users,
          label: 'Account',
          items: [
            KlpMenuItemData(
              label: '帳號功能尚未提供',
              enabled: false,
              onPressed: () {},
            ),
          ],
        ),
        KlpRailButtonEntry(
          id: 'settings',
          icon: KlpIcons.settings,
          label: '設定',
          onPressed: actions.onOpenSettings,
        ),
      ],
      isReorderable: false,
    );
  }

  KlpDockPanel _buildNavigationPanel(
    NotistProjectController? project,
    bool showsNotes,
  ) {
    return KlpDockPanel(
      id: NotistWorkbenchController.navigationPanelId,
      header: KlpText(
        showsNotes ? 'Notes' : 'Notist AI',
        role: KlpTextRole.appTitle,
      ),
      content: showsNotes
          ? NotistSidebar(
              projectController: project,
              onDocumentSelected: (_) => actions.onShowDocument(),
              scrollController: record.navigationScrollController,
            )
          : const NotistAssistantScreen(
              record: NtsAssistantPanelRecord(
                placeholder: '詢問 Notist AI',
                sendLabel: '傳送',
                attachLabel: '附加內容',
                scopeTags: ['這則筆記'],
              ),
            ),
      contentScrollController: record.navigationScrollController,
      allowSide: true,
      allowBottom: false,
    );
  }
}
