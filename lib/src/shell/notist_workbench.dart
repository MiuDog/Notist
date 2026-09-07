import 'dart:async';

/// Notist 專案模組。

import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import '../markdown/notist_markdown_file_intent.dart';
import '../project/notist_project_controller.dart';
import '../project/notist_workspace_project_store.dart';
import '../settings/notist_settings_visual_style.dart';
import '../stage/notist_project_page.dart';
import 'notist_session_state.dart';
import 'notist_workbench_controller.dart';
import 'workbench/view/notist_workbench_actions_record.dart';
import 'workbench/view/notist_workbench_view.dart';
import 'workbench/view/notist_workbench_view_record.dart';

/// Notist 絕對 golden 的兩欄工作台。
class NotistWorkbenchScreen extends StatefulWidget implements KlpPanelLayout {
  const NotistWorkbenchScreen({
    super.key,
    this.flowFilePath = '',
    this.flowEditorBuilder,
    this.projectDirectoryPath = '',
    this.projectController,
    this.workbenchController,
    this.markdownFileIntent,
    this.startupFilePaths = const [],
    this.sessionStore,
    this.onOpenSettings,
  });

  final String flowFilePath;
  final NotistFlowEditorBuilder? flowEditorBuilder;
  final String projectDirectoryPath;
  final NotistProjectController? projectController;
  final NotistWorkbenchController? workbenchController;
  final NotistMarkdownFileIntent? markdownFileIntent;
  final List<String> startupFilePaths;
  final NotistSessionStore? sessionStore;
  final VoidCallback? onOpenSettings;

  @override
  State<NotistWorkbenchScreen> createState() => _NotistWorkbenchState();

  @override
  Widget buildPanelLayout(BuildContext context) => this;
}

class _NotistWorkbenchState extends State<NotistWorkbenchScreen> {
  late final NotistWorkbenchController _workbenchController;
  late final bool _ownsWorkbenchController;
  final ScrollController _navigationScrollController = ScrollController();

  NotistProjectController? _projectController;
  var _ownsProjectController = false;
  late final NotistMarkdownFileIntent _markdownFileIntent;
  late final bool _ownsMarkdownFileIntent;
  NotistWorkspaceProjectStore? _workspaceProjectStore;
  List<NotistWorkspaceProjectEntry> _workspaceProjects = const [];
  NotistWorkspaceProjectEntry? _activeWorkspaceProject;

  NotistSessionStore? _sessionStore;
  var _restoringSession = true;
  Future<void>? _saveSessionOperation;

  @override
  void initState() {
    super.initState();

    // 步驟 1：建立本畫面擁有的 controller 與 intent 實體。
    _workbenchController =
        widget.workbenchController ?? NotistWorkbenchController();
    _ownsWorkbenchController = widget.workbenchController == null;
    _markdownFileIntent =
        widget.markdownFileIntent ?? NotistMarkdownFileIntent();
    _ownsMarkdownFileIntent = widget.markdownFileIntent == null;

    // 步驟 2：載入專案 controller 與 session store，避免空值邏輯在後續使用時重複判斷。
    _projectController = widget.projectController;
    if (_projectController == null && widget.projectDirectoryPath.isNotEmpty) {
      _workspaceProjectStore = NotistLocalWorkspaceProjectStore(
        widget.projectDirectoryPath,
      );
      _projectController = NotistProjectController.local(
        directoryPath: widget.projectDirectoryPath,
      );
      _ownsProjectController = true;
      _activeWorkspaceProject = NotistWorkspaceProjectEntry(
        name: '根目錄專案',
        path: widget.projectDirectoryPath,
        isRoot: true,
      );
    }

    _sessionStore =
        widget.sessionStore ??
        (widget.projectDirectoryPath.isEmpty
            ? null
            : NotistLocalSessionStore(widget.projectDirectoryPath));

    unawaited(_initializeWorkspaceProjects());

    // 步驟 3：綁定持久化與匯入 flow 的監聽回路後回填 session。
    _workbenchController.addListener(_persistSession);
    _projectController?.addListener(_persistSession);
    _markdownFileIntent.listen(_importMarkdownPaths);
    // 由 _initializeWorkspaceProjects 觸發的 _restoreSession 直接接在專案資料回填後執行，
    // 保持根目錄專案與已切換專案都走同一份 session 還原流程。
  }

