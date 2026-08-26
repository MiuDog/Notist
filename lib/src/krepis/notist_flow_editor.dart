import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'krepis_block.dart';
import 'krepis_display.dart';
import 'krepis_editing.dart';
import 'krepis_editor_controller.dart';
import 'krepis_ink.dart';
import 'notist_block_command.dart';
import 'notist_block_command_actions.dart';
import 'notist_block_command_registry.dart';
import 'notist_flow_block_chrome.dart';
import 'notist_flow_slash_menu.dart';
import 'notist_flow_selection.dart';
import 'notist_local_save_projection.dart';
import 'notist_ink_preview.dart';
import 'text_edit_diff.dart';

class NotistFlowEditor extends StatefulWidget {
  const NotistFlowEditor({
    super.key,
    required this.filePath,
    this.opener,
    this.saveProjection,
    this.onProjectionChanged,
    this.inkEnabled = false,
    this.onStylusDetected,
  });

  final String filePath;
  final KrepisEditorOpener? opener;
  final NotistLocalSaveController? saveProjection;
  final ValueChanged<KrepisEditorSnapshot>? onProjectionChanged;
  final bool inkEnabled;
  final VoidCallback? onStylusDetected;

  @override
  State<NotistFlowEditor> createState() => _NotistFlowEditorState();
}

