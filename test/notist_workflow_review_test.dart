import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/assistant/notist_proposal_review.dart';
import 'package:notist/src/components/assistant/notist_requirement_review.dart';
import 'package:notist/src/components/assistant/notist_workflow_composer.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: buildKlpTheme(Brightness.light),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );

  testWidgets('proposal actions remain three distinct typed callbacks', (
    tester,
  ) async {
    var confirmations = 0;
    var rejections = 0;
    var revisions = 0;
    await pump(
      tester,
      NotistProposalReview(
        title: 'Proposal',
        summary: 'Summary',
        versionLabel: 'v1',
        statusLabel: 'Ready',
        affectedLabel: '1 artifact',
        changes: const [
          NotistProposalChangeData(
            path: 'screens/Home',
            kindLabel: 'Create',
            reason: 'New screen',
            kind: NotistProposalChangeKind.create,
          ),
        ],
        confirmLabel: 'Confirm',
        rejectLabel: 'Reject',
        reviseLabel: 'Revise',
        onConfirm: () => confirmations += 1,
        onReject: () => rejections += 1,
        onRevise: () => revisions += 1,
      ),
    );

    await tester.tap(find.widgetWithText(KlpButton, 'Confirm'));
    await tester.tap(find.widgetWithText(KlpButton, 'Reject'));
    await tester.tap(find.widgetWithText(KlpButton, 'Revise'));
    expect((confirmations, rejections, revisions), (1, 1, 1));
  });

  testWidgets(
    'stale proposal disables confirmation but keeps recovery actions',
    (tester) async {
      var confirmations = 0;
      var revisions = 0;
      await pump(
        tester,
        NotistProposalReview(
          title: 'Proposal',
          summary: 'Summary',
          versionLabel: 'v1',
          statusLabel: 'Stale',
          affectedLabel: '1 artifact',
          changes: const [],
          confirmLabel: 'Confirm',
          rejectLabel: 'Reject',
          reviseLabel: 'Revise',
          staleMessage: 'The base revision changed.',
          onConfirm: () => confirmations += 1,
          onRevise: () => revisions += 1,
        ),
      );

      final confirm = tester.widget<KlpButton>(
        find.widgetWithText(KlpButton, 'Confirm'),
      );
      expect(confirm.onPressed, isNull);
      await tester.tap(find.widgetWithText(KlpButton, 'Revise'));
      expect((confirmations, revisions), (0, 1));
    },
  );

  testWidgets('proposal header wraps without overflowing a narrow panel', (
    tester,
  ) async {
    await pump(
      tester,
      const SizedBox(
        width: 200,
        child: NotistProposalReview(
          title: 'Checkout application proposal',
          summary: 'Summary',
          versionLabel: 'Revision 3',
          statusLabel: 'Awaiting confirmation',
          affectedLabel: '4 artifacts',
          changes: [],
          confirmLabel: 'Confirm',
          rejectLabel: 'Reject',
          reviseLabel: 'Revise',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
  testWidgets('workflow composer keeps draft and attachment callbacks typed', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var selectedExample = '';
    await pump(
      tester,
      NotistWorkflowComposer(
        controller: controller,
        placeholder: 'Describe the product',
        sendLabel: 'Send',
        attachLabel: 'Attach',
        removeAttachmentLabel: 'Remove',
        onChanged: (_) {},
        examples: const ['Create a dashboard'],
        onExampleSelected: (value) => selectedExample = value,
      ),
    );

    await tester.tap(find.text('Create a dashboard'));
    expect(selectedExample, 'Create a dashboard');
    expect(find.byType(NotistPromptTextField), findsOneWidget);
  });

  testWidgets('requirement review preserves product status projection', (
    tester,
  ) async {
    await pump(
      tester,
      const NotistRequirementSummary(
        title: 'Requirements',
        confidenceLabel: 'High',
        requirements: [
          NotistRequirementData(
            id: 'audience',
            label: 'Audience',
            value: 'Operations team',
            sourceLabel: 'User',
            statusLabel: 'Confirmed',
            source: NotistRequirementSource.user,
            status: NotistRequirementStatus.confirmed,
          ),
        ],
      ),
    );

    expect(find.text('Audience'), findsOneWidget);
    final badgeLabels = tester
        .widgetList<KlpBadge>(find.byType(KlpBadge))
        .map((badge) => badge.label);
    expect(badgeLabels, containsAll(['High', 'User', 'Confirmed']));
    expect(find.text('Operations team'), findsOneWidget);
  });
}
