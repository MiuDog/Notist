/// Notist 專案模組。

library;

import 'dart:ui';

import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_display.dart';
import 'package:notist/src/krepis/krepis_editing.dart';
import 'package:notist/src/krepis/krepis_ink.dart';
import 'package:notist/src/krepis/krepis_editor_controller.dart';

final class KeyboardKrepisAuthority extends KrepisEditorAuthority {
  KeyboardKrepisAuthority({
    KrepisEditorSnapshot? initialSnapshot,
    bool blockSelection = false,
    this.displayFrame = _frame,
  }) : snapshot =
           initialSnapshot ??
           (blockSelection ? _defaultBlockSelectionSnapshot : _defaultSnapshot);

  static const _defaultBlocks = [
    KrepisFlowBlockProjection(
      position: 0,
      id: '00000000000000000000000000000002',
      kind: KrepisFlowBlockKind.paragraph,
      level: 0,
      nestingDepth: 0,
      orderedStart: 0,
      taskChecked: false,
      text: 'abc',
      info: '',
      marks: [],
    ),
  ];

  static const _defaultSnapshot = KrepisEditorSnapshot(
    rootId: '00000000000000000000000000000001',
    title: 'abc',
    text: 'abc',
    contentRevision: 1,
    blockCount: 1,
    blockPosition: 0,
    utf8ByteOffset: 3,
    canUndo: true,
    canRedo: true,
    hasComposition: false,
    selectionMode: KrepisSelectionMode.text,
    flowCount: 1,
    spatialCount: 0,
    blocks: _defaultBlocks,
  );

  static const _defaultBlockSelectionSnapshot = KrepisEditorSnapshot(
    rootId: '00000000000000000000000000000001',
    title: 'abc',
    text: 'abc',
    contentRevision: 1,
    blockCount: 1,
    blockPosition: 0,
    utf8ByteOffset: 3,
    canUndo: true,
    canRedo: true,
    hasComposition: false,
    selectionMode: KrepisSelectionMode.blocks,
    flowCount: 1,
    spatialCount: 0,
    blocks: _defaultBlocks,
    selection: KrepisTextSelectionProjection(
      contentRevision: 1,
      anchor: KrepisTextEndpointProjection(
        blockId: '00000000000000000000000000000002',
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.downstream,
      ),
      focus: KrepisTextEndpointProjection(
        blockId: '00000000000000000000000000000002',
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.downstream,
      ),
    ),
  );

  static const _frame = KrepisDisplayFrame(1, []);

  int backspaceCount = 0;
  int paragraphBreakCount = 0;
  int redoCount = 0;
  int duplicateCount = 0;
  int markdownPasteCount = 0;
  int plainTextPasteCount = 0;
  int moveCount = 0;
  int convertCount = 0;
  int toggleShortcutCount = 0;
  bool toggleShortcutApplied = false;
  int inkBeginCount = 0;
  int inkCommitCount = 0;
  List<Rect> selectionRects = const [];
  bool rejectSelectionGeometry = false;
  KrepisTextSelectionProjection? lastStableTextSelection;
  KrepisTextSelectionProjection? lastStableBlockSelection;
  String? lastMarkdown;
  KrepisFlowBlockRange? lastMoveSource;
  KrepisFlowBlockTarget? lastMoveTarget;
  KrepisFlowBlockKind? lastConvertKind;

  final KrepisDisplayFrame displayFrame;

  @override
  KrepisEditorSnapshot snapshot;

  @override
  KrepisDisplayFrame get frame => displayFrame;

  @override
  String get filePath => r'C:\Notist dogfood\keyboard.krdf';

  @override
  double get flowExtent => 0;

  @override
  void backspace(int timestamp) {
    backspaceCount += 1;
  }

  @override
  Rect caretRect(Size viewport, double scrollY) => Rect.zero;

  @override
  List<Rect> textSelectionRects(Size viewport, double scrollY) {
    if (rejectSelectionGeometry) {
      throw StateError('stale selection geometry');
    }
    return selectionRects;
  }

  /// 版面矩形：高 32，相鄰之間無縫（24 + position * 32 恰好首尾相接）。
  @override
  Rect blockRect(int position, Size viewport, double scrollY) {
    return Rect.fromLTWH(24, 24 + position * 32, viewport.width - 48, 32);
  }

  /// 視覺矩形：同原點但矮 8（模擬扣掉 block_spacing），相鄰之間留有間隙。
  @override
  Rect blockVisualRect(int position, Size viewport, double scrollY) {
    final layout = blockRect(position, viewport, scrollY);
    return Rect.fromLTWH(
      layout.left,
      layout.top,
      layout.width,
      layout.height - 8,
    );
  }

  @override
  void redo() {
    redoCount += 1;
  }

  @override
  void replaceFlowBlocks({
    required int expectedContentRevision,
    required int position,
    required int removeCount,
    required List<KrepisFlowBlockDraft> blocks,
    required int timestamp,
  }) {
    duplicateCount += 1;
  }

