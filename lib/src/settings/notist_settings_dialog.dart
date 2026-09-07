/// Notist 設定對話框的產品組裝入口。

library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../shell/notist_workbench_controller.dart';
import 'notist_appearance_settings.dart';
import 'notist_settings_navigation.dart';
import 'notist_workspace_settings.dart';

/// 由 Notist 持有導覽與設定狀態，Kallopis 只負責通用設定版面。
class NotistSettingsPanel extends StatefulWidget implements KlpPanelLayout {
	const NotistSettingsPanel({
		super.key,
		required this.controller,
		required this.onClose,
		this.initialSection = NotistSettingsSection.appearance,
	});

	final NotistWorkbenchController controller;
	final VoidCallback onClose;
	final NotistSettingsSection initialSection;

	@override
	State<NotistSettingsPanel> createState() => _NotistSettingsPanelState();

	@override
	Widget buildPanelLayout(BuildContext context) => this;
}

class _NotistSettingsPanelState extends State<NotistSettingsPanel> {
	late NotistSettingsSection _section = widget.initialSection;
	var _query = '';

	@override
	Widget build(BuildContext context) {
		return KlpSettingsPage(
			navigation: NotistSettingsNavigation(
				selected: _section,
				query: _query,
				onQueryChanged: (value) => setState(() => _query = value),
				onSelected: (value) => setState(() => _section = value),
			),
			content: AnimatedBuilder(
				animation: widget.controller,
				builder: (context, child) => _buildContent(context),
			),
		);
	}

	Widget _buildContent(BuildContext context) {
		final close = KlpIconButton(
			icon: KlpIcons.x,
			label: '關閉設定',
			tone: KlpIconButtonTone.inline,
			onPressed: widget.onClose,
		);
		return switch (_section) {
			NotistSettingsSection.appearance => NotistAppearanceSettings(
				controller: widget.controller,
				trailing: close,
			),
			NotistSettingsSection.workspace => NotistWorkspaceSettings(
				controller: widget.controller,
				trailing: close,
			),
			NotistSettingsSection.shortcuts => _informationPane(
				title: '鍵盤快捷鍵',
				description: '檢視 Notist 目前提供的工作區快捷操作。',
				body: '⌘K　開啟快速搜尋',
				trailing: close,
			),
			NotistSettingsSection.about => _informationPane(
				title: '關於 Notist',
				description: 'Windows 優先的個人與團隊知識工作區。',
				body: 'Notist 0.1.0 Beta',
				trailing: close,
			),
		};
	}

	Widget _informationPane({
		required String title,
		required String description,
		required String body,
		required Widget trailing,
	}) {
		return KlpSettingsContentPane(
			title: title,
			description: description,
			trailing: trailing,
			child: KlpSettingsField(title: '資訊', child: KlpText(body)),
		);
	}
}
