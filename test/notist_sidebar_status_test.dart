import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';

void main() {
  testWidgets('sidebar status uses the shared horizontal inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: const SizedBox(
            width: 240,
            height: 240,
            child: NotistSidebar(),
          ),
        ),
      ),
    );

    final sidebar = find.byType(NotistSidebar);
    final indicator = find.byType(KlpStatusIndicator);
    final inset = tester.element(sidebar).klp.space.chromePanelInset;

    expect(
      tester.getRect(indicator).left,
      tester.getRect(sidebar).left + inset,
    );
  });
}
