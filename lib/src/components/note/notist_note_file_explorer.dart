// Notist 筆記檔案瀏覽器。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 使用筆記工作台分區內距的檔案瀏覽器。
class NotistNoteFileExplorer extends StatelessWidget {
  const NotistNoteFileExplorer({
    super.key,
    required this.sections,
    this.expandedSectionIds,
    this.expandedItemIds,
    this.selectedId,
    this.onSectionToggle,
    this.onItemToggle,
    this.onItemSelected,
    this.indent,
    this.emptyStateSections = const [],
    this.scrollController,
  });

  final List<KlpFileExplorerSection> sections;
  final Set<String>? expandedSectionIds;
  final Set<String>? expandedItemIds;
  final String? selectedId;
  final ValueChanged<String>? onSectionToggle;
  final ValueChanged<String>? onItemToggle;
  final ValueChanged<String>? onItemSelected;
  final double? indent;
  final List<KlpFileExplorerSection> emptyStateSections;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return KlpFileExplorer(
      scrollController: scrollController,
      sections: sections,
      expandedSectionIds: expandedSectionIds,
      expandedItemIds: expandedItemIds,
      selectedId: selectedId,
      onSectionToggle: onSectionToggle,
      onItemToggle: onItemToggle,
      onItemSelected: onItemSelected,
      indent: indent,
      emptyStateSections: emptyStateSections,
      sectionPadding: EdgeInsets.zero,
      sectionMargin: EdgeInsets.symmetric(
        horizontal: context.klp.space.hairline,
      ),
      itemPadding: EdgeInsets.zero,
    );
  }
}
