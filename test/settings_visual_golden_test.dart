/// Notist 設定頁的桌面視覺回歸測試。

library;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';

import 'support/load_kallopis_fonts.dart';

void main() {
	setUpAll(loadKallopisFonts);

	testWidgets('settings page matches the approved desktop composition', (
		tester,
	) async {
		tester.view.physicalSize = const Size(1920, 1032);
		tester.view.devicePixelRatio = 1;
		addTearDown(tester.view.resetPhysicalSize);
		addTearDown(tester.view.resetDevicePixelRatio);

		final controller = NotistWorkbenchController();
		addTearDown(controller.dispose);
		await tester.pumpWidget(NotistApp(workbenchController: controller));
		await tester.pumpAndSettle();

		await tester.tap(
			find.descendant(
				of: find.byType(KlpNavigationRail),
				matching: find.bySemanticsLabel('設定'),
			),
		);
		await tester.pumpAndSettle();
		await tester.sendEventToBinding(
			const PointerHoverEvent(position: Offset(1400, 900)),
		);
		await tester.pumpAndSettle();

		await expectLater(
			find.byType(NotistApp),
			matchesGoldenFile('goldens/notist_settings_appearance.png'),
		);
	});

	testWidgets('settings page fills a compact desktop window', (tester) async {
		tester.view.physicalSize = const Size(900, 700);
		tester.view.devicePixelRatio = 1;
		addTearDown(tester.view.resetPhysicalSize);
		addTearDown(tester.view.resetDevicePixelRatio);

		final controller = NotistWorkbenchController();
		addTearDown(controller.dispose);
		await tester.pumpWidget(NotistApp(workbenchController: controller));
		await tester.pumpAndSettle();
		await tester.tap(
			find.descendant(
				of: find.byType(KlpNavigationRail),
				matching: find.bySemanticsLabel('設定'),
			),
		);
		await tester.pumpAndSettle();
		await tester.sendEventToBinding(
			const PointerHoverEvent(position: Offset(880, 680)),
		);
		await tester.pumpAndSettle();

		await expectLater(
			find.byType(NotistApp),
			matchesGoldenFile('goldens/notist_settings_full_page.png'),
		);
	});
}
