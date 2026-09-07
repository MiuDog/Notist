// Notist 筆記區塊操作把手。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 僅供 Notist 筆記區塊元件組合使用，不由產品公開入口匯出。
final class NotistNoteBlockHandle extends StatefulWidget {
  const NotistNoteBlockHandle({
    super.key,
    required this.label,
    required this.onPressed,
    this.onFocusChange,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final String label;
  final ValueChanged<Offset> onPressed;
  final ValueChanged<bool>? onFocusChange;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;

  @override
  State<NotistNoteBlockHandle> createState() => _NotistNoteBlockHandleState();
}

final class _NotistNoteBlockHandleState extends State<NotistNoteBlockHandle> {
  bool _dragging = false;

  bool get _draggable =>
      widget.onDragStart != null ||
      widget.onDragUpdate != null ||
      widget.onDragEnd != null;

  void _openMenu() {
    final box = context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset(0, box.size.height));
    widget.onPressed(anchor);
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() => _dragging = true);
    widget.onDragStart?.call(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _dragging = false);
    widget.onDragEnd?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    final space = context.klp.space;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: _dragging
            ? SystemMouseCursors.grabbing
            : _draggable
            ? SystemMouseCursors.grab
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _draggable ? _handleDragStart : null,
          onPanUpdate: _draggable ? widget.onDragUpdate : null,
          onPanEnd: _draggable ? _handleDragEnd : null,
          child: KlpPressable(
            onPressed: _openMenu,
            onFocusChange: widget.onFocusChange,
            selected: _dragging,
            child: SizedBox.square(
              dimension: space.iconButton,
              child: const Center(child: KlpIcon(KlpIcons.gripVertical)),
            ),
          ),
        ),
      ),
    );
  }
}
