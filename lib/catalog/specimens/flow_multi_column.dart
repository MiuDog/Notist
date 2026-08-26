part of 'flow_demo.dart';

class _ResizableColumnsPreview extends StatefulWidget {
  const _ResizableColumnsPreview();

  @override
  State<_ResizableColumnsPreview> createState() =>
      _ResizableColumnsPreviewState();
}

class _ResizableColumnsPreviewState extends State<_ResizableColumnsPreview> {
  var _weights = <double>[1, 1, 1];

  List<double> _widths(double availableWidth) {
    final total = _weights.reduce((sum, value) => sum + value);
    return [for (final weight in _weights) availableWidth * weight / total];
  }

  void _resize({
    required int index,
    required double delta,
    required double availableWidth,
    required double minimumWidth,
  }) {
    final widths = _widths(availableWidth);
    final pairWidth = widths[index] + widths[index + 1];
    final nextLeading = (widths[index] + delta)
        .clamp(minimumWidth, pairWidth - minimumWidth)
        .toDouble();

    widths[index] = nextLeading;
    widths[index + 1] = pairWidth - nextLeading;
    setState(() => _weights = widths);
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      const _ColumnContent(title: '觀察', body: '使用者先建立內容，再決定如何分類。'),
      const _ColumnContent(title: '問題', body: '跨頁尋找相關筆記時容易失去脈絡。'),
      const _ColumnContent(title: '方向', body: '保留閱讀順序，窄版時依序向下排列。'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final klp = context.klp;
        final stacked =
            constraints.maxWidth < klp.geometry.layout.primaryPaneBreakpoint;
        if (stacked) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  SizedBox(height: klp.space.itemGap),
              ],
            ],
          );
        }

        final handleWidth = klp.space.base;
        final availableWidth =
            constraints.maxWidth - handleWidth * (children.length - 1);
        final widths = _widths(availableWidth);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                SizedBox(
                  key: ValueKey('flow-column-$index'),
                  width: widths[index],
                  child: children[index],
                ),
                if (index < children.length - 1)
                  _ColumnResizeHandle(
                    key: ValueKey('flow-column-resize-$index'),
                    onDelta: (delta) => _resize(
                      index: index,
                      delta: delta,
                      availableWidth: availableWidth,
                      minimumWidth: klp.space.pageLarge,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ColumnResizeHandle extends StatelessWidget {
  const _ColumnResizeHandle({super.key, required this.onDelta});

  final ValueChanged<double> onDelta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.klp.space.base,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          const KlpDivider(vertical: true),
          KlpResizeHandle(
            semanticLabel: 'Resize adjacent columns',
            onDelta: onDelta,
          ),
          IgnorePointer(
            child: KlpIcon(
              KlpIcons.gripVertical,
              size: context.klp.space.iconSmall,
              color: context.klpColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnContent extends StatelessWidget {
  const _ColumnContent({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return KlpSurface(
      tone: KlpSurfaceTone.muted,
      padding: EdgeInsets.all(context.klp.space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KlpText(title, role: KlpTextRole.bodyStrong),
          SizedBox(height: context.klp.space.tight),
          KlpText(body, tone: KlpTextTone.muted),
        ],
      ),
    );
  }
}
