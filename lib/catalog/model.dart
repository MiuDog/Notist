import 'package:flutter/widgets.dart';

@immutable
class NtsCatalogSpecimen {
  const NtsCatalogSpecimen({
    required this.name,
    required this.states,
    required this.build,
    this.note,
  });

  final String name;
  final List<String> states;
  final WidgetBuilder build;
  final String? note;
}

@immutable
class NtsCatalogPage {
  const NtsCatalogPage({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.specimens,
  });

  final String label;
  final String title;
  final String description;
  final String icon;
  final List<NtsCatalogSpecimen> specimens;
}
