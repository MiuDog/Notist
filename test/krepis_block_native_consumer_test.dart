/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_block_adapter.dart';
import 'package:notist/src/krepis/krepis_editing.dart';
import 'package:notist/src/krepis/krepis_editing_adapter.dart';
import 'package:notist/src/krepis/krepis_display.dart';
import 'package:notist/src/krepis/krepis_ink.dart';
import 'package:notist/src/krepis/krepis_ink_adapter.dart';
import 'package:notist/src/krepis/krepis_native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final enabled =
      Platform.isWindows &&
      Platform.environment['NOTIST_KREPIS_NATIVE_TEST'] == '1';

  test(
    'reads and mutates structured Blocks through the real ABI 1.11 DLL',
    () async {
      final native = KrepisNative.open();
      final engineSlot = calloc<ffi.Pointer<ffi.Void>>();
      try {
        expect(native.createNegotiatedEngine(engineSlot), 0);
        final engine = engineSlot.value;
        final initial = utf8.encode('old');
        final initialBytes = calloc<ffi.Uint8>(initial.length);
        final state = calloc<KrepisEditorState>();
        final events = calloc<KrepisEditorEvents>();
        final fontData = await rootBundle.load(
          'packages/kallopis/assets/fonts/IBMPlexSansTC-Regular.ttf',
        );
        final font = fontData.buffer.asUint8List(
          fontData.offsetInBytes,
          fontData.lengthInBytes,
        );
        final fontBytes = calloc<ffi.Uint8>(font.length);
        try {
          fontBytes.asTypedList(font.length).setAll(0, font);
          expect(native.registerFont(engine, 1, fontBytes, font.length, 0), 0);
          initialBytes.asTypedList(initial.length).setAll(0, initial);
          expect(native.initialize(engine, initialBytes, initial.length), 0);
          events.ref.structSize = ffi.sizeOf<KrepisEditorEvents>();
          expect(native.consumeEvents(engine, events), 0);
          expect(events.ref.flags, 0);
          state.ref.structSize = ffi.sizeOf<KrepisEditorState>();
          expect(native.getState(engine, state), 0);

          final adapter = KrepisBlockAdapter(native, engine, (
            status,
            operation,
          ) {
            if (status != 0) {
              throw StateError('$operation 失敗（Krepis status $status）');
            }
          });
          final baseRevision = state.ref.contentRevision;
          adapter.replace(
            expectedContentRevision: baseRevision,
            position: 0,
            removeCount: 1,
            timestamp: 1,
            blocks: const [
              KrepisFlowBlockDraft(
                kind: KrepisFlowBlockKind.heading,
                text: '規格',
                level: 2,
              ),
              KrepisFlowBlockDraft(
                kind: KrepisFlowBlockKind.paragraph,
                text: 'consumer',
                marks: [
                  KrepisInlineMarkDraft(
                    kind: KrepisInlineMarkKind.strong,
                    beginByte: 0,
                    endByte: 8,
                  ),
                ],
              ),
            ],
          );

          final blocks = adapter.readBlocks(2);
          expect(blocks.map((block) => block.kind), [
            KrepisFlowBlockKind.heading,
            KrepisFlowBlockKind.paragraph,
          ]);
          expect(blocks.map((block) => block.text), ['規格', 'consumer']);
          expect(blocks[0].level, 2);
          expect(blocks[0].id, hasLength(32));
          expect(blocks[1].marks.single.kind, KrepisInlineMarkKind.strong);
          final firstRect = adapter.readRect(0, 640, 0);
          expect(firstRect.width, greaterThan(0));
          expect(firstRect.height, greaterThan(0));

          state.ref.structSize = ffi.sizeOf<KrepisEditorState>();
          expect(native.getState(engine, state), 0);
          expect(
            () => adapter.replace(
              expectedContentRevision: state.ref.contentRevision,
              position: 1,
              removeCount: 1,
              timestamp: 2,
              blocks: const [
                KrepisFlowBlockDraft(
                  kind: KrepisFlowBlockKind.paragraph,
                  text: 'bad',
                  marks: [
                    KrepisInlineMarkDraft(
                      kind: KrepisInlineMarkKind.strong,
                      beginByte: 0,
                      endByte: 99,
                    ),
                  ],
                ),
              ],
            ),
            throwsStateError,
          );
          expect(adapter.readBlocks(2).map((block) => block.text), [
            '規格',
            'consumer',
          ]);

          expect(
            () => adapter.replace(
              expectedContentRevision: baseRevision,
              position: 0,
              removeCount: 1,
              timestamp: 3,
              blocks: const [
                KrepisFlowBlockDraft(
                  kind: KrepisFlowBlockKind.paragraph,
                  text: 'stale',
                ),
              ],
            ),
            throwsStateError,
          );
          expect(adapter.readBlocks(2).map((block) => block.text), [
            '規格',
            'consumer',
          ]);

          state.ref.structSize = ffi.sizeOf<KrepisEditorState>();
          expect(native.getState(engine, state), 0);
          final editing = KrepisEditingAdapter(native, engine, (
            status,
            operation,
          ) {
            if (status != 0) {
              throw StateError('$operation 失敗（Krepis status $status）');
            }
          });
          final beforeEditing = adapter.readBlocks(2);
          final endpoint = KrepisTextEndpointProjection(
            blockId: beforeEditing.first.id,
            graphemeBoundary: 0,
            affinity: KrepisTextAffinity.downstream,
          );
          editing.setSelection(
            KrepisTextSelectionProjection(
              contentRevision: state.ref.contentRevision,
              anchor: endpoint,
              focus: endpoint,
            ),
          );
          final roundTrip = editing.readSelection();
          final applicability = editing.readApplicability();
          expect(roundTrip.anchor.blockId, beforeEditing.first.id);
          expect(roundTrip.focus.blockId, beforeEditing.first.id);
          expect(applicability.contentRevision, state.ref.contentRevision);
          expect(applicability.anchorCanConvert, isTrue);
          expect(applicability.selectionRangeHasMoveTarget, isTrue);

          final geometrySelection = KrepisTextSelectionProjection(
            contentRevision: state.ref.contentRevision,
            anchor: endpoint,
            focus: KrepisTextEndpointProjection(
              blockId: beforeEditing.last.id,
              graphemeBoundary: 4,
              affinity: KrepisTextAffinity.downstream,
            ),
          );
          editing.setSelection(geometrySelection);
          final geometryCount = calloc<ffi.Uint64>();
          try {
            expect(
              native.getTextSelectionRects(
                engine,
                640,
                0,
                ffi.nullptr,
                0,
                geometryCount,
              ),
              2,
            );
            expect(geometryCount.value, 2);
            final geometry = calloc<KrepisRect>(geometryCount.value);
            try {
              expect(
                native.getTextSelectionRects(
                  engine,
                  640,
                  0,
                  geometry,
                  geometryCount.value,
                  geometryCount,
                ),
                0,
              );
              expect(geometry[0].width, greaterThan(0));
              expect(geometry[1].y, greaterThan(geometry[0].y));
            } finally {
              calloc.free(geometry);
            }
          } finally {
            calloc.free(geometryCount);
          }

          editing.setBlockSelection(
            KrepisTextSelectionProjection(
              contentRevision: state.ref.contentRevision,
              anchor: endpoint,
              focus: endpoint,
            ),
          );
          state.ref.structSize = ffi.sizeOf<KrepisEditorState>();
          expect(native.getState(engine, state), 0);
          expect(state.ref.flags & 8, 8);
          expect(native.backspace(engine, 4), 5);
          editing.setSelection(
            KrepisTextSelectionProjection(
              contentRevision: state.ref.contentRevision,
              anchor: endpoint,
              focus: endpoint,
            ),
          );

          editing.convert(
            expectedContentRevision: state.ref.contentRevision,
            blockId: beforeEditing.first.id,
            attributes: KrepisFlowBlockAttributes.fromBlock(
              beforeEditing.first,
              kind: KrepisFlowBlockKind.blockQuote,
            ),
            timestamp: 4,
          );
          state.ref.structSize = ffi.sizeOf<KrepisEditorState>();
          expect(native.getState(engine, state), 0);
          editing.move(
            expectedContentRevision: state.ref.contentRevision,
            source: KrepisFlowBlockRange(
              firstBlockId: beforeEditing.first.id,
              lastBlockId: beforeEditing.first.id,
            ),
            target: KrepisFlowBlockTarget(
              blockId: beforeEditing.last.id,
              affinity: KrepisBlockTargetAffinity.after,
            ),
            timestamp: 5,
          );
          final afterEditing = adapter.readBlocks(2);
          expect(afterEditing.map((block) => block.id), [
            beforeEditing.last.id,
            beforeEditing.first.id,
          ]);
          expect(afterEditing.last.kind, KrepisFlowBlockKind.blockQuote);

          final ink = KrepisInkAdapter(native, engine, (status, operation) {
            if (status != 0) {
              throw StateError('$operation 失敗（Krepis status $status）');
            }
          });
          try {
            const brush = KrepisInkBrushProjection(
              widthMode: KrepisInkWidthMode.constant,
              baseWidth: 2,
            );
            final outline = ink.outline(
              samples: const [
                KrepisInkPreviewSampleProjection(
                  xNormalized: 0,
                  yFixed: 0,
                  pressure: 255,
                  dtMs: 0,
                ),
                KrepisInkPreviewSampleProjection(
                  xNormalized: 65535,
                  yFixed: 0,
                  pressure: 255,
                  dtMs: 10,
                ),
              ],
              captureBlockWidth: 10,
              displayBlockWidth: 10,
              brush: brush,
            );
            expect(outline, hasLength(18));

            final capture = ink.begin(brush: brush, captureWidth26_6: 6400);
            final committed = ink.commit(
              capture: capture,
              ownerBlockId: afterEditing.first.id,
              samples: const [
                KrepisInkRawSampleProjection(
                  timeMs: 100,
                  y26_6: 0,
                  xNormalized: 0,
                  pressure: 255,
                ),
                KrepisInkRawSampleProjection(
                  timeMs: 110,
                  y26_6: 640,
                  xNormalized: 65535,
                  pressure: 255,
                ),
              ],
              placement: const KrepisInkPlacementProjection(),
              committedAtMs: 120,
            );
            expect(committed.strokeId, hasLength(32));
            expect(
              committed.contentRevision,
              greaterThan(capture.contentRevision),
            );

            final frameToken = calloc<ffi.Uint64>();
            final displaySpan = calloc<KrepisDisplaySpan>();
            try {
              expect(native.render(engine, 640, 480, 0, frameToken), 0);
              displaySpan.ref.structSize = ffi.sizeOf<KrepisDisplaySpan>();
              expect(native.acquire(engine, displaySpan), 0);
              try {
                final bytes = Uint8List.fromList(
                  displaySpan.ref.data.asTypedList(displaySpan.ref.byteSize),
                );
                final frame = decodeKrepisDisplay(bytes);
                expect(frame.token, frameToken.value);
                expect(
                  frame.commands.whereType<KrepisDrawFilledPolygon>(),
                  isNotEmpty,
                );
                _saveEvidenceFileIfRequested(native, engine);
              } finally {
                expect(native.release(engine, displaySpan.ref.lease), 0);
              }
            } finally {
              calloc.free(displaySpan);
              calloc.free(frameToken);
            }
          } finally {
            ink.dispose();
          }
        } finally {
          calloc.free(fontBytes);
          calloc.free(events);
          calloc.free(state);
          calloc.free(initialBytes);
          if (engineSlot.value != ffi.nullptr) {
            expect(native.destroy(engineSlot.value), 0);
          }
        }
      } finally {
        calloc.free(engineSlot);
      }
    },
    skip: enabled ? false : '需要 Windows Krepis ABI 1.11 DLL gate',
  );
}

void _saveEvidenceFileIfRequested(
  KrepisNative native,
  ffi.Pointer<ffi.Void> engine,
) {
  final path = Platform.environment['NOTIST_KREPIS_EVIDENCE_PATH'];
  if (path == null || path.isEmpty) return;

  // 將實際含 committed Ink 的文件保存到 build，供 Release 實機驗證使用。
  Directory(File(path).parent.path).createSync(recursive: true);
  final encodedPath = utf8.encode(path);
  final pathBytes = calloc<ffi.Uint8>(encodedPath.length);
  try {
    pathBytes.asTypedList(encodedPath.length).setAll(0, encodedPath);
    expect(native.saveFile(engine, pathBytes, encodedPath.length), 0);
  } finally {
    calloc.free(pathBytes);
  }
}
