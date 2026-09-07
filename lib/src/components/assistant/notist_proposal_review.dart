/// Notist 專案模組。
library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 提案變更的有限種類。
enum NotistProposalChangeKind { create, replace, remove }

/// 一筆提案變更的呈現資料。
@immutable
class NotistProposalChangeData {
  const NotistProposalChangeData({
    required this.path,
    required this.kindLabel,
    required this.reason,
    required this.kind,
  });

  final String path;
  final String kindLabel;
  final String reason;
  final NotistProposalChangeKind kind;
}

/// 一筆提案問題的呈現資料。
@immutable
class NotistProposalIssueData {
  const NotistProposalIssueData({
    required this.message,
    required this.tone,
    this.path,
  });

  final String message;
  final String? path;
  final KlpFeedbackTone tone;
}

/// 提案審查表面；確認、拒絕與要求修訂是三個獨立的 typed callback。
class NotistProposalReview extends StatelessWidget {
  const NotistProposalReview({
    super.key,
    required this.title,
    required this.summary,
    required this.versionLabel,
    required this.statusLabel,
    required this.affectedLabel,
    required this.changes,
    required this.confirmLabel,
    required this.rejectLabel,
    required this.reviseLabel,
    this.issues = const [],
    this.diff,
    this.dependencies,
    this.staleMessage,
    this.onConfirm,
    this.onReject,
    this.onRevise,
  });

  final String title;
  final String summary;
  final String versionLabel;
  final String statusLabel;
  final String affectedLabel;
  final List<NotistProposalChangeData> changes;
  final List<NotistProposalIssueData> issues;
  final String confirmLabel;
  final String rejectLabel;
  final String reviseLabel;
  final Widget? diff;
  final Widget? dependencies;
  final String? staleMessage;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onRevise;

  @override
  Widget build(BuildContext context) {
    final stale = staleMessage != null;
    return Semantics(
      container: true,
      label: '$title. $statusLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KlpText(title, role: KlpTextRole.title),
          SizedBox(height: context.klp.space.tight),
          Wrap(
            spacing: context.klp.space.tight,
            runSpacing: context.klp.space.tight,
            children: [
              KlpBadge(label: versionLabel),
              KlpBadge(
                label: statusLabel,
                tone: stale ? KlpFeedbackTone.warning : KlpFeedbackTone.info,
              ),
            ],
          ),
          SizedBox(height: context.klp.space.contentStackGap),
          KlpText(
            affectedLabel,
            role: KlpTextRole.sub,
            tone: KlpTextTone.muted,
          ),
          SizedBox(height: context.klp.space.base),
          KlpText(summary, role: KlpTextRole.bodyStrong),
          if (stale) ...[
            SizedBox(height: context.klp.space.base),
            KlpInlineNotice(
              title: statusLabel,
              message: staleMessage!,
              tone: KlpFeedbackTone.warning,
            ),
          ],
          for (final change in changes) ...[
            SizedBox(height: context.klp.space.contentStackGap),
            KlpSurface(
              tone: KlpSurfaceTone.inset,
              padding: EdgeInsets.all(context.klp.space.contentInset),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KlpBadge(
                    label: change.kindLabel,
                    tone: change.kind == NotistProposalChangeKind.remove
                        ? KlpFeedbackTone.danger
                        : KlpFeedbackTone.info,
                  ),
                  SizedBox(width: context.klp.space.contentInlineGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KlpText(change.path, role: KlpTextRole.code),
                        KlpText(
                          change.reason,
                          role: KlpTextRole.sub,
                          tone: KlpTextTone.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          for (final issue in issues) ...[
            SizedBox(height: context.klp.space.contentStackGap),
            KlpInlineNotice(
              title: issue.path ?? statusLabel,
              message: issue.message,
              tone: issue.tone,
            ),
          ],
          if (diff != null) ...[
            SizedBox(height: context.klp.space.base),
            diff!,
          ],
          if (dependencies != null) ...[
            SizedBox(height: context.klp.space.base),
            dependencies!,
          ],
          SizedBox(height: context.klp.space.base),
          const KlpDivider(),
          SizedBox(height: context.klp.space.base),
          Wrap(
            spacing: context.klp.space.tight,
            runSpacing: context.klp.space.tight,
            children: [
              KlpButton(
                label: confirmLabel,
                onPressed: stale ? null : onConfirm,
              ),
              KlpButton(
                label: reviseLabel,
                tone: KlpButtonTone.secondary,
                onPressed: onRevise,
              ),
              KlpButton(
                label: rejectLabel,
                tone: KlpButtonTone.danger,
                onPressed: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