  @override
  KrepisDisplayFrame render(Size size, double scrollY) => displayFrame;

  @override
  KrepisDisplayFrame renderReferenceFlow(int index, Size size) => displayFrame;

  @override
  KrepisDisplayFrame renderSpatial(int index, Rect source, Size size) =>
      displayFrame;

  @override
  Rect spatialBounds(int index) => Rect.zero;

  @override
  Path glyphPath(int fontId, int glyphId, int fontSize) => Path();

  @override
  void beginComposition(String text, int selectionByteOffset) {}

  @override
  void cancelComposition() {}

  @override
  void commitComposition(int timestamp) {}

  @override
  void insertParagraphBreak(int timestamp) {
    paragraphBreakCount += 1;
  }

  @override
  void insertText(String text, {required int timestamp, required int group}) {
    plainTextPasteCount += 1;
  }

  @override
  bool applyToggleShortcut({
    required int expectedContentRevision,
    required int timestamp,
  }) {
    toggleShortcutCount += 1;
    return toggleShortcutApplied;
  }

  @override
  KrepisMarkdownImportResult importMarkdown(
    String markdown, {
    required int timestamp,
  }) {
    markdownPasteCount += 1;
    lastMarkdown = markdown;
    return const KrepisMarkdownImportResult(
      insertedBlockCount: 2,
      diagnosticCount: 0,
    );
  }

  @override
  void placeCaret(Size viewport, Offset point, double scrollY) {}

  @override
  void retrySave() {}

  @override
  void setSelection({
    required int blockPosition,
    required int anchorUtf8,
    required int focusUtf8,
  }) {}

  @override
  void setStableSelection(KrepisTextSelectionProjection selection) {
    lastStableTextSelection = selection;
    _replaceSelection(KrepisSelectionMode.text, selection);
  }

  @override
  void setStableBlockSelection(KrepisTextSelectionProjection selection) {
    lastStableBlockSelection = selection;
    _replaceSelection(KrepisSelectionMode.blocks, selection);
  }

  void _replaceSelection(
    KrepisSelectionMode mode,
    KrepisTextSelectionProjection selection,
  ) {
    final focusPosition = snapshot.blocks.indexWhere(
      (block) => block.id == selection.focus.blockId,
    );
    snapshot = KrepisEditorSnapshot(
      rootId: snapshot.rootId,
      title: snapshot.title,
      text: snapshot.text,
      contentRevision: snapshot.contentRevision,
      blockCount: snapshot.blockCount,
      blockPosition: focusPosition < 0
          ? snapshot.blockPosition
          : snapshot.blocks[focusPosition].position,
      utf8ByteOffset: selection.focus.graphemeBoundary,
      canUndo: snapshot.canUndo,
      canRedo: snapshot.canRedo,
      hasComposition: snapshot.hasComposition,
      selectionMode: mode,
      flowCount: snapshot.flowCount,
      spatialCount: snapshot.spatialCount,
      blocks: snapshot.blocks,
      selection: selection,
      applicability: snapshot.applicability,
      undoHistoryEvicted: snapshot.undoHistoryEvicted,
    );
  }

  @override
  void moveFlowBlockRange({
    required int expectedContentRevision,
    required KrepisFlowBlockRange source,
    required KrepisFlowBlockTarget target,
    required int timestamp,
  }) {
    moveCount += 1;
    lastMoveSource = source;
    lastMoveTarget = target;
  }

  @override
  void convertFlowBlock({
    required int expectedContentRevision,
    required String blockId,
    required KrepisFlowBlockAttributes attributes,
    required int timestamp,
  }) {
    convertCount += 1;
    lastConvertKind = attributes.kind;
  }

  @override
  KrepisInkCaptureProjection beginInkCapture({
    required KrepisInkBrushProjection brush,
    required int captureWidth26_6,
  }) {
    inkBeginCount += 1;
    return KrepisInkCaptureProjection(
      handle: inkBeginCount,
      contentRevision: snapshot.contentRevision,
      brushId: '00000000000000000000000000000020',
    );
  }

  @override
  void cancelInkCapture(int handle) {}

  @override
  KrepisInkCommitProjection commitInkCapture({
    required KrepisInkCaptureProjection capture,
    required String ownerBlockId,
    required List<KrepisInkRawSampleProjection> samples,
    required KrepisInkPlacementProjection placement,
    required int committedAtMs,
  }) {
    inkCommitCount += 1;
    return KrepisInkCommitProjection(
      contentRevision: snapshot.contentRevision + 1,
      strokeId: '00000000000000000000000000000021',
    );
  }

  @override
  KrepisInkOutline buildInkOutline({
    required List<KrepisInkPreviewSampleProjection> samples,
    required double captureBlockWidth,
    required double displayBlockWidth,
    required KrepisInkBrushProjection brush,
  }) {
    return const [Offset(0, 0), Offset(12, 1), Offset(0, 2)];
  }

  @override
  void undo() {}

  @override
  void updateComposition(String text, int selectionByteOffset) {}
}
