/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import 'nts_quick_search_record.dart';

/// Notist 快速搜尋元件。
final class NotistQuickSearch extends StatelessWidget {
  const NotistQuickSearch({
    super.key,
    required this.record,
    required this.onQueryChanged,
    required this.onOpen,
  });

  final NtsQuickSearchRecord record;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final query = record.query.trim();

    return Padding(
      padding: EdgeInsets.all(context.klp.space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KlpTextField(
            autofocus: true,
            clearable: true,
            leadingIcon: KlpIcons.search,
            placeholder: '搜尋 Flow 標題與資料夾',
            onChanged: onQueryChanged,
            onClear: () => onQueryChanged(''),
          ),
          SizedBox(height: context.klp.space.base),
          Expanded(child: _buildResults(query)),
        ],
      ),
    );
  }

  Widget _buildResults(String query) {
    if (query.isEmpty) {
      return const KlpEmptyState(
        icon: KlpIcons.search,
        title: '快速搜尋',
        message: '輸入 Flow 標題或資料夾名稱。全文搜尋等待 Krepis 專案查詢契約。',
      );
    }
    if (record.results.isEmpty) {
      return const KlpEmptyState(
        icon: KlpIcons.search,
        title: '找不到 Flow',
        message: '目前沒有符合的標題或資料夾。',
      );
    }

    return KlpScrollViewport(
      child: Column(
        children: [
          for (final result in record.results)
            KlpListTile(
              title: result.title,
              subtitle: result.locationLabel,
              icon: KlpIcons.edit,
              onPressed: () => onOpen(result.rootId),
            ),
        ],
      ),
    );
  }
}
