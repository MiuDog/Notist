/// Notist 專案模組。

library;

import 'dart:ffi' as ffi;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_editing_native.dart';
import 'package:notist/src/krepis/krepis_ink_native.dart';
import 'package:notist/src/krepis/krepis_native.dart';

void main() {
  test('matches the Krepis ABI 1.4 stable editing layouts', () {
    expect(KrepisNative.requiredAbiMinor, greaterThanOrEqualTo(4));
    expect(ffi.sizeOf<KrepisTextEndpointNative>(), 32);
    expect(ffi.sizeOf<KrepisTextSelectionNative>(), 80);
    expect(ffi.sizeOf<KrepisFlowBlockRangeInputNative>(), 40);
    expect(ffi.sizeOf<KrepisFlowBlockTargetInputNative>(), 24);
    expect(ffi.sizeOf<KrepisFlowBlockAttributesInputNative>(), 48);
    expect(ffi.sizeOf<KrepisCommandApplicabilityNative>(), 16);
  });

  test('matches the Krepis ABI 1.6 editor event layout', () {
    expect(ffi.sizeOf<KrepisEditorEvents>(), 8);
  });

  test('matches the Krepis ABI 1.7 Ink layouts', () {
    expect(ffi.sizeOf<KrepisInkBrushNative>(), 112);
    expect(ffi.sizeOf<KrepisInkOutlineVertexNative>(), 16);
    expect(ffi.sizeOf<KrepisInkRawSampleNative>(), 24);
    expect(ffi.sizeOf<KrepisInkPlacementTransformNative>(), 16);
    expect(ffi.sizeOf<KrepisInkCaptureBeginResultNative>(), 40);
    expect(ffi.sizeOf<KrepisInkCaptureCommitResultNative>(), 32);
  });
}