  @override
  void dispose() {
    _workbenchController.removeListener(_persistSession);
    _projectController?.removeListener(_persistSession);
    if (_ownsProjectController) _projectController?.dispose();
    if (_ownsMarkdownFileIntent) _markdownFileIntent.dispose();
    if (_ownsWorkbenchController) _workbenchController.dispose();
    _navigationScrollController.dispose();
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
    final state = _workbenchController.state;
    final activeProjectName = _activeWorkspaceProject?.name ?? '專案';
    final activeProjectPath =
        _activeWorkspaceProject?.path ?? widget.projectDirectoryPath;

    return NotistWorkbenchView(
      record: NotistWorkbenchViewRecord(
        state: state,
        activeProjectName: activeProjectName,
        activeProjectPath: activeProjectPath,
        projectController: projectController,
        flowFilePath: widget.flowFilePath,
        flowEditorBuilder: widget.flowEditorBuilder,
        navigationScrollController: _navigationScrollController,
        canManageProjects:
            _workspaceProjectStore != null && widget.projectController == null,
      ),
      actions: NotistWorkbenchActionsRecord(
        onCreateFlow: () => projectController?.createFlow(),
        onImportMarkdown: _pickMarkdownFile,
        onCreateFolder: () => _createFlowFolder(context),
        onDeleteFolder: () => _deleteCurrentFolder(context),
        onOpenProjectManager: _openWorkspaceProjectManager,
        onShowNotes: _workbenchController.showNotesSidebar,
        onShowAssistant: _workbenchController.showAssistantSidebar,
        onShowDocument: _workbenchController.showDocument,
        onOpenDocument: _openDocument,
        onOpenSettings: widget.onOpenSettings ?? () {},
        onLayoutChanged: _workbenchController.setDockLayout,
        onStartupBehaviorChanged: _workbenchController.setStartupBehavior,
      ),
    );
  }

  Future<void> _pickMarkdownFile() async {
    final path = await _markdownFileIntent.pick();
    if (path != null) await _importMarkdownPaths([path]);
  }

