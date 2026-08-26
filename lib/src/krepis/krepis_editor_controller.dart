import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'krepis_block.dart';
import 'krepis_block_adapter.dart';
import 'krepis_display.dart';
import 'krepis_editing.dart';
import 'krepis_editing_adapter.dart';
import 'krepis_ink.dart';
import 'krepis_ink_adapter.dart';
import 'krepis_native.dart';
import 'notist_local_save_projection.dart';

final class KrepisEditorOpenRequest {
  const KrepisEditorOpenRequest({
    required this.filePath,
    this.initialText = '',
    this.saveOnCreate = true,
  });

  final String filePath;
  final String initialText;
  final bool saveOnCreate;
}

typedef KrepisEditorOpener =
    Future<KrepisEditorAuthority> Function(KrepisEditorOpenRequest request);

final class KrepisMarkdownImportResult {
  const KrepisMarkdownImportResult({
    required this.insertedBlockCount,
    required this.diagnosticCount,
  });

  final int insertedBlockCount;
  final int diagnosticCount;
}

final class KrepisEditorSnapshot {
  const KrepisEditorSnapshot({
    required this.rootId,
    required this.title,
    required this.text,
    required this.contentRevision,
    required this.blockCount,
    required this.blockPosition,
    required this.utf8ByteOffset,
    required this.canUndo,
    required this.canRedo,
    required this.hasComposition,
    required this.flowCount,
    required this.spatialCount,
    this.blocks = const [],
    this.selection,
    this.applicability,
    this.undoHistoryEvicted = false,
  });

  final String rootId;
  final String title;
  final String text;
  final int contentRevision;
  final int blockCount;
  final int blockPosition;
  final int utf8ByteOffset;
  final bool canUndo;
  final bool canRedo;
  final bool hasComposition;
  final int flowCount;
  final int spatialCount;
  final List<KrepisFlowBlockProjection> blocks;
  final KrepisTextSelectionProjection? selection;
  final KrepisCommandApplicabilityProjection? applicability;
  final bool undoHistoryEvicted;
}

/// Notist 的薄狀態投影；所有修改仍由 Krepis authority 接受或拒絕。
abstract class KrepisEditorAuthority extends ChangeNotifier {
  KrepisEditorSnapshot? get snapshot;
  KrepisDisplayFrame? get frame;
  String get filePath;
  double get flowExtent;

  void setSelection({
    required int blockPosition,
    required int anchorUtf8,
    required int focusUtf8,
  });
  void placeCaret(Size viewport, Offset point, double scrollY);
  Rect caretRect(Size viewport, double scrollY);

