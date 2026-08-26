import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'nts_asset_item.dart';

/// 資產庫入口畫面：排序列 ＋ 瀑布流。
class NotistAssetsPage extends StatelessWidget {
  const NotistAssetsPage({
    super.key,
    required this.sortLabel,
    required this.sortOptions,
    required this.selectedSortId,
    required this.summaryLabel,
    this.items = const <NtsAssetItem>[],
    this.onSortChanged,
    this.onOpenAsset,
  });

  final List<NtsAssetItem> items;

  /// 排序列前方的標籤，例如「排序」。
  final String sortLabel;

  /// 排序選項的 id 與顯示文字。順序即呈現順序。
  final Map<String, String> sortOptions;
  final String selectedSortId;

  /// 右側摘要，例如「12 個資產 · 本機」。
  final String summaryLabel;

  final ValueChanged<String>? onSortChanged;
  final ValueChanged<NtsAssetItem>? onOpenAsset;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(klp.space.base),
          child: Row(
            children: [
              KlpText(
                sortLabel,
                role: KlpTextRole.label,
                tone: KlpTextTone.faint,
              ),
              SizedBox(width: klp.space.compact),
              KlpSegmentedControl(
                items: sortOptions.values.toList(),
                selected: sortOptions.keys.toList().indexOf(selectedSortId),
                onSelected: (index) =>
                    onSortChanged?.call(sortOptions.keys.elementAt(index)),
                dense: true,
              ),
              const Spacer(),
              KlpText(
                summaryLabel,
                role: KlpTextRole.code,
                tone: KlpTextTone.faint,
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const KlpEmptyState(
                  icon: KlpIcons.archive,
                  title: '資產庫是空的',
                  message: '把檔案放進專案資料夾後會出現在這裡。',
                )
              : KlpScrollViewport(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: klp.space.base),
                    child: Wrap(
                      spacing: klp.space.compact,
                      runSpacing: klp.space.compact,
                      children: [
                        for (final item in items)
                          _AssetCard(item: item, onOpen: onOpenAsset),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item, required this.onOpen});

  final NtsAssetItem item;
  final ValueChanged<NtsAssetItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final width = klp.space.gridTileWidth;

    return SizedBox(
      width: width,
      child: KlpPressable(
        onPressed: onOpen == null ? null : () => onOpen!(item),
        child: KlpSurface(
          tone: KlpSurfaceTone.component,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: _ratioOf(item.shape),
                child: KlpSurface(
                  tone: KlpSurfaceTone.inset,
                  child: const SizedBox.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(klp.space.compact),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KlpText(
                      item.name,
                      role: KlpTextRole.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: klp.space.hairline),
                    Row(
                      children: [
                        KlpText(
                          item.kind,
                          role: KlpTextRole.code,
                          tone: KlpTextTone.faint,
                        ),
                        SizedBox(width: klp.space.compact),
                        KlpText(
                          item.sizeLabel,
                          role: KlpTextRole.code,
                          tone: KlpTextTone.faint,
                        ),
                        const Spacer(),
                        KlpText(
                          item.whenLabel,
                          role: KlpTextRole.code,
                          tone: KlpTextTone.faint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 三種固定比例，對應 [NtsAssetShape]。
  double _ratioOf(NtsAssetShape shape) => switch (shape) {
    NtsAssetShape.tall => 4 / 5,
    NtsAssetShape.square => 1,
    NtsAssetShape.wide => 16 / 10,
  };
}
