/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import '../../journal/nts_journal_entry.dart';

/// Notist Journals 的待辦清單元件。
final class NotistJournalTodoList extends StatelessWidget {
  const NotistJournalTodoList({super.key, required this.items, this.onToggle});

  final List<NtsTodoItem> items;
  final ValueChanged<NtsTodoItem>? onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const KlpEmptyState(
        icon: KlpIcons.checkSquare,
        title: '今天沒有待辦',
        message: '從筆記或 Flow 建立待辦後會出現在這裡。',
      );
    }

    final klp = context.klp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.symmetric(vertical: klp.space.hairline),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KlpCheckbox(
                  value: item.done,
                  label: item.label,
                  showLabel: false,
                  onChanged: onToggle == null ? null : (_) => onToggle!(item),
                ),
                SizedBox(width: klp.space.tight),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KlpText(item.label, role: KlpTextRole.body),
                      KlpText(
                        item.meta,
                        role: KlpTextRole.code,
                        tone: KlpTextTone.faint,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
