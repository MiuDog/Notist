/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import '../../assets/nts_asset_item.dart';
import 'nts_asset_library_record.dart';

/// Notist 資產庫元件。
final class NotistAssetLibrary extends StatelessWidget {
  const NotistAssetLibrary({
    super.key,
    required this.record,
    this.onSortChanged,
    this.onOpenAsset,
  });

  final NtsAssetLibraryRecord record;
  final ValueChanged<String>? onSortChanged;
  final ValueChanged<NtsAssetItem>? onOpenAsset;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final sortIds = record.sortOptions.keys.toList(growable: false);
    final selectedIndex = sortIds.indexOf(record.selectedSortId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(klp.space.base),
          child: Row(
            children: [
              KlpText(
                record.sortLabel,
                role: KlpTextRole.label,
                tone: KlpTextTone.faint,
              ),
              SizedBox(width: klp.space.tight),
              KlpSegmentedControl(
                items: record.sortOptions.values.toList(growable: false),
                selected: selectedIndex < 0 ? 0 : selectedIndex,
                onSelected: (index) => onSortChanged?.call(sortIds[index]),
                dense: true,
              ),
              const Spacer(),
              KlpText(
                record.summaryLabel,
                role: KlpTextRole.code,
                tone: KlpTextTone.faint,
              ),
            ],
          ),
        ),
        Expanded(
          child: record.items.isEmpty
              ? const KlpEmptyState(
                  icon: KlpIcons.archive,
                  title: '資產庫是空的',
                  message: '把檔案放進專案資料夾後會出現在這裡。',
                )
              : KlpScrollViewport(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: klp.space.base),
                    child: Wrap(
                      spacing: klp.space.tight,
                      runSpacing: klp.space.tight,
                      children: [
                        for (final item in record.items)
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

final class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item, required this.onOpen});

  final NtsAssetItem item;
  final ValueChanged<NtsAssetItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return SizedBox(
      width: klp.space.gridTileWidth,
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
                padding: EdgeInsets.all(klp.space.tight),
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
                        SizedBox(width: klp.space.tight),
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
