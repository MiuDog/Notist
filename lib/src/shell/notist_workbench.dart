import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_project_controller.dart';
import '../markdown/notist_markdown_file_intent.dart';
import '../sidebar/notist_sidebar.dart';
import '../stage/notist_project_page.dart';
import '../stage/notist_stage.dart';
import 'notist_workbench_controller.dart';
import 'notist_session_state.dart';

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
    this.sessionStore,
  });

  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final String projectDirectoryPath;
  final NotistProjectController? projectController;
  final NotistWorkbenchController? workbenchController;
  final NotistMarkdownFileIntent? markdownFileIntent;
  final List<String> startupFilePaths;
  final NotistSessionStore? sessionStore;

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
  NotistSessionStore? _sessionStore;
  var _restoringSession = true;
  Future<void>? _saveSessionOperation;

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
    _sessionStore =
        widget.sessionStore ??
        (widget.projectDirectoryPath.isEmpty
            ? null
            : NotistLocalSessionStore(widget.projectDirectoryPath));
    _workbenchController.addListener(_persistSession);
    _projectController?.addListener(_persistSession);
    _markdownFileIntent.listen(_importMarkdownPaths);
    _restoreSession();
  }

  @override
  void dispose() {
    _workbenchController.removeListener(_persistSession);
    _projectController?.removeListener(_persistSession);
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
        onDocumentSelected: (_) => _workbenchController.showDocument(),
      ),
      stage: NotistStage(
        zone: _workbenchController.zone,
        destination: _workbenchController.destination,
        flowFilePath: widget.flowFilePath,
        flowEditorBuilder: widget.flowEditorBuilder,
        projectController: projectController,
        onImportMarkdownFile: _pickMarkdownFile,
        startupBehavior: _workbenchController.startupBehavior,
        onStartupBehaviorChanged: _workbenchController.setStartupBehavior,
        onDocumentOpen: _openDocument,
      ),
      secondaryVisible: false,
      secondary: const SizedBox.shrink(),
    );
  }

  Future<void> _pickMarkdownFile() async {
    final path = await _markdownFileIntent.pick();
    if (path != null) await _importMarkdownPaths([path]);
  }

  void _openDocument(String rootId) {
    _projectController?.select(rootId);
    _workbenchController.showDocument();
  }

  Future<void> _importMarkdownPaths(List<String> paths) async {
    final project = _projectController;
    if (project == null) return;
    await project.load();
    for (final path in paths) {
      await project.importMarkdownFile(path);
    }
  }

  Future<void> _restoreSession() async {
    final project = _projectController;
    if (project != null) await project.load();
    final session = await _sessionStore?.load();
    if (!mounted) return;
    if (session != null) {
      _workbenchController.restore(session);
      final rootId = session.selectedRootId;
      if (session.startupBehavior == NotistStartupBehavior.restoreLast &&
          rootId != null &&
          project != null &&
          project.documents.any((document) => document.rootId == rootId)) {
        project.select(rootId);
      }
    }
    _restoringSession = false;
    await _importMarkdownPaths(widget.startupFilePaths);
  }

  void _persistSession() {
    final store = _sessionStore;
    if (_restoringSession || store == null) return;
    final snapshot = NotistSessionState(
      startupBehavior: _workbenchController.startupBehavior,
      primaryVisible: _workbenchController.primaryVisible,
      primaryWidth: _workbenchController.primaryWidth,
      zone: _workbenchController.zone,
      destination: _workbenchController.destination,
      selectedRootId: _projectController?.selectedRootId,
    );
    final prior = _saveSessionOperation;
    late final Future<void> operation;
    operation =
        (() async {
          if (prior != null) await prior;
          await store.save(snapshot);
        })().whenComplete(() {
          if (identical(_saveSessionOperation, operation)) {
            _saveSessionOperation = null;
          }
        });
    _saveSessionOperation = operation;
  }
}
