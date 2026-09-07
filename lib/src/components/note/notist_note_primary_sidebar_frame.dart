// Notist 筆記主側欄框架。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 以筆記工作台水平節奏組合身分列、導覽、Explorer 與 footer。
class NotistNotePrimarySidebarFrame extends StatelessWidget {
  const NotistNotePrimarySidebarFrame({
    super.key,
    this.header,
    this.navigation,
    required this.explorer,
    this.footer,
  });

  final Widget? header;
  final Widget? navigation;
  final Widget explorer;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return KlpPrimarySidebarFrame(
      padding: EdgeInsets.symmetric(horizontal: context.klp.space.contentInset),
      headerNavigationPadding: EdgeInsets.zero,
      headerNavigationGap: context.klp.space.tight,
      header: header,
      navigation: navigation,
      explorer: explorer,
      footer: footer,
    );
  }
}
