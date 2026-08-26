import 'dart:ui';

enum KrepisInkWidthMode { constant, pressure, velocity, pressureAndVelocity }

final class KrepisInkBrushProjection {
  const KrepisInkBrushProjection({
    required this.widthMode,
    required this.baseWidth,
    this.pressureCurve = const [1, 1, 1, 1, 1],
    this.velocityCurve = const [1, 1, 1, 1, 1],
    this.velocityReference = 1000,
    this.smoothing = 0,
  });

  final KrepisInkWidthMode widthMode;
  final double baseWidth;
  final List<double> pressureCurve;
  final List<double> velocityCurve;
  final double velocityReference;
  final double smoothing;
}

final class KrepisInkRawSampleProjection {
  const KrepisInkRawSampleProjection({
    required this.timeMs,
    required this.y26_6,
    required this.xNormalized,
    required this.pressure,
    this.tiltAltitude = 0,
    this.tiltAzimuth = 0,
  });

  final int timeMs;
  final int y26_6;
  final int xNormalized;
  final int pressure;
  final int tiltAltitude;
  final int tiltAzimuth;
}

final class KrepisInkPreviewSampleProjection {
  const KrepisInkPreviewSampleProjection({
    required this.xNormalized,
    required this.yFixed,
    required this.pressure,
    required this.dtMs,
    this.tiltAltitude = 0,
    this.tiltAzimuth = 0,
  });

  final int xNormalized;
  final int yFixed;
  final int pressure;
  final int tiltAltitude;
  final int tiltAzimuth;
  final int dtMs;
}

final class KrepisInkCaptureProjection {
  const KrepisInkCaptureProjection({
    required this.handle,
    required this.contentRevision,
    required this.brushId,
  });

  final int handle;
  final int contentRevision;
  final String brushId;
}

final class KrepisInkCommitProjection {
  const KrepisInkCommitProjection({
    required this.contentRevision,
    required this.strokeId,
  });

  final int contentRevision;
  final String strokeId;
}

final class KrepisInkPlacementProjection {
  const KrepisInkPlacementProjection({
    this.position = 0,
    this.horizontalScaleQ16_16 = 1 << 16,
    this.translationX26_6 = 0,
    this.translationY26_6 = 0,
  });

  final int position;
  final int horizontalScaleQ16_16;
  final int translationX26_6;
  final int translationY26_6;
}

typedef KrepisInkOutline = List<Offset>;
