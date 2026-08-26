import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_project_controller.dart';
import '../shell/notist_stage_zone.dart';
import '../shell/notist_workspace_destination.dart';
import 'notist_sidebar_explorer.dart';

/// Notist 絕對 golden 的 Primary Sidebar 組合。
class NotistSidebar extends StatelessWidget {
  const NotistSidebar({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
    this.zone = NotistStageZone.destination,
    this.projectController,
    this.onDocumentSelected,
  });

  /// Stage 目前顯示哪一類內容。
  ///
  /// 導覽入口與文件選取**互斥**：顯示文件時導覽項目一個都不該亮著，否則側欄會
  /// 同時指向兩個地方，使用者無從判斷現在在哪。
  final NotistStageZone zone;

  final NotistWorkspaceDestination selectedDestination;
  final ValueChanged<NotistWorkspaceDestination> onDestinationSelected;
  final NotistProjectController? projectController;
  final ValueChanged<String>? onDocumentSelected;

  @override
  Widget build(BuildContext context) {
    final ready = projectController?.state == NotistProjectLoadState.ready;

    return KlpPrimarySidebarFrame(
      header: KlpSidebarIdentityHeader(
        icon: KlpIcons.folder,
        title: 'Flows',
        avatarLabel: 'C',
        avatarSemanticLabel: 'Chia-Yu',
      ),
      navigation: KlpSidebarNavigationGroup(
        children: [
          for (final destination in NotistWorkspaceDestination.values)
            _DestinationButton(
              destination: destination,
              selected:
                  zone == NotistStageZone.destination &&
                  selectedDestination == destination,
              onPressed: onDestinationSelected,
            ),
        ],
      ),
      explorer: NotistSidebarExplorer(
        controller: projectController,
        onDocumentSelected: onDocumentSelected,
      ),
      footer: Align(
        alignment: Alignment.centerLeft,
        child: KlpStatusIndicator(
          label: 'Flow · local',
          kind: ready ? KlpStatusKind.check : KlpStatusKind.circle,
          active: ready,
        ),
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final NotistWorkspaceDestination destination;
  final bool selected;
  final ValueChanged<NotistWorkspaceDestination> onPressed;

  @override
  Widget build(BuildContext context) {
    return KlpSidebarNavigationButton(
      icon: switch (destination) {
        NotistWorkspaceDestination.search => KlpIcons.search,
        NotistWorkspaceDestination.journals => KlpIcons.clipboard,
        NotistWorkspaceDestination.ai => KlpIcons.sparkles,
        NotistWorkspaceDestination.assets => KlpIcons.archive,
      },
      label: destination.label,
      selected: selected,
      onPressed: () => onPressed(destination),
    );
  }
}
