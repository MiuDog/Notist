import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  test('note density recipe preserves established spacing and geometry', () {
    final base = KlpVisualStyle.defaultStyle;
    final note = NotistNoteVisualStyle.apply(base);
    final spacing = note.spacing;
    final control = note.geometry.control;
    final layout = note.geometry.layout;
    final densityValues = [
      spacing.contentInlineGap,
      spacing.contentStackGap,
      spacing.contentInset,
      spacing.controlContentGap,
      spacing.controlInset,
      spacing.actionGap,
      spacing.chromeGap,
      spacing.chromePanelInset,
      spacing.chromeToolbarGap,
      spacing.navigationItemInset,
      spacing.navigationRailInset,
      spacing.navigationRailItemGap,
      spacing.overlayContentInset,
      spacing.overlayHeadingGap,
      spacing.overlayItemGap,
      control.pageBackgroundHitRadius,
      control.presenceMarkerExtent,
      control.colorPickerCursorRadius,
      control.swatchExtent,
      control.segmentedProgressHeight,
      layout.resizeHandleExtent,
      layout.overlayViewportInset,
      layout.railDropTargetExtent,
      layout.disclosureIconSize,
      layout.treeLeadingGap,
      layout.tooltipOffsetX,
    ];
    expect(densityValues, everyElement(10));
    expect([
      spacing.appFrameInset,
      spacing.workbenchContentInset,
      spacing.windowHeaderMargin,
      spacing.dockMargin,
    ], everyElement(5));
    expect(spacing.navigationSectionGap, 10 - base.spacing.hairline);
    expect(layout.windowHeaderHeight, 34);
    expect(layout.windowHeaderControlSize, 32);
    expect(base.spacing.contentInlineGap, 8);
    expect(base.geometry.control.colorPickerCursorRadius, 8);
    expect(note.colors, same(base.colors));
  });
}
