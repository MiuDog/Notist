/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

/// Notist 專屬的工作區視覺組裝。
///
/// Rail、Dock 與 Stage 都使用 Kallopis 公開 primitive；產品擁有它們的組合及 panel
/// 可用性，不再依賴通用的 `IstWorkbenchScreen`。
final class NotistWorkbenchSurface extends StatelessWidget {
  const NotistWorkbenchSurface({
    super.key,
    required this.railTop,
    required this.railCenter,
    required this.railBottom,
    required this.stage,
    required this.panels,
    required this.layout,
    required this.onLayoutChanged,
    required this.leftConstraints,
    required this.rightConstraints,
  });

  final KlpRailItemGroup railTop;
  final KlpRailItemGroup railCenter;
  final KlpRailItemGroup railBottom;
  final KlpPanelFrame stage;
  final List<KlpDockPanel> panels;
  final KlpDockLayoutData layout;
  final ValueChanged<KlpDockLayoutData> onLayoutChanged;
  final KlpDockAreaConstraints leftConstraints;
  final KlpDockAreaConstraints rightConstraints;

  @override
  Widget build(BuildContext context) {
    final spacing = context.klp.space;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          // Frame 的 dock margin 位於可見 rail surface 之外；補回兩側 margin 後，
          // surface 才維持 48px＝32px 正方形 item＋左右各 8px inset。
          width: spacing.chromeRail + (spacing.dockMargin * 2),
          child: KlpNavigationRailFrame(
            child: KlpNavigationRail(
              top: railTop,
              center: railCenter,
              bottom: railBottom,
            ),
          ),
        ),
        Expanded(
          child: KlpDockLayout(
            stage: stage,
            panels: panels,
            layout: layout,
            onLayoutChanged: onLayoutChanged,
            leftConstraints: leftConstraints,
            rightConstraints: rightConstraints,
          ),
        ),
      ],
    );
  }
}
