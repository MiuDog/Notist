part of 'flow_demo.dart';

class _EmptyTablePreview extends StatelessWidget {
  const _EmptyTablePreview();

  @override
  Widget build(BuildContext context) {
    return _HorizontalDocumentViewport(
      child: Table(
        key: const ValueKey('flow-empty-table-grid'),
        border: TableBorder.all(
          color: context.klpColors.divider,
          width: context.klp.shape.hairline,
        ),
        children: [
          for (var row = 0; row < 3; row++)
            TableRow(
              children: [
                for (var column = 0; column < 3; column++)
                  SizedBox(height: context.klp.space.controlHeightLarge),
              ],
            ),
        ],
      ),
    );
  }
}

class _DatabasePreview extends StatelessWidget {
  const _DatabasePreview();

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: KlpText('New database', role: KlpTextRole.h3),
            ),
            KlpIconButton(
              icon: KlpIcons.search,
              label: 'Search',
              onPressed: () {},
            ),
            SizedBox(width: klp.space.tight),
            KlpIconButton(
              icon: KlpIcons.maximize,
              label: 'Expand',
              onPressed: () {},
            ),
            SizedBox(width: klp.space.tight),
            KlpIconButton(
              icon: KlpIcons.settings,
              label: 'Properties',
              onPressed: () {},
            ),
            SizedBox(width: klp.space.compact),
            KlpButton(
              label: 'New',
              compact: true,
              trailing: const KlpIcon(KlpIcons.chevronDown),
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: klp.space.itemGap),
        _HorizontalDocumentViewport(
          child: Table(
            border: TableBorder(
              top: BorderSide(
                color: context.klpColors.divider,
                width: klp.shape.hairline,
              ),
              horizontalInside: BorderSide(
                color: context.klpColors.divider,
                width: klp.shape.hairline,
              ),
              verticalInside: BorderSide(
                color: context.klpColors.divider,
                width: klp.shape.hairline,
              ),
            ),
            children: [
              TableRow(
                children: [
                  _DatabaseCell(
                    child: Row(
                      children: [
                        const KlpText('Aa', tone: KlpTextTone.muted),
                        SizedBox(width: klp.space.compact),
                        const KlpText('Name'),
                      ],
                    ),
                  ),
                  const _DatabaseCell(child: KlpText('Add property')),
                ],
              ),
              TableRow(
                children: [
                  _DatabaseCell(
                    child: Row(
                      children: [
                        const KlpText('＋'),
                        SizedBox(width: klp.space.compact),
                        const KlpText('New page'),
                      ],
                    ),
                  ),
                  const _DatabaseCell(child: SizedBox.shrink()),
                ],
              ),
              for (var row = 0; row < 2; row++)
                const TableRow(
                  children: [
                    _DatabaseCell(child: SizedBox.shrink()),
                    _DatabaseCell(child: SizedBox.shrink()),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatabaseCell extends StatelessWidget {
  const _DatabaseCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.klp.space.controlHeightLarge,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.klp.space.base),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}

class _HorizontalDocumentViewport extends StatefulWidget {
  const _HorizontalDocumentViewport({required this.child});

  final Widget child;

  @override
  State<_HorizontalDocumentViewport> createState() =>
      _HorizontalDocumentViewportState();
}

class _HorizontalDocumentViewportState
    extends State<_HorizontalDocumentViewport> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minimumWidth =
            context.klp.geometry.layout.secondaryPaneBreakpoint;

        return Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth > minimumWidth
                  ? constraints.maxWidth
                  : minimumWidth,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return KlpFilePreview(
      name: 'research-board.png',
      metadata: 'PNG',
      height: height,
      preview: KlpSurface(
        tone: KlpSurfaceTone.inset,
        child: Center(
          child: KlpIcon(KlpIcons.box, size: context.klp.space.iconLarge),
        ),
      ),
    );
  }
}
