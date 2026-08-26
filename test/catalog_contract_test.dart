import 'package:flutter_test/flutter_test.dart';
import 'package:notist/catalog/catalog.dart';

void main() {
  test('Catalog 依序涵蓋全部筆記頁面', () {
    expect(ntsCatalogPages.map((page) => page.label), [
      'Flow',
      'Canva',
      'Sheet',
      'Backgrounds',
    ]);
  });

  test('Catalog 為每個頁面提供狀態視覺', () {
    for (final page in ntsCatalogPages) {
      expect(page.specimens, isNotEmpty, reason: page.label);
      expect(
        page.specimens.every((specimen) => specimen.states.isNotEmpty),
        isTrue,
        reason: page.label,
      );
    }
  });
}
