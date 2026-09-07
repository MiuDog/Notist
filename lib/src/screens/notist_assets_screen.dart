/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';

import '../assets/nts_asset_item.dart';
import '../components/assets/notist_asset_library.dart';
import '../components/assets/nts_asset_library_record.dart';

/// 資產庫畫面組裝入口。
final class NotistAssetsScreen extends StatelessWidget {
  const NotistAssetsScreen({
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
    return NotistAssetLibrary(
      record: record,
      onSortChanged: onSortChanged,
      onOpenAsset: onOpenAsset,
    );
  }
}
