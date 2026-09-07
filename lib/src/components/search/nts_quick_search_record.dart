/// Notist 專案模組。

library;

/// 快速搜尋元件所需的完整呈現資料。
final class NtsQuickSearchRecord {
  const NtsQuickSearchRecord({required this.query, required this.results});

  final String query;
  final List<NtsQuickSearchResultRecord> results;
}

/// 一筆可開啟的快速搜尋結果。
final class NtsQuickSearchResultRecord {
  const NtsQuickSearchResultRecord({
    required this.rootId,
    required this.title,
    required this.locationLabel,
  });

  final String rootId;
  final String title;
  final String locationLabel;
}
