/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import '../../journal/nts_journal_entry.dart';
import 'notist_journal_schedule_list.dart';
import 'notist_journal_todo_list.dart';
import 'nts_journals_overview_record.dart';

/// Notist Journals 總覽元件。
final class NotistJournalsOverview extends StatelessWidget {
  const NotistJournalsOverview({
    super.key,
    required this.record,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onToggleTodo,
  });

  final NtsJournalsOverviewRecord record;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<NtsTodoItem>? onToggleTodo;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return KlpScrollViewport(
      child: Padding(
        padding: EdgeInsets.all(klp.space.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthHeading(
              monthLabel: record.monthLabel,
              summaryLabel: record.summaryLabel,
            ),
            SizedBox(height: klp.space.tight),
            KlpCalendar(
              month: record.month,
              monthLabel: record.monthLabel,
              weekdayLabels: record.weekdayLabels,
              previousMonthLabel: record.previousMonthLabel,
              nextMonthLabel: record.nextMonthLabel,
              today: record.today,
              onPreviousMonth: onPreviousMonth,
              onNextMonth: onNextMonth,
              dayContentBuilder: _buildDayContent,
            ),
            SizedBox(height: klp.space.section),
            KlpSection(
              title: '今日待辦',
              child: NotistJournalTodoList(
                items: record.todos,
                onToggle: onToggleTodo,
              ),
            ),
            SizedBox(height: klp.space.section),
            KlpSection(
              title: '排程',
              label: '來自 Flow、提醒與外部行事曆',
              child: NotistJournalScheduleList(items: record.schedule),
            ),
          ],
        ),
      ),
    );
  }

  /// 月曆格子裡的當日條目；空值代表該日沒有項目。
  Widget? _buildDayContent(DateTime date) {
    final entries = record.entries
        .where((entry) {
          return entry.date.year == date.year &&
              entry.date.month == date.month &&
              entry.date.day == date.day;
        })
        .toList(growable: false);
    if (entries.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in entries)
          KlpText(
            entry.label,
            role: KlpTextRole.caption,
            tone: KlpTextTone.muted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

final class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.monthLabel, required this.summaryLabel});

  final String monthLabel;
  final String summaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: KlpText(monthLabel, role: KlpTextRole.section)),
        KlpText(summaryLabel, role: KlpTextRole.code, tone: KlpTextTone.faint),
      ],
    );
  }
}
