import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

part 'internal/nts_block_handle.dart';

/// 文件內容的共通互動基底。
///
/// 內容點擊與區塊選取刻意分離：內容透過 [onContentPressed] 進入編輯，只有左上角六點
/// 操作鈕會先呼叫 [onSelected]，再透過 [onHandlePressed] 回報選單錨點。所有狀態視覺
/// 由 Kallopis 提供；拖曳 callbacks 只回報手勢，區塊順序仍由 Flow 等消費端持有。
class NtsBlock extends StatelessWidget {
  const NtsBlock({
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

  /// `null` 只用於刻意停用的呈現；Flow 內容區塊應提供 callback。
  final VoidCallback? onContentPressed;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<bool>? onHover;
  final String? semanticLabel;

  /// Catalog 不提供這三個 callback，因此六點操作鈕只能開啟選單、不能重新排序。
  final GestureDragStartCallback? onHandleDragStart;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  void _handlePressed(Offset anchor) {
    onSelected();
    onHandlePressed(anchor);
  }

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final content = Padding(
      padding: padding ?? EdgeInsets.all(klp.space.base),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final handle = _NtsBlockHandle(
            key: const ValueKey('nts-block-handle'),
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
              SizedBox(width: klp.space.compact),
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
        // 明確標示「承載區塊選取狀態」的那個 pressable。
        // 六點操作鈕內部也是 KlpPressable，僅靠型別無法區分兩者。
        key: const ValueKey('nts-block-content-pressable'),
        selected: selected,
        onPressed: onContentPressed,
        onHover: onHover,
        child: content,
      ),
    );
  }
}

class NtsBlockCanvas extends StatelessWidget {
  const NtsBlockCanvas({
    super.key,
    required this.children,
    this.constrained = false,
  });

  final List<Widget> children;
  final bool constrained;

  @override
  Widget build(BuildContext context) {
    final canvas = KlpSurface(
      tone: KlpSurfaceTone.inset,
      child: Stack(children: children),
    );

    return constrained ? canvas : InteractiveViewer(child: canvas);
  }
}

/// 疊在 authority-rendered 內容上的 Block 選取框與操作把手。
///
/// [contentLeft]、[contentWidth] 與 [visualHeight] 必須由內容 layout authority
/// 提供；本元件只畫 chrome，不量測或推導 Block 位置。
///
/// **本元件本身佔滿版面高度（含區塊間距），選取框卻只畫到 [visualHeight]。**
/// 兩者刻意不同：佔滿版面高度讓相鄰 Block 的點擊區連續無縫，區塊之間不會有
/// 選不到的死區；而選取框若跟著畫滿，框就會比文字高一個間距，看起來像文字
/// 上浮、每個區塊佔了兩行。
class NtsBlockChrome extends StatefulWidget {
  const NtsBlockChrome({
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

  /// 內容本身的高度，不含區塊間距。選取框畫到這個高度為止。
  final double visualHeight;
  final String handleLabel;
  final ValueChanged<Offset> onHandlePressed;
  final VoidCallback onSelected;
  final bool selected;
  final GestureDragStartCallback? onHandleDragStart;
  final GestureDragUpdateCallback? onHandleDragUpdate;
  final GestureDragEndCallback? onHandleDragEnd;

  @override
  State<NtsBlockChrome> createState() => _NtsBlockChromeState();
}

class _NtsBlockChromeState extends State<NtsBlockChrome> {
  bool _hovered = false;

  void _handlePressed(Offset anchor) {
    widget.onSelected();
    widget.onHandlePressed(anchor);
  }

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final handleLeft =
        (widget.contentLeft - klp.space.iconButton - klp.space.tight).clamp(
          0.0,
          double.infinity,
        );

    // 握把只在指標停在這個區塊上、或該區塊被選取時出現。
    //
    // 先前是常駐顯示，結果空白區塊看起來就是一排光禿禿的握把——文件還沒開始寫，
    // 畫面上已經有五個控制項在搶注意力。
    final showHandle = _hovered || widget.selected;

    final chrome = Stack(
      clipBehavior: Clip.none,
      children: [
        // 選取的填色由編輯器畫在原生內容底下（見 _buildSelectionUnderlay）。
        // 這裡不畫邊框：準則 §2.1 的選取是填色，第 5 條又禁止 accent 用於選取，
        // 而先前這裡正是用 accent 畫了一圈實線。
        if (showHandle)
          Positioned(
            left: handleLeft,
            top: 0,
            child: _NtsBlockHandle(
              key: const ValueKey('nts-block-chrome-handle'),
              label: widget.handleLabel,
              onPressed: _handlePressed,
              onDragStart: widget.onHandleDragStart,
              onDragUpdate: widget.onHandleDragUpdate,
              onDragEnd: widget.onHandleDragEnd,
            ),
          ),
      ],
    );

    // hover 只在 desktop 有意義；觸控裝置上握把由選取狀態決定。
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: chrome,
    );
  }
}
