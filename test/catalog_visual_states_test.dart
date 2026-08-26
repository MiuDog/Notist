import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/catalog/registry.dart';
import 'package:notist/catalog/shell.dart';

void main() {
  testWidgets('Catalog 每頁在三種主題下皆可呈現狀態視覺', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final variant in const [
      KlpThemeVariant.light,
      KlpThemeVariant.dark,
      KlpThemeVariant.ultraDark,
    ]) {
      for (var index = 0; index < ntsCatalogPages.length; index++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildKlpThemeVariant(variant),
            home: NtsCatalogShell(
              pages: ntsCatalogPages,
              selected: index,
              onSelected: (_) {},
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(
            ValueKey(
              'nts-catalog-${ntsCatalogPages[index].label.toLowerCase()}',
            ),
          ),
          findsOneWidget,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '${variant.name}/${ntsCatalogPages[index].label}',
        );
      }
    }
  });
}
