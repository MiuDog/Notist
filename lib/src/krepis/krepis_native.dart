/// Notist 專案模組。

library;

import 'dart:ffi' as ffi;
import 'dart:io';

import 'krepis_editing_native.dart';
import 'krepis_ink_native.dart';

final class KrepisDisplaySpan extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint16()
  external int abiMajor;

  @ffi.Uint16()
  external int abiMinor;

  external ffi.Pointer<ffi.Uint8> data;

  @ffi.Uint64()
  external int byteSize;

  @ffi.Uint64()
  external int frameToken;

  @ffi.Uint64()
  external int lease;
}

final class KrepisGlyphPathCommand extends ffi.Struct {
  @ffi.Uint32()
  external int opcode;

  @ffi.Array(6)
  external ffi.Array<ffi.Float> values;
}

final class KrepisGlyphPathSpan extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint16()
  external int abiMajor;

  @ffi.Uint16()
  external int abiMinor;

  external ffi.Pointer<KrepisGlyphPathCommand> commands;

  @ffi.Uint64()
  external int commandCount;

  @ffi.Uint64()
  external int lease;
}

final class KrepisEditorState extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int flags;

  @ffi.Uint64()
  external int contentRevision;

  @ffi.Uint64()
  external int blockCount;

  @ffi.Uint64()
  external int blockPosition;

  @ffi.Uint64()
  external int graphemeBoundary;

  @ffi.Uint64()
  external int utf8ByteOffset;
}

final class KrepisEditorEvents extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int flags;
}

final class KrepisDocumentViews extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int flowCount;

  @ffi.Uint64()
  external int spatialCount;
}

final class KrepisFlowDocumentInfo extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int rootIdHigh;

  @ffi.Uint64()
  external int rootIdLow;
}

final class KrepisInlineMarkInput extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int kind;

  @ffi.Uint64()
  external int beginByte;

  @ffi.Uint64()
  external int endByte;

  external ffi.Pointer<ffi.Uint8> metadataUtf8;

  @ffi.Uint64()
  external int metadataSize;
}

final class KrepisFlowBlockInput extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int kind;

  @ffi.Uint32()
  external int level;

  @ffi.Uint32()
  external int nestingDepth;

  @ffi.Uint64()
  external int orderedStart;

  @ffi.Uint32()
  external int taskChecked;

  @ffi.Uint32()
  external int toggleCollapsed;

  external ffi.Pointer<ffi.Uint8> utf8;

  @ffi.Uint64()
  external int utf8Size;

  external ffi.Pointer<ffi.Uint8> infoUtf8;

  @ffi.Uint64()
  external int infoSize;

  external ffi.Pointer<KrepisInlineMarkInput> marks;

  @ffi.Uint64()
  external int markCount;
}

final class KrepisFlowBlockInfo extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int kind;

  @ffi.Uint32()
  external int level;

  @ffi.Uint32()
  external int nestingDepth;

  @ffi.Uint64()
  external int orderedStart;

  @ffi.Uint32()
  external int taskChecked;

  @ffi.Uint32()
  external int toggleCollapsed;

  @ffi.Uint64()
  external int blockIdHigh;

  @ffi.Uint64()
  external int blockIdLow;

  @ffi.Uint64()
  external int utf8Size;

  @ffi.Uint64()
  external int infoSize;

  @ffi.Uint64()
  external int markCount;
}

final class KrepisMarkdownImportResultNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int insertedBlockCount;

  @ffi.Uint64()
  external int diagnosticCount;
}

final class KrepisInlineMarkInfo extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int kind;

  @ffi.Uint64()
  external int beginByte;

  @ffi.Uint64()
  external int endByte;

  @ffi.Uint64()
  external int metadataSize;
}

final class KrepisRect extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;

  @ffi.Double()
  external double width;

  @ffi.Double()
  external double height;
}

final class KrepisCompositionSegment extends ffi.Struct {
  @ffi.Uint64()
  external int byteStart;

  @ffi.Uint64()
  external int byteEnd;

  @ffi.Uint32()
  external int attribute;

  @ffi.Uint32()
  external int reserved;
}

typedef _CreateNative =
    ffi.Uint32 Function(
      ffi.Uint16,
      ffi.Uint16,
      ffi.Pointer<ffi.Pointer<ffi.Void>>,
    );
typedef KrepisCreate =
    int Function(int, int, ffi.Pointer<ffi.Pointer<ffi.Void>>);
typedef _DestroyNative = ffi.Uint32 Function(ffi.Pointer<ffi.Void>);
typedef KrepisDestroy = int Function(ffi.Pointer<ffi.Void>);
typedef _RegisterFontNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint32,
    );
