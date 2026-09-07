/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import '../../journal/nts_journal_entry.dart';

/// Notist Journals 的排程清單元件。
final class NotistJournalScheduleList extends StatelessWidget {
  const NotistJournalScheduleList({super.key, required this.items});

  final List<NtsScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const KlpEmptyState(
        icon: KlpIcons.calendar,
        title: '今天沒有排程',
        message: 'Flow 觸發、提醒與外部行事曆的項目會集中在這裡。',
      );
    }

    final klp = context.klp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.symmetric(vertical: klp.space.hairline),
            child: KlpSurface(
              tone: KlpSurfaceTone.inset,
              padding: EdgeInsets.symmetric(
                horizontal: klp.space.tight,
                vertical: klp.space.tight,
              ),
              child: Row(
                children: [
                  KlpText(
                    item.time,
                    role: KlpTextRole.code,
                    tone: KlpTextTone.muted,
                  ),
                  SizedBox(width: klp.space.tight),
                  Expanded(
                    child: KlpText(
                      item.label,
                      role: KlpTextRole.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  KlpBadge(label: item.tag, tone: _toneOf(item.tone)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  KlpFeedbackTone _toneOf(NtsScheduleTone tone) => switch (tone) {
    NtsScheduleTone.neutral => KlpFeedbackTone.neutral,
    NtsScheduleTone.info => KlpFeedbackTone.info,
    NtsScheduleTone.success => KlpFeedbackTone.success,
    NtsScheduleTone.warning => KlpFeedbackTone.warning,
  };
}
