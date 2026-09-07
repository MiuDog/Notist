/// Notist 專案模組。

library;

import 'dart:ffi' as ffi;

final class KrepisTextEndpointNative extends ffi.Struct {
  @ffi.Uint64()
  external int blockIdHigh;

  @ffi.Uint64()
  external int blockIdLow;

  @ffi.Uint64()
  external int graphemeBoundary;

  @ffi.Uint32()
  external int affinity;

  @ffi.Uint32()
  external int reserved;
}

final class KrepisTextSelectionNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int contentRevision;

  external KrepisTextEndpointNative anchor;
  external KrepisTextEndpointNative focus;
}

final class KrepisFlowBlockRangeInputNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int firstBlockIdHigh;

  @ffi.Uint64()
  external int firstBlockIdLow;

  @ffi.Uint64()
  external int lastBlockIdHigh;

  @ffi.Uint64()
  external int lastBlockIdLow;
}

final class KrepisFlowBlockTargetInputNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int affinity;

  @ffi.Uint64()
  external int blockIdHigh;

  @ffi.Uint64()
  external int blockIdLow;
}

final class KrepisFlowBlockAttributesInputNative extends ffi.Struct {
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

  external ffi.Pointer<ffi.Uint8> infoUtf8;

  @ffi.Uint64()
  external int infoSize;
}

final class KrepisCommandApplicabilityNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int flags;

  @ffi.Uint64()
  external int contentRevision;
}

typedef KrepisGetTextSelection =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisTextSelectionNative>);
typedef KrepisSetTextSelection =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisTextSelectionNative>);
typedef KrepisSetBlockSelection =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<KrepisTextSelectionNative>);
typedef KrepisMoveFlowBlockRange =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      ffi.Pointer<KrepisFlowBlockRangeInputNative>,
      ffi.Pointer<KrepisFlowBlockTargetInputNative>,
      int,
    );
typedef KrepisConvertFlowBlock =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      int,
      ffi.Pointer<KrepisFlowBlockAttributesInputNative>,
      int,
    );
typedef KrepisGetCommandApplicability =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisCommandApplicabilityNative>,
    );
typedef KrepisApplyToggleShortcut =
    int Function(ffi.Pointer<ffi.Void>, int, int, ffi.Pointer<ffi.Uint32>);

typedef KrepisGetTextSelectionNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisTextSelectionNative>,
    );
typedef KrepisSetTextSelectionNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisTextSelectionNative>,
    );
typedef KrepisSetBlockSelectionNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisTextSelectionNative>,
    );
typedef KrepisMoveFlowBlockRangeNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Pointer<KrepisFlowBlockRangeInputNative>,
      ffi.Pointer<KrepisFlowBlockTargetInputNative>,
      ffi.Uint64,
    );
typedef KrepisConvertFlowBlockNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisFlowBlockAttributesInputNative>,
      ffi.Uint64,
    );
typedef KrepisGetCommandApplicabilityNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisCommandApplicabilityNative>,
    );
typedef KrepisApplyToggleShortcutNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint32>,
    );
