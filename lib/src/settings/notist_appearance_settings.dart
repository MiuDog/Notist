/// Notist 外觀設定內容。

library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../shell/notist_workbench_controller.dart';
import 'notist_settings.dart';
import 'notist_settings_visual_style.dart';

class NotistAppearanceSettings extends StatelessWidget {
	const NotistAppearanceSettings({
		super.key,
		required this.controller,
		required this.trailing,
	});

	final NotistWorkbenchController controller;
	final Widget trailing;

	@override
	Widget build(BuildContext context) {
		final settings = controller.settings;
		return KlpSettingsContentPane(
			title: '外觀',
			description: '調整顯示模式與操作色，變更會立即套用。',
			trailing: trailing,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					KlpSettingsField(
						title: '顯示模式',
						description: '選擇 Notist 的明暗外觀；跟隨系統會依 Windows 設定切換。',
						child: KlpThemeModePicker(
							options: const [
								KlpThemeModeOption(
									mode: KlpThemePreviewMode.light,
									label: '淺色',
									description: '紙張白、墨色文字',
								),
								KlpThemeModeOption(
									mode: KlpThemePreviewMode.dark,
									label: '深色',
									description: '溫暖近黑',
								),
								KlpThemeModeOption(
									mode: KlpThemePreviewMode.ultraDark,
									label: '全暗',
									description: '純黑、OLED',
								),
								KlpThemeModeOption(
									mode: KlpThemePreviewMode.system,
									label: '跟隨系統',
									description: '依作業系統切換',
								),
								KlpThemeModeOption(
									mode: KlpThemePreviewMode.transparent,
									label: '透明化',
									description: '尚未提供',
									enabled: false,
								),
							],
							selected: settings.appearanceMode.previewMode,
							onSelected: (mode) => _selectMode(context, mode),
						),
					),
					SizedBox(height: context.klp.space.comfortable),
					KlpSettingsField(
						title: '操作色',
						description: '操作色用於按鈕、焦點與互動提示，不改變內容本身的顏色。',
						child: _NotistAccentPicker(
							selected: settings.accent,
							onSelected: controller.setAccent,
						),
					),
				],
			),
		);
	}

	void _selectMode(BuildContext context, KlpThemePreviewMode preview) {
		final mode = switch (preview) {
			KlpThemePreviewMode.light => NotistAppearanceMode.light,
			KlpThemePreviewMode.dark => NotistAppearanceMode.dark,
			KlpThemePreviewMode.ultraDark => NotistAppearanceMode.ultraDark,
			KlpThemePreviewMode.system => NotistAppearanceMode.system,
			KlpThemePreviewMode.transparent => controller.settings.appearanceMode,
		};
		controller.setAppearanceMode(mode);
		KlpApp.of(context).setThemeMode(mode.themeMode);
	}
}

class _NotistAccentPicker extends StatelessWidget {
	const _NotistAccentPicker({required this.selected, required this.onSelected});

	final NotistAccent selected;
	final ValueChanged<NotistAccent> onSelected;

	@override
	Widget build(BuildContext context) {
		final klp = context.klp;
		return Wrap(
			spacing: klp.space.base,
			runSpacing: klp.space.tight,
			children: [
				for (final accent in NotistAccent.values)
					SizedBox(
						width: klp.geometry.layout.themePreviewTileWidth,
						child: KlpPressable(
							key: ValueKey('notist-accent-${accent.name}'),
							onPressed: () => onSelected(accent),
							borderRadius: BorderRadius.circular(klp.shape.control),
							child: KlpSurface(
								tone: accent == selected
										? KlpSurfaceTone.muted
										: KlpSurfaceTone.transparent,
								radius: klp.shape.control,
								padding: EdgeInsets.symmetric(
									horizontal: klp.space.tight,
									vertical: klp.space.tight,
								),
								child: Row(
									children: [
										Expanded(child: KlpText(accent.label)),
										DecoratedBox(
											decoration: BoxDecoration(
												color: accent.color,
												shape: BoxShape.circle,
												border: accent == selected
														? Border.all(
																color: context.klpColors.text,
																width: klp.shape.stroke,
															)
														: null,
											),
											child: SizedBox.square(dimension: klp.space.icon),
										),
									],
								),
							),
						),
					),
			],
		);
	}
}
