import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'nts_journal_entry.dart';

/// Journals 入口畫面：月曆 ＋ 今日待辦 ＋ 排程。
///
/// 這個檔案只做**組合**：所有視覺都來自 Kallopis 的元件與 token，這裡沒有任何
/// 顏色、間距或尺寸的字面值。畫面本身的語意（什麼是待辦、排程來源怎麼分類）
/// 才是 Notist 的部分。
class NotistJournalsPage extends StatelessWidget {
  const NotistJournalsPage({
    super.key,
    required this.month,
    required this.monthLabel,
    required this.summaryLabel,
    required this.weekdayLabels,
    required this.previousMonthLabel,
    required this.nextMonthLabel,
    this.today,
    this.entries = const <NtsJournalEntry>[],
    this.todos = const <NtsTodoItem>[],
    this.schedule = const <NtsScheduleItem>[],
    this.onPreviousMonth,
    this.onNextMonth,
    this.onToggleTodo,
  });

  final DateTime month;

  /// 月份標題，例如「2026 年 8 月」。由呼叫端組出——庫與畫面都不決定語言。
  final String monthLabel;

  /// 月份右側的摘要，例如「7 個排程 · 3 個待辦」。
  final String summaryLabel;

  final List<String> weekdayLabels;
  final String previousMonthLabel;
  final String nextMonthLabel;
  final DateTime? today;

  final List<NtsJournalEntry> entries;
  final List<NtsTodoItem> todos;
  final List<NtsScheduleItem> schedule;

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
            _MonthHeading(monthLabel: monthLabel, summaryLabel: summaryLabel),
            SizedBox(height: klp.space.compact),
            KlpCalendar(
              month: month,
              monthLabel: monthLabel,
              weekdayLabels: weekdayLabels,
              previousMonthLabel: previousMonthLabel,
              nextMonthLabel: nextMonthLabel,
              today: today,
              onPreviousMonth: onPreviousMonth,
              onNextMonth: onNextMonth,
              dayContentBuilder: _buildDayContent,
            ),
            SizedBox(height: klp.space.section),
            KlpSection(
              title: '今日待辦',
              child: _TodoList(items: todos, onToggle: onToggleTodo),
            ),
            SizedBox(height: klp.space.section),
            KlpSection(
              title: '排程',
              label: '來自 Flow、提醒與外部行事曆',
              child: _ScheduleList(items: schedule),
            ),
          ],
        ),
      ),
    );
  }

  /// 月曆格子裡的當日條目。回傳 `null` 代表那天沒有東西——月曆會因此維持空格。
  Widget? _buildDayContent(DateTime date) {
    final ofDay = entries
        .where(
          (entry) =>
              entry.date.year == date.year &&
              entry.date.month == date.month &&
              entry.date.day == date.day,
        )
        .toList();
    if (ofDay.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in ofDay)
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

class _MonthHeading extends StatelessWidget {
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

class _TodoList extends StatelessWidget {
  const _TodoList({required this.items, required this.onToggle});

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
                SizedBox(width: klp.space.compact),
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

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({required this.items});

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
                horizontal: klp.space.compact,
                vertical: klp.space.tight,
              ),
              child: Row(
                children: [
                  KlpText(
                    item.time,
                    role: KlpTextRole.code,
                    tone: KlpTextTone.muted,
                  ),
                  SizedBox(width: klp.space.compact),
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
