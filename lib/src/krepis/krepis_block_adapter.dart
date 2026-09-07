/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'krepis_block.dart';
import 'krepis_block_input_writer.dart';
import 'krepis_native.dart';

typedef KrepisStatusCheck = void Function(int status, String operation);

/// 將 C ABI 1.3 的 Block query／command 轉為 immutable Dart 投影。
final class KrepisBlockAdapter {
  const KrepisBlockAdapter(this._native, this._engine, this._check);

  static const int _ok = 0;
  static const int _outOfRange = 2;

  final KrepisNative _native;
  final ffi.Pointer<ffi.Void> _engine;
  final KrepisStatusCheck _check;

  List<KrepisFlowBlockProjection> readBlocks(int blockCount) {
    if (blockCount < 0) throw StateError('Krepis 回傳負數 Block count');

    return List.unmodifiable([
      for (var position = 0; position < blockCount; position++)
        _readBlock(position),
    ]);
  }

  /// 讀取 Block 的矩形。
  ///
  /// [visual] 為 true 時回傳**視覺**矩形（緊貼內容，相鄰之間留有間距），
  /// 供選取框、hover 與裝飾使用；為 false 時回傳**版面／命中**矩形
  /// （含 block_spacing，相鄰連續無縫），供命中測試使用。
  ///
  /// 兩者混用會出事：拿版面矩形畫框，框會比文字高一個間距；拿視覺矩形做
  /// 命中測試，區塊之間的留白會變成點不到的死區。
  KrepisFlowBlockRect readRect(
    int position,
    double viewportWidth,
    double scrollY, {
    bool visual = false,
  }) {
    final rect = calloc<KrepisRect>();
    try {
      _check(
        (visual ? _native.getFlowBlockVisualRect : _native.getFlowBlockRect)(
          _engine,
          position,
          viewportWidth,
          scrollY,
          rect,
        ),
        '讀取第 $position 個 Flow Block geometry',
      );
      return KrepisFlowBlockRect(
        x: rect.ref.x,
        y: rect.ref.y,
        width: rect.ref.width,
        height: rect.ref.height,
      );
    } finally {
      calloc.free(rect);
    }
  }

  void replace({
    required int expectedContentRevision,
    required int position,
    required int removeCount,
    required List<KrepisFlowBlockDraft> blocks,
    required int timestamp,
  }) {
    if (expectedContentRevision < 0 ||
        position < 0 ||
        removeCount < 0 ||
        timestamp < 0) {
      throw ArgumentError('Block replace 的 revision、位置、數量與時間不得為負數');
    }

    using((arena) {
      final inputs = KrepisBlockInputWriter.write(blocks, arena);

      // Provider 會複製全部 input，Dart arena 可在呼叫結束後安全釋放。
      _check(
        _native.replaceFlowBlocks(
          _engine,
          expectedContentRevision,
          position,
          removeCount,
          inputs,
          blocks.length,
          timestamp,
        ),
        '替換 Flow Blocks',
      );
    });
  }

  KrepisFlowBlockProjection _readBlock(int position) {
    final info = calloc<KrepisFlowBlockInfo>();
    try {
      info.ref.structSize = ffi.sizeOf<KrepisFlowBlockInfo>();
      _check(
        _native.getFlowBlockInfo(_engine, position, info),
        '讀取第 $position 個 Flow Block',
      );
      final value = info.ref;
      final marks = List<KrepisInlineMarkProjection>.unmodifiable([
        for (var markIndex = 0; markIndex < value.markCount; markIndex++)
          _readMark(position, markIndex),
      ]);

      return KrepisFlowBlockProjection(
        position: position,
        id: formatKrepisRootId(value.blockIdHigh, value.blockIdLow),
        kind: KrepisFlowBlockKind.fromAbi(value.kind),
        level: value.level,
        nestingDepth: value.nestingDepth,
        orderedStart: value.orderedStart,
        taskChecked: value.taskChecked != 0,
        toggleCollapsed: value.toggleCollapsed != 0,
        text: _copyUtf8(
          (bytes, capacity, required) => _native.copyFlowBlock(
            _engine,
            position,
            bytes,
            capacity,
            required,
          ),
          '讀取第 $position 個 Flow Block 文字',
        ),
        info: _copyUtf8(
          (bytes, capacity, required) => _native.copyFlowBlockInfo(
            _engine,
            position,
            bytes,
            capacity,
            required,
          ),
          '讀取第 $position 個 Flow Block info',
        ),
        marks: marks,
      );
    } finally {
      calloc.free(info);
    }
  }

  KrepisInlineMarkProjection _readMark(int blockPosition, int markIndex) {
    final info = calloc<KrepisInlineMarkInfo>();
    try {
      info.ref.structSize = ffi.sizeOf<KrepisInlineMarkInfo>();
      _check(
        _native.getInlineMarkInfo(_engine, blockPosition, markIndex, info),
        '讀取第 $blockPosition 個 Flow Block 的 mark $markIndex',
      );
      final value = info.ref;

      return KrepisInlineMarkProjection(
        kind: KrepisInlineMarkKind.fromAbi(value.kind),
        beginByte: value.beginByte,
        endByte: value.endByte,
        metadata: _copyUtf8(
          (bytes, capacity, required) => _native.copyInlineMarkMetadata(
            _engine,
            blockPosition,
            markIndex,
            bytes,
            capacity,
            required,
          ),
          '讀取第 $blockPosition 個 Flow Block 的 mark metadata',
        ),
      );
    } finally {
      calloc.free(info);
    }
  }

  String _copyUtf8(
    int Function(
      ffi.Pointer<ffi.Uint8> bytes,
      int capacity,
      ffi.Pointer<ffi.Uint64> required,
    )
    copy,
    String operation,
  ) {
    final required = calloc<ffi.Uint64>();
    try {
      final query = copy(ffi.nullptr, 0, required);
      if (query != _ok && query != _outOfRange) _check(query, operation);

      final byteCount = required.value;
      final bytes = calloc<ffi.Uint8>(byteCount == 0 ? 1 : byteCount);
      try {
        _check(copy(bytes, byteCount, required), operation);
        return utf8.decode(bytes.asTypedList(byteCount));
      } finally {
        calloc.free(bytes);
      }
    } finally {
      calloc.free(required);
    }
  }
}
