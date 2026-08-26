import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import 'src/project/notist_flow_project_path.dart';
import 'src/project/notist_project_controller.dart';
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
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _workbenchController =
        widget.workbenchController ?? NotistWorkbenchController();
    _ownsWorkbenchController = widget.workbenchController == null;
    WidgetsBinding.instance.addObserver(this);
    _refreshMaximizedState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsWorkbenchController) _workbenchController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _refreshMaximizedState();
  }

  Future<void> _refreshMaximizedState() async {
    final isMaximized = await KlpWindowAction.checkIsMaximized();
    if (!mounted || isMaximized == _isMaximized) return;

    setState(() => _isMaximized = isMaximized);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _workbenchController,
      builder: (context, child) {
        return KlpApp(
          title: 'Notist',
          debugShowCheckedModeBanner: false,
          isMaximized: _isMaximized,
          windowHeader: KlpWorkbenchWindowHeader(
            titleText: 'Notist',
            appIcon: const _NotistAppIcon(),
            primaryPaneWidth: _workbenchController.primaryWidth,
            primaryVisible: _workbenchController.primaryVisible,
            onTogglePrimary: _workbenchController.togglePrimary,
            collapseLabel: '收合側邊面板',
            expandLabel: '展開側邊面板',
            actions: const [KlpShortcutHint(label: '⌘K')],
            isMaximized: _isMaximized,
          ),
          home: KlpAppScreen(
            child: widget.startupError == null
                ? NotistWorkbench(
                    flowFilePath: widget.flowFilePath,
                    flowEditorBuilder: widget.flowEditorBuilder,
                    projectDirectoryPath: widget.projectDirectoryPath,
                    projectController: widget.projectController,
                    workbenchController: _workbenchController,
                    startupFilePaths: widget.startupFilePaths,
                  )
                : const Center(
                    child: KlpErrorState(
                      title: '無法開啟本機 Flow 專案',
                      message: 'Notist 找不到可用的本機專案路徑。',
                    ),
                  ),
          ),
        );
      },
    );
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
