import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

/// 一套與 `KlpVisualStyle.defaultStyle` **每個維度都不同**的風格，只存在於測試裡。
///
/// Kallopis 只出貨 `default` 一套，各層也只有一個 preset——庫不替任何產品預先組好第二套
/// 外觀。但只有一套時，沒有任何東西能發現元件退回硬編碼：值是對的、畫面是對的，
/// 只是換 theme 時它不會跟著變，而且沒有徵兆。
///
/// 因此對照組由測試自己用各層的**建構子**組出來，不依賴任何出貨的 preset。
/// 它同時示範了消費者要換外觀時該怎麼做。
///
/// **切換到它若需要改動任何元件的程式碼，就代表該元件還在硬編碼風格。**
final KlpVisualStyle contrastingStyle = KlpVisualStyle.defaultStyle.copyWith(
  name: 'contrasting',

  // 顏色一樣取自色梯——連測試都不寫死色碼，否則色梯調整時這裡會悄悄變成孤兒。
  colors: KlpThemeData.ultraDark,

  // 全域等寬、行高收緊。
  typography: KlpTypographyTheme.proportional.copyWith(
    uiFamily: KlpTypographyTheme.proportional.monoFamily,
    bodyFamily: KlpTypographyTheme.proportional.monoFamily,
    bodyLeading: 1.4,
    headingLeading: 1.3,
    captionLeading: 1.3,
    labelTracking: 0,
    displayTracking: 0,
  ),

  // 高密度。
  spacing: KlpSpacingTheme.comfortableDensity.copyWith(
    hairline: 0,
    tight: 2,
    compact: 4,
    base: 8,
    comfortable: 8,
    loose: 12,
    section: 16,
    page: 16,
    controlPaddingX: 8,
    controlPaddingY: 2,
    containerPadding: 8,
    itemGap: 4,
    groupGap: 8,
    controlHeight: 24,
    controlHeightSmall: 20,
    controlHeightLarge: 30,
    iconSmall: 12,
    icon: 14,
    iconLarge: 18,
    chromeHeader: 36,
    chromeStatusBar: 22,
    chromeRail: 40,
    chromeTab: 24,
    iconButton: 22,
  ),

  // 全部直角，虛線更長更疏。
  shape: KlpShapeTheme.standardShape.copyWith(
    control: 0,
    card: 0,
    panel: 0,
    pill: 0,
    dashedLength: 6,
    dashedGap: 4,
    dashedOpacity: 1,
  ),

  // 完全沒有過場。
  motion: KlpMotionTheme.standardMotion.copyWith(
    stateTransition: Duration.zero,
    overlayEnter: Duration.zero,
    overlayExit: Duration.zero,
    standard: Curves.linear,
    emphasized: Curves.linear,
  ),

  // 用實線框分層而不是陰影。
  surface: KlpSurfaceTheme.elevated.copyWith(
    separation: KlpSurfaceSeparation.outline,
    overlayBlur: 0,
    overlaySpread: 0,
    overlayOffsetY: 0,
    overlayShadowOpacity: 0,
    scrimOpacity: 0.8,
  ),

  // 控制項一律帶實線框。
  components: KlpComponentTheme.inherited.copyWith(
    buttonRadius: 0,
    buttonBorderWidth: 1,
    fieldRadius: 0,
    fieldBorderWidth: 1,
    menuRadius: 0,
    cardRadius: 0,
    badgeRadius: 0,
  ),
);
