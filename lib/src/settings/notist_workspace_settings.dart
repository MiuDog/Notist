/// Notist 工作區設定內容。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../shell/notist_session_state.dart';
import '../shell/notist_workbench_controller.dart';

class NotistWorkspaceSettings extends StatelessWidget {
	const NotistWorkspaceSettings({
		super.key,
		required this.controller,
		required this.trailing,
	});

	final NotistWorkbenchController controller;
	final Widget trailing;

	@override
	Widget build(BuildContext context) {
		return KlpSettingsContentPane(
			title: '啟動與工作區',
			description: '決定 Notist 開啟工作區時要還原哪些狀態。',
			trailing: trailing,
			child: KlpSettingsField(
				title: '啟動行為',
				description: '設定會隨目前工作區保存。',
				child: KlpRadioGroup<NotistStartupBehavior>(
					vertical: true,
					items: const {
						NotistStartupBehavior.restoreLast: '保留上次狀態',
						NotistStartupBehavior.initial: '使用初始狀態',
					},
					descriptions: const {
						NotistStartupBehavior.restoreLast: '還原上次開啟的文件與面板配置。',
						NotistStartupBehavior.initial: '每次以預設工作區配置啟動。',
					},
					value: controller.startupBehavior,
					onChanged: controller.setStartupBehavior,
				),
			),
		);
	}
}
