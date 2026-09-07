/// Notist 專案模組。

library;

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';

import 'krepis_block.dart';
import 'krepis_ink.dart';
import 'krepis_ink_codec.dart';
import 'krepis_ink_native.dart';
import 'krepis_native.dart';

typedef KrepisInkStatusCheck = void Function(int status, String operation);

/// ABI 1.5/1.7 Ink bridge；preview 與 commit 共用 Krepis 的筆刷規則。
final class KrepisInkAdapter {
  KrepisInkAdapter(this._native, this._engine, this._check);

  static const int _outOfRange = 2;

  final KrepisNative _native;
  final ffi.Pointer<ffi.Void> _engine;
  final KrepisInkStatusCheck _check;
  ffi.Pointer<ffi.Void> _outlineEngine = ffi.nullptr;

  KrepisInkCaptureProjection begin({
    required KrepisInkBrushProjection brush,
    required int captureWidth26_6,
  }) {
    return using((arena) {
      final nativeBrush = arena<KrepisInkBrushNative>();
      final result = arena<KrepisInkCaptureBeginResultNative>();
      writeKrepisInkBrush(nativeBrush.ref, brush);
      result.ref.structSize = ffi.sizeOf<KrepisInkCaptureBeginResultNative>();
      _check(
        _native.beginInkCapture(_engine, nativeBrush, captureWidth26_6, result),
        '開始 Ink capture',
      );
      return KrepisInkCaptureProjection(
        handle: result.ref.handle,
        contentRevision: result.ref.contentRevision,
        brushId: formatKrepisRootId(
          result.ref.brushIdHigh,
          result.ref.brushIdLow,
        ),
      );
    });
  }

  void cancel(int handle) {
    _check(_native.cancelInkCapture(_engine, handle), '取消 Ink capture');
  }

  KrepisInkCommitProjection commit({
    required KrepisInkCaptureProjection capture,
    required String ownerBlockId,
    required List<KrepisInkRawSampleProjection> samples,
    required KrepisInkPlacementProjection placement,
    required int committedAtMs,
  }) {
    return using((arena) {
      final owner = parseKrepisStableId(ownerBlockId);
      final nativeSamples = arena<KrepisInkRawSampleNative>(samples.length);
      for (var index = 0; index < samples.length; index += 1) {
        final source = samples[index];
        nativeSamples[index]
          ..timeMs = source.timeMs
          ..y26_6 = source.y26_6
          ..xNormalized = source.xNormalized
          ..pressure = source.pressure
          ..tiltAltitude = source.tiltAltitude
          ..tiltAzimuth = source.tiltAzimuth;
      }
      final transform = arena<KrepisInkPlacementTransformNative>();
      transform.ref
        ..structSize = ffi.sizeOf<KrepisInkPlacementTransformNative>()
        ..horizontalScaleQ16_16 = placement.horizontalScaleQ16_16
        ..translationX26_6 = placement.translationX26_6
        ..translationY26_6 = placement.translationY26_6;
      final result = arena<KrepisInkCaptureCommitResultNative>();
      result.ref.structSize = ffi.sizeOf<KrepisInkCaptureCommitResultNative>();

      _check(
        _native.commitInkCapture(
          _engine,
          capture.handle,
          owner.$1,
          owner.$2,
          placement.position,
          nativeSamples,
          samples.length,
          transform,
          committedAtMs,
          result,
        ),
        '提交 Ink capture',
      );
      return KrepisInkCommitProjection(
        contentRevision: result.ref.contentRevision,
        strokeId: formatKrepisRootId(
          result.ref.strokeIdHigh,
          result.ref.strokeIdLow,
        ),
      );
    });
  }

  KrepisInkOutline outline({
    required List<KrepisInkPreviewSampleProjection> samples,
    required double captureBlockWidth,
    required double displayBlockWidth,
    required KrepisInkBrushProjection brush,
  }) {
    _ensureOutlineEngine();
    return using((arena) {
      final encoded = encodeKrepisInkPreviewSamples(samples);
      final nativeBytes = arena<ffi.Uint8>(
        encoded.isEmpty ? 1 : encoded.length,
      );
      if (encoded.isNotEmpty) {
        nativeBytes.asTypedList(encoded.length).setAll(0, encoded);
      }
      final nativeBrush = arena<KrepisInkBrushNative>();
      writeKrepisInkBrush(nativeBrush.ref, brush);
      final required = arena<ffi.Uint64>();
      final query = _native.buildInkOutline(
        _outlineEngine,
        nativeBytes,
        encoded.length,
        captureBlockWidth,
        displayBlockWidth,
        nativeBrush,
        ffi.nullptr,
        0,
        required,
      );
      if (query != 0 && query != _outOfRange) {
        _check(query, '查詢 Ink outline 容量');
      }
      if (required.value == 0) return const [];

      final vertices = arena<KrepisInkOutlineVertexNative>(required.value);
      _check(
        _native.buildInkOutline(
          _outlineEngine,
          nativeBytes,
          encoded.length,
          captureBlockWidth,
          displayBlockWidth,
          nativeBrush,
          vertices,
          required.value,
          required,
        ),
        '建立 Ink outline',
      );
      return [
        for (var index = 0; index < required.value; index += 1)
          Offset(vertices[index].x, vertices[index].y),
      ];
    });
  }

  void dispose() {
    if (_outlineEngine == ffi.nullptr) return;
    _check(
      _native.destroyInkOutlineEngine(_outlineEngine),
      '釋放 Ink outline engine',
    );
    _outlineEngine = ffi.nullptr;
  }

  void _ensureOutlineEngine() {
    if (_outlineEngine != ffi.nullptr) return;
    final slot = calloc<ffi.Pointer<ffi.Void>>();
    try {
      _check(
        _native.createInkOutlineEngine(
          KrepisNative.requiredAbiMajor,
          KrepisNative.requiredAbiMinor,
          slot,
        ),
        '建立 Ink outline engine',
      );
      _outlineEngine = slot.value;
    } finally {
      calloc.free(slot);
    }
  }
}
