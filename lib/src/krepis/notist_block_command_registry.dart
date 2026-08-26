import 'package:flutter/foundation.dart';

import 'krepis_block.dart';
import 'notist_block_command.dart';
import 'notist_block_command_actions.dart';

/// Notist 的 Block 操作字典；不保存內容或 selection，只統一各入口的產品語意。
final class NotistBlockCommandRegistry {
  NotistBlockCommandRegistry._(this.commands);

  static const String providerUnavailable = '等待筆記核心提供此操作';
  static const _conversionDefinitions = [
    _ConversionDefinition(
      NotistBlockCommandId.paragraph,
      KrepisFlowBlockKind.paragraph,
      NotistBlockCommandSection.basicBlocks,
      '文字',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.heading,
      KrepisFlowBlockKind.heading,
      NotistBlockCommandSection.basicBlocks,
      '標題',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.unorderedList,
      KrepisFlowBlockKind.unorderedListItem,
      NotistBlockCommandSection.basicBlocks,
      '項目符號清單',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.orderedList,
      KrepisFlowBlockKind.orderedListItem,
      NotistBlockCommandSection.basicBlocks,
      '編號清單',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.taskList,
      KrepisFlowBlockKind.taskListItem,
      NotistBlockCommandSection.basicBlocks,
      '待辦事項',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.quote,
      KrepisFlowBlockKind.blockQuote,
      NotistBlockCommandSection.advancedBlocks,
      '引用',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.code,
      KrepisFlowBlockKind.codeBlock,
      NotistBlockCommandSection.advancedBlocks,
      '程式碼',
    ),
    _ConversionDefinition(
      NotistBlockCommandId.divider,
      KrepisFlowBlockKind.thematicBreak,
      NotistBlockCommandSection.advancedBlocks,
      '分隔線',
    ),
  ];

  final List<NotistBlockCommand> commands;

  factory NotistBlockCommandRegistry.forBlock({
    required KrepisFlowBlockProjection block,
    required NotistBlockCommandActions actions,
  }) {
    const context = {NotistBlockCommandSurface.contextMenu};
    const everyMenu = {
      NotistBlockCommandSurface.contextMenu,
      NotistBlockCommandSurface.slashMenu,
    };

    return NotistBlockCommandRegistry._([
      NotistBlockCommand(
        id: NotistBlockCommandId.duplicate,
        section: NotistBlockCommandSection.actions,
        label: '建立副本',
        surfaces: context,
        onPressed: actions.onDuplicate,
      ),
      _unavailableAction(
        id: NotistBlockCommandId.moveUp,
        section: NotistBlockCommandSection.movement,
        label: '向上移動',
        surfaces: context,
        onPressed: actions.onMoveUp,
      ),
      _unavailableAction(
        id: NotistBlockCommandId.moveDown,
        section: NotistBlockCommandSection.movement,
        label: '向下移動',
        surfaces: context,
        onPressed: actions.onMoveDown,
      ),
      _unavailableAction(
        id: NotistBlockCommandId.delete,
        section: NotistBlockCommandSection.actions,
        label: '刪除',
        surfaces: context,
        onPressed: actions.onDelete,
        danger: true,
      ),
      if (block.kind == KrepisFlowBlockKind.taskListItem)
        _unavailableAction(
          id: NotistBlockCommandId.toggleTask,
          section: NotistBlockCommandSection.actions,
          label: block.taskChecked ? '標記為未完成' : '標記為完成',
          surfaces: context,
          onPressed: actions.onToggleTask,
        ),
      for (final definition in _conversionDefinitions)
        _conversion(
          block: block,
          actions: actions,
          definition: definition,
          surfaces: everyMenu,
        ),
    ]);
  }

  List<NotistBlockCommand> forSurface(NotistBlockCommandSurface surface) {
    return [
      for (final command in commands)
        if (command.surfaces.contains(surface)) command,
    ];
  }

  static NotistBlockCommand _conversion({
    required KrepisFlowBlockProjection block,
    required NotistBlockCommandActions actions,
    required _ConversionDefinition definition,
    required Set<NotistBlockCommandSurface> surfaces,
  }) {
    final selected = block.kind == definition.kind;
    final action = actions.onConvert[definition.kind];

    return NotistBlockCommand(
      id: definition.id,
      section: definition.section,
      label: definition.label,
      surfaces: surfaces,
      onPressed: selected ? null : action,
      caption: selected
          ? '目前區塊類型'
          : action == null
          ? providerUnavailable
          : null,
      selected: selected,
    );
  }

  static NotistBlockCommand _unavailableAction({
    required NotistBlockCommandId id,
    required NotistBlockCommandSection section,
    required String label,
    required Set<NotistBlockCommandSurface> surfaces,
    required VoidCallback? onPressed,
    bool danger = false,
  }) {
    return NotistBlockCommand(
      id: id,
      section: section,
      label: label,
      surfaces: surfaces,
      onPressed: onPressed,
      caption: onPressed == null ? providerUnavailable : null,
      danger: danger,
    );
  }
}

final class _ConversionDefinition {
  const _ConversionDefinition(this.id, this.kind, this.section, this.label);

  final NotistBlockCommandId id;
  final KrepisFlowBlockKind kind;
  final NotistBlockCommandSection section;
  final String label;
}
