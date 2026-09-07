/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'krepis_block.dart';
import 'krepis_native.dart';

abstract final class KrepisBlockInputWriter {
  static ffi.Pointer<KrepisFlowBlockInput> write(
    List<KrepisFlowBlockDraft> blocks,
    Arena arena,
  ) {
    if (blocks.isEmpty) return ffi.nullptr.cast<KrepisFlowBlockInput>();

    final inputs = arena.allocate<KrepisFlowBlockInput>(
      ffi.sizeOf<KrepisFlowBlockInput>() * blocks.length,
    );
    for (var blockIndex = 0; blockIndex < blocks.length; blockIndex++) {
      _writeBlock(inputs[blockIndex], blocks[blockIndex], arena);
    }

    return inputs;
  }

  static void _writeBlock(
    KrepisFlowBlockInput target,
    KrepisFlowBlockDraft source,
    Arena arena,
  ) {
    final text = _allocateUtf8(source.text, arena);
    final info = _allocateUtf8(source.info, arena);
    final marks = source.marks.isEmpty
        ? ffi.nullptr.cast<KrepisInlineMarkInput>()
        : arena.allocate<KrepisInlineMarkInput>(
            ffi.sizeOf<KrepisInlineMarkInput>() * source.marks.length,
          );
    for (var markIndex = 0; markIndex < source.marks.length; markIndex++) {
      final sourceMark = source.marks[markIndex];
      final metadata = _allocateUtf8(sourceMark.metadata, arena);
      final targetMark = marks[markIndex];
      targetMark.structSize = ffi.sizeOf<KrepisInlineMarkInput>();
      targetMark.kind = sourceMark.kind.abiValue;
      targetMark.beginByte = sourceMark.beginByte;
      targetMark.endByte = sourceMark.endByte;
      targetMark.metadataUtf8 = metadata.pointer;
      targetMark.metadataSize = metadata.length;
    }

    target.structSize = ffi.sizeOf<KrepisFlowBlockInput>();
    target.kind = source.kind.abiValue;
    target.level = source.level;
    target.nestingDepth = source.nestingDepth;
    target.orderedStart = source.orderedStart;
    target.taskChecked = source.taskChecked ? 1 : 0;
    target.toggleCollapsed = source.toggleCollapsed ? 1 : 0;
    target.utf8 = text.pointer;
    target.utf8Size = text.length;
    target.infoUtf8 = info.pointer;
    target.infoSize = info.length;
    target.marks = marks;
    target.markCount = source.marks.length;
  }

  static ({ffi.Pointer<ffi.Uint8> pointer, int length}) _allocateUtf8(
    String value,
    Arena arena,
  ) {
    final encoded = utf8.encode(value);
    final pointer = arena.allocate<ffi.Uint8>(
      encoded.isEmpty ? 1 : encoded.length,
    );
    if (encoded.isNotEmpty) {
      pointer.asTypedList(encoded.length).setAll(0, encoded);
    }

    return (pointer: pointer, length: encoded.length);
  }
}
