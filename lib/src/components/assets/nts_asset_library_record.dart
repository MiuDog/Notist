/// Notist 專案模組。

library;

import '../../assets/nts_asset_item.dart';

/// 資產庫元件所需的完整呈現資料。
final class NtsAssetLibraryRecord {
  const NtsAssetLibraryRecord({
    required this.sortLabel,
    required this.sortOptions,
    required this.selectedSortId,
    required this.summaryLabel,
    this.items = const <NtsAssetItem>[],
  });

  final String sortLabel;
  final Map<String, String> sortOptions;
  final String selectedSortId;
  final String summaryLabel;
  final List<NtsAssetItem> items;
}