class _NotistFlowEditorState extends State<NotistFlowEditor>
    with TextInputClient {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Notist Flow editor');
  final GlobalKey _flowSurfaceKey = GlobalKey(
    debugLabel: 'Notist Flow surface',
  );
  KrepisEditorAuthority? _controller;
  TextInputConnection? _connection;
  TextEditingValue _value = TextEditingValue.empty;
  Object? _loadError;
  late final NotistLocalSaveController _saveProjection;
  late final bool _ownsSaveProjection;
  var _openGeneration = 0;
  var _opening = true;
  bool _compositionActive = false;
  int? _paragraphBreakRevisionAwaitingAction;
  bool _slashMenuOpen = false;
  String? _draggedBlockId;
  String? _dropTargetBlockId;
  KrepisBlockTargetAffinity? _dropTargetAffinity;
  Offset? _dragPointer;
  Size _viewportSize = Size.zero;
  double _scrollY = 0;
  KrepisInkCaptureProjection? _inkCapture;
  KrepisFlowBlockProjection? _inkOwner;
  Rect? _inkOwnerRect;
  int? _inkStartedAtMs;
  final List<KrepisInkRawSampleProjection> _inkSamples = [];
  final List<KrepisInkPreviewSampleProjection> _inkPreviewSamples = [];
  KrepisInkOutline _inkOutline = const [];

  /// 預覽外框改為「每幀最多重建一次」。
  ///
  /// 先前每個 pointer move 都以**累積的全部取樣點**重建整條外框：編碼 n 點、
  /// 跨 FFI 解碼 n 點、建外框、配置頂點緩衝、複製回 Dart，再 setState 重繪。
  /// 觸控筆取樣可達 120Hz 且單幀可能送出多個事件，總成本是 O(事件數 × n)——
  /// 畫長筆畫時每秒數百萬次運算加上大量配置／釋放，會嚴重卡頓甚至耗盡資源。
  ///
  /// 合併到每幀一次後成本降為 O(幀數 × n)。**取樣點本身一個都不丟**，
  /// 只有預覽的重建頻率被限制在畫面更新率——超過的部分本來也畫不出來。
  bool _inkOutlineDirty = false;

  static const _inkBrush = KrepisInkBrushProjection(
    widthMode: KrepisInkWidthMode.pressure,
    baseWidth: 2,
    pressureCurve: [0.35, 0.55, 0.75, 0.9, 1],
    smoothing: 0.35,
  );

  @override
  void initState() {
    super.initState();
    _ownsSaveProjection = widget.saveProjection == null;
    _saveProjection = widget.saveProjection ?? NotistLocalSaveController();
    _focusNode.addListener(_handleFocus);
    _open();
  }

  Future<void> _open() async {
    final generation = ++_openGeneration;
    setState(() {
      _opening = true;
      _loadError = null;
    });

    try {
      final request = KrepisEditorOpenRequest(filePath: widget.filePath);
      final opener =
          widget.opener ??
          (request) => KrepisEditorController.open(
            request,
            saveProjection: _saveProjection,
          );

      final controller = await opener(request);
      if (!mounted || generation != _openGeneration) {
        controller.dispose();
        return;
      }
      controller.addListener(_handleAuthorityChange);
      setState(() {
        _controller = controller;
        _opening = false;
        _syncFromAuthority();
      });
      final snapshot = controller.snapshot;
      if (snapshot != null) widget.onProjectionChanged?.call(snapshot);
    } catch (error) {
      if (kDebugMode) debugPrint('Notist 無法啟動 Krepis editor：$error');
      if (!mounted || generation != _openGeneration) return;

      setState(() {
        _opening = false;
        _loadError = error;
      });
    }
  }

  void _handleAuthorityChange() {
    if (!mounted) return;
    setState(_syncFromAuthority);
    final snapshot = _controller?.snapshot;
    if (snapshot != null) widget.onProjectionChanged?.call(snapshot);
  }

  void _handleFocus() {
    if (kDebugMode) {
      debugPrint('Notist Flow focus=${_focusNode.hasFocus}');
    }
    if (_focusNode.hasFocus && _controller != null) {
      _connection ??= TextInput.attach(
        this,
        TextInputConfiguration(
          viewId: View.of(context).viewId,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          enableSuggestions: true,
          autocorrect: true,
        ),
      );
      _connection!
        ..setEditingState(_value)
        ..show();
    } else {
      _connection?.close();
      _connection = null;
    }
  }

  void _syncFromAuthority() {
    final snapshot = _controller?.snapshot;
    if (snapshot == null) return;
    final bytes = utf8.encode(snapshot.text);
    final byteOffset = snapshot.utf8ByteOffset.clamp(0, bytes.length);
    final utf16Offset = utf8.decode(bytes.sublist(0, byteOffset)).length;
    _value = TextEditingValue(
      text: snapshot.text,
      selection: TextSelection.collapsed(offset: utf16Offset),
    );
    _connection?.setEditingState(_value);
  }

  int _utf8Offset(String text, int utf16Offset) {
    return utf8.encode(text.substring(0, utf16Offset)).length;
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_opening) {
      return const Center(
        key: ValueKey('paragraph-editor-loading'),
        child: KlpLoadingState(label: '正在開啟本機測試文件'),
      );
    }
    if (_loadError != null || controller == null) {
      return Center(
        key: const ValueKey('paragraph-editor-load-failure'),
        child: KlpErrorState(
          title: '無法開啟本機測試文件',
          message: 'Krepis 暫時無法讀取這份本機測試暫存。原檔不會被覆寫。',
          retryLabel: '重試',
          onRetry: _open,
        ),
      );
    }
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): _redo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): _redo,
        const SingleActivator(
          LogicalKeyboardKey.keyV,
          control: true,
          shift: true,
        ): () {
          _pasteClipboard(asMarkdown: false);
        },
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
          _pasteClipboard(asMarkdown: true);
        },
      },
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              if (controller.snapshot!.spatialCount == 0) {
                return _buildFlowSurface(controller, size);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, flowConstraints) => _buildFlowSurface(
                        controller,
                        Size(
                          flowConstraints.maxWidth,
                          flowConstraints.maxHeight,
                        ),
                      ),
                    ),
                  ),
                  if (controller.snapshot!.flowCount > 1)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, flowReferenceConstraints) {
                          final referenceSize = Size(
                            flowReferenceConstraints.maxWidth,
                            flowReferenceConstraints.maxHeight,
                          );
                          final frame = controller.renderReferenceFlow(
                            1,
                            referenceSize,
                          );
                          return SizedBox.expand(
                            child: CustomPaint(
                              key: const ValueKey(
                                'notist-krepis-flow-reference-preview',
                              ),
                              painter: _KrepisDisplayPainter(controller, frame),
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, spatialConstraints) {
                        final spatialSize = Size(
                          spatialConstraints.maxWidth,
                          spatialConstraints.maxHeight,
                        );
                        final bounds = controller.spatialBounds(0);
                        final frame = controller.renderSpatial(
                          0,
                          bounds,
                          spatialSize,
                        );
                        return SizedBox.expand(
                          child: CustomPaint(
                            key: const ValueKey(
                              'notist-krepis-spatial-preview',
                            ),
                            painter: _KrepisDisplayPainter(controller, frame),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFlowSurface(KrepisEditorAuthority controller, Size size) {
    _viewportSize = size;
    final frame = controller.render(size, _scrollY);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTextInputGeometry(controller, size);
    });
    return Listener(
      key: _flowSurfaceKey,
      onPointerDown: (event) {
        if (_shouldCaptureInk(event)) {
          _beginInk(controller, event);
          return;
        }
        if (_slashMenuOpen) _dismissSlashMenu(restoreFocus: false);
        _focusNode.requestFocus();
        if (_viewportSize.isEmpty) return;
        try {
          controller.placeCaret(_viewportSize, event.localPosition, _scrollY);
          _syncFromAuthority();
          setState(() {});
        } catch (error) {
          if (kDebugMode) {
            debugPrint('Notist 拒絕 pointer caret intent：$error');
          }
        }
      },
      onPointerMove: (event) {
        if (_inkCapture != null) _appendInkSample(controller, event);
      },
      onPointerUp: (event) {
        if (_inkCapture != null) _commitInk(controller, event);
      },
      onPointerCancel: (event) => _cancelInk(controller),
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final maximum = math.max(0.0, controller.flowExtent - size.height);
        final next = (_scrollY + event.scrollDelta.dy).clamp(0.0, maximum);
        if (next == _scrollY) return;
        setState(() => _scrollY = next);
      },
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              key: const ValueKey('notist-krepis-flow-editor'),
              painter: _KrepisDisplayPainter(controller, frame),
            ),
            ..._buildBlockChrome(controller, size),
            if (_currentInkOutline(controller).isNotEmpty &&
                _inkOwnerRect != null)
              NotistInkPreview(
                points: _inkOutline,
                origin: _inkOwnerRect!.topLeft,
              ),
            if (_draggedBlockId != null) ..._buildDragFeedback(controller),
            if (_slashMenuOpen) _buildSlashMenu(controller, size),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _buildBlockChrome(
    KrepisEditorAuthority controller,
    Size size,
  ) sync* {
    final snapshot = controller.snapshot!;
    final fallback = snapshot.blocks.firstWhere(
      (block) => block.position == snapshot.blockPosition,
    );
    final selectedRange = resolveNotistFlowSelectionRange(
      snapshot.blocks,
      snapshot.selection,
      fallback,
    );
    final viewport = Offset.zero & size;
    for (final block in snapshot.blocks) {
      // Chrome 佔**版面**矩形（含區塊間距），使相鄰 Block 的點擊區連續無縫；
      // 選取框則畫到**視覺**高度為止，才不會比文字高一個間距。
      final rect = controller.blockRect(block.position, size, _scrollY);
      if (!rect.overlaps(viewport)) continue;
      final visualRect = controller.blockVisualRect(
        block.position,
        size,
        _scrollY,
      );

      yield Positioned(
        key: ValueKey('notist-flow-block-${block.id}'),
        left: 0,
        top: rect.top,
        width: rect.right,
        height: rect.height,
        child: NotistFlowBlockChrome(
          block: block,
          contentLeft: rect.left,
          contentWidth: rect.width,
          visualHeight: visualRect.height,
          selected: selectedRange.contains(block),
          onSelected: () => _selectBlock(controller, block),
          registry: _commandsFor(controller, block),
          onHandleDragStart: (details) =>
              _beginBlockDrag(controller, block, details),
          onHandleDragUpdate: (details) =>
              _updateBlockDrag(controller, details),
          onHandleDragEnd: (details) => _finishBlockDrag(controller),
        ),
      );
    }
  }

  NotistBlockCommandRegistry _commandsFor(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
  ) {
    final snapshot = controller.snapshot!;
    final selection = snapshot.selection;
    final applicability = snapshot.applicability;
    final currentGate =
        applicability?.contentRevision == snapshot.contentRevision;
    final selectedAnchor = selection?.anchor.blockId == block.id;
    final canMove =
        currentGate &&
        applicability!.selectionRangeHasMoveTarget &&
        selectedAnchor;
    final canConvert =
        currentGate && applicability!.anchorCanConvert && selectedAnchor;

    return NotistBlockCommandRegistry.forBlock(
      block: block,
      actions: NotistBlockCommandActions(
        onDuplicate: () => _duplicateBlock(controller, block),
        onMoveUp: canMove ? () => _moveSelectionOneStep(controller, -1) : null,
        onMoveDown: canMove ? () => _moveSelectionOneStep(controller, 1) : null,
        onConvert: canConvert
            ? {
                for (final kind in KrepisFlowBlockKind.values)
                  if (kind != KrepisFlowBlockKind.thematicBreak ||
                      block.text.isEmpty)
                    kind: () => _convertBlock(controller, block, kind),
              }
            : const {},
        onToggleTask:
            canConvert && block.kind == KrepisFlowBlockKind.taskListItem
            ? () => _toggleTask(controller, block)
            : null,
      ),
    );
  }

  Widget _buildSlashMenu(KrepisEditorAuthority controller, Size size) {
    final snapshot = controller.snapshot!;
    final block = snapshot.blocks.firstWhere(
      (candidate) => candidate.position == snapshot.blockPosition,
    );
    final commands = _commandsFor(controller, block);
    final itemCount = commands
        .forSurface(NotistBlockCommandSurface.slashMenu)
        .length;
    final caret = controller.caretRect(size, _scrollY);
    final position = KlpMenuLayout.resolvePosition(
      anchor: Offset(caret.left, caret.bottom),
      viewport: size,
      context: context,
      itemCount: itemCount,
      separatorCount: 1,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: NotistFlowSlashMenu(
        registry: commands,
        onEscape: _dismissSlashMenu,
        onCommandSelected: (command) =>
            _executeSlashCommand(controller, command),
      ),
    );
  }

  void _dismissSlashMenu({bool restoreFocus = true}) {
    if (!_slashMenuOpen) return;

    setState(() => _slashMenuOpen = false);
    if (!restoreFocus) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _selectBlock(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
  ) {
    final snapshot = controller.snapshot!;
    final previous = snapshot.selection;
    final extendsSelection =
        HardwareKeyboard.instance.isShiftPressed &&
        previous?.contentRevision == snapshot.contentRevision;
    final endpoint = KrepisTextEndpointProjection(
      blockId: block.id,
      graphemeBoundary: 0,
      affinity: KrepisTextAffinity.downstream,
    );
    controller.setStableSelection(
      KrepisTextSelectionProjection(
        contentRevision: snapshot.contentRevision,
        anchor: extendsSelection ? previous!.anchor : endpoint,
        focus: endpoint,
      ),
    );
    _syncFromAuthority();
    setState(() {});
  }

  void _moveSelectionOneStep(KrepisEditorAuthority controller, int direction) {
    final snapshot = controller.snapshot!;
    final fallback = snapshot.blocks.firstWhere(
      (block) => block.position == snapshot.blockPosition,
    );
    final range = resolveNotistFlowSelectionRange(
      snapshot.blocks,
      snapshot.selection,
      fallback,
    );
    final targetPosition = direction < 0
        ? range.firstPosition - 1
        : range.lastPosition + 1;
    final target = snapshot.blocks.where(
      (block) => block.position == targetPosition,
    );
    if (target.isEmpty) return;

    controller.moveFlowBlockRange(
      expectedContentRevision: snapshot.contentRevision,
      source: range.stableRange,
      target: KrepisFlowBlockTarget(
        blockId: target.single.id,
        affinity: direction < 0
            ? KrepisBlockTargetAffinity.before
            : KrepisBlockTargetAffinity.after,
      ),
      timestamp: _now(),
    );
  }

  void _convertBlock(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
    KrepisFlowBlockKind kind,
  ) {
    final snapshot = controller.snapshot!;
    controller.convertFlowBlock(
      expectedContentRevision: snapshot.contentRevision,
      blockId: block.id,
      attributes: KrepisFlowBlockAttributes.fromBlock(block, kind: kind),
      timestamp: _now(),
    );
  }

  void _toggleTask(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
  ) {
    final snapshot = controller.snapshot!;
    controller.convertFlowBlock(
      expectedContentRevision: snapshot.contentRevision,
      blockId: block.id,
      attributes: KrepisFlowBlockAttributes.fromBlock(
        block,
        taskChecked: !block.taskChecked,
      ),
      timestamp: _now(),
    );
  }

  void _executeSlashCommand(
    KrepisEditorAuthority controller,
    NotistBlockCommand command,
  ) {
    final kind = command.id.conversionKind;
    if (kind == null || !command.enabled) return;

    try {
      controller.backspace(_now());
      final snapshot = controller.snapshot!;
      final block = snapshot.blocks.firstWhere(
        (candidate) => candidate.position == snapshot.blockPosition,
      );
      _convertBlock(controller, block, kind);
      _dismissSlashMenu();
    } catch (error) {
      _recoverAfterIntentFailure('Slash command intent', error);
    }
  }

  bool _shouldCaptureInk(PointerDownEvent event) {
    final stylus =
        event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
    if (stylus) widget.onStylusDetected?.call();
    return widget.inkEnabled || stylus;
  }

  void _beginInk(KrepisEditorAuthority controller, PointerDownEvent event) {
    if (_inkCapture != null) _cancelInk(controller);
    final snapshot = controller.snapshot!;
    final owner = snapshot.blocks.firstWhere(
      (block) => controller
          .blockRect(block.position, _viewportSize, _scrollY)
          .contains(event.localPosition),
      orElse: () => snapshot.blocks.firstWhere(
        (block) => block.position == snapshot.blockPosition,
      ),
    );
    final rect = controller.blockRect(owner.position, _viewportSize, _scrollY);
    try {
      final capture = controller.beginInkCapture(
        brush: _inkBrush,
        captureWidth26_6: (rect.width * 64).round(),
      );
      _inkCapture = capture;
      _inkOwner = owner;
      _inkOwnerRect = rect;
      _inkStartedAtMs = _now();
      _inkSamples.clear();
      _inkPreviewSamples.clear();
      _appendInkSample(controller, event);
    } catch (error) {
      _clearInk();
      _recoverAfterIntentFailure('Ink begin intent', error);
    }
  }

  void _appendInkSample(KrepisEditorAuthority controller, PointerEvent event) {
    final rect = _inkOwnerRect;
    final startedAt = _inkStartedAtMs;
    if (rect == null || startedAt == null || rect.width <= 0) return;

    final local = event.localPosition - rect.topLeft;
    final xNormalized = ((local.dx / rect.width) * 65535).round().clamp(
      0,
      65535,
    );
    final elapsed = (_now() - startedAt).clamp(0, 65535);
    final pressureRange = event.pressureMax - event.pressureMin;
    final normalizedPressure = pressureRange > 0
        ? (event.pressure - event.pressureMin) / pressureRange
        : event.pressure;
    final pressure = (normalizedPressure * 255).round().clamp(0, 255);
    final altitude =
        (((math.pi / 2 - event.tilt).clamp(0.0, math.pi / 2) / (math.pi / 2)) *
                255)
            .round();
    final azimuth =
        (((event.orientation % (math.pi * 2)) / (math.pi * 2)) * 255)
            .round()
            .clamp(0, 255);
    _inkSamples.add(
      KrepisInkRawSampleProjection(
        timeMs: startedAt + elapsed,
        y26_6: (local.dy * 64).round(),
        xNormalized: xNormalized,
        pressure: pressure,
        tiltAltitude: altitude,
        tiltAzimuth: azimuth,
      ),
    );
    _inkPreviewSamples.add(
      KrepisInkPreviewSampleProjection(
        xNormalized: xNormalized,
        // y 以 DocumentUnit 的定點儲存（每 DocumentUnit 100 單位）。
        // **不是毫米**——05-ink（2026-08-23）明訂真實毫米不進入 Ink 權威資料。
        yFixed: (local.dy * 100).round().clamp(-32768, 32767),
        pressure: pressure,
        tiltAltitude: altitude,
        tiltAzimuth: azimuth,
        dtMs: elapsed,
      ),
    );
    // 只標記待重建並請求一幀；實際重建在 build 時進行。
    setState(() => _inkOutlineDirty = true);
  }

  /// 取得目前的預覽外框，必要時重建。
  ///
  /// **刻意在 build 期間計算**：Flutter 的幀管線本身就把同一幀內的多個 pointer
  /// 事件合併成一次 build，因此重建頻率自然被限制在畫面更新率，不需要手動排程。
  ///
  /// 先前是在每個 pointer move 同步重建：編碼 n 點、跨 FFI 解碼 n 點、建外框、
  /// 配置頂點緩衝、複製回 Dart，再 setState。觸控筆 120Hz 且單幀可能多個事件，
  /// 總成本 O(事件數 × n)，長筆畫會嚴重卡頓甚至耗盡資源。
  ///
  /// **取樣點一個都不丟**，只有預覽的重建頻率被限制——超過幀率的部分本來也畫不出來。
  KrepisInkOutline _currentInkOutline(KrepisEditorAuthority controller) {
    if (!_inkOutlineDirty) return _inkOutline;

    final rect = _inkOwnerRect;
    if (_inkCapture == null ||
        rect == null ||
        rect.width <= 0 ||
        _inkPreviewSamples.isEmpty) {
      return const [];
    }

    _inkOutlineDirty = false;
    try {
      _inkOutline = controller.buildInkOutline(
        samples: _inkPreviewSamples,
        captureBlockWidth: rect.width,
        displayBlockWidth: rect.width,
        brush: _inkBrush,
      );
    } catch (error) {
      // build 期間不得改動 widget tree 狀態，因此延到本幀之後再收拾。
      _inkOutline = const [];
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _cancelInk(controller);
        _recoverAfterIntentFailure('Ink preview intent', error);
      });
    }
    return _inkOutline;
  }

  void _commitInk(KrepisEditorAuthority controller, PointerUpEvent event) {
    final capture = _inkCapture;
    final owner = _inkOwner;
    if (capture == null || owner == null) return;
    _appendInkSample(controller, event);
    try {
      controller.commitInkCapture(
        capture: capture,
        ownerBlockId: owner.id,
        samples: List.unmodifiable(_inkSamples),
        placement: const KrepisInkPlacementProjection(),
        committedAtMs: _now(),
      );
      _clearInk();
      setState(() {});
    } catch (error) {
      try {
        controller.cancelInkCapture(capture.handle);
      } catch (_) {}
      _clearInk();
      _recoverAfterIntentFailure('Ink commit intent', error);
    }
  }

  void _cancelInk(KrepisEditorAuthority controller) {
    final capture = _inkCapture;
    if (capture != null) {
      try {
        controller.cancelInkCapture(capture.handle);
      } catch (error) {
        if (kDebugMode) debugPrint('Notist 無法取消 Ink capture：$error');
      }
    }
    _clearInk();
    if (mounted) setState(() {});
  }

  void _clearInk() {
    _inkCapture = null;
    _inkOwner = null;
    _inkOwnerRect = null;
    _inkStartedAtMs = null;
    _inkSamples.clear();
    _inkPreviewSamples.clear();
    _inkOutline = const [];
    _inkOutlineDirty = false;
  }

  void _beginBlockDrag(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
    DragStartDetails details,
  ) {
    final snapshot = controller.snapshot!;
    final current = resolveNotistFlowSelectionRange(
      snapshot.blocks,
      snapshot.selection,
      block,
    );
    if (!current.contains(block)) {
      final endpoint = KrepisTextEndpointProjection(
        blockId: block.id,
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.downstream,
      );
      controller.setStableSelection(
        KrepisTextSelectionProjection(
          contentRevision: snapshot.contentRevision,
          anchor: endpoint,
          focus: endpoint,
        ),
      );
    }

    setState(() {
      _draggedBlockId = block.id;
      _dragPointer = _surfacePosition(details.globalPosition);
      _dropTargetBlockId = null;
      _dropTargetAffinity = null;
    });
  }

  void _updateBlockDrag(
    KrepisEditorAuthority controller,
    DragUpdateDetails details,
  ) {
    final pointer = _surfacePosition(details.globalPosition);
    final snapshot = controller.snapshot!;
    final dragged = snapshot.blocks.firstWhere(
      (block) => block.id == _draggedBlockId,
    );
    final source = resolveNotistFlowSelectionRange(
      snapshot.blocks,
      snapshot.selection,
      dragged,
    );
    KrepisFlowBlockProjection? closest;
    var distance = double.infinity;
    for (final block in snapshot.blocks) {
      if (source.contains(block)) continue;
      final rect = controller.blockRect(
        block.position,
        _viewportSize,
        _scrollY,
      );
      final candidateDistance = (rect.center.dy - pointer.dy).abs();
      if (candidateDistance >= distance) continue;
      closest = block;
      distance = candidateDistance;
    }
    final targetRect = closest == null
        ? null
        : controller.blockRect(closest.position, _viewportSize, _scrollY);

    setState(() {
      _dragPointer = pointer;
      _dropTargetBlockId = closest?.id;
      _dropTargetAffinity = targetRect == null
          ? null
          : pointer.dy < targetRect.center.dy
          ? KrepisBlockTargetAffinity.before
          : KrepisBlockTargetAffinity.after;
    });
  }

  void _finishBlockDrag(KrepisEditorAuthority controller) {
    final targetId = _dropTargetBlockId;
    final affinity = _dropTargetAffinity;
    final draggedId = _draggedBlockId;
    setState(() {
      _draggedBlockId = null;
      _dragPointer = null;
      _dropTargetBlockId = null;
      _dropTargetAffinity = null;
    });
    if (targetId == null || affinity == null || draggedId == null) return;

    try {
      final snapshot = controller.snapshot!;
      final dragged = snapshot.blocks.firstWhere(
        (block) => block.id == draggedId,
      );
      final source = resolveNotistFlowSelectionRange(
        snapshot.blocks,
        snapshot.selection,
        dragged,
      );
      controller.moveFlowBlockRange(
        expectedContentRevision: snapshot.contentRevision,
        source: source.stableRange,
        target: KrepisFlowBlockTarget(blockId: targetId, affinity: affinity),
        timestamp: _now(),
      );
    } catch (error) {
      _recoverAfterIntentFailure('Block drag intent', error);
    }
  }

  Iterable<Widget> _buildDragFeedback(KrepisEditorAuthority controller) sync* {
    final targetId = _dropTargetBlockId;
    final affinity = _dropTargetAffinity;
    if (targetId != null && affinity != null) {
      final target = controller.snapshot!.blocks.firstWhere(
        (block) => block.id == targetId,
      );
      final rect = controller.blockRect(
        target.position,
        _viewportSize,
        _scrollY,
      );
      yield Positioned(
        key: const ValueKey('notist-flow-drop-indicator'),
        left: rect.left,
        top: affinity == KrepisBlockTargetAffinity.before
            ? rect.top
            : rect.bottom,
        width: rect.width,
        child: const IgnorePointer(child: KlpDropIndicator()),
      );
    }

    final pointer = _dragPointer;
    if (pointer != null) {
      yield Positioned(
        key: const ValueKey('notist-flow-drag-preview'),
        left: pointer.dx + context.klp.space.tight,
        top: pointer.dy + context.klp.space.tight,
        child: const IgnorePointer(
          child: KlpDragPreview(
            child: KlpText('移動區塊', role: KlpTextRole.label),
          ),
        ),
      );
    }
  }

  Offset _surfacePosition(Offset globalPosition) {
    final renderObject = _flowSurfaceKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return globalPosition;
    return renderObject.globalToLocal(globalPosition);
  }

  void _duplicateBlock(
    KrepisEditorAuthority controller,
    KrepisFlowBlockProjection block,
  ) {
    controller.replaceFlowBlocks(
      expectedContentRevision: controller.snapshot!.contentRevision,
      position: block.position + 1,
      removeCount: 0,
      blocks: [block.toDraft()],
      timestamp: _now(),
    );
    _syncFromAuthority();
    setState(() {});
  }

  void _updateTextInputGeometry(KrepisEditorAuthority controller, Size size) {
    final connection = _connection;
    final renderObject = _flowSurfaceKey.currentContext?.findRenderObject();
    if (!mounted || connection == null || renderObject is! RenderBox) return;
    final caret = controller.caretRect(size, _scrollY);
    connection
      ..setEditableSizeAndTransform(size, renderObject.getTransformTo(null))
      ..setCaretRect(caret);
    if (_compositionActive) connection.setComposingRect(caret);
  }

  @override
  TextEditingValue get currentTextEditingValue => _value;

  @override
  AutofillScope? get currentAutofillScope => null;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_slashMenuOpen &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        event is KeyDownEvent) {
      _dismissSlashMenu();
      return KeyEventResult.handled;
    }

    final controller = _controller;
    final handlesBackspace =
        event.logicalKey == LogicalKeyboardKey.backspace &&
        (event is KeyDownEvent || event is KeyRepeatEvent);
    if (controller == null || !handlesBackspace || _compositionActive) {
      return KeyEventResult.ignored;
    }

    try {
      controller.backspace(_now());
      _syncFromAuthority();
      setState(() {});
    } catch (error) {
      _recoverAfterIntentFailure('Backspace intent', error);
    }
    return KeyEventResult.handled;
  }

  void _undo() {
    final controller = _controller;
    if (controller == null || !controller.snapshot!.canUndo) return;
    try {
      controller.undo();
      _syncFromAuthority();
      setState(() {});
    } catch (error) {
      _recoverAfterIntentFailure('undo intent', error);
    }
  }

  void _redo() {
    final controller = _controller;
    if (controller == null || !controller.snapshot!.canRedo) return;
    try {
      controller.redo();
      _syncFromAuthority();
      setState(() {});
    } catch (error) {
      _recoverAfterIntentFailure('redo intent', error);
    }
  }

  Future<void> _pasteClipboard({required bool asMarkdown}) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;

    final text = clipboard?.text;
    final controller = _controller;
    if (text == null || text.isEmpty || controller == null) return;

    try {
      if (asMarkdown) {
        controller.importMarkdown(text, timestamp: _now());
      } else {
        controller.insertText(text, timestamp: _now(), group: 0);
      }
      _syncFromAuthority();
      setState(() {});
    } catch (error) {
      _recoverAfterIntentFailure('clipboard paste intent', error);
    }
  }

  @override
  void updateEditingValue(TextEditingValue next) {
    final controller = _controller;
    if (controller == null) return;
    if (kDebugMode) {
      debugPrint(
        'Notist TextInput update: text=${next.text.length}, '
        'selection=${next.selection}, composing=${next.composing}',
      );
    }
    try {
      if (next.composing.isValid && !next.composing.isCollapsed) {
        final composing = next.text.substring(
          next.composing.start,
          next.composing.end,
        );
        final localSelection =
            (next.selection.extentOffset - next.composing.start).clamp(
              0,
              composing.length,
            );
        final selectionBytes = _utf8Offset(composing, localSelection);
        if (!_compositionActive) {
          final selected = _value.selection;
          controller.setSelection(
            blockPosition: controller.snapshot!.blockPosition,
            anchorUtf8: _utf8Offset(_value.text, selected.baseOffset),
            focusUtf8: _utf8Offset(_value.text, selected.extentOffset),
          );
          controller.beginComposition(composing, selectionBytes);
          _compositionActive = true;
        } else {
          controller.updateComposition(composing, selectionBytes);
        }
        _value = next;
        setState(() {});
        return;
      }
      if (_compositionActive) {
        controller.commitComposition(_now());
        _compositionActive = false;
        _syncFromAuthority();
        setState(() {});
        return;
      }

      final range = findTextReplacement(_value.text, next.text);
      final inserted = next.text.substring(range.prefix, range.newEnd);
      final opensSlashMenu = _shouldOpenSlashMenu(range, inserted);
      controller.setSelection(
        blockPosition: controller.snapshot!.blockPosition,
        anchorUtf8: _utf8Offset(_value.text, range.prefix),
        focusUtf8: _utf8Offset(_value.text, range.oldEnd),
      );
      if (inserted == '\n' && range.prefix == range.oldEnd) {
        controller.insertParagraphBreak(_now());
        final revision = controller.snapshot!.contentRevision;
        _paragraphBreakRevisionAwaitingAction = revision;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_paragraphBreakRevisionAwaitingAction == revision) {
            _paragraphBreakRevisionAwaitingAction = null;
          }
        });
      } else {
        controller.insertText(inserted, timestamp: _now(), group: 1);
      }
      _syncFromAuthority();
      setState(() => _slashMenuOpen = opensSlashMenu);
    } catch (error) {
      _recoverAfterIntentFailure('TextInput intent', error);
    }
  }

  bool _shouldOpenSlashMenu(TextReplacementRange range, String inserted) {
    if (inserted != '/' || range.prefix != range.oldEnd) return false;
    if (range.prefix == 0) return true;

    return RegExp(r'\s').hasMatch(_value.text[range.prefix - 1]);
  }

  @override
  void performAction(TextInputAction action) {
    if (action != TextInputAction.newline || _controller == null) return;
    final revision = _controller!.snapshot!.contentRevision;
    if (_paragraphBreakRevisionAwaitingAction == revision) {
      _paragraphBreakRevisionAwaitingAction = null;
      return;
    }
    try {
      _controller!.insertParagraphBreak(_now());
      _syncFromAuthority();
      setState(() {});
    } catch (error) {
      _recoverAfterIntentFailure('Enter intent', error);
    }
  }

  void _recoverAfterIntentFailure(String operation, Object error) {
    final controller = _controller;
    if (controller?.snapshot != null) {
      _compositionActive = controller!.snapshot!.hasComposition;
      _syncFromAuthority();
    } else {
      _connection?.setEditingState(_value);
    }
    if (mounted) setState(() {});
    if (kDebugMode) debugPrint('Notist 拒絕 $operation：$error');
  }

  @override
  void connectionClosed() {
    _connection = null;
    _focusNode.unfocus();
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void dispose() {
    _openGeneration += 1;
    _connection?.close();
    final capture = _inkCapture;
    if (capture != null) {
      try {
        _controller?.cancelInkCapture(capture.handle);
      } catch (error) {
        if (kDebugMode) debugPrint('Notist 關閉時無法取消 Ink capture：$error');
      }
    }
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _controller
      ?..removeListener(_handleAuthorityChange)
      ..dispose();
    if (_ownsSaveProjection) _saveProjection.dispose();
    super.dispose();
  }
}

