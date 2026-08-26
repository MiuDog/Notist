import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'nts_page_background.dart';
import 'nts_page_background_recipe.dart';

part 'internal/nts_background_selection_painter.dart';

/// 編輯受限 point／line 背景 recipe 的受控視覺元件。
class NtsPageBackgroundEditor extends StatefulWidget {
  const NtsPageBackgroundEditor({
    super.key,
    required this.recipe,
    required this.tool,
    required this.onChanged,
    this.viewport,
    this.onSelectionChanged,
    this.child,
  });

  final NtsCustomPageBackgroundRecipe recipe;
  final NtsPageBackgroundEditorTool tool;
  final ValueChanged<NtsCustomPageBackgroundRecipe> onChanged;
  final NtsPageBackgroundViewport? viewport;
  final ValueChanged<NtsPageBackgroundSelection?>? onSelectionChanged;
  final Widget? child;

  @override
  State<NtsPageBackgroundEditor> createState() {
    return _NtsPageBackgroundEditorState();
  }
}

class _NtsPageBackgroundEditorState extends State<NtsPageBackgroundEditor> {
  int? _chainPointId;
  NtsPageBackgroundSelection? _selection;

  NtsPageBackgroundViewport get _viewport {
    return widget.viewport ?? NtsPageBackgroundViewport();
  }

  @override
  void didUpdateWidget(covariant NtsPageBackgroundEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tool != widget.tool) {
      _chainPointId = null;
    }
    if (_selection case final selection?) {
      if (!_selectionExists(selection, widget.recipe)) {
        _selection = null;
        final onSelectionChanged = widget.onSelectionChanged;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) onSelectionChanged?.call(null);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        child: CustomPaint(
          foregroundPainter: _NtsBackgroundSelectionPainter(
            recipe: widget.recipe,
            viewport: _viewport,
            selection: _selection,
            color: klp.color.interaction,
            guideColor: klp.color.pagePattern,
            width: klp.shape.hairline,
            snapSpacing: widget.recipe.snapSpacing ?? klp.space.loose,
          ),
          child: NtsPageBackground.recipe(
            recipe: widget.recipe,
            viewport: _viewport,
            child: widget.child ?? const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _chainPointId = null);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;

    final pagePosition = _viewport.viewportToPage(event.localPosition);
    final hit = _hitTest(pagePosition);

    switch (widget.tool) {
      case NtsPageBackgroundEditorTool.connect:
        _connect(pagePosition, hit);
      case NtsPageBackgroundEditorTool.select:
        _setSelection(hit);
      case NtsPageBackgroundEditorTool.delete:
        _delete(hit);
    }
  }

  void _connect(Offset pagePosition, NtsPageBackgroundSelection? hit) {
    final existingPointId = hit?.kind == NtsPageBackgroundElementKind.point
        ? hit!.id
        : null;
    var recipe = widget.recipe;
    final targetId = existingPointId ?? recipe.nextPointId;

    if (existingPointId == null) {
      final position = HardwareKeyboard.instance.isShiftPressed
          ? pagePosition
          : _snap(pagePosition);
      recipe = recipe.copyWith(
        points: [
          ...recipe.points,
          NtsPageBackgroundPoint(id: targetId, position: position),
        ],
      );
    }

    final startId = _chainPointId;
    if (startId != null && startId != targetId) {
      recipe = recipe.copyWith(
        lines: [
          ...recipe.lines,
          NtsPageBackgroundLine(
            id: recipe.nextLineId,
            startPointId: startId,
            endPointId: targetId,
          ),
        ],
      );
    }

    setState(() => _chainPointId = targetId);
    if (recipe != widget.recipe) widget.onChanged(recipe);
  }

  Offset _snap(Offset position) {
    final spacing = widget.recipe.snapSpacing ?? context.klp.space.loose;
    return Offset(
      (position.dx / spacing).round() * spacing,
      (position.dy / spacing).round() * spacing,
    );
  }

  void _delete(NtsPageBackgroundSelection? hit) {
    if (hit == null) return;
    final recipe = switch (hit.kind) {
      NtsPageBackgroundElementKind.point => widget.recipe.removePoint(hit.id),
      NtsPageBackgroundElementKind.line => widget.recipe.removeLine(hit.id),
    };
    _setSelection(null);
    widget.onChanged(recipe);
  }

  NtsPageBackgroundSelection? _hitTest(Offset position) {
    final threshold = context.klp.space.compact / _viewport.scale;

    for (final point in widget.recipe.points.reversed) {
      if ((point.position - position).distance <= threshold) {
        return NtsPageBackgroundSelection.point(point.id);
      }
    }

    final points = <int, NtsPageBackgroundPoint>{
      for (final point in widget.recipe.points) point.id: point,
    };
    for (final line in widget.recipe.lines.reversed) {
      final start = points[line.startPointId];
      final end = points[line.endPointId];
      if (start == null || end == null) continue;
      if (_distanceToSegment(position, start.position, end.position) <=
          threshold) {
        return NtsPageBackgroundSelection.line(line.id);
      }
    }
    return null;
  }

  void _setSelection(NtsPageBackgroundSelection? selection) {
    if (_selection == selection) return;
    setState(() => _selection = selection);
    widget.onSelectionChanged?.call(selection);
  }
}
