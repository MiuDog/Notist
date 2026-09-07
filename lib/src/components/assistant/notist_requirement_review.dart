/// Notist 專案模組。
library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 需求來源的有限分類。
enum NotistRequirementSource { user, assumption }

/// 需求的有限審查狀態。
enum NotistRequirementStatus {
  unknown,
  assumed,
  answered,
  conflicting,
  confirmed,
}

/// 一筆不可變的需求呈現資料。
@immutable
class NotistRequirementData {
  const NotistRequirementData({
    required this.id,
    required this.label,
    required this.value,
    required this.sourceLabel,
    required this.statusLabel,
    required this.source,
    required this.status,
    this.impact,
  });

  final String id;
  final String label;
  final String value;
  final String sourceLabel;
  final String statusLabel;
  final NotistRequirementSource source;
  final NotistRequirementStatus status;
  final String? impact;
}

/// 呈現單一探索問題、輔助提示與有限導覽動作。
class NotistDiscoveryQuestionCard extends StatelessWidget {
  const NotistDiscoveryQuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
    this.relatedPrompts = const [],
    this.actions = const [],
  });

  final String question;
  final String answer;
  final ValueChanged<String> onChanged;
  final List<String> relatedPrompts;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => KlpSurface(
    tone: KlpSurfaceTone.component,
    padding: EdgeInsets.all(context.klp.space.base),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KlpText(question, role: KlpTextRole.lead),
        if (relatedPrompts.isNotEmpty) ...[
          SizedBox(height: context.klp.space.contentStackGap),
          for (final prompt in relatedPrompts)
            KlpText(prompt, role: KlpTextRole.sub, tone: KlpTextTone.muted),
        ],
        SizedBox(height: context.klp.space.base),
        TextFormField(
          initialValue: answer,
          onChanged: onChanged,
          maxLines: null,
        ),
        if (actions.isNotEmpty) ...[
          SizedBox(height: context.klp.space.base),
          Wrap(
            spacing: context.klp.space.tight,
            runSpacing: context.klp.space.tight,
            children: actions,
          ),
        ],
      ],
    ),
  );
}

/// 需求摘要；衝突與假設透過不同語意名稱與色調呈現。
class NotistRequirementSummary extends StatelessWidget {
  const NotistRequirementSummary({
    super.key,
    required this.title,
    required this.requirements,
    this.confidenceLabel,
  });

  final String title;
  final List<NotistRequirementData> requirements;
  final String? confidenceLabel;

  KlpFeedbackTone _tone(NotistRequirementStatus status) => switch (status) {
    NotistRequirementStatus.confirmed => KlpFeedbackTone.success,
    NotistRequirementStatus.conflicting => KlpFeedbackTone.danger,
    NotistRequirementStatus.assumed => KlpFeedbackTone.warning,
    NotistRequirementStatus.answered => KlpFeedbackTone.info,
    NotistRequirementStatus.unknown => KlpFeedbackTone.neutral,
  };

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: KlpText(title, role: KlpTextRole.bodyStrong)),
            if (confidenceLabel != null) KlpBadge(label: confidenceLabel!),
          ],
        ),
        SizedBox(height: context.klp.space.contentStackGap),
        for (final requirement in requirements) ...[
          KlpSurface(
            tone: KlpSurfaceTone.inset,
            padding: EdgeInsets.all(context.klp.space.contentInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: KlpText(
                        requirement.label,
                        role: KlpTextRole.bodyStrong,
                      ),
                    ),
                    KlpBadge(
                      label: requirement.sourceLabel,
                      tone:
                          requirement.source ==
                              NotistRequirementSource.assumption
                          ? KlpFeedbackTone.warning
                          : KlpFeedbackTone.info,
                    ),
                    SizedBox(width: context.klp.space.tight),
                    KlpBadge(
                      label: requirement.statusLabel,
                      tone: _tone(requirement.status),
                    ),
                  ],
                ),
                SizedBox(height: context.klp.space.tight),
                KlpText(requirement.value),
                if (requirement.impact != null)
                  KlpText(
                    requirement.impact!,
                    role: KlpTextRole.sub,
                    tone: KlpTextTone.muted,
                  ),
              ],
            ),
          ),
          SizedBox(height: context.klp.space.tight),
        ],
      ],
    ),
  );
}
