import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

enum NotistFlowStageMode { read, edit, ink }

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
          KlpPhaseToggle<NotistFlowStageMode>(
            options: const [
              KlpPhaseOption(
                value: NotistFlowStageMode.read,
                label: '閱讀模式',
                icon: KlpIcons.eye,
              ),
              KlpPhaseOption(
                value: NotistFlowStageMode.edit,
                label: '編輯模式',
                icon: KlpIcons.keyboard,
              ),
              KlpPhaseOption(
                value: NotistFlowStageMode.ink,
                label: '手寫模式',
                icon: KlpIcons.handWriting,
              ),
            ],
            selected: mode,
            enabled: enabled,
            onSelected: enabled ? onModeChanged : null,
          ),
          SizedBox(width: context.klp.space.compact),
        ],
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
