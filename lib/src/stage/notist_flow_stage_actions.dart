/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

enum NotistFlowStageMode { read, edit }

/// Flow 專屬的 Stage mode actions；視覺全部由 Kallopis controls 提供。
class NotistFlowStageActions extends StatelessWidget {
  const NotistFlowStageActions({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onPageMenu,
    this.enabled = true,
    this.showModeToggle = true,
  });

  final NotistFlowStageMode mode;
  final ValueChanged<NotistFlowStageMode> onModeChanged;
  final VoidCallback onPageMenu;
  final bool enabled;
  final bool showModeToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showModeToggle) ...[
          KlpIconButton(
            icon: KlpIcons.eye,
            label: '唯讀',
            selected: mode == NotistFlowStageMode.read,
            onPressed: enabled
                ? () => onModeChanged(NotistFlowStageMode.read)
                : null,
            tone: KlpIconButtonTone.inline,
          ),
          KlpIconButton(
            icon: KlpIcons.keyboard,
            label: '編輯',
            selected: mode == NotistFlowStageMode.edit,
            onPressed: enabled
                ? () => onModeChanged(NotistFlowStageMode.edit)
                : null,
            tone: KlpIconButtonTone.inline,
          ),
        ],
        KlpIconButton(
          icon: KlpIcons.handWriting,
          label: '手寫（尚未提供）',
          onPressed: null,
          tone: KlpIconButtonTone.inline,
        ),
        KlpIconButton(
          icon: KlpIcons.menu,
          label: '頁面選單',
          onPressed: onPageMenu,
          // 這顆按鈕嵌在 Stage 標題列上，不是浮在空白處的獨立控制項。
          tone: KlpIconButtonTone.inline,
        ),
      ],
    );
  }
}
