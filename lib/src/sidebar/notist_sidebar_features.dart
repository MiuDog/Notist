import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

/// Primary Sidebar 上方的產品功能導覽列。
class NotistSidebarFeatures extends StatelessWidget {
  const NotistSidebarFeatures({
    super.key,
    required this.selectedFeature,
    required this.onFeatureSelected,
  });

  final String? selectedFeature;
  final ValueChanged<String> onFeatureSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KlpRailItem(
          icon: KlpIcons.sparkles,
          label: 'Notist AI',
          selected: selectedFeature == 'ai',
          onPressed: () => onFeatureSelected('ai'),
        ),
      ],
    );
  }
}
