import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

import 'krepis_block.dart';
import 'notist_block_command.dart';
import 'notist_block_command_registry.dart';

final class NotistFlowBlockChrome extends StatefulWidget {
  const NotistFlowBlockChrome({
    super.key,
    required this.block,
    required this.contentLeft,
    required this.contentWidth,
    required this.visualHeight,
    required this.selected,
    required this.onSelected,
    required this.registry,
    this.onHandleDragStart,
    this.onHandleDragUpdate,
    this.onHandleDragEnd,
  });

  final KrepisFlowBlockProjection block;
  final double contentLeft;
  final double contentWidth;

  /// 內容高度，不含區塊間距。見 [NtsBlockChrome.visualHeight]。
  final double visualHeight;
  final bool selected;
  final VoidCallback onSelected;
  final NotistBlockCommandRegistry registry;
  final GestureDragStartCallback? onHandleDragStart;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  @override
  State<NotistFlowBlockChrome> createState() => _NotistFlowBlockChromeState();
}

final class _NotistFlowBlockChromeState extends State<NotistFlowBlockChrome> {
  final KlpContextMenuController _menuController = KlpContextMenuController();

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(widget.block.kind);

    return KlpContextMenu(
      controller: _menuController,
      label: '$label 區塊操作',
      items: [
        for (final command in widget.registry.forSurface(
          NotistBlockCommandSurface.contextMenu,
        ))
          _menuItem(command),
      ],
      child: NtsBlockChrome(
        contentLeft: widget.contentLeft,
        contentWidth: widget.contentWidth,
        visualHeight: widget.visualHeight,
        selected: widget.selected,
        handleLabel: '$label 區塊操作',
        onHandlePressed: _menuController.openAt,
        onSelected: widget.onSelected,
        onHandleDragStart: widget.onHandleDragStart,
        onHandleDragUpdate: widget.onHandleDragUpdate,
        onHandleDragEnd: widget.onHandleDragEnd,
      ),
    );
  }

  KlpMenuItemData _menuItem(NotistBlockCommand command) {
    return KlpMenuItemData(
      key: ValueKey('notist-block-command-${command.id.name}'),
      label: command.label,
      icon: _iconFor(command.id),
      shortcut: command.caption,
      danger: command.danger,
      selected: command.selected,
      enabled: command.enabled,
      separatedBefore:
          command.id == NotistBlockCommandId.moveUp ||
          command.id == NotistBlockCommandId.paragraph,
      onPressed: command.onPressed ?? _ignoreUnavailable,
    );
  }

  String _iconFor(NotistBlockCommandId id) {
    return switch (id) {
      NotistBlockCommandId.duplicate => KlpIcons.clipboard,
      NotistBlockCommandId.moveUp ||
      NotistBlockCommandId.moveDown => KlpIcons.switchVertical,
      NotistBlockCommandId.delete => KlpIcons.trash,
      NotistBlockCommandId.toggleTask => KlpIcons.checkSquare,
      NotistBlockCommandId.taskList => KlpIcons.checkSquare,
      NotistBlockCommandId.divider => KlpIcons.minus,
      NotistBlockCommandId.code => KlpIcons.cpu,
      NotistBlockCommandId.paragraph ||
      NotistBlockCommandId.heading ||
      NotistBlockCommandId.unorderedList ||
      NotistBlockCommandId.orderedList ||
      NotistBlockCommandId.quote => KlpIcons.edit,
    };
  }

  static void _ignoreUnavailable() {}

  String _labelFor(KrepisFlowBlockKind kind) {
    return switch (kind) {
      KrepisFlowBlockKind.paragraph => '文字',
      KrepisFlowBlockKind.heading => '標題',
      KrepisFlowBlockKind.unorderedListItem => '項目符號清單',
      KrepisFlowBlockKind.orderedListItem => '編號清單',
      KrepisFlowBlockKind.taskListItem => '待辦事項',
      KrepisFlowBlockKind.blockQuote => '引用',
      KrepisFlowBlockKind.codeBlock => '程式碼',
      KrepisFlowBlockKind.thematicBreak => '分隔線',
    };
  }
}
