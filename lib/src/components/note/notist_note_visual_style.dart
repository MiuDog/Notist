// Notist 筆記工作台視覺配方。

import 'package:kallopis/kallopis_foundation.dart';

/// 只調整 Notist 筆記工作台已核准的幾何語意，不加入文件、區塊或保存狀態。
abstract final class NotistNoteVisualStyle {
  static KlpVisualStyle apply(KlpVisualStyle base) {
    // 此配方刻意設定整套筆記密度；各語意分別賦值，不建立跨角色別名。
    final compact = base.spacing.space2 + base.spacing.space0_5;
    final spacing = base.spacing.copyWith(
      contentInlineGap: compact,
      contentStackGap: compact,
      contentInset: compact,
      controlContentGap: compact,
      controlInset: compact,
      actionGap: compact,
      chromeGap: compact,
      chromePanelInset: compact,
      chromeToolbarGap: compact,
      navigationItemInset: compact,
      navigationRailInset: compact,
      navigationRailItemGap: compact,
      overlayContentInset: compact,
      overlayHeadingGap: compact,
      overlayItemGap: compact,
      navigationSectionGap: compact - base.spacing.hairline,
      appFrameInset: compact / 2,
      workbenchContentInset: compact / 2,
      windowHeaderMargin: compact / 2,
      dockMargin: compact / 2,
      controlHeight: base.spacing.controlHeightLarge,
      controlHeightXSmall: base.spacing.space8 + base.spacing.space1,
      iconSmall: base.spacing.space4 + base.spacing.space1,
    );
    final layout = base.geometry.layout.copyWith(
      resizeHandleExtent: compact,
      overlayViewportInset: compact,
      railDropTargetExtent: compact,
      disclosureIconSize: compact,
      treeLeadingGap: compact,
      tooltipOffsetX: compact,
      windowHeaderHeight: base.spacing.space8 + base.spacing.space0_5,
      windowHeaderControlSize: base.spacing.space8,
    );
    final control = base.geometry.control.copyWith(
      pageBackgroundHitRadius: compact,
      presenceMarkerExtent: compact,
      colorPickerCursorRadius: compact,
      swatchExtent: compact,
      segmentedProgressHeight: compact,
    );

    return base.copyWith(
      name: 'note-workbench',
      spacing: spacing,
      geometry: base.geometry.copyWith(layout: layout, control: control),
    );
  }
}
