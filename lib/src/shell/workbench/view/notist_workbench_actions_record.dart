/// Notist Workbench 畫面事件。

library;

import 'package:flutter/foundation.dart';
import 'package:kallopis/kallopis.dart';

import '../../notist_session_state.dart';

/// Workbench View 唯一接收的操作 record。
final class NotistWorkbenchActionsRecord {
  const NotistWorkbenchActionsRecord({
    required this.onCreateFlow,
    required this.onImportMarkdown,
    required this.onCreateFolder,
    required this.onDeleteFolder,
    required this.onOpenProjectManager,
    required this.onShowNotes,
    required this.onShowAssistant,
    required this.onShowDocument,
    required this.onOpenDocument,
    required this.onOpenSettings,
    required this.onLayoutChanged,
    required this.onStartupBehaviorChanged,
  });

  final VoidCallback onCreateFlow;
  final VoidCallback onImportMarkdown;
  final VoidCallback onCreateFolder;
  final VoidCallback onDeleteFolder;
  final VoidCallback onOpenProjectManager;
  final VoidCallback onShowNotes;
  final VoidCallback onShowAssistant;
  final VoidCallback onShowDocument;
  final ValueChanged<String> onOpenDocument;
  final VoidCallback onOpenSettings;
  final ValueChanged<KlpDockLayoutData> onLayoutChanged;
  final ValueChanged<NotistStartupBehavior> onStartupBehaviorChanged;
}