typedef KrepisRegisterFont =
    int Function(ffi.Pointer<ffi.Void>, int, ffi.Pointer<ffi.Uint8>, int, int);
typedef _BytesNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
    );
typedef KrepisBytesOperation =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int);
typedef _StateNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisEditorState>);
typedef KrepisGetState =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisEditorState>);
typedef _EventsNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisEditorEvents>);
typedef KrepisConsumeEvents =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisEditorEvents>);
typedef _ViewsNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisDocumentViews>,
    );
typedef KrepisGetViews =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisDocumentViews>);
typedef _FlowDocumentInfoNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisFlowDocumentInfo>,
    );
typedef KrepisGetFlowDocumentInfo =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisFlowDocumentInfo>);
typedef _ReplaceFlowBlocksNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisFlowBlockInput>,
      ffi.Uint64,
      ffi.Uint64,
    );
typedef KrepisReplaceFlowBlocks =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      int,
      ffi.Pointer<KrepisFlowBlockInput>,
      int,
      int,
    );
typedef _ImportMarkdownNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisMarkdownImportResultNative>,
    );
typedef KrepisImportMarkdown =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<KrepisMarkdownImportResultNative>,
    );
typedef _GetFlowBlockInfoNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<KrepisFlowBlockInfo>,
    );
typedef KrepisGetFlowBlockInfo =
    int Function(ffi.Pointer<ffi.Void>, int, ffi.Pointer<KrepisFlowBlockInfo>);
typedef _GetFlowBlockRectNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<KrepisRect>,
    );
typedef KrepisGetFlowBlockRect =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      double,
      double,
      ffi.Pointer<KrepisRect>,
    );
typedef _CopyFlowBlockUtf8Native =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisCopyFlowBlockUtf8 =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _GetInlineMarkInfoNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisInlineMarkInfo>,
    );
typedef KrepisGetInlineMarkInfo =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      ffi.Pointer<KrepisInlineMarkInfo>,
    );
typedef _CopyInlineMarkMetadataUtf8Native =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisCopyInlineMarkMetadataUtf8 =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _SpatialBoundsNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<KrepisRect>,
    );
typedef KrepisGetSpatialBounds =
    int Function(ffi.Pointer<ffi.Void>, int, ffi.Pointer<KrepisRect>);
typedef _CopyTextNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisCopyText =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _SelectionNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
    );
typedef KrepisSetSelection = int Function(ffi.Pointer<ffi.Void>, int, int, int);
typedef _PointNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Double,
      ffi.Double,
      ffi.Double,
      ffi.Double,
    );
typedef KrepisPointOperation =
    int Function(ffi.Pointer<ffi.Void>, double, double, double, double);
typedef _CaretRectNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<KrepisRect>,
    );
typedef KrepisGetCaretRect =
    int Function(
      ffi.Pointer<ffi.Void>,
      double,
      double,
      ffi.Pointer<KrepisRect>,
    );
typedef _TextSelectionRectsNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<KrepisRect>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisGetTextSelectionRects =
    int Function(
      ffi.Pointer<ffi.Void>,
      double,
      double,
      ffi.Pointer<KrepisRect>,
      int,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _FlowExtentNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Double>);
typedef KrepisGetFlowExtent =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Double>);
typedef _InsertNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
    );
typedef KrepisInsert =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, int, int);
typedef _TimestampNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Uint64);
typedef KrepisTimestampOperation = int Function(ffi.Pointer<ffi.Void>, int);
typedef _EngineNative = ffi.Uint32 Function(ffi.Pointer<ffi.Void>);
typedef KrepisEngineOperation = int Function(ffi.Pointer<ffi.Void>);
typedef _CompositionNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisCompositionSegment>,
      ffi.Uint64,
    );
typedef KrepisCompositionOperation =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<KrepisCompositionSegment>,
      int,
    );
typedef _RenderNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Double,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisRender =
    int Function(
      ffi.Pointer<ffi.Void>,
      double,
      double,
      double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _ReferenceFlowRenderNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisReferenceFlowRender =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      double,
      double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _SpatialRenderNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<KrepisRect>,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisSpatialRender =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      ffi.Pointer<KrepisRect>,
      double,
      double,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _AcquireNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisDisplaySpan>);
typedef KrepisAcquireDisplay =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisDisplaySpan>);
typedef _ReleaseNative = ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Uint64);
typedef KrepisRelease = int Function(ffi.Pointer<ffi.Void>, int);
typedef _OutlineNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint32,
      ffi.Int32,
      ffi.Pointer<KrepisGlyphPathSpan>,
    );
