import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

import 'registry.dart';
import 'shell.dart';

class NtsCatalogApp extends StatefulWidget {
  const NtsCatalogApp({super.key});

  @override
  State<NtsCatalogApp> createState() => _NtsCatalogAppState();
}

class _NtsCatalogAppState extends State<NtsCatalogApp> {
  var _selected = 0;
  var _variant = KlpThemeVariant.light;

  void _cycleTheme() {
    setState(() {
      _variant = switch (_variant) {
        KlpThemeVariant.light => KlpThemeVariant.dark,
        KlpThemeVariant.dark => KlpThemeVariant.ultraDark,
        KlpThemeVariant.ultraDark => KlpThemeVariant.light,
        KlpThemeVariant.transparent => KlpThemeVariant.light,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildKlpThemeVariant(_variant);

    return KlpApp(
      title: 'Notist Catalog',
      debugShowCheckedModeBanner: false,
      minWidth: 800,
      minHeight: 500,
      appIcon: Image.asset('design/app_icon/app_icon_master.png'),
      headerActions: [
        KlpIconButton(
          icon: KlpIcons.sparkles,
          label: '切換 Catalog 主題',
          onPressed: _cycleTheme,
        ),
      ],
      builder: (context, child) =>
          Theme(data: theme, child: child ?? const SizedBox.shrink()),
      home: NtsCatalogShell(
        pages: ntsCatalogPages,
        selected: _selected,
        onSelected: (index) => setState(() => _selected = index),
      ),
    );
  }
}
