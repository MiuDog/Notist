/// Notist 設定分類導覽。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

enum NotistSettingsSection { appearance, workspace, shortcuts, about }

class NotistSettingsNavigation extends StatelessWidget {
	const NotistSettingsNavigation({
		super.key,
		required this.selected,
		required this.query,
		required this.onQueryChanged,
		required this.onSelected,
	});

	final NotistSettingsSection selected;
	final String query;
	final ValueChanged<String> onQueryChanged;
	final ValueChanged<NotistSettingsSection> onSelected;

	@override
	Widget build(BuildContext context) {
		final appScope = selected != NotistSettingsSection.workspace;
		return KlpSettingsNavigationPane(
			header: KlpSettingsNavigationHeader(
				scopeSwitcher: KlpSettingsScopeSwitcher(
					options: const [
						KlpSettingsScopeOption(label: '工作區', icon: KlpIcons.folder),
						KlpSettingsScopeOption(label: '應用程式', icon: KlpIcons.settings),
					],
					selectedIndex: appScope ? 1 : 0,
					onSelected: (index) => onSelected(
						index == 0
								? NotistSettingsSection.workspace
								: NotistSettingsSection.appearance,
					),
				),
				search: KlpSettingsSearchField(
					placeholder: '搜尋設定',
					onChanged: onQueryChanged,
				),
			),
			children: [
				if (_matches('體驗 外觀 主題 操作色'))
					KlpSettingsNavigationGroup(
						label: '體驗',
						children: [
							KlpSettingsNavigationItem(
								title: '外觀',
								icon: KlpIcons.grid,
								selected: selected == NotistSettingsSection.appearance,
								onPressed: () => onSelected(NotistSettingsSection.appearance),
								children: const [KlpText('顯示模式'), KlpText('操作色')],
							),
						],
					),
				if (_matches('工作區 啟動 行為'))
					KlpSettingsNavigationGroup(
						label: '工作區',
						children: [
							KlpSettingsNavigationItem(
								title: '啟動與工作區',
								icon: KlpIcons.folder,
								selected: selected == NotistSettingsSection.workspace,
								onPressed: () => onSelected(NotistSettingsSection.workspace),
							),
						],
					),
				if (_matches('系統 鍵盤 快捷鍵 關於'))
					KlpSettingsNavigationGroup(
						label: '系統',
						children: [
							KlpSettingsNavigationItem(
								title: '鍵盤快捷鍵',
								icon: KlpIcons.keyboard,
								selected: selected == NotistSettingsSection.shortcuts,
								onPressed: () => onSelected(NotistSettingsSection.shortcuts),
							),
							KlpSettingsNavigationItem(
								title: '關於 Notist',
								icon: KlpIcons.infoSquare,
								selected: selected == NotistSettingsSection.about,
								onPressed: () => onSelected(NotistSettingsSection.about),
							),
						],
					),
			],
		);
	}

	bool _matches(String terms) {
		final normalized = query.trim().toLowerCase();
		return normalized.isEmpty || terms.toLowerCase().contains(normalized);
	}
}
