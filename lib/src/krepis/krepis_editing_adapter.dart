/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'krepis_block.dart';
import 'krepis_editing.dart';
import 'krepis_editing_native.dart';
import 'krepis_native.dart';

typedef KrepisEditingStatusCheck = void Function(int status, String operation);

/// 將 ABI 1.4 stable editing command 轉成 immutable Dart intent 與投影。
final class KrepisEditingAdapter {
  const KrepisEditingAdapter(this._native, this._engine, this._check);

  static const int _selectionCanReplace = 1 << 0;
  static const int _selectionRangeHasMoveTarget = 1 << 1;
  static const int _anchorCanConvert = 1 << 2;
  static const int _knownApplicabilityFlags =
      _selectionCanReplace | _selectionRangeHasMoveTarget | _anchorCanConvert;

  final KrepisNative _native;
  final ffi.Pointer<ffi.Void> _engine;
  final KrepisEditingStatusCheck _check;

  KrepisTextSelectionProjection readSelection() {
    final value = calloc<KrepisTextSelectionNative>();
    try {
      value.ref.structSize = ffi.sizeOf<KrepisTextSelectionNative>();
      _check(
        _native.getTextSelection(_engine, value),
        '讀取 stable text selection',
      );

      return _selectionFromNative(value.ref);
    } finally {
      calloc.free(value);
    }
  }

  KrepisCommandApplicabilityProjection readApplicability() {
    final value = calloc<KrepisCommandApplicabilityNative>();
    try {
      value.ref.structSize = ffi.sizeOf<KrepisCommandApplicabilityNative>();
      _check(
        _native.getCommandApplicability(_engine, value),
        '讀取 editing command applicability',
      );
      final flags = value.ref.flags & _knownApplicabilityFlags;

      return KrepisCommandApplicabilityProjection(
        contentRevision: value.ref.contentRevision,
        selectionCanReplace: flags & _selectionCanReplace != 0,
        selectionRangeHasMoveTarget: flags & _selectionRangeHasMoveTarget != 0,
        anchorCanConvert: flags & _anchorCanConvert != 0,
      );
    } finally {
      calloc.free(value);
    }
  }

  void setSelection(KrepisTextSelectionProjection selection) {
    final value = calloc<KrepisTextSelectionNative>();
    try {
      _writeSelection(value.ref, selection);
      _check(
        _native.setTextSelection(_engine, value),
        '設定 stable text selection',
      );
    } finally {
      calloc.free(value);
    }
  }

  void setBlockSelection(KrepisTextSelectionProjection selection) {
    final value = calloc<KrepisTextSelectionNative>();
    try {
      _writeSelection(value.ref, selection);
      _check(
        _native.setBlockSelection(_engine, value),
        '設定 stable Block selection',
      );
    } finally {
      calloc.free(value);
    }
  }

  void move({
    required int expectedContentRevision,
    required KrepisFlowBlockRange source,
    required KrepisFlowBlockTarget target,
    required int timestamp,
  }) {
    final nativeSource = calloc<KrepisFlowBlockRangeInputNative>();
    final nativeTarget = calloc<KrepisFlowBlockTargetInputNative>();
    try {
      final first = _parseId(source.firstBlockId);
      final last = _parseId(source.lastBlockId);
      final anchor = _parseId(target.blockId);
      nativeSource.ref
        ..structSize = ffi.sizeOf<KrepisFlowBlockRangeInputNative>()
        ..firstBlockIdHigh = first.$1
        ..firstBlockIdLow = first.$2
        ..lastBlockIdHigh = last.$1
        ..lastBlockIdLow = last.$2;
      nativeTarget.ref
        ..structSize = ffi.sizeOf<KrepisFlowBlockTargetInputNative>()
        ..affinity = target.affinity.index
        ..blockIdHigh = anchor.$1
        ..blockIdLow = anchor.$2;

      _check(
        _native.moveFlowBlockRange(
          _engine,
          expectedContentRevision,
          nativeSource,
          nativeTarget,
          timestamp,
        ),
        '移動 stable Flow Block range',
      );
    } finally {
      calloc.free(nativeTarget);
      calloc.free(nativeSource);
    }
  }

  void convert({
    required int expectedContentRevision,
    required String blockId,
    required KrepisFlowBlockAttributes attributes,
    required int timestamp,
  }) {
    using((arena) {
      final id = _parseId(blockId);
      final info = utf8.encode(attributes.info);
      final infoBytes = arena<ffi.Uint8>(info.isEmpty ? 1 : info.length);
      if (info.isNotEmpty) infoBytes.asTypedList(info.length).setAll(0, info);
      final value = arena<KrepisFlowBlockAttributesInputNative>();
      value.ref
        ..structSize = ffi.sizeOf<KrepisFlowBlockAttributesInputNative>()
        ..kind = attributes.kind.abiValue
        ..level = attributes.level
        ..nestingDepth = attributes.nestingDepth
        ..orderedStart = attributes.orderedStart
        ..taskChecked = attributes.taskChecked ? 1 : 0
        ..toggleCollapsed = attributes.toggleCollapsed ? 1 : 0
        ..infoUtf8 = infoBytes
        ..infoSize = info.length;

      _check(
        _native.convertFlowBlock(
          _engine,
          expectedContentRevision,
          id.$1,
          id.$2,
          value,
          timestamp,
        ),
        '轉換 stable Flow Block',
      );
    });
  }

  KrepisTextSelectionProjection _selectionFromNative(
    KrepisTextSelectionNative value,
  ) {
    return KrepisTextSelectionProjection(
      contentRevision: value.contentRevision,
      anchor: _endpointFromNative(value.anchor),
      focus: _endpointFromNative(value.focus),
    );
  }

  KrepisTextEndpointProjection _endpointFromNative(
    KrepisTextEndpointNative value,
  ) {
    if (value.affinity < 0 ||
        value.affinity >= KrepisTextAffinity.values.length) {
      throw StateError('Krepis 回傳未知 text affinity：${value.affinity}');
    }

    return KrepisTextEndpointProjection(
      blockId: formatKrepisRootId(value.blockIdHigh, value.blockIdLow),
      graphemeBoundary: value.graphemeBoundary,
      affinity: KrepisTextAffinity.values[value.affinity],
    );
  }

  void _writeSelection(
    KrepisTextSelectionNative target,
    KrepisTextSelectionProjection source,
  ) {
    target
      ..structSize = ffi.sizeOf<KrepisTextSelectionNative>()
      ..contentRevision = source.contentRevision;
    _writeEndpoint(target.anchor, source.anchor);
    _writeEndpoint(target.focus, source.focus);
  }

  void _writeEndpoint(
    KrepisTextEndpointNative target,
    KrepisTextEndpointProjection source,
  ) {
    final id = _parseId(source.blockId);
    target
      ..blockIdHigh = id.$1
      ..blockIdLow = id.$2
      ..graphemeBoundary = source.graphemeBoundary
      ..affinity = source.affinity.index;
  }

  (int, int) _parseId(String value) {
    if (!RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(value)) {
      throw FormatException('Krepis stable ID 必須是 32 位十六進位字串', value);
    }
    final high = BigInt.parse(value.substring(0, 16), radix: 16).toSigned(64);
    final low = BigInt.parse(value.substring(16), radix: 16).toSigned(64);
    return (high.toInt(), low.toInt());
  }
}
