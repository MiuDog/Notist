part of 'flow_demo.dart';

class _FlowBlockPreview extends StatefulWidget {
  const _FlowBlockPreview({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.onContentPressed,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onContentPressed;
  final Widget child;

  @override
  State<_FlowBlockPreview> createState() => _FlowBlockPreviewState();
}

class _FlowBlockPreviewState extends State<_FlowBlockPreview> {
  final _menuController = KlpContextMenuController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.klp.space.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KlpText(
            widget.label,
            role: KlpTextRole.caption,
            tone: KlpTextTone.muted,
          ),
          SizedBox(height: context.klp.space.tight),
          KlpContextMenu(
            controller: _menuController,
            label: 'Block actions',
            items: [
              KlpMenuItemData(
                label: 'Duplicate',
                icon: KlpIcons.clipboard,
                onPressed: () {},
              ),
              KlpMenuItemData(
                label: 'Turn into',
                icon: KlpIcons.switchVertical,
                onPressed: () {},
              ),
              KlpMenuItemData(
                label: 'Delete',
                icon: KlpIcons.trash,
                danger: true,
                separatedBefore: true,
                onPressed: () {},
              ),
            ],
            child: NtsBlock(
              selected: widget.selected,
              semanticLabel: widget.label,
              handleLabel: '${widget.label} actions',
              onHandlePressed: _menuController.openAt,
              onSelected: widget.onSelected,
              onContentPressed: widget.onContentPressed,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
