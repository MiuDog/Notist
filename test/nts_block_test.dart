import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

void main() {
  testWidgets('內容點擊只編輯，六點操作鈕才選取區塊', (tester) async {
    final hoverStates = <bool>[];
    var editRequests = 0;
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Center(
              child: NtsBlock(
                selected: selected,
                handleLabel: 'Block actions',
                onHandlePressed: (_) {},
                onSelected: () => setState(() => selected = true),
                onHover: hoverStates.add,
                onContentPressed: () => editRequests += 1,
                child: const KlpText('一般段落'),
              ),
            ),
          ),
        ),
      ),
    );

    // 斷言的是行為（hover 有回饋），不是 Kallopis 的內部節點 key。
    // 先前這裡綁死 'klp-pressable-state-highlight'，Kallopis 一改實作就紅——
    // 那不是回歸，是耦合。
    expect(
      tester
          .widgetList<KlpStateHighlight>(find.byType(KlpStateHighlight))
          .every((highlight) => highlight.state == KlpHighlightState.none),
      isTrue,
      reason: '靜止時不該有任何狀態呈現',
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byType(NtsBlock)));
    await tester.pump();

    expect(hoverStates, contains(true));
    expect(
      tester
          .widgetList<KlpStateHighlight>(find.byType(KlpStateHighlight))
          .any((highlight) => highlight.state != KlpHighlightState.none),
      isTrue,
      reason: 'hover 必須有視覺回饋——手法由 Kallopis 決定，這裡只驗證它存在',
    );

    await tester.tap(find.text('一般段落'));
    await tester.pump();

    expect(editRequests, 1);
    expect(selected, isFalse);

    await tester.tap(find.byKey(const ValueKey('nts-block-handle')));
    await tester.pump();

    expect(selected, isTrue);
    expect(editRequests, 1);
    // 指名內容的 pressable：六點操作鈕內部也是 KlpPressable，
    // 只用型別會同時找到兩個。
    expect(
      tester
          .widget<KlpPressable>(
            find.byKey(const ValueKey('nts-block-content-pressable')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('六點操作鈕回報全域座標並提供可選拖曳手勢', (tester) async {
    Offset? menuAnchor;
    var dragDelta = Offset.zero;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: Scaffold(
          body: NtsBlock(
            handleLabel: 'Block actions',
            onHandlePressed: (position) => menuAnchor = position,
            onSelected: () {},
            onHandleDragUpdate: (details) => dragDelta += details.delta,
            onContentPressed: () {},
            child: const KlpText('表格'),
          ),
        ),
      ),
    );

    final handle = find.byKey(const ValueKey('nts-block-handle'));
    final icon = tester.widget<KlpIcon>(
      find.descendant(of: handle, matching: find.byType(KlpIcon)),
    );

    expect(icon.asset, KlpIcons.gripVertical);

    await tester.tap(handle);
    await tester.drag(handle, const Offset(60, 40));
    await tester.pump();

    expect(menuAnchor, isNotNull);
    expect(dragDelta, isNot(Offset.zero));
  });
}
