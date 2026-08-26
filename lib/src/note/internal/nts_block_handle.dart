part of '../nts_block.dart';

class _NtsBlockHandle extends StatefulWidget {
  const _NtsBlockHandle({
    super.key,
    required this.label,
    required this.onPressed,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final String label;
  final ValueChanged<Offset> onPressed;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;

  @override
  State<_NtsBlockHandle> createState() => _NtsBlockHandleState();
}

class _NtsBlockHandleState extends State<_NtsBlockHandle> {
  // hover 與 focus 狀態由 `KlpPressable` 自行維護，此處不重複追蹤——
  // 重複追蹤等於在 Notist 這一側複製了一份互動狀態機。
  var _dragging = false;

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
    final klp = context.klp;

    // 互動視覺由 `KlpPressable` 提供，Notist 不自行組合 Material／InkWell。
    //
    // 先前這裡用 Flutter 的 `Material` ＋ `InkWell` 自行畫 hover 背景與圓角。
    // 即使數值取自 Kallopis token，**「怎麼呈現按壓與 hover」仍是風格決定**，
    // 那屬於 Kallopis。自行組合會讓這顆 handle 的互動視覺與其他控制項分岔，
    // 且 Kallopis 之後調整互動樣式時，這裡不會跟著變。
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
            // 拖曳中維持 active 外觀；hover 與 focus 由 KlpPressable 自理。
            selected: _dragging,
            child: SizedBox.square(
              dimension: klp.space.iconButton,
              child: Center(child: KlpIcon(KlpIcons.gripVertical)),
            ),
          ),
        ),
      ),
    );
  }
}
