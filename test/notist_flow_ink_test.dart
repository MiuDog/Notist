/// Notist 專案模組。

library;

import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/krepis/krepis_display.dart';
import 'package:notist/src/krepis/notist_flow_editor.dart';

import 'support/keyboard_krepis_authority.dart';

void main() {
  testWidgets('Ink mode previews through Krepis and commits on pointer up', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: KlpAppScreen(
            child: NotistFlowEditor(
              filePath: r'C:\Notist dogfood\ink.krdf',
              opener: (request) async => authority,
              inkEnabled: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final editor = find.byKey(const ValueKey('notist-krepis-flow-editor'));
    final origin = tester.getTopLeft(editor);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.down(origin + const Offset(80, 28));
    await gesture.moveTo(origin + const Offset(120, 36));

    await tester.pump();

    expect(authority.inkBeginCount, 1);
    expect(
      find.byKey(const ValueKey('notist-note-ink-preview')),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pump();

    expect(authority.inkCommitCount, 1);
    expect(find.byKey(const ValueKey('notist-note-ink-preview')), findsNothing);
  });

  testWidgets(
    'Stylus pointer does not create Ink when Notist stage disables it',
    (tester) async {
      final authority = KeyboardKrepisAuthority();
      await tester.pumpWidget(
        KlpApp(
          showWindowHeader: false,
          home: KlpPanelFrame(
            content: KlpAppScreen(
              child: NotistFlowEditor(
                filePath: r'C:\Notist dogfood\ink.krdf',
                opener: (request) async => authority,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final editor = find.byKey(const ValueKey('notist-krepis-flow-editor'));
      final origin = tester.getTopLeft(editor);
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.stylus,
      );
      addTearDown(gesture.removePointer);
      await gesture.down(origin + const Offset(80, 28));
      await gesture.moveTo(origin + const Offset(120, 36));

      await tester.pump();
      expect(authority.inkBeginCount, 0);
      expect(authority.inkCommitCount, 0);
      expect(
        find.byKey(const ValueKey('notist-note-ink-preview')),
        findsNothing,
      );

      await gesture.up();
      await tester.pump();
      expect(authority.inkBeginCount, 0);
      expect(authority.inkCommitCount, 0);
      expect(
        find.byKey(const ValueKey('notist-note-ink-preview')),
        findsNothing,
      );
    },
  );

  testWidgets('committed Ink polygon is painted as a closed filled path', (
    tester,
  ) async {
    const boundaryKey = ValueKey('krepis-polygon-boundary');
    final authority = KeyboardKrepisAuthority(
      displayFrame: const KrepisDisplayFrame(2, [
        KrepisDrawFilledPolygon(0xff336699, [
          KrepisDisplayPoint(150, 150),
          KrepisDisplayPoint(250, 150),
          KrepisDisplayPoint(150, 250),
        ]),
      ]),
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: KlpApp(
          showWindowHeader: false,
          home: KlpPanelFrame(
            content: KlpAppScreen(
              child: NotistFlowEditor(
                filePath: r'C:\Notist dogfood\ink.krdf',
                opener: (request) async => authority,
                inkEnabled: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    final image = await tester.runAsync(boundary.toImage);
    expect(image, isNotNull);
    final renderedImage = image!;
    final bytes = await tester.runAsync(
      () => renderedImage.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final editorOrigin = tester.getTopLeft(
      find.byKey(const ValueKey('notist-krepis-flow-editor')),
    );
    final boundaryOrigin = tester.getTopLeft(find.byKey(boundaryKey));
    final sample = editorOrigin - boundaryOrigin + const Offset(160, 160);
    final offset =
        (sample.dy.floor() * renderedImage.width + sample.dx.floor()) * 4;

    expect(bytes, isNotNull);
    expect(bytes!.getUint8(offset), 0x33);
    expect(bytes.getUint8(offset + 1), 0x66);
    expect(bytes.getUint8(offset + 2), 0x99);
    expect(bytes.getUint8(offset + 3), 0xff);
    renderedImage.dispose();
  });
}
