import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

void main() {
  testWidgets('connect tool snaps points and Shift bypasses snapping', (
    tester,
  ) async {
    var recipe = NtsCustomPageBackgroundRecipe(snapSpacing: 10);

    await tester.pumpWidget(
      _EditorHarness(
        recipe: recipe,
        tool: NtsPageBackgroundEditorTool.connect,
        onChanged: (value) => recipe = value,
      ),
    );

    final editor = find.byType(NtsPageBackgroundEditor);
    final topLeft = tester.getTopLeft(editor);

    await tester.tapAt(topLeft + const Offset(13, 17));
    await tester.pump();
    expect(recipe.points.single.position, const Offset(10, 20));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tapAt(topLeft + const Offset(26, 24));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(recipe.points.last.position, const Offset(26, 24));
    expect(recipe.lines, hasLength(1));
    expect(recipe.lines.single.startPointId, recipe.points.first.id);
    expect(recipe.lines.single.endPointId, recipe.points.last.id);
  });

  testWidgets(
    'select prefers points and delete keeps recipe references valid',
    (tester) async {
      var recipe = NtsCustomPageBackgroundRecipe(
        snapSpacing: 10,
        points: const [
          NtsPageBackgroundPoint(id: 1, position: Offset(20, 20)),
          NtsPageBackgroundPoint(id: 2, position: Offset(80, 20)),
        ],
        lines: const [
          NtsPageBackgroundLine(id: 1, startPointId: 1, endPointId: 2),
        ],
      );
      NtsPageBackgroundSelection? selection;

      await tester.pumpWidget(
        _EditorHarness(
          recipe: recipe,
          tool: NtsPageBackgroundEditorTool.select,
          onChanged: (value) => recipe = value,
          onSelectionChanged: (value) => selection = value,
        ),
      );

      final editor = find.byType(NtsPageBackgroundEditor);
      final topLeft = tester.getTopLeft(editor);
      await tester.tapAt(topLeft + const Offset(20, 20));
      await tester.pump();

      expect(selection, const NtsPageBackgroundSelection.point(1));

      await tester.pumpWidget(
        _EditorHarness(
          recipe: recipe,
          tool: NtsPageBackgroundEditorTool.delete,
          onChanged: (value) => recipe = value,
        ),
      );
      await tester.tapAt(
        tester.getTopLeft(find.byType(NtsPageBackgroundEditor)) +
            const Offset(20, 20),
      );
      await tester.pump();

      expect(recipe.points.map((point) => point.id), [2]);
      expect(recipe.lines, isEmpty);
    },
  );

  testWidgets('Escape ends the current connect chain', (tester) async {
    var recipe = NtsCustomPageBackgroundRecipe(snapSpacing: 10);

    await tester.pumpWidget(
      _EditorHarness(
        recipe: recipe,
        tool: NtsPageBackgroundEditorTool.connect,
        onChanged: (value) => recipe = value,
      ),
    );

    final editor = find.byType(NtsPageBackgroundEditor);
    final topLeft = tester.getTopLeft(editor);
    await tester.tapAt(topLeft + const Offset(20, 20));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.tapAt(topLeft + const Offset(80, 20));
    await tester.pump();

    expect(recipe.points, hasLength(2));
    expect(recipe.lines, isEmpty);
  });

  testWidgets('line selection and deletion preserve endpoint points', (
    tester,
  ) async {
    var recipe = NtsCustomPageBackgroundRecipe(
      snapSpacing: 10,
      points: const [
        NtsPageBackgroundPoint(id: 1, position: Offset(20, 20)),
        NtsPageBackgroundPoint(id: 2, position: Offset(100, 20)),
      ],
      lines: const [
        NtsPageBackgroundLine(id: 7, startPointId: 1, endPointId: 2),
      ],
    );
    NtsPageBackgroundSelection? selection;

    await tester.pumpWidget(
      _EditorHarness(
        recipe: recipe,
        tool: NtsPageBackgroundEditorTool.select,
        onChanged: (value) => recipe = value,
        onSelectionChanged: (value) => selection = value,
      ),
    );
    final editor = find.byType(NtsPageBackgroundEditor);
    await tester.tapAt(tester.getTopLeft(editor) + const Offset(60, 20));
    await tester.pump();

    expect(selection, const NtsPageBackgroundSelection.line(7));

    await tester.pumpWidget(
      _EditorHarness(
        recipe: recipe,
        tool: NtsPageBackgroundEditorTool.delete,
        onChanged: (value) => recipe = value,
      ),
    );
    await tester.tapAt(
      tester.getTopLeft(find.byType(NtsPageBackgroundEditor)) +
          const Offset(60, 20),
    );
    await tester.pump();

    expect(recipe.points, hasLength(2));
    expect(recipe.lines, isEmpty);
  });
}

class _EditorHarness extends StatefulWidget {
  const _EditorHarness({
    required this.recipe,
    required this.tool,
    required this.onChanged,
    this.onSelectionChanged,
  });

  final NtsCustomPageBackgroundRecipe recipe;
  final NtsPageBackgroundEditorTool tool;
  final ValueChanged<NtsCustomPageBackgroundRecipe> onChanged;
  final ValueChanged<NtsPageBackgroundSelection?>? onSelectionChanged;

  @override
  State<_EditorHarness> createState() => _EditorHarnessState();
}

class _EditorHarnessState extends State<_EditorHarness> {
  late NtsCustomPageBackgroundRecipe recipe = widget.recipe;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeAnimationDuration: Duration.zero,
      theme: buildKlpTheme(Brightness.light),
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 200,
          height: 160,
          child: NtsPageBackgroundEditor(
            recipe: recipe,
            tool: widget.tool,
            onChanged: (value) {
              setState(() => recipe = value);
              widget.onChanged(value);
            },
            onSelectionChanged: widget.onSelectionChanged,
          ),
        ),
      ),
    );
  }
}
