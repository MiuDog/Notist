/// Notist Workbench 畫面組裝資料。

library;

import 'package:flutter/widgets.dart';

import '../../../project/notist_project_controller.dart';
import '../../../stage/notist_project_page.dart';
import '../notist_workbench_state_record.dart';

/// Workbench View 唯一接收的完整資料 record。
final class NotistWorkbenchViewRecord {
  const NotistWorkbenchViewRecord({
    required this.state,
    required this.activeProjectName,
    required this.activeProjectPath,
    required this.projectController,
    required this.flowFilePath,
    required this.flowEditorBuilder,
    required this.navigationScrollController,
    required this.canManageProjects,
  });

  final NotistWorkbenchStateRecord state;
  final String activeProjectName;
  final String activeProjectPath;
  final NotistProjectController? projectController;
  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final ScrollController navigationScrollController;
  final bool canManageProjects;
}
