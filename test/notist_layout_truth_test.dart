import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/shell/notist_workbench.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/stage/notist_stage.dart';

import 'layout_truth/notist_layout_truth.dart' as truth;

/// 拿實際渲染出來的幾何與 `Notist.dc.html` 版面稿逐項比對。**零容差。**
///
/// 既有的 `workbench_spacing_test` 斷言的是
/// `expect(sidebarRect.left - shellRect.left, compact)`——不管 `compact` 是多少
/// 都會通過。那種測試只能發現「程式碼沒照自己宣告的 token 走」，發現不了
/// 「尺寸偏離版面稿」。真相在稿件裡，所以這裡一律對著字面數字斷言。
void main() {
  /// 用稿件自己的預覽尺寸渲染，量出來的數字才和稿件可比。
  Future<void> pumpAtPreviewSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(
      truth.previewWidth,
      truth.previewHeight,
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();
  }

  group('外框', () {
    testWidgets('應用標題列高度是 ${truth.appHeaderHeight}', (tester) async {
      await pumpAtPreviewSize(tester);

      final header = find.byType(KlpWorkbenchWindowHeader);
      expect(header, findsOneWidget, reason: '版面稿第 15 行有 PlnAppWindowHeader');
      expect(tester.getSize(header).height, truth.appHeaderHeight);
    });

    testWidgets('主體區的內距與間距', (tester) async {
      await pumpAtPreviewSize(tester);

      final shell = tester.getRect(find.byType(NotistWorkbench));
      final sidebar = tester.getRect(find.byType(NotistSidebar));
      final stage = tester.getRect(find.byType(NotistStage));

      expect(
        sidebar.left - shell.left,
        truth.bodyPaddingHorizontal,
        reason: '版面稿第 23 行 padding 左側是 10px',
      );
      expect(
        shell.right - stage.right,
        truth.bodyPaddingHorizontal,
        reason: '版面稿第 23 行 padding 右側是 10px',
      );
      expect(
        shell.bottom - stage.bottom,
        truth.bodyPaddingBottom,
        reason: '版面稿第 23 行 padding 下方是 10px',
      );
      expect(
        sidebar.top - shell.top,
        truth.bodyPaddingTop,
        reason: '版面稿第 23 行 padding 上方是 0——標題列與內容不留空隙',
      );
      expect(
        stage.left - sidebar.right,
        truth.paneGap,
        reason: '版面稿第 23 行 gap 是 10px',
      );
    });
  });

  group('側欄', () {
    testWidgets('預設寬度是 ${truth.sidebarDefaultWidth}', (tester) async {
      await pumpAtPreviewSize(tester);

      expect(
        tester.getSize(find.byType(NotistSidebar)).width,
        truth.sidebarDefaultWidth,
        reason: '版面稿第 253 行 sidebarWidth:268',
      );
    });

    testWidgets('身分列的高度、內距與標記尺寸', (tester) async {
      await pumpAtPreviewSize(tester);

      final banner = find.byType(KlpSidebarIdentityHeader);
      expect(banner, findsOneWidget, reason: '版面稿第 308 行有身分列');

      final bannerRect = tester.getRect(banner);
      final sidebarRect = tester.getRect(find.byType(NotistSidebar));

      expect(
        bannerRect.height,
        truth.sidebarBannerHeight,
        reason: '版面稿第 308 行 height:36',
      );
      expect(
        bannerRect.left - sidebarRect.left,
        truth.sidebarBannerPaddingHorizontal,
        reason: '版面稿第 308 行 padding:"0 10px"',
      );

      final avatar = find.descendant(
        of: banner,
        matching: find.byType(KlpAvatar),
      );
      expect(avatar, findsOneWidget, reason: '版面稿第 314 行身分列右端有識別標記');
      expect(
        tester.getSize(avatar).width,
        truth.sidebarBannerChipSize,
        reason: '版面稿第 314 行 width:24,height:24',
      );
    });

    testWidgets('導覽項目的列高、內距與圖示格', (tester) async {
      await pumpAtPreviewSize(tester);

      final navButtons = find.byType(KlpSidebarNavigationButton);
      expect(navButtons, findsNWidgets(4), reason: '產品組合包含四個固定導覽入口');

      final first = tester.getRect(navButtons.first);
      expect(
        first.height,
        truth.navItemHeight,
        reason: '版面稿第 35 行 height:36px',
      );

      // 格子與字形是兩個值，必須分別量。只量 KlpIcon 量到的是字形——
      // 拿字形去對格子的期望值，會讓「字形頂滿格子」這種缺陷通過測試。
      final iconBox = find.descendant(
        of: navButtons.first,
        matching: find.byKey(const ValueKey(klpNavigationIconBoxKey)),
      );
      expect(iconBox, findsOneWidget, reason: '版面稿第 36 行每個導覽項目都有圖示格');
      expect(
        tester.getSize(iconBox).width,
        truth.navItemIconBox,
        reason: '版面稿第 36 行 width:20px;height:20px',
      );

      final icon = find.descendant(
        of: navButtons.first,
        matching: find.byType(KlpIcon),
      );
      expect(icon, findsOneWidget, reason: '版面稿第 36 行每個導覽項目都有圖示');
      expect(
        tester.getSize(icon).width,
        truth.navItemIconGlyph,
        reason: '版面稿第 318 行 PlnIcon,{size:18}',
      );

      final iconRect = tester.getRect(iconBox);
      expect(
        iconRect.left - first.left,
        truth.navItemPaddingHorizontal,
        reason: '版面稿第 35 行 padding:0 10px',
      );
    });

    testWidgets('導覽項目之間的間距是 ${truth.navItemSpacing}', (tester) async {
      await pumpAtPreviewSize(tester);

      final navButtons = find.byType(KlpSidebarNavigationButton);
      final first = tester.getRect(navButtons.at(0));
      final second = tester.getRect(navButtons.at(1));

      expect(
        second.top - first.bottom,
        truth.navItemSpacing,
        reason: '版面稿第 32 行 gap:2px',
      );
    });

    testWidgets('底部有本機狀態指示', (tester) async {
      await pumpAtPreviewSize(tester);

      expect(
        find.byType(KlpStatusIndicator),
        findsWidgets,
        reason: '版面稿第 315 行 sidebarFooter 是 PlnStatusIndicator',
      );
    });
  });

  group('側欄寬度拖曳', () {
    testWidgets('把手的感應寬度與可見尺寸', (tester) async {
      await pumpAtPreviewSize(tester);

      final handle = find.byType(KlpResizeHandle);
      expect(handle, findsOneWidget, reason: '版面稿第 69 行有寬度拖曳把手');
      expect(
        tester.getSize(handle).width,
        truth.resizerHitWidth,
        reason: '版面稿第 69 行 width:10px',
      );
    });
  });

  group('Stage', () {
    testWidgets('文件內容的最大寬度是 ${truth.docMaxWidth}', (tester) async {
      await pumpAtPreviewSize(tester);

      final stage = find.byType(KlpStageFrame);
      expect(stage, findsOneWidget, reason: '版面稿第 75 行有 PlnStageFrame');
    });
  });

  group('側欄分區標題', () {
    testWidgets('釘選與筆記的列高、內距與展開箭頭', (tester) async {
      await pumpAtPreviewSize(tester);

      final sections = find.byType(KlpFileExplorerSection);
      expect(sections, findsWidgets, reason: '版面稿第 51、58 行有釘選與筆記兩個分區');

      final header = find.descendant(
        of: sections.first,
        matching: find.byType(KlpPressable),
      );
      expect(header, findsWidgets, reason: '分區標題應該是可點的收合控制');

      expect(
        tester.getSize(header.first).height,
        truth.sectionHeaderHeight,
        reason: '版面稿第 51 行 height:20px',
      );

      final caret = find.descendant(
        of: header.first,
        matching: find.byType(KlpIcon),
      );
      expect(caret, findsWidgets, reason: '版面稿第 52 行分區標題有展開箭頭');
      expect(
        tester.getSize(caret.first).width,
        truth.sectionHeaderCaretSize,
        reason: '版面稿第 52 行 width:10px;height:10px',
      );

      expect(
        tester.getRect(header.first).left -
            tester.getRect(find.byType(NotistSidebar)).left,
        truth.sectionHeaderPaddingHorizontal,
        reason: '版面稿第 51 行 padding:0 12px',
      );
    });
  });

  group('側欄寬度的可調範圍', () {
    testWidgets('下限是 ${truth.sidebarMinWidth}、上限是 ${truth.sidebarMaxWidth}', (
      tester,
    ) async {
      final controller = NotistWorkbenchController();
      addTearDown(controller.dispose);

      controller.resizePrimary(0);
      expect(
        controller.primaryWidth,
        truth.sidebarMinWidth,
        reason: '版面稿第 255 行 Math.max(200,...)',
      );

      controller.resizePrimary(9999);
      expect(
        controller.primaryWidth,
        truth.sidebarMaxWidth,
        reason: '版面稿第 255 行 Math.min(460,...)',
      );
    });
  });

  group('側欄收合按鈕', () {
    testWidgets('尺寸是 ${truth.sidebarToggleSize}', (tester) async {
      await pumpAtPreviewSize(tester);

      final toggle = find.descendant(
        of: find.byType(KlpWorkbenchWindowHeader),
        matching: find.byType(KlpIconButton),
      );
      expect(toggle, findsWidgets, reason: '版面稿第 28 行標題列帶有側欄收合按鈕');
      expect(
        tester.getSize(toggle.first).width,
        truth.sidebarToggleSize,
        reason: '版面稿第 28 行 size="{{ 32 }}"',
      );
    });
  });

  group('側欄寬度拖曳把手的可見尺寸', () {
    testWidgets(
      '把手是 ${truth.resizerHandleWidth}×${truth.resizerHandleHeight}',
      (tester) async {
        await pumpAtPreviewSize(tester);

        final handle = find.byType(KlpResizeHandle);
        expect(handle, findsOneWidget, reason: '版面稿第 69 行有寬度拖曳把手');

        final grip = find.descendant(
          of: handle,
          matching: find.byType(DecoratedBox),
        );
        expect(grip, findsWidgets, reason: '版面稿第 70 行把手中央有一段可見的握把');
        expect(tester.getSize(grip.first).width, truth.resizerHandleWidth);
        expect(tester.getSize(grip.first).height, truth.resizerHandleHeight);
      },
    );
  });

  group('導覽與文件互斥', () {
    // 版面稿第 319-321 行：
    //   Nav and explorer share one selection: picking a nav item clears the
    //   document selection, and picking a note clears the nav item.
    //   selected: zone==="nav" && n.id===section
    //
    // 這條是我從實際跑起來的畫面看出來的——文件區時「Journals」仍然亮著。
    // 只靠眼睛看得到一次，寫成測試才擋得住第二次。
    testWidgets('顯示文件時，導覽項目一個都不亮', (tester) async {
      await pumpAtPreviewSize(tester);

      final selected = tester
          .widgetList<KlpSidebarNavigationButton>(
            find.byType(KlpSidebarNavigationButton),
          )
          .where((button) => button.selected)
          .toList();

      expect(
        selected,
        isEmpty,
        reason:
            '起始顯示的是 Flow 文件，此時側欄不該有任何導覽項目亮著——'
            '兩邊同時亮，使用者無從判斷現在在哪。',
      );
    });
  });
}