class _KrepisDisplayPainter extends CustomPainter {
  _KrepisDisplayPainter(this.controller, this.frame);

  final KrepisEditorAuthority controller;
  final KrepisDisplayFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    for (final command in frame.commands) {
      switch (command) {
        case KrepisDrawRect():
          canvas.drawRect(
            Rect.fromLTWH(command.x, command.y, command.width, command.height),
            Paint()..color = Color(command.color),
          );
        case KrepisDrawGlyphRun():
          _drawGlyphRun(canvas, command);
        case KrepisPushClip():
          canvas.save();
          canvas.clipRect(
            Rect.fromLTWH(command.x, command.y, command.width, command.height),
          );
        case KrepisPopClip():
          canvas.restore();
        case KrepisPushTransform():
          final a = command.affine;
          canvas.save();
          canvas.transform(
            Float64List.fromList([
              a[0],
              a[1],
              0,
              0,
              a[2],
              a[3],
              0,
              0,
              0,
              0,
              1,
              0,
              a[4],
              a[5],
              0,
              1,
            ]),
          );
        case KrepisPopTransform():
          canvas.restore();
      }
    }
  }

  void _drawGlyphRun(Canvas canvas, KrepisDrawGlyphRun run) {
    final paint = Paint()
      ..color = Color(run.color)
      ..style = PaintingStyle.fill;
    var penX = run.baselineX;
    var penY = run.baselineY;
    for (final glyph in run.glyphs) {
      final outline = controller.glyphPath(run.fontId, glyph.id, run.fontSize);
      canvas.save();
      canvas.translate(
        (penX + glyph.xOffset) / 64,
        (penY + glyph.yOffset) / 64,
      );
      canvas.scale(1 / 64, -1 / 64);
      canvas.drawPath(outline, paint);
      canvas.restore();
      penX += glyph.xAdvance;
      penY += glyph.yAdvance;
    }
  }

  @override
  bool shouldRepaint(_KrepisDisplayPainter oldDelegate) {
    return oldDelegate.frame.token != frame.token;
  }
}