  Future<void> _createFlowFolder(BuildContext context) async {
    final project = _projectController;
    if (project == null) return;
    final folderNameController = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增資料夾'),
          content: SizedBox(
            width: 360,
            child: TextField(
              controller: folderNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '資料夾名稱'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(folderNameController.text.trim()),
              child: const Text('建立'),
            ),
          ],
        );
      },
    );
    if (folderName == null || folderName.isEmpty) return;
    await project.createFolder(folderName);
  }

  Future<void> _deleteCurrentFolder(BuildContext context) async {
    final project = _projectController;
    if (project == null) return;
    final folderPath = project.selectedFolderPath;
    if (folderPath == null) return;

    final canDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('刪除資料夾'),
          content: Text('確定要刪除「$folderPath」嗎？刪除後無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
    if (canDelete != true) return;

    await project.deleteFolder(folderPath);
  }

  void _openDocument(String rootId) {
    _projectController?.select(rootId);
    _workbenchController.showDocument();
  }

  // 步驟 1：逐一匯入啟動參數中的 Markdown 路徑，維持順序。
  Future<void> _importMarkdownPaths(List<String> paths) async {
    final project = _projectController;
    if (project == null) return;

    await project.load();
    for (final path in paths) {
      await project.importMarkdownFile(path);
    }
  }

  // 步驟 1：先還原上次 session；步驟 2：再套用啟動後匯入任務。
  Future<void> _restoreSession() async {
    final project = _projectController;
    if (project != null) await project.load();
    final session = await _sessionStore?.load();
    if (!mounted) return;
    if (session != null) {
      _workbenchController.restore(session);
      KlpApp.of(
        context,
      ).setThemeMode(_workbenchController.settings.appearanceMode.themeMode);
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

  Future<void> _refreshWorkspaceProjects() async {
    final store = _workspaceProjectStore;
    if (store == null) return;

    final entries = await store.listProjects();
    if (!mounted) return;

    entries.sort((left, right) {
      if (left.isRoot) return -1;
      if (right.isRoot) return 1;
      return left.name.compareTo(right.name);
    });

    NotistWorkspaceProjectEntry selected = entries.first;
    if (_activeWorkspaceProject != null) {
      for (final entry in entries) {
        if (entry.path == _activeWorkspaceProject!.path) {
          selected = entry;
          break;
        }
      }
    }

    setState(() {
      _workspaceProjects = entries;
      _activeWorkspaceProject = selected;
    });
  }

  Future<void> _selectWorkspaceProject(
    NotistWorkspaceProjectEntry entry,
  ) async {
    if (_activeWorkspaceProject?.path == entry.path) {
      return;
    }
    if (_workspaceProjectStore == null || widget.projectController != null) {
      return;
    }
    final projectController = _projectController;
    if (projectController == null) return;

    setState(() {
      _restoringSession = true;
      _projectController?.removeListener(_persistSession);
    });

    if (_ownsProjectController) {
      projectController.dispose();
    } else {
      projectController.removeListener(_persistSession);
    }
    _projectController = NotistProjectController.local(
      directoryPath: entry.path,
    );
    _ownsProjectController = true;
    await _workspaceProjectStore?.saveActiveProjectPath(entry.path);
    _projectController?.addListener(_persistSession);
    _activeWorkspaceProject = entry;
    _sessionStore = NotistLocalSessionStore(entry.path);
    if (mounted) setState(() {});

    await _projectController!.load();
    _restoringSession = true;
    await _restoreSession();
  }

  Future<void> _createWorkspaceProject(String name) async {
    final store = _workspaceProjectStore;
    if (store == null) return;

    final created = await store.createProject(name);
    await store.saveActiveProjectPath(created.path);
    await _refreshWorkspaceProjects();
    await _selectWorkspaceProject(created);
  }

  Future<void> _deleteWorkspaceProject(
    NotistWorkspaceProjectEntry entry,
  ) async {
    final store = _workspaceProjectStore;
    if (store == null || entry.isRoot) return;

    await store.deleteProject(entry.name);
    final wasActive = entry.path == _activeWorkspaceProject?.path;
    await _refreshWorkspaceProjects();
    if (wasActive && _workspaceProjects.isNotEmpty) {
      await _selectWorkspaceProject(_workspaceProjects.first);
    }
  }

  Future<void> _initializeWorkspaceProjects() async {
    if (_workspaceProjectStore == null || widget.projectController != null) {
      await _restoreSession();
      return;
    }

    final store = _workspaceProjectStore!;
    final activePath = await store.loadActiveProjectPath();
    await _refreshWorkspaceProjects();

    if (activePath != null &&
        activePath.isNotEmpty &&
        activePath != (_activeWorkspaceProject?.path ?? '')) {
      final target = _workspaceProjects.firstWhere(
        (project) => project.path == activePath,
        orElse: () => _workspaceProjects.first,
      );
      if (target.path != _activeWorkspaceProject?.path) {
        await _selectWorkspaceProject(target);
        return;
      }
    }

    _restoringSession = false;
    await _restoreSession();
  }

  Future<void> _openWorkspaceProjectManager() async {
    await _refreshWorkspaceProjects();
    final createController = TextEditingController();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('專案管理'),
              content: SizedBox(
                width: 560,
                height: 420,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workspaceProjects.length,
                        itemBuilder: (context, index) {
                          final project = _workspaceProjects[index];
                          final isActive =
                              _activeWorkspaceProject?.path == project.path;
                          return ListTile(
                            dense: true,
                            title: Text(project.name),
                            subtitle: Text(
                              project.isRoot ? '預設根目錄專案' : project.path,
                            ),
                            leading: isActive
                                ? KlpIcon(
                                    KlpIcons.check,
                                    color: context.klpColors.success,
                                  )
                                : const KlpIcon(KlpIcons.circle),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isActive)
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _selectWorkspaceProject(project);
                                    },
                                    child: const Text('進入'),
                                  ),
                                if (!project.isRoot)
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _deleteWorkspaceProject(project);
                                    },
                                    child: const Text('刪除'),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: createController,
                            decoration: const InputDecoration(
                              labelText: '新專案名稱',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _createWorkspaceProject(
                              createController.text,
                            );
                            createController.clear();
                            await _refreshWorkspaceProjects();
                            setDialogState(() {});
                          },
                          child: const Text('建立'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('關閉'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _persistSession() {
    final store = _sessionStore;
    if (_restoringSession || store == null) return;

    // 只寫入目前 UI 狀態的快照，交由後續非同步保存流程排隊執行。
    final snapshot = NotistSessionState(
      startupBehavior: _workbenchController.startupBehavior,
      primaryVisible: _workbenchController.primaryVisible,
      primaryWidth: _workbenchController.primaryWidth,
      zone: _workbenchController.zone,
      destination: _workbenchController.destination,
      sidebarMode: _workbenchController.sidebarMode,
      selectedRootId: _projectController?.selectedRootId,
      dockLayout: _workbenchController.dockLayout,
      settings: _workbenchController.settings,
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

/// 舊名稱的相容別名。
typedef NotistWorkbench = NotistWorkbenchScreen;
