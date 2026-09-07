// Notist 筆記區塊的選取與操作外框。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import 'internal/notist_note_block_handle.dart';

/// 疊在 authority-rendered 內容上的選取框與操作把手。
///
/// [contentLeft]、[contentWidth] 與 [visualHeight] 由 layout authority 提供；
/// 本元件只繪製 chrome，不量測或推導區塊位置。
class NotistNoteBlockChrome extends StatefulWidget {
  const NotistNoteBlockChrome({
    super.key,
    required this.contentLeft,
    required this.contentWidth,
    required this.visualHeight,
    required this.handleLabel,
    required this.onHandlePressed,
    required this.onSelected,
    this.selected = false,
    this.onHandleDragStart,
    this.onHandleDragUpdate,
    this.onHandleDragEnd,
  });

  final double contentLeft;
  final double contentWidth;
  final double visualHeight;
  final String handleLabel;
  final ValueChanged<Offset> onHandlePressed;
  final VoidCallback onSelected;
  final bool selected;
  final GestureDragStartCallback? onHandleDragStart;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  @override
  State<NotistNoteBlockChrome> createState() => _NotistNoteBlockChromeState();
}

final class _NotistNoteBlockChromeState extends State<NotistNoteBlockChrome> {
  static const _visibleOpacity = 1.0;
  static const _hiddenOpacity = 0.0;

  bool _hovered = false;
  bool _handleFocused = false;

  bool get _handleVisible => widget.selected || _hovered || _handleFocused;

  void _setHovered(bool value) {
    if (_hovered == value) return;

    setState(() => _hovered = value);
  }

  void _setHandleFocused(bool value) {
    if (_handleFocused == value) return;

    setState(() => _handleFocused = value);
  }

  void _handlePressed(Offset anchor) {
    widget.onSelected();
    widget.onHandlePressed(anchor);
  }

  @override
  Widget build(BuildContext context) {
    final space = context.klp.space;
    final handleLeft = (widget.contentLeft - space.iconButton - space.tight)
        .clamp(_hiddenOpacity, double.infinity);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.selected)
            Positioned(
              left: widget.contentLeft,
              width: widget.contentWidth,
              top: _hiddenOpacity,
              height: widget.visualHeight,
              child: IgnorePointer(
                child: KlpStateHighlight(
                  state: KlpHighlightState.selected,
                  child: const SizedBox.expand(
                    key: ValueKey('notist-note-block-selection-surface'),
                  ),
                ),
              ),
            ),
          Positioned(
            left: handleLeft,
            top: _hiddenOpacity,
            child: IgnorePointer(
              ignoring: !_handleVisible,
              child: Opacity(
                key: const ValueKey(
                  'notist-note-block-chrome-handle-visibility',
                ),
                opacity: _handleVisible ? _visibleOpacity : _hiddenOpacity,
                child: NotistNoteBlockHandle(
                  key: const ValueKey('notist-note-block-chrome-handle'),
                  label: widget.handleLabel,
                  onPressed: _handlePressed,
                  onFocusChange: _setHandleFocused,
                  onDragStart: widget.onHandleDragStart,
                  onDragUpdate: widget.onHandleDragUpdate,
                  onDragEnd: widget.onHandleDragEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
