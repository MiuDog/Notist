import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

/// 以 Kallopis 方格背景與資料表組裝的 Sheet 筆記頁。
class NotistSheetPage extends StatelessWidget {
  const NotistSheetPage({super.key, required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return NtsPageBackground(
      key: const ValueKey('notist-sheet-page'),
      style: NtsPageBackgroundStyle.grid,
      child: KlpScrollViewport(
        padding: EdgeInsets.all(klp.space.section),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KlpText(
              'SHEET',
              role: KlpTextRole.code,
              tone: KlpTextTone.faint,
            ),
            KlpText(noteTitle, role: KlpTextRole.display),
            SizedBox(height: klp.space.section),
            const KlpDataTable(
              columns: [
                KlpDataColumn(id: 'item', label: 'ITEM', width: 2),
                KlpDataColumn(id: 'qty', label: 'QTY'),
                KlpDataColumn(id: 'note', label: 'NOTE', width: 2),
              ],
              rows: [
                KlpDataRow(
                  id: 'coffee',
                  cells: {
                    'item': 'Coffee beans',
                    'qty': '1',
                    'note': 'Medium roast',
                  },
                ),
                KlpDataRow(
                  id: 'oats',
                  cells: {
                    'item': 'Rolled oats',
                    'qty': '2',
                    'note': 'Large bag',
                  },
                ),
                KlpDataRow(
                  id: 'lemons',
                  cells: {'item': 'Lemons', 'qty': '4', 'note': 'For tea'},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
