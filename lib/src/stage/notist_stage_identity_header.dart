import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

/// Notist Flow Stage 的產品識別與標題排版政策。
class NotistStageIdentityHeader extends StatelessWidget {
  const NotistStageIdentityHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return KlpStageHeader(
      projectName: 'Flows',
      sectionLabel: 'Flow',
      title: title,
      typeLabel: 'FLOW',
      wrapTitle: true,
      actions: actions,
    );
  }
}
