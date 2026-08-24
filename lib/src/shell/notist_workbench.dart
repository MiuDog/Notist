import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_project_controller.dart';
import '../markdown/notist_markdown_file_intent.dart';
import '../sidebar/notist_sidebar.dart';
import '../stage/notist_project_page.dart';
import '../stage/notist_stage.dart';
import 'notist_workbench_controller.dart';

/// Notist 絕對 golden 的兩欄工作台。
class NotistWorkbench extends StatefulWidget {
  const NotistWorkbench({
    super.key,
    this.flowFilePath = '',
    this.flowEditorBuilder,
    this.projectDirectoryPath = '',
    this.projectController,
    this.workbenchController,
    this.markdownFileIntent,
    this.startupFilePaths = const [],
  });

  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final String projectDirectoryPath;
  final NotistProjectController? projectController;
  final NotistWorkbenchController? workbenchController;
  final NotistMarkdownFileIntent? markdownFileIntent;
  final List<String> startupFilePaths;

  @override
  State<NotistWorkbench> createState() => _NotistWorkbenchState();
}

class _NotistWorkbenchState extends State<NotistWorkbench> {
  late final NotistWorkbenchController _workbenchController;
  late final bool _ownsWorkbenchController;
  NotistProjectController? _projectController;
  var _ownsProjectController = false;
  late final NotistMarkdownFileIntent _markdownFileIntent;
  late final bool _ownsMarkdownFileIntent;

  @override
  void initState() {
    super.initState();
    _workbenchController =
        widget.workbenchController ?? NotistWorkbenchController();
    _ownsWorkbenchController = widget.workbenchController == null;
    _markdownFileIntent =
        widget.markdownFileIntent ?? NotistMarkdownFileIntent();
    _ownsMarkdownFileIntent = widget.markdownFileIntent == null;
    _projectController = widget.projectController;
    if (_projectController == null && widget.projectDirectoryPath.isNotEmpty) {
      _projectController = NotistProjectController.local(
        directoryPath: widget.projectDirectoryPath,
      );
      _ownsProjectController = true;
    }
    _markdownFileIntent.listen(_importMarkdownPaths);
    _projectController?.load().then(
      (_) => _importMarkdownPaths(widget.startupFilePaths),
    );
  }

  @override
  void dispose() {
    if (_ownsProjectController) _projectController?.dispose();
    if (_ownsMarkdownFileIntent) _markdownFileIntent.dispose();
    if (_ownsWorkbenchController) _workbenchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectController = _projectController;
    final listenables = <Listenable>[_workbenchController, ?projectController];

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, child) => _buildShell(projectController),
    );
  }

  Widget _buildShell(NotistProjectController? projectController) {
    return KlpWorkbenchShell(
      primaryVisible: _workbenchController.primaryVisible,
      primaryWidth: _workbenchController.primaryWidth,
      onPrimaryWidthChanged: _workbenchController.resizePrimary,
      primary: NotistSidebar(
        projectController: projectController,
        zone: _workbenchController.zone,
        selectedDestination: _workbenchController.destination,
        onDestinationSelected: _workbenchController.selectDestination,
      ),
      stage: NotistStage(
        zone: _workbenchController.zone,
        destination: _workbenchController.destination,
        flowFilePath: widget.flowFilePath,
        flowEditorBuilder: widget.flowEditorBuilder,
        projectController: projectController,
        onImportMarkdownFile: _pickMarkdownFile,
      ),
      secondaryVisible: false,
      secondary: const SizedBox.shrink(),
    );
  }

  Future<void> _pickMarkdownFile() async {
    final path = await _markdownFileIntent.pick();
    if (path != null) await _importMarkdownPaths([path]);
  }

  Future<void> _importMarkdownPaths(List<String> paths) async {
    final project = _projectController;
    if (project == null) return;
    await project.load();
    for (final path in paths) {
      await project.importMarkdownFile(path);
    }
  }
}
