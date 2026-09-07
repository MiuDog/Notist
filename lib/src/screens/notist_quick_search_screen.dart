/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';

import '../components/search/notist_quick_search.dart';
import '../components/search/nts_quick_search_record.dart';
import '../project/notist_flow_document.dart';

/// 快速搜尋畫面組裝入口；在這裡把領域文件投影成搜尋元件 record。
final class NotistQuickSearchScreen extends StatefulWidget {
  const NotistQuickSearchScreen({
    super.key,
    required this.documents,
    required this.onOpen,
  });

  final List<NotistFlowDocument> documents;
  final ValueChanged<String> onOpen;

  @override
  State<NotistQuickSearchScreen> createState() =>
      _NotistQuickSearchScreenState();
}

final class _NotistQuickSearchScreenState
    extends State<NotistQuickSearchScreen> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    return NotistQuickSearch(
      record: _buildRecord(),
      onQueryChanged: (query) => setState(() => _query = query),
      onOpen: widget.onOpen,
    );
  }

  NtsQuickSearchRecord _buildRecord() {
    final normalizedQuery = _query.trim().toLowerCase();
    final documents = normalizedQuery.isEmpty
        ? const <NotistFlowDocument>[]
        : widget.documents
              .where((document) {
                return document.title.toLowerCase().contains(normalizedQuery) ||
                    document.folderPath.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);

    return NtsQuickSearchRecord(
      query: _query,
      results: [
        for (final document in documents)
          NtsQuickSearchResultRecord(
            rootId: document.rootId,
            title: document.title.isEmpty ? '未命名 Flow' : document.title,
            locationLabel: document.folderPath.isEmpty
                ? '專案根目錄'
                : document.folderPath,
          ),
      ],
    );
  }
}
