// Notist 筆記區塊互動元件。

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis_foundation.dart';

import 'internal/notist_note_block_handle.dart';

/// 筆記內容的通用互動外框。
///
/// 本元件只處理選取、hover、操作把手與手勢回報；內容、順序與編輯 authority
/// 仍由 Notist 的資料與編輯層提供。
class NotistNoteBlock extends StatelessWidget {
  const NotistNoteBlock({
    super.key,
    required this.child,
    required this.handleLabel,
    required this.onHandlePressed,
    required this.onSelected,
    required this.onContentPressed,
    this.selected = false,
    this.padding,
    this.onHover,
    this.semanticLabel,
    this.onHandleDragStart,
    this.onHandleDragUpdate,
    this.onHandleDragEnd,
  });

  final Widget child;
  final String handleLabel;
  final ValueChanged<Offset> onHandlePressed;
  final VoidCallback onSelected;
  final VoidCallback? onContentPressed;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<bool>? onHover;
  final String? semanticLabel;
  final GestureDragStartCallback? onHandleDragStart;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  void _handlePressed(Offset anchor) {
    onSelected();
    onHandlePressed(anchor);
  }

  @override
  Widget build(BuildContext context) {
    final space = context.klp.space;
    final content = Padding(
      padding: padding ?? EdgeInsets.all(space.base),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final handle = NotistNoteBlockHandle(
            key: const ValueKey('notist-note-block-handle'),
            label: handleLabel,
            onPressed: _handlePressed,
            onDragStart: onHandleDragStart,
            onDragUpdate: onHandleDragUpdate,
            onDragEnd: onHandleDragEnd,
          );

          return Row(
            mainAxisSize: constraints.hasBoundedWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              handle,
              SizedBox(width: space.contentInlineGap),
              if (constraints.hasBoundedWidth)
                Expanded(child: child)
              else
                child,
            ],
          );
        },
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      button: onContentPressed != null,
      selected: selected,
      child: KlpPressable(
        key: const ValueKey('notist-note-block-content-pressable'),
        selected: selected,
        onPressed: onContentPressed,
        onHover: onHover,
        child: content,
      ),
    );
  }
}
