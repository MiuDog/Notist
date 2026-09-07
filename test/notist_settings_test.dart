/// Notist 設定資料與互動契約。

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/settings/notist_settings.dart';
import 'package:notist/src/settings/notist_settings_dialog.dart';
import 'package:notist/src/shell/notist_workbench.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';

void main() {
	test('settings JSON round-trips appearance and accent', () {
		const settings = NotistSettings(
			appearanceMode: NotistAppearanceMode.ultraDark,
			accent: NotistAccent.blue,
		);

		expect(
			NotistSettings.fromJson(settings.toJson()).toJson(),
			settings.toJson(),
		);
	});

	test('legacy settings JSON uses stable defaults', () {
		final settings = NotistSettings.fromJson(const {});

		expect(settings.appearanceMode, NotistAppearanceMode.light);
		expect(settings.accent, NotistAccent.graphite);
	});

	test('workbench controller publishes settings changes', () {
		final controller = NotistWorkbenchController();
		addTearDown(controller.dispose);
		var notifications = 0;
		controller.addListener(() => notifications++);

		controller.setAppearanceMode(NotistAppearanceMode.dark);
		controller.setAccent(NotistAccent.rose);

		expect(controller.settings.appearanceMode, NotistAppearanceMode.dark);
		expect(controller.settings.accent, NotistAccent.rose);
		expect(notifications, 2);
	});

	testWidgets('large popup applies appearance changes to the app', (
		tester,
	) async {
		tester.view.physicalSize = const Size(1600, 1000);
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
		await tester.tap(find.byKey(const ValueKey('theme-preview-dark')));
		await tester.pumpAndSettle();

		expect(controller.settings.appearanceMode, NotistAppearanceMode.dark);
		final context = tester.element(find.byType(KlpSettingsPage));
		expect(KlpApp.of(context).themeMode, ThemeMode.dark);
		expect(tester.getSize(find.byType(KlpPopupPanel)), KlpPopupPanel.largeSize);
	});

	testWidgets('small window replaces the workbench with a full page', (
		tester,
	) async {
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

		expect(find.byType(KlpPopupBackground), findsNothing);
		expect(find.byType(KlpPopupPanel), findsNothing);
		expect(find.byType(NotistSettingsPanel), findsOneWidget);
		expect(find.byType(NotistWorkbenchScreen), findsNothing);
		final page = tester.getSize(find.byType(KlpSettingsPage));
		final context = tester.element(find.byType(KlpSettingsPage));
		final klp = context.klp;
		expect(page.width, 900 - klp.space.appFrameInset * 2);
		expect(
			page.height,
			700 -
				klp.space.appFrameInset * 2 -
				klp.geometry.layout.windowHeaderHeight,
		);
	});
}
