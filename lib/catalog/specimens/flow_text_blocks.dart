part of 'flow_demo.dart';

class _TextList extends StatelessWidget {
  const _TextList({required this.items, this.numbered = false});

  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: EdgeInsets.only(bottom: context.klp.space.tight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.klp.space.loose,
                  child: KlpText(numbered ? '${index + 1}.' : '•'),
                ),
                Expanded(child: KlpText(items[index])),
              ],
            ),
          ),
      ],
    );
  }
}

class _CollapsibleListPreview extends StatelessWidget {
  const _CollapsibleListPreview();

  @override
  Widget build(BuildContext context) {
    return const KlpAccordion(
      initialExpandedIds: {'empty-list'},
      items: [
        KlpAccordionItemData(
          id: 'empty-list',
          title: '摺疊列表',
          child: KlpText('空的摺疊列表。按一下標題即可收合或展開。', tone: KlpTextTone.muted),
        ),
      ],
    );
  }
}

class _AnnotationHeading extends StatelessWidget {
  const _AnnotationHeading({required this.gap});

  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const KlpText(
          '註 01',
          role: KlpTextRole.caption,
          tone: KlpTextTone.faint,
        ),
        SizedBox(width: gap),
        const Expanded(child: KlpText('資料來源與補充說明', role: KlpTextRole.h4)),
      ],
    );
  }
}
