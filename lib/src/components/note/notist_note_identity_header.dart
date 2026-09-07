// Notist 筆記側欄身分列。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 以筆記工作台核准列高約束共用的側欄身分列。
class NotistNoteIdentityHeader extends StatelessWidget {
  const NotistNoteIdentityHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.avatarLabel,
    this.avatarSemanticLabel,
    this.avatarImage,
  }) : assert(trailing == null || avatarLabel == null);

  final KlpIconData icon;
  final String title;
  final Widget? trailing;
  final String? avatarLabel;
  final String? avatarSemanticLabel;
  final ImageProvider? avatarImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.klp.space.controlHeightSmall,
      child: KlpSidebarIdentityHeader(
        icon: icon,
        title: title,
        trailing: trailing,
        avatarLabel: avatarLabel,
        avatarSemanticLabel: avatarSemanticLabel,
        avatarImage: avatarImage,
      ),
    );
  }
}
