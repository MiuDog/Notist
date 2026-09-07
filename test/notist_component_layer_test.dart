/// Notist 專案模組。

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/assets/notist_assets_page.dart';
import 'package:notist/src/components/assets/nts_asset_library_record.dart';
import 'package:notist/src/components/assistant/nts_assistant_panel_record.dart';
import 'package:notist/src/components/journals/nts_journals_overview_record.dart';
import 'package:notist/src/project/notist_flow_document.dart';
import 'package:notist/src/search/notist_quick_search_page.dart';
import 'package:notist/src/screens/notist_assistant_screen.dart';

void main() {
  test('product screens accept a dedicated presentation record', () {
    const assistantRecord = NtsAssistantPanelRecord(
      placeholder: '詢問 Notist AI',
      sendLabel: '傳送',
      attachLabel: '附加內容',
    );
    const assetRecord = NtsAssetLibraryRecord(
      sortLabel: '排序',
      sortOptions: {'recent': '最近'},
      selectedSortId: 'recent',
      summaryLabel: '',
    );
    final journalsRecord = NtsJournalsOverviewRecord(
      month: DateTime(2026, 9),
      monthLabel: '2026 年 9 月',
      summaryLabel: '',
      weekdayLabels: const ['一', '二', '三', '四', '五', '六', '日'],
      previousMonthLabel: '上個月',
      nextMonthLabel: '下個月',
    );

    final assistantScreen = NotistAssistantScreen(record: assistantRecord);
    final assetScreen = NotistAssetsPage(record: assetRecord);
    final searchScreen = NotistQuickSearchPage(
      documents: const [
        NotistFlowDocument(
          rootId: 'root-1',
          title: '規格',
          filePath: r'C:\project\spec.krdf',
        ),
      ],
      onOpen: (_) {},
    );

    expect(assistantScreen.record, same(assistantRecord));
    expect(assetScreen.record, same(assetRecord));
    expect(searchScreen.documents.single.rootId, 'root-1');
    expect(journalsRecord.month, DateTime(2026, 9));
  });
}
