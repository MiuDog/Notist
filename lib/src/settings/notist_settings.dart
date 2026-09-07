/// Notist 可持久化的應用程式設定。

library;

/// 應用程式的顯示模式。
enum NotistAppearanceMode { light, dark, ultraDark, system }

/// Notist 的操作色選項。
enum NotistAccent { graphite, clay, amber, olive, blue, rose }

/// 與畫面框架無關、可寫入 JSON 的設定快照。
final class NotistSettings {
	const NotistSettings({
		this.appearanceMode = NotistAppearanceMode.light,
		this.accent = NotistAccent.graphite,
	});

	factory NotistSettings.fromJson(Map<String, Object?> json) {
		return NotistSettings(
			appearanceMode: _enumValue(
				json: json,
				key: 'appearanceMode',
				values: NotistAppearanceMode.values,
				fallback: NotistAppearanceMode.light,
			),
			accent: _enumValue(
				json: json,
				key: 'accent',
				values: NotistAccent.values,
				fallback: NotistAccent.graphite,
			),
		);
	}

	static const defaults = NotistSettings();

	final NotistAppearanceMode appearanceMode;
	final NotistAccent accent;

	NotistSettings copyWith({
		NotistAppearanceMode? appearanceMode,
		NotistAccent? accent,
	}) {
		return NotistSettings(
			appearanceMode: appearanceMode ?? this.appearanceMode,
			accent: accent ?? this.accent,
		);
	}

	Map<String, Object?> toJson() => {
		'appearanceMode': appearanceMode.name,
		'accent': accent.name,
	};
}

T _enumValue<T extends Enum>({
	required Map<String, Object?> json,
	required String key,
	required List<T> values,
	required T fallback,
}) {
	final value = json[key];
	if (value == null) return fallback;
	if (value is! String) {
		throw FormatException('Notist setting $key 必須是字串');
	}
	for (final option in values) {
		if (option.name == value) return option;
	}
	throw FormatException('Notist setting $key 不支援 $value');
}