typedef KrepisAcquireOutline =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      int,
      ffi.Pointer<KrepisGlyphPathSpan>,
    );

/// `krepis_c.h` 的薄 bindings；不保存任何文件或 selection 規則。
final class KrepisNative {
  KrepisNative._(this.library);

  static const int requiredAbiMajor = 1;
  static const int requiredAbiMinor = 11;

  factory KrepisNative.open() {
    if (!Platform.isWindows) {
      throw UnsupportedError('P1 Krepis native bridge 目前只封裝 Windows');
    }
    return KrepisNative._(ffi.DynamicLibrary.open('krepis_c.dll'));
  }

  final ffi.DynamicLibrary library;
  late final KrepisDestroy destroy;
  late final KrepisRegisterFont registerFont;
  late final KrepisBytesOperation initialize;
  late final KrepisBytesOperation loadFile;
  late final KrepisBytesOperation saveFile;
  late final KrepisGetState getState;
  late final KrepisConsumeEvents consumeEvents;
  late final KrepisGetFlowDocumentInfo getFlowDocumentInfo;
  late final KrepisReplaceFlowBlocks replaceFlowBlocks;
  late final KrepisImportMarkdown importMarkdown;
  late final KrepisGetFlowBlockInfo getFlowBlockInfo;
  late final KrepisGetFlowBlockRect getFlowBlockRect;
  late final KrepisGetFlowBlockRect getFlowBlockVisualRect;
  late final KrepisCopyFlowBlockUtf8 copyFlowBlock;
  late final KrepisCopyFlowBlockUtf8 copyFlowBlockInfo;
  late final KrepisGetInlineMarkInfo getInlineMarkInfo;
  late final KrepisCopyInlineMarkMetadataUtf8 copyInlineMarkMetadata;
  late final KrepisCopyText copyFlowTitle;
  late final KrepisGetViews getViews;
  late final KrepisGetSpatialBounds getSpatialBounds;
  late final KrepisCopyText copyText;
  late final KrepisSetSelection setSelection;
  late final KrepisGetTextSelection getTextSelection;
  late final KrepisSetTextSelection setTextSelection;
  late final KrepisSetBlockSelection setBlockSelection;
  late final KrepisMoveFlowBlockRange moveFlowBlockRange;
  late final KrepisConvertFlowBlock convertFlowBlock;
  late final KrepisApplyToggleShortcut applyToggleShortcut;
  late final KrepisGetCommandApplicability getCommandApplicability;
  late final KrepisInkOutlineCreate createInkOutlineEngine;
  late final KrepisInkOutlineDestroy destroyInkOutlineEngine;
  late final KrepisInkOutlineBuild buildInkOutline;
  late final KrepisBeginInkCapture beginInkCapture;
  late final KrepisCancelInkCapture cancelInkCapture;
  late final KrepisCommitInkCapture commitInkCapture;
  late final KrepisPointOperation placeCaret;
  late final KrepisGetCaretRect getCaretRect;
  late final KrepisGetTextSelectionRects getTextSelectionRects;
  late final KrepisGetFlowExtent getFlowExtent;
  late final KrepisInsert insert;
  late final KrepisTimestampOperation paragraphBreak;
  late final KrepisTimestampOperation backspace;
  late final KrepisEngineOperation undo;
  late final KrepisEngineOperation redo;
  late final KrepisCompositionOperation beginComposition;
  late final KrepisCompositionOperation updateComposition;
  late final KrepisTimestampOperation commitComposition;
  late final KrepisEngineOperation cancelComposition;
  late final KrepisRender render;
  late final KrepisReferenceFlowRender renderReferenceFlow;
  late final KrepisSpatialRender renderSpatial;
  late final KrepisAcquireDisplay acquire;
  late final KrepisRelease release;
  late final KrepisAcquireOutline acquireOutline;
  late final KrepisRelease releaseOutline;

  int createNegotiatedEngine(ffi.Pointer<ffi.Pointer<ffi.Void>> outEngine) {
    // create／destroy 是 bootstrap pair；其餘 symbol 只能在 ABI 1.11 協商成功後綁定。
    final create = library.lookupFunction<_CreateNative, KrepisCreate>(
      'krepis_display_engine_create',
    );
    destroy = library.lookupFunction<_DestroyNative, KrepisDestroy>(
      'krepis_display_engine_destroy',
    );
    final status = create(requiredAbiMajor, requiredAbiMinor, outEngine);
    if (status != 0) return status;

    try {
      _bindNegotiatedSymbols();
    } catch (_) {
      destroy(outEngine.value);
      outEngine.value = ffi.nullptr;
      rethrow;
    }
    return status;
  }

