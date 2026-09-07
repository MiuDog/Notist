/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'notist_block_command.dart';
import 'notist_block_command_registry.dart';

final class NotistFlowSlashMenu extends StatelessWidget {
  const NotistFlowSlashMenu({
    super.key,
    required this.registry,
    required this.onEscape,
    required this.onCommandSelected,
  });

  final NotistBlockCommandRegistry registry;
  final VoidCallback onEscape;
  final ValueChanged<NotistBlockCommand> onCommandSelected;

  @override
  Widget build(BuildContext context) {
    final commands = registry.forSurface(NotistBlockCommandSurface.slashMenu);

    return KlpCommandMenu(
      key: const ValueKey('notist-flow-slash-menu'),
      width: KlpMenuLayout.widthOf(context),
      onEscape: onEscape,
      sections: [
        for (final section in const [
          NotistBlockCommandSection.basicBlocks,
          NotistBlockCommandSection.advancedBlocks,
        ])
          KlpCommandSectionData(
            label: _sectionLabel(section),
            items: [
              for (final command in commands)
                if (command.section == section)
                  KlpCommandItemData(
                    label: command.label,
                    caption: command.caption,
                    selected: command.selected,
                    danger: command.danger,
                    onPressed: command.enabled
                        ? () => onCommandSelected(command)
                        : null,
                  ),
            ],
          ),
      ],
    );
  }

  static String _sectionLabel(NotistBlockCommandSection section) {
    return switch (section) {
      NotistBlockCommandSection.basicBlocks => '基本區塊',
      NotistBlockCommandSection.advancedBlocks => '進階區塊',
      NotistBlockCommandSection.actions || NotistBlockCommandSection.movement =>
        throw ArgumentError.value(section, 'section', 'Slash Menu 不接受此分組'),
    };
  }
}
