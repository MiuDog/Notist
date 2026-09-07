/// Notist 專案模組。

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/notist_block_command.dart';
import 'package:notist/src/krepis/notist_block_command_actions.dart';
import 'package:notist/src/krepis/notist_block_command_registry.dart';

void main() {
  const block = KrepisFlowBlockProjection(
    position: 0,
    id: '00000000000000000000000000000002',
    kind: KrepisFlowBlockKind.paragraph,
    level: 0,
    nestingDepth: 0,
    orderedStart: 0,
    taskChecked: false,
    text: 'abc',
    info: '',
    marks: [],
  );

  test('context and slash surfaces share conversion command truth', () {
    final registry = NotistBlockCommandRegistry.forBlock(
      block: block,
      actions: NotistBlockCommandActions(onDuplicate: () {}),
    );
    final context = {
      for (final command in registry.forSurface(
        NotistBlockCommandSurface.contextMenu,
      ))
        command.id: command,
    };
    final slash = registry.forSurface(NotistBlockCommandSurface.slashMenu);

    for (final slashCommand in slash) {
      final contextCommand = context[slashCommand.id];

      expect(contextCommand, isNotNull);
      expect(contextCommand!.label, slashCommand.label);
      expect(contextCommand.caption, slashCommand.caption);
      expect(contextCommand.enabled, slashCommand.enabled);
    }
  });

  test('only duplicate is enabled before Krepis command gate', () {
    var duplicateCount = 0;
    final registry = NotistBlockCommandRegistry.forBlock(
      block: block,
      actions: NotistBlockCommandActions(
        onDuplicate: () => duplicateCount += 1,
      ),
    );
    final enabled = registry.commands.where((command) => command.enabled);

    expect(enabled.map((command) => command.id), [
      NotistBlockCommandId.duplicate,
    ]);
    for (final command in registry.commands.where(
      (command) => !command.enabled,
    )) {
      expect(command.caption, isNotEmpty);
    }

    enabled.single.onPressed!();
    expect(duplicateCount, 1);
  });

  test('task command exposes the current completion transition', () {
    var toggleCount = 0;
    final registry = NotistBlockCommandRegistry.forBlock(
      block: const KrepisFlowBlockProjection(
        position: 0,
        id: '00000000000000000000000000000003',
        kind: KrepisFlowBlockKind.taskListItem,
        level: 0,
        nestingDepth: 0,
        orderedStart: 0,
        taskChecked: true,
        text: 'done',
        info: '',
        marks: [],
      ),
      actions: NotistBlockCommandActions(
        onDuplicate: () {},
        onToggleTask: () => toggleCount += 1,
      ),
    );
    final toggle = registry.commands.singleWhere(
      (command) => command.id == NotistBlockCommandId.toggleTask,
    );

    expect(toggle.label, '標記為未完成');
    toggle.onPressed!();
    expect(toggleCount, 1);
  });

  test('conversion command IDs map to one Block kind', () {
    expect(
      NotistBlockCommandId.heading.conversionKind,
      KrepisFlowBlockKind.heading,
    );
    expect(NotistBlockCommandId.moveDown.conversionKind, isNull);
  });
}