  void _bindNegotiatedSymbols() {
    registerFont = library
        .lookupFunction<_RegisterFontNative, KrepisRegisterFont>(
          'krepis_display_register_font',
        );
    initialize = library.lookupFunction<_BytesNative, KrepisBytesOperation>(
      'krepis_editor_initialize',
    );
    loadFile = library.lookupFunction<_BytesNative, KrepisBytesOperation>(
      'krepis_editor_load_file',
    );
    saveFile = library.lookupFunction<_BytesNative, KrepisBytesOperation>(
      'krepis_editor_save_file',
    );
    getState = library.lookupFunction<_StateNative, KrepisGetState>(
      'krepis_editor_get_state',
    );
    consumeEvents = library.lookupFunction<_EventsNative, KrepisConsumeEvents>(
      'krepis_editor_consume_events',
    );
    getFlowDocumentInfo = library
        .lookupFunction<_FlowDocumentInfoNative, KrepisGetFlowDocumentInfo>(
          'krepis_editor_get_flow_document_info',
        );
    replaceFlowBlocks = library
        .lookupFunction<_ReplaceFlowBlocksNative, KrepisReplaceFlowBlocks>(
          'krepis_editor_replace_flow_blocks',
        );
    importMarkdown = library
        .lookupFunction<_ImportMarkdownNative, KrepisImportMarkdown>(
          'krepis_editor_import_markdown',
        );
    getFlowBlockInfo = library
        .lookupFunction<_GetFlowBlockInfoNative, KrepisGetFlowBlockInfo>(
          'krepis_editor_get_flow_block_info',
        );
    getFlowBlockRect = library
        .lookupFunction<_GetFlowBlockRectNative, KrepisGetFlowBlockRect>(
          'krepis_editor_get_flow_block_rect',
        );
    getFlowBlockVisualRect = library
        .lookupFunction<_GetFlowBlockRectNative, KrepisGetFlowBlockRect>(
          'krepis_editor_get_flow_block_visual_rect',
        );
    copyFlowBlock = library
        .lookupFunction<_CopyFlowBlockUtf8Native, KrepisCopyFlowBlockUtf8>(
          'krepis_editor_copy_flow_block_utf8',
        );
    copyFlowBlockInfo = library
        .lookupFunction<_CopyFlowBlockUtf8Native, KrepisCopyFlowBlockUtf8>(
          'krepis_editor_copy_flow_block_info_utf8',
        );
    getInlineMarkInfo = library
        .lookupFunction<_GetInlineMarkInfoNative, KrepisGetInlineMarkInfo>(
          'krepis_editor_get_inline_mark_info',
        );
    copyInlineMarkMetadata = library
        .lookupFunction<
          _CopyInlineMarkMetadataUtf8Native,
          KrepisCopyInlineMarkMetadataUtf8
        >('krepis_editor_copy_inline_mark_metadata_utf8');
    copyFlowTitle = library.lookupFunction<_CopyTextNative, KrepisCopyText>(
      'krepis_editor_copy_flow_title_utf8',
    );
    getViews = library.lookupFunction<_ViewsNative, KrepisGetViews>(
      'krepis_editor_get_document_views',
    );
    getSpatialBounds = library
        .lookupFunction<_SpatialBoundsNative, KrepisGetSpatialBounds>(
          'krepis_editor_get_spatial_bounds',
        );
    copyText = library.lookupFunction<_CopyTextNative, KrepisCopyText>(
      'krepis_editor_copy_current_utf8',
    );
    setSelection = library.lookupFunction<_SelectionNative, KrepisSetSelection>(
      'krepis_editor_set_utf8_selection',
    );
    getTextSelection = library
        .lookupFunction<KrepisGetTextSelectionNative, KrepisGetTextSelection>(
          'krepis_editor_get_text_selection',
        );
    setTextSelection = library
        .lookupFunction<KrepisSetTextSelectionNative, KrepisSetTextSelection>(
          'krepis_editor_set_text_selection',
        );
    setBlockSelection = library
        .lookupFunction<KrepisSetBlockSelectionNative, KrepisSetBlockSelection>(
          'krepis_editor_set_block_selection',
        );
    moveFlowBlockRange = library
        .lookupFunction<
          KrepisMoveFlowBlockRangeNative,
          KrepisMoveFlowBlockRange
        >('krepis_editor_move_flow_block_range');
    convertFlowBlock = library
        .lookupFunction<KrepisConvertFlowBlockNative, KrepisConvertFlowBlock>(
          'krepis_editor_convert_flow_block',
        );
    applyToggleShortcut = library
        .lookupFunction<
          KrepisApplyToggleShortcutNative,
          KrepisApplyToggleShortcut
        >('krepis_editor_apply_toggle_shortcut');
    getCommandApplicability = library
        .lookupFunction<
          KrepisGetCommandApplicabilityNative,
          KrepisGetCommandApplicability
        >('krepis_editor_get_command_applicability');
    createInkOutlineEngine = library
        .lookupFunction<KrepisInkOutlineCreateNative, KrepisInkOutlineCreate>(
          'krepis_ink_outline_engine_create',
        );
    destroyInkOutlineEngine = library
        .lookupFunction<KrepisInkOutlineDestroyNative, KrepisInkOutlineDestroy>(
          'krepis_ink_outline_engine_destroy',
        );
    buildInkOutline = library
        .lookupFunction<KrepisInkOutlineBuildNative, KrepisInkOutlineBuild>(
          'krepis_ink_outline_build',
        );
    beginInkCapture = library
        .lookupFunction<KrepisBeginInkCaptureNative, KrepisBeginInkCapture>(
          'krepis_editor_begin_ink_capture',
        );
    cancelInkCapture = library
        .lookupFunction<KrepisCancelInkCaptureNative, KrepisCancelInkCapture>(
          'krepis_editor_cancel_ink_capture',
        );
    commitInkCapture = library
        .lookupFunction<KrepisCommitInkCaptureNative, KrepisCommitInkCapture>(
          'krepis_editor_commit_ink_capture',
        );
    placeCaret = library.lookupFunction<_PointNative, KrepisPointOperation>(
      'krepis_editor_place_caret',
    );
    getCaretRect = library.lookupFunction<_CaretRectNative, KrepisGetCaretRect>(
      'krepis_editor_get_caret_rect',
    );
    getTextSelectionRects = library
        .lookupFunction<_TextSelectionRectsNative, KrepisGetTextSelectionRects>(
          'krepis_editor_get_text_selection_rects',
        );
    getFlowExtent = library
        .lookupFunction<_FlowExtentNative, KrepisGetFlowExtent>(
          'krepis_editor_get_flow_extent',
        );
    insert = library.lookupFunction<_InsertNative, KrepisInsert>(
      'krepis_editor_insert_utf8',
    );
    paragraphBreak = library
        .lookupFunction<_TimestampNative, KrepisTimestampOperation>(
          'krepis_editor_insert_paragraph_break',
        );
    backspace = library
        .lookupFunction<_TimestampNative, KrepisTimestampOperation>(
          'krepis_editor_backspace',
        );
    undo = library.lookupFunction<_EngineNative, KrepisEngineOperation>(
      'krepis_editor_undo',
    );
    redo = library.lookupFunction<_EngineNative, KrepisEngineOperation>(
      'krepis_editor_redo',
    );
    beginComposition = library
        .lookupFunction<_CompositionNative, KrepisCompositionOperation>(
          'krepis_editor_begin_composition',
        );
    updateComposition = library
        .lookupFunction<_CompositionNative, KrepisCompositionOperation>(
          'krepis_editor_update_composition',
        );
    commitComposition = library
        .lookupFunction<_TimestampNative, KrepisTimestampOperation>(
          'krepis_editor_commit_composition',
        );
    cancelComposition = library
        .lookupFunction<_EngineNative, KrepisEngineOperation>(
          'krepis_editor_cancel_composition',
        );
    render = library.lookupFunction<_RenderNative, KrepisRender>(
      'krepis_editor_render',
    );
    renderReferenceFlow = library
        .lookupFunction<_ReferenceFlowRenderNative, KrepisReferenceFlowRender>(
          'krepis_editor_render_reference_flow',
        );
    renderSpatial = library
        .lookupFunction<_SpatialRenderNative, KrepisSpatialRender>(
          'krepis_editor_render_spatial',
        );
    acquire = library.lookupFunction<_AcquireNative, KrepisAcquireDisplay>(
      'krepis_display_acquire',
    );
    release = library.lookupFunction<_ReleaseNative, KrepisRelease>(
      'krepis_display_release',
    );
    acquireOutline = library
        .lookupFunction<_OutlineNative, KrepisAcquireOutline>(
          'krepis_display_acquire_glyph_path',
        );
    releaseOutline = library.lookupFunction<_ReleaseNative, KrepisRelease>(
      'krepis_display_release_glyph_path',
    );
  }
}
