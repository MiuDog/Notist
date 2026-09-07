/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import 'src/project/notist_flow_project_path.dart';
import 'src/project/notist_project_controller.dart';
import 'src/settings/notist_settings.dart';
import 'src/settings/notist_settings_dialog.dart';
import 'src/settings/notist_settings_visual_style.dart';
import 'src/shell/notist_workbench.dart';
import 'src/shell/notist_workbench_controller.dart';
import 'src/stage/notist_project_page.dart';

void main(List<String> arguments) {
	try {
		runApp(
			NotistApp(
				projectDirectoryPath: NotistFlowProjectPath.resolve(),
				startupFilePaths: arguments,
			),
		);
	} catch (error) {
		runApp(NotistApp(startupError: error));
	}
}

/// Notist 應用程式進入點。
class NotistApp extends StatefulWidget {
	const NotistApp({
		super.key,
		this.flowFilePath = '',
		this.flowEditorBuilder,
		this.projectDirectoryPath = '',
		this.projectController,
		this.workbenchController,
		this.startupError,
		this.startupFilePaths = const [],
	});

	final String flowFilePath;
	final NotistFlowEditorBuilder? flowEditorBuilder;
	final String projectDirectoryPath;
	final NotistProjectController? projectController;
	final NotistWorkbenchController? workbenchController;
	final Object? startupError;
	final List<String> startupFilePaths;

	@override
	State<NotistApp> createState() => _NotistAppState();
}

class _NotistAppState extends State<NotistApp> with WidgetsBindingObserver {
	late final NotistWorkbenchController _workbenchController;
	late final bool _ownsWorkbenchController;
	late NotistSettings _settings;
	bool _isMaximized = false;
	bool _settingsOpen = false;

	@override
	void initState() {
		super.initState();
		_workbenchController =
				widget.workbenchController ?? NotistWorkbenchController();
		_ownsWorkbenchController = widget.workbenchController == null;
		_settings = _workbenchController.settings;
		_workbenchController.addListener(_handleWorkbenchSettingsChanged);
		WidgetsBinding.instance.addObserver(this);
		_refreshMaximizedState();
	}

	@override
	void dispose() {
		WidgetsBinding.instance.removeObserver(this);
		_workbenchController.removeListener(_handleWorkbenchSettingsChanged);
		if (_ownsWorkbenchController) _workbenchController.dispose();
		super.dispose();
	}

	@override
	void didChangeMetrics() {
		if (mounted) setState(() {});
		_refreshMaximizedState();
	}

	Future<void> _refreshMaximizedState() async {
		final isMaximized = await KlpWindowAction.checkIsMaximized();
		if (!mounted || isMaximized == _isMaximized) return;

		setState(() => _isMaximized = isMaximized);
	}

	void _handleWorkbenchSettingsChanged() {
		final next = _workbenchController.settings;
		if (identical(_settings, next) || !mounted) return;

		setState(() => _settings = next);
	}

	@override
	Widget build(BuildContext context) {
		final lightStyle = buildNotistVisualStyle(_settings, Brightness.light);
		final darkStyle = buildNotistVisualStyle(_settings, Brightness.dark);
		final viewport = MediaQueryData.fromView(View.of(context)).size;
		final centersSettings = _settingsOpen &&
			_canCenterSettings(viewport, lightStyle);
		final showsFullPageSettings = _settingsOpen && !centersSettings;
		final KlpPanelLayout workbench = widget.startupError == null
				? NotistWorkbenchScreen(
						flowFilePath: widget.flowFilePath,
						flowEditorBuilder: widget.flowEditorBuilder,
						projectDirectoryPath: widget.projectDirectoryPath,
						projectController: widget.projectController,
						workbenchController: _workbenchController,
						startupFilePaths: widget.startupFilePaths,
						onOpenSettings: _openSettings,
					)
				: const KlpPanelFrame(
						content: Center(
							child: KlpErrorState(
								title: '無法開啟本機專案',
								message: 'Notist 找不到可用的本機專案路徑。',
							),
						),
					);
		final KlpPanelLayout home = showsFullPageSettings
			? NotistSettingsPanel(
				controller: _workbenchController,
				onClose: _closeSettings,
			)
			: workbench;

		return KlpApp(
			lightStyle: lightStyle,
			darkStyle: darkStyle,
			initialThemeMode: _settings.appearanceMode.themeMode,
			title: 'Notist',
			appIcon: const _NotistAppIcon(),
			debugShowCheckedModeBanner: false,
			isMaximized: _isMaximized,
			headerActions: const [KlpShortcutHint(label: '⌘K')],
			popup: centersSettings
					? KlpPopupBackground(
							onDismiss: _closeSettings,
							child: KlpPopupPanel(
								kind: KlpPopupPanelKind.large,
								child: NotistSettingsPanel(
									controller: _workbenchController,
									onClose: _closeSettings,
								),
							),
						)
					: null,
			home: home,
		);
	}

	void _openSettings() => setState(() => _settingsOpen = true);

	void _closeSettings() => setState(() => _settingsOpen = false);

	bool _canCenterSettings(Size viewport, KlpVisualStyle style) {
		final frameInset = style.spacing.appFrameInset;
		final availableWidth = viewport.width - frameInset * 2;
		final availableHeight =
			viewport.height -
			frameInset * 2 -
			style.geometry.layout.windowHeaderHeight;
		return availableWidth >= KlpPopupPanel.largeSize.width &&
			availableHeight >= KlpPopupPanel.largeSize.height;
	}
}

class _NotistAppIcon extends StatelessWidget {
	const _NotistAppIcon();

	@override
	Widget build(BuildContext context) {
		return Image.asset(
			'design/app_icon/app_icon_master.png',
			key: const ValueKey('notist-app-icon'),
			filterQuality: FilterQuality.high,
		);
	}
}
