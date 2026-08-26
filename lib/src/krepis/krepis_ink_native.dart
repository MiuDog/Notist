import 'dart:ffi' as ffi;

final class KrepisInkBrushNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int widthMode;

  @ffi.Double()
  external double baseWidth;

  @ffi.Array(5)
  external ffi.Array<ffi.Double> pressureCurve;

  @ffi.Array(5)
  external ffi.Array<ffi.Double> velocityCurve;

  @ffi.Double()
  external double velocityReference;

  @ffi.Double()
  external double smoothing;
}

final class KrepisInkOutlineVertexNative extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;
}

final class KrepisInkRawSampleNative extends ffi.Struct {
  @ffi.Uint64()
  external int timeMs;

  @ffi.Int32()
  external int y26_6;

  @ffi.Uint16()
  external int xNormalized;

  @ffi.Uint8()
  external int pressure;

  @ffi.Uint8()
  external int tiltAltitude;

  @ffi.Uint8()
  external int tiltAzimuth;

  @ffi.Array(7)
  external ffi.Array<ffi.Uint8> reserved;
}

final class KrepisInkPlacementTransformNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int horizontalScaleQ16_16;

  @ffi.Int32()
  external int translationX26_6;

  @ffi.Int32()
  external int translationY26_6;
}

final class KrepisInkCaptureBeginResultNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int handle;

  @ffi.Uint64()
  external int contentRevision;

  @ffi.Uint64()
  external int brushIdHigh;

  @ffi.Uint64()
  external int brushIdLow;
}

final class KrepisInkCaptureCommitResultNative extends ffi.Struct {
  @ffi.Uint32()
  external int structSize;

  @ffi.Uint32()
  external int reserved;

  @ffi.Uint64()
  external int contentRevision;

  @ffi.Uint64()
  external int strokeIdHigh;

  @ffi.Uint64()
  external int strokeIdLow;
}

typedef KrepisInkOutlineCreate =
    int Function(int, int, ffi.Pointer<ffi.Pointer<ffi.Void>>);
typedef KrepisInkOutlineDestroy = int Function(ffi.Pointer<ffi.Void>);
typedef KrepisInkOutlineBuild =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      double,
      double,
      ffi.Pointer<KrepisInkBrushNative>,
      ffi.Pointer<KrepisInkOutlineVertexNative>,
      int,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisBeginInkCapture =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisInkBrushNative>,
      int,
      ffi.Pointer<KrepisInkCaptureBeginResultNative>,
    );
typedef KrepisCancelInkCapture = int Function(ffi.Pointer<ffi.Void>, int);
typedef KrepisCommitInkCapture =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      int,
      int,
      int,
      ffi.Pointer<KrepisInkRawSampleNative>,
      int,
      ffi.Pointer<KrepisInkPlacementTransformNative>,
      int,
      ffi.Pointer<KrepisInkCaptureCommitResultNative>,
    );

typedef KrepisInkOutlineCreateNative =
    ffi.Uint32 Function(
      ffi.Uint16,
      ffi.Uint16,
      ffi.Pointer<ffi.Pointer<ffi.Void>>,
    );
typedef KrepisInkOutlineDestroyNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>);
typedef KrepisInkOutlineBuildNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Double,
      ffi.Double,
      ffi.Pointer<KrepisInkBrushNative>,
      ffi.Pointer<KrepisInkOutlineVertexNative>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint64>,
    );
typedef KrepisBeginInkCaptureNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<KrepisInkBrushNative>,
      ffi.Int32,
      ffi.Pointer<KrepisInkCaptureBeginResultNative>,
    );
typedef KrepisCancelInkCaptureNative =
    ffi.Uint32 Function(ffi.Pointer<ffi.Void>, ffi.Uint64);
typedef KrepisCommitInkCaptureNative =
    ffi.Uint32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<KrepisInkRawSampleNative>,
      ffi.Uint64,
      ffi.Pointer<KrepisInkPlacementTransformNative>,
      ffi.Uint64,
      ffi.Pointer<KrepisInkCaptureCommitResultNative>,
    );
