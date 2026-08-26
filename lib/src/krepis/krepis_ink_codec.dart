import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'krepis_ink.dart';
import 'krepis_ink_native.dart';

void writeKrepisInkBrush(
  KrepisInkBrushNative target,
  KrepisInkBrushProjection source,
) {
  if (source.pressureCurve.length != 5 || source.velocityCurve.length != 5) {
    throw ArgumentError('Ink response curve 必須恰有五個控制點');
  }
  target
    ..structSize = ffi.sizeOf<KrepisInkBrushNative>()
    ..widthMode = source.widthMode.index
    ..baseWidth = source.baseWidth
    ..velocityReference = source.velocityReference
    ..smoothing = source.smoothing;
  for (var index = 0; index < 5; index += 1) {
    target.pressureCurve[index] = source.pressureCurve[index];
    target.velocityCurve[index] = source.velocityCurve[index];
  }
}

Uint8List encodeKrepisInkPreviewSamples(
  List<KrepisInkPreviewSampleProjection> samples,
) {
  final output = Uint8List(samples.length * 9);
  final data = ByteData.sublistView(output);
  for (var index = 0; index < samples.length; index += 1) {
    final sample = samples[index];
    final offset = index * 9;
    data.setUint16(offset, sample.xNormalized, Endian.little);
    data.setInt16(offset + 2, sample.yFixed, Endian.little);
    data.setUint8(offset + 4, sample.pressure);
    data.setUint8(offset + 5, sample.tiltAltitude);
    data.setUint8(offset + 6, sample.tiltAzimuth);
    data.setUint16(offset + 7, sample.dtMs, Endian.little);
  }
  return output;
}

(int, int) parseKrepisStableId(String value) {
  if (!RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(value)) {
    throw FormatException('Krepis stable ID 必須是 32 位十六進位字串', value);
  }
  final high = BigInt.parse(value.substring(0, 16), radix: 16).toSigned(64);
  final low = BigInt.parse(value.substring(16), radix: 16).toSigned(64);
  return (high.toInt(), low.toInt());
}
