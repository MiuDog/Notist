/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_project_controller.dart';
import 'notist_sidebar_explorer.dart';

/// Notist 絕對 golden 的 Primary Sidebar 組合。
class NotistSidebar extends StatelessWidget {
  const NotistSidebar({
    super.key,
    this.projectController,
    this.onDocumentSelected,
    this.scrollController,
  });

  final NotistProjectController? projectController;
  final ValueChanged<String>? onDocumentSelected;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final ready = projectController?.state == NotistProjectLoadState.ready;

    // 左側主體固定為內容 Explorer，上方保留微量邊距，底部保留狀態列。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.klp.space.tight),

        Expanded(
          child: NotistSidebarExplorer(
            controller: projectController,
            onDocumentSelected: onDocumentSelected,
            scrollController: scrollController,
          ),
        ),
        SizedBox(
          height: context.klp.space.chromeStatusBar,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.klp.space.chromePanelInset,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: KlpStatusIndicator(
                data: KlpStatusItemData(
                  label: 'Flow · local',
                  kind: ready ? KlpStatusKind.check : KlpStatusKind.circle,
                  active: ready,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