  /// 版面／命中矩形：含區塊間距，相鄰 Block 連續無縫。**命中測試用這個。**
  Rect blockRect(int position, Size viewport, double scrollY) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Block geometry');
  }

  /// 視覺矩形：緊貼內容，不含區塊間距。**選取框、hover 與裝飾用這個。**
  ///
  /// 相鄰視覺矩形之間刻意留有間距，因此不可用於命中測試。
  Rect blockVisualRect(int position, Size viewport, double scrollY) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Block geometry');
  }

  void insertText(String text, {required int timestamp, required int group});
  void insertParagraphBreak(int timestamp);
  void backspace(int timestamp);
  void undo();
  void redo();
  void beginComposition(String text, int selectionByteOffset);
  void updateComposition(String text, int selectionByteOffset);
  void commitComposition(int timestamp);
  void cancelComposition();
  KrepisDisplayFrame render(Size size, double scrollY);
  KrepisDisplayFrame renderReferenceFlow(int index, Size size);
  Rect spatialBounds(int index);
  KrepisDisplayFrame renderSpatial(int index, Rect source, Size size);
  Path glyphPath(int fontId, int glyphId, int fontSize);
  void retrySave();

  void setStableSelection(KrepisTextSelectionProjection selection) {
    throw UnsupportedError('此 Krepis authority 尚未提供 stable selection');
  }

  void moveFlowBlockRange({
    required int expectedContentRevision,
    required KrepisFlowBlockRange source,
    required KrepisFlowBlockTarget target,
    required int timestamp,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 stable Block move');
  }

  void convertFlowBlock({
    required int expectedContentRevision,
    required String blockId,
    required KrepisFlowBlockAttributes attributes,
    required int timestamp,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 stable Block convert');
  }

  KrepisInkCaptureProjection beginInkCapture({
    required KrepisInkBrushProjection brush,
    required int captureWidth26_6,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Ink capture');
  }

  void cancelInkCapture(int handle) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Ink capture');
  }

  KrepisInkCommitProjection commitInkCapture({
    required KrepisInkCaptureProjection capture,
    required String ownerBlockId,
    required List<KrepisInkRawSampleProjection> samples,
    required KrepisInkPlacementProjection placement,
    required int committedAtMs,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Ink capture');
  }

  KrepisInkOutline buildInkOutline({
    required List<KrepisInkPreviewSampleProjection> samples,
    required double captureBlockWidth,
    required double displayBlockWidth,
    required KrepisInkBrushProjection brush,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Ink outline');
  }

  KrepisMarkdownImportResult importMarkdown(
    String markdown, {
    required int timestamp,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Markdown 匯入');
  }

  void replaceFlowBlocks({
    required int expectedContentRevision,
    required int position,
    required int removeCount,
    required List<KrepisFlowBlockDraft> blocks,
    required int timestamp,
  }) {
    throw UnsupportedError('此 Krepis authority 尚未提供 Block replace');
  }
}

final class KrepisEditorController extends KrepisEditorAuthority {
  KrepisEditorController._(
    this._native,
    this._engine,
    this.filePath,
    this._saveProjection,
    this._saveSession,
  ) : _blockAdapter = KrepisBlockAdapter(_native, _engine, _check),
      _editingAdapter = KrepisEditingAdapter(_native, _engine, _check),
      _inkAdapter = KrepisInkAdapter(_native, _engine, _check);

  static const int _ok = 0;
  static const int _outOfRange = 2;
  static const int rawComposition = 0;
  static const int convertedComposition = 2;

  final KrepisNative _native;
  final ffi.Pointer<ffi.Void> _engine;
  final NotistLocalSaveController? _saveProjection;
  final int? _saveSession;
  final KrepisBlockAdapter _blockAdapter;
  final KrepisEditingAdapter _editingAdapter;
  final KrepisInkAdapter _inkAdapter;
  @override
  final String filePath;
  final Map<(int, int, int), Path> _outlineCache = {};

  @override
  KrepisEditorSnapshot? snapshot;
  @override
  KrepisDisplayFrame? frame;
  bool _disposed = false;
  bool _undoHistoryEvicted = false;

  static Future<KrepisEditorAuthority> open(
    KrepisEditorOpenRequest request, {
    NotistLocalSaveController? saveProjection,
  }) async {
    if (request.filePath.isEmpty) {
      throw ArgumentError.value(request.filePath, 'filePath', '不得為空');
    }

    final native = KrepisNative.open();
    final engineSlot = calloc<ffi.Pointer<ffi.Void>>();
    final saveSession = saveProjection?.beginSession();
    try {
      _check(
        native.createNegotiatedEngine(engineSlot),
        '建立 Krepis ABI 1.3 engine',
      );
      final engine = engineSlot.value;
      final controller = KrepisEditorController._(
        native,
        engine,
        request.filePath,
        saveProjection,
        saveSession,
      );
      try {
        await controller._registerFonts();
        final fileExists = File(controller.filePath).existsSync();
        if (fileExists) {
          controller._withUtf8(
            controller.filePath,
            (bytes, size) =>
                _check(native.loadFile(engine, bytes, size), '載入 Q1=A 暫存檔'),
          );
        } else {
          controller._withUtf8(
            request.initialText,
            (bytes, size) =>
                _check(native.initialize(engine, bytes, size), '初始化 Flow 文件'),
          );
        }
        controller.refresh();
        saveProjection?.configureRetry(
          controller.retrySave,
          session: saveSession,
        );
        if (fileExists) {
          saveProjection?.markLoaded(session: saveSession);
        } else if (request.saveOnCreate) {
          controller.retrySave();
        }
        return controller;
      } catch (_) {
        native.destroy(engine);
        rethrow;
      }
    } catch (_) {
      if (saveSession != null) saveProjection?.endSession(saveSession);
      rethrow;
    } finally {
      calloc.free(engineSlot);
    }
  }

  static void _check(int status, String operation) {
    if (status != _ok) throw StateError('$operation 失敗（Krepis status $status）');
  }

  Future<void> _registerFonts() async {
    final data = await rootBundle.load(
      'packages/kallopis/assets/fonts/IBMPlexSansTC-Regular.ttf',
    );
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final nativeBytes = calloc<ffi.Uint8>(bytes.length);
    try {
      nativeBytes.asTypedList(bytes.length).setAll(0, bytes);
      _check(
        _native.registerFont(_engine, 1, nativeBytes, bytes.length, 0),
        '註冊 Kallopis 字型',
      );
    } finally {
      calloc.free(nativeBytes);
    }
  }

  T _withUtf8<T>(
    String value,
    T Function(ffi.Pointer<ffi.Uint8> bytes, int size) body,
  ) {
    final encoded = utf8.encode(value);
    final bytes = calloc<ffi.Uint8>(encoded.isEmpty ? 1 : encoded.length);
    try {
      if (encoded.isNotEmpty) {
        bytes.asTypedList(encoded.length).setAll(0, encoded);
      }
      return body(bytes, encoded.length);
    } finally {
      calloc.free(bytes);
    }
  }

  void refresh() {
    final nativeState = calloc<KrepisEditorState>();
    final documentInfo = calloc<KrepisFlowDocumentInfo>();
    final views = calloc<KrepisDocumentViews>();
    final events = calloc<KrepisEditorEvents>();
    final required = calloc<ffi.Uint64>();
    try {
      nativeState.ref.structSize = ffi.sizeOf<KrepisEditorState>();
      _check(_native.getState(_engine, nativeState), '取得 editor state');
      events.ref.structSize = ffi.sizeOf<KrepisEditorEvents>();
      _check(
        _native.consumeEvents(_engine, events),
        '讀取 editor session events',
      );
      _undoHistoryEvicted = _undoHistoryEvicted || events.ref.flags & 1 != 0;
      documentInfo.ref.structSize = ffi.sizeOf<KrepisFlowDocumentInfo>();
      _check(
        _native.getFlowDocumentInfo(_engine, documentInfo),
        '取得 Flow 文件身分',
      );
      views.ref.structSize = ffi.sizeOf<KrepisDocumentViews>();
      _check(_native.getViews(_engine, views), '取得文件 view 數量');
      final query = _native.copyText(_engine, ffi.nullptr, 0, required);
      if (query != _ok && query != _outOfRange) {
        _check(query, '查詢 Paragraph 文字大小');
      }
      final byteCount = required.value;
      final bytes = calloc<ffi.Uint8>(byteCount == 0 ? 1 : byteCount);
      try {
        _check(
          _native.copyText(_engine, bytes, byteCount, required),
          '讀取 Paragraph 文字',
        );
        final text = utf8.decode(bytes.asTypedList(byteCount));
        final title = _copyFlowTitle(required);
        final flags = nativeState.ref.flags;
        final selection = _editingAdapter.readSelection();
        final applicability = _editingAdapter.readApplicability();
        if (selection.contentRevision != nativeState.ref.contentRevision ||
            applicability.contentRevision != nativeState.ref.contentRevision) {
          throw StateError(
            'Krepis editing projection 與 editor state revision 分岔',
          );
        }
        snapshot = KrepisEditorSnapshot(
          rootId: formatKrepisRootId(
            documentInfo.ref.rootIdHigh,
            documentInfo.ref.rootIdLow,
          ),
          title: title,
          text: text,
          contentRevision: nativeState.ref.contentRevision,
          blockCount: nativeState.ref.blockCount,
          blockPosition: nativeState.ref.blockPosition,
          utf8ByteOffset: nativeState.ref.utf8ByteOffset,
          canUndo: flags & 1 != 0,
          canRedo: flags & 2 != 0,
          hasComposition: flags & 4 != 0,
          flowCount: views.ref.flowCount,
          spatialCount: views.ref.spatialCount,
          blocks: _blockAdapter.readBlocks(nativeState.ref.blockCount),
          selection: selection,
          applicability: applicability,
          undoHistoryEvicted: _undoHistoryEvicted,
        );
      } finally {
        calloc.free(bytes);
      }
    } finally {
      calloc.free(events);
      calloc.free(required);
      calloc.free(views);
      calloc.free(documentInfo);
      calloc.free(nativeState);
    }
    notifyListeners();
  }

  String _copyFlowTitle(ffi.Pointer<ffi.Uint64> required) {
    required.value = 0;
    final query = _native.copyFlowTitle(_engine, ffi.nullptr, 0, required);
    if (query != _ok && query != _outOfRange) {
      _check(query, '查詢 Flow 標題大小');
    }
    final byteCount = required.value;
    final bytes = calloc<ffi.Uint8>(byteCount == 0 ? 1 : byteCount);
    try {
      _check(
        _native.copyFlowTitle(_engine, bytes, byteCount, required),
        '讀取 Flow 標題',
      );
      return utf8.decode(bytes.asTypedList(byteCount));
    } finally {
      calloc.free(bytes);
    }
  }

  @override
  void setSelection({
    required int blockPosition,
    required int anchorUtf8,
    required int focusUtf8,
  }) {
    _check(
      _native.setSelection(_engine, blockPosition, anchorUtf8, focusUtf8),
      '設定 selection',
    );
    refresh();
  }

  @override
  void setStableSelection(KrepisTextSelectionProjection selection) {
    _editingAdapter.setSelection(selection);
    refresh();
  }

  @override
  void moveFlowBlockRange({
    required int expectedContentRevision,
    required KrepisFlowBlockRange source,
    required KrepisFlowBlockTarget target,
    required int timestamp,
  }) {
    _editingAdapter.move(
      expectedContentRevision: expectedContentRevision,
      source: source,
      target: target,
      timestamp: timestamp,
    );
    _finishEdit();
  }

  @override
  void convertFlowBlock({
    required int expectedContentRevision,
    required String blockId,
    required KrepisFlowBlockAttributes attributes,
    required int timestamp,
  }) {
    _editingAdapter.convert(
      expectedContentRevision: expectedContentRevision,
      blockId: blockId,
      attributes: attributes,
      timestamp: timestamp,
    );
    _finishEdit();
  }

  @override
  KrepisInkCaptureProjection beginInkCapture({
    required KrepisInkBrushProjection brush,
    required int captureWidth26_6,
  }) {
    final result = _inkAdapter.begin(
      brush: brush,
      captureWidth26_6: captureWidth26_6,
    );
    refresh();
    return result;
  }

  @override
  void cancelInkCapture(int handle) {
    _inkAdapter.cancel(handle);
  }

  @override
  KrepisInkCommitProjection commitInkCapture({
    required KrepisInkCaptureProjection capture,
    required String ownerBlockId,
    required List<KrepisInkRawSampleProjection> samples,
    required KrepisInkPlacementProjection placement,
    required int committedAtMs,
  }) {
    final result = _inkAdapter.commit(
      capture: capture,
      ownerBlockId: ownerBlockId,
      samples: samples,
      placement: placement,
      committedAtMs: committedAtMs,
    );
    _finishEdit();
    return result;
  }

  @override
  KrepisInkOutline buildInkOutline({
    required List<KrepisInkPreviewSampleProjection> samples,
    required double captureBlockWidth,
    required double displayBlockWidth,
    required KrepisInkBrushProjection brush,
  }) {
    return _inkAdapter.outline(
      samples: samples,
      captureBlockWidth: captureBlockWidth,
      displayBlockWidth: displayBlockWidth,
      brush: brush,
    );
  }

  @override
  void placeCaret(Size viewport, Offset point, double scrollY) {
    _check(
      _native.placeCaret(_engine, viewport.width, scrollY, point.dx, point.dy),
      '依 viewport point 設定 caret',
    );
    refresh();
  }

  @override
  Rect caretRect(Size viewport, double scrollY) {
    final rect = calloc<KrepisRect>();
    try {
      _check(
        _native.getCaretRect(_engine, viewport.width, scrollY, rect),
        '取得 caret geometry',
      );
      return Rect.fromLTWH(
        rect.ref.x,
        rect.ref.y,
        rect.ref.width,
        rect.ref.height,
      );
    } finally {
      calloc.free(rect);
    }
  }

  @override
  Rect blockRect(int position, Size viewport, double scrollY) {
    final rect = _blockAdapter.readRect(position, viewport.width, scrollY);
    return Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
  }

  @override
  Rect blockVisualRect(int position, Size viewport, double scrollY) {
    final rect = _blockAdapter.readRect(
      position,
      viewport.width,
      scrollY,
      visual: true,
    );
    return Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
  }

  @override
  double get flowExtent {
    final extent = calloc<ffi.Double>();
    try {
      _check(_native.getFlowExtent(_engine, extent), '取得 Flow 總高度');
      return extent.value;
    } finally {
      calloc.free(extent);
    }
  }

  @override
  void insertText(String text, {required int timestamp, required int group}) {
    _withUtf8(
      text,
      (bytes, size) => _check(
        _native.insert(_engine, bytes, size, timestamp, group),
        '插入文字',
      ),
    );
    _finishEdit();
  }

  @override
  KrepisMarkdownImportResult importMarkdown(
    String markdown, {
    required int timestamp,
  }) {
    final current = snapshot!;
    final block = current.blocks[current.blockPosition];
    final replaceCurrent = block.text.isEmpty;
    final output = calloc<KrepisMarkdownImportResultNative>();
    try {
      output.ref.structSize = ffi.sizeOf<KrepisMarkdownImportResultNative>();
      _withUtf8(
        markdown,
        (bytes, size) => _check(
          _native.importMarkdown(
            _engine,
            current.contentRevision,
            replaceCurrent ? current.blockPosition : current.blockPosition + 1,
            replaceCurrent ? 1 : 0,
            bytes,
            size,
            timestamp,
            output,
          ),
          '匯入 Markdown',
        ),
      );
      final result = KrepisMarkdownImportResult(
        insertedBlockCount: output.ref.insertedBlockCount,
        diagnosticCount: output.ref.diagnosticCount,
      );
      _finishEdit();
      return result;
    } finally {
      calloc.free(output);
    }
  }

  @override
  void insertParagraphBreak(int timestamp) {
    _check(_native.paragraphBreak(_engine, timestamp), '插入 Paragraph');
    _finishEdit();
  }

  @override
  void backspace(int timestamp) {
    _check(_native.backspace(_engine, timestamp), 'Backspace');
    _finishEdit();
  }

  @override
  void undo() {
    _check(_native.undo(_engine), 'Undo');
    _finishEdit();
  }

  @override
  void redo() {
    _check(_native.redo(_engine), 'Redo');
    _finishEdit();
  }

  @override
  void replaceFlowBlocks({
    required int expectedContentRevision,
    required int position,
    required int removeCount,
    required List<KrepisFlowBlockDraft> blocks,
    required int timestamp,
  }) {
    _blockAdapter.replace(
      expectedContentRevision: expectedContentRevision,
      position: position,
      removeCount: removeCount,
      blocks: blocks,
      timestamp: timestamp,
    );
    _finishEdit();
  }

  @override
  void beginComposition(String text, int selectionByteOffset) {
    _composition(
      text,
      selectionByteOffset,
      rawComposition,
      _native.beginComposition,
      '開始 composition',
    );
    refresh();
  }

  @override
  void updateComposition(String text, int selectionByteOffset) {
    _composition(
      text,
      selectionByteOffset,
      convertedComposition,
      _native.updateComposition,
      '更新 composition',
    );
    refresh();
  }

  void _composition(
    String text,
    int selectionByteOffset,
    int attribute,
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<KrepisCompositionSegment>,
      int,
    )
    operation,
    String label,
  ) {
    _withUtf8(text, (bytes, size) {
      final segment = calloc<KrepisCompositionSegment>();
      try {
        segment.ref
          ..byteStart = 0
          ..byteEnd = size
          ..attribute = attribute
          ..reserved = 0;
        _check(
          operation(
            _engine,
            bytes,
            size,
            selectionByteOffset,
            selectionByteOffset,
            segment,
            1,
          ),
          label,
        );
      } finally {
        calloc.free(segment);
      }
    });
  }

  @override
  void commitComposition(int timestamp) {
    _check(_native.commitComposition(_engine, timestamp), '確定 composition');
    _finishEdit();
  }

  @override
  void cancelComposition() {
    _check(_native.cancelComposition(_engine), '取消 composition');
    refresh();
  }

  @override
  KrepisDisplayFrame render(Size size, double scrollY) {
    return _renderPublished(
      '建立 Flow display list',
      (token) =>
          _native.render(_engine, size.width, size.height, scrollY, token),
    );
  }

  @override
  KrepisDisplayFrame renderReferenceFlow(int index, Size size) {
    return _renderPublished(
      '建立 Flow reference display list',
      (token) => _native.renderReferenceFlow(
        _engine,
        index,
        size.width,
        size.height,
        token,
      ),
    );
  }

  @override
  Rect spatialBounds(int index) {
    final bounds = calloc<KrepisRect>();
    try {
      _check(_native.getSpatialBounds(_engine, index, bounds), '取得 Spatial 邊界');
      return Rect.fromLTWH(
        bounds.ref.x,
        bounds.ref.y,
        bounds.ref.width,
        bounds.ref.height,
      );
    } finally {
      calloc.free(bounds);
    }
  }

  @override
  KrepisDisplayFrame renderSpatial(int index, Rect source, Size size) {
    final nativeSource = calloc<KrepisRect>();
    try {
      nativeSource.ref
        ..x = source.left
        ..y = source.top
        ..width = source.width
        ..height = source.height;
      return _renderPublished(
        '建立 Spatial display list',
        (token) => _native.renderSpatial(
          _engine,
          index,
          nativeSource,
          size.width,
          size.height,
          token,
        ),
      );
    } finally {
      calloc.free(nativeSource);
    }
  }

  KrepisDisplayFrame _renderPublished(
    String label,
    int Function(ffi.Pointer<ffi.Uint64> token) publish,
  ) {
    final token = calloc<ffi.Uint64>();
    final span = calloc<KrepisDisplaySpan>();
    try {
      _check(publish(token), label);
      span.ref.structSize = ffi.sizeOf<KrepisDisplaySpan>();
      _check(_native.acquire(_engine, span), '取得 display list lease');
      try {
        final copied = Uint8List.fromList(
          span.ref.data.asTypedList(span.ref.byteSize),
        );
        frame = decodeKrepisDisplay(copied);
        return frame!;
      } finally {
        _check(
          _native.release(_engine, span.ref.lease),
          '釋放 display list lease',
        );
      }
    } finally {
      calloc.free(span);
      calloc.free(token);
    }
  }

  @override
  Path glyphPath(int fontId, int glyphId, int fontSize) {
    final key = (fontId, glyphId, fontSize);
    final cached = _outlineCache[key];
    if (cached != null) return cached;
    final span = calloc<KrepisGlyphPathSpan>();
    try {
      span.ref.structSize = ffi.sizeOf<KrepisGlyphPathSpan>();
      _check(
        _native.acquireOutline(_engine, fontId, glyphId, fontSize, span),
        '取得 glyph outline',
      );
      try {
        final path = Path();
        for (var index = 0; index < span.ref.commandCount; index += 1) {
          final command = span.ref.commands[index];
          switch (command.opcode) {
            case 1:
              path.moveTo(command.values[0], command.values[1]);
            case 2:
              path.lineTo(command.values[0], command.values[1]);
            case 3:
              path.quadraticBezierTo(
                command.values[0],
                command.values[1],
                command.values[2],
                command.values[3],
              );
            case 4:
              path.cubicTo(
                command.values[0],
                command.values[1],
                command.values[2],
                command.values[3],
                command.values[4],
                command.values[5],
              );
            case 5:
              path.close();
            default:
              throw StateError('未知 glyph outline opcode ${command.opcode}');
          }
        }
        _outlineCache[key] = path;
        return path;
      } finally {
        _check(
          _native.releaseOutline(_engine, span.ref.lease),
          '釋放 glyph outline lease',
        );
      }
    } finally {
      calloc.free(span);
    }
  }

  void _finishEdit() {
    refresh();
    retrySave();
  }

  @override
  void retrySave() {
    _saveProjection?.beginSave(session: _saveSession);
    try {
      _withUtf8(
        filePath,
        (bytes, size) =>
            _check(_native.saveFile(_engine, bytes, size), '保存本機測試暫存'),
      );
      _saveProjection?.completeSave(session: _saveSession);
    } catch (error) {
      _saveProjection?.failSave(error, session: _saveSession);
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_saveSession case final session?) {
      _saveProjection?.endSession(session);
    }
    _outlineCache.clear();
    _inkAdapter.dispose();
    _check(_native.destroy(_engine), '銷毀 Krepis engine');
    super.dispose();
  }
}
