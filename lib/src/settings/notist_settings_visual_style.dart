/// Notist 設定與 Kallopis 視覺風格的接合層。

library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import 'notist_settings.dart';

extension NotistAppearanceModeVisuals on NotistAppearanceMode {
	ThemeMode get themeMode => switch (this) {
		NotistAppearanceMode.light => ThemeMode.light,
		NotistAppearanceMode.dark => ThemeMode.dark,
		NotistAppearanceMode.ultraDark => ThemeMode.dark,
		NotistAppearanceMode.system => ThemeMode.system,
	};

	KlpThemePreviewMode get previewMode => switch (this) {
		NotistAppearanceMode.light => KlpThemePreviewMode.light,
		NotistAppearanceMode.dark => KlpThemePreviewMode.dark,
		NotistAppearanceMode.ultraDark => KlpThemePreviewMode.ultraDark,
		NotistAppearanceMode.system => KlpThemePreviewMode.system,
	};
}

extension NotistAccentVisuals on NotistAccent {
	String get label => switch (this) {
		NotistAccent.graphite => '石墨',
		NotistAccent.clay => '陶土',
		NotistAccent.amber => '琥珀',
		NotistAccent.olive => '橄欖',
		NotistAccent.blue => '深藍',
		NotistAccent.rose => '緋紅',
	};

	Color get color => switch (this) {
		NotistAccent.graphite => KlpPalette.ink800,
		NotistAccent.clay => KlpPalette.clay300,
		NotistAccent.amber => KlpPalette.ochre500,
		NotistAccent.olive => KlpPalette.green600,
		NotistAccent.blue => KlpPalette.blue500,
		NotistAccent.rose => KlpPalette.red400,
	};
}

KlpVisualStyle buildNotistVisualStyle(
	NotistSettings settings,
	Brightness brightness,
) {
	final base = KlpVisualStyle.defaultStyle;
	final colors = switch ((settings.appearanceMode, brightness)) {
		(NotistAppearanceMode.ultraDark, Brightness.dark) => KlpThemeData.ultraDark,
		(_, Brightness.dark) => KlpThemeData.dark,
		_ => KlpThemeData.light,
	};
	final accent = settings.accent.color;
	return base.copyWith(
		name: 'notist-${settings.appearanceMode.name}-${settings.accent.name}',
		colors: colors.copyWith(
			brand: accent,
			accent: accent,
			accentSoft: accent.withValues(alpha: KlpScale.opacity180),
			interaction: accent,
			interactionSoft: accent.withValues(alpha: KlpScale.opacity140),
		),
		geometry: base.geometry.copyWith(
			layout: base.geometry.layout.copyWith(
				resizeHandleExtent: KlpScale.space100,
			),
		),
	);
}
