/// Notist 專案模組。

library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Notist 與 Kallopis 的職責分界。
///
/// 分工是：**Kallopis 負責無語意元件與全部風格，Notist 負責組合畫面與筆記語意元件，
/// 風格一律由 Kallopis 繼承而來。**
///
/// 這條分界靠人看是守不住的：在 Notist 裡寫一個 `Color(0xFF...)` 或一個
/// `padding: EdgeInsets.all(12)` 不會出錯、不會被 analyze 抓到、畫面看起來也對——
/// 它只是從此不再跟著 Kallopis 的 theme 走。等到要換一套視覺風格時才會發現，
/// 而那時已經散落各處。
void main() {
  late List<File> sources;

  setUpAll(() {
    sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  });

  test('產品程式碼不得寫死風格值', () {
    expect(sources, isNotEmpty, reason: '掃不到任何原始檔，這道閘門本身失效了');

    // 目前是 0。這個數字只能是 0——風格一律由 Kallopis 繼承，沒有例外。
    final offenders = <String>[];

    final patterns = <String, RegExp>{
      '寫死顏色': RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)'),
      'Material 調色盤': RegExp(r'\bColors\.[a-zA-Z]+'),
      '寫死時長': RegExp(r'Duration\(\s*(?:milliseconds|seconds)\s*:\s*[1-9]'),
      '寫死內距': RegExp(
        r'EdgeInsets\.(?:all|symmetric|only|fromLTRB)\([^)]*[1-9]\d*(?:\.\d+)?',
      ),
      '寫死圓角': RegExp(r'BorderRadius\.circular\(\s*[1-9]'),
    };

    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      final lines = file.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        patterns.forEach((label, pattern) {
          if (pattern.hasMatch(lines[i])) {
            offenders.add('$path:${i + 1}  [$label]  ${lines[i].trim()}');
          }
        });
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Notist 裡出現了寫死的風格值：\n${offenders.join('\n')}\n'
          '風格一律由 Kallopis 繼承——請改用 context.klp 上的 token。'
          '若某個值 Kallopis 沒有提供，那代表 Kallopis 缺一個 token，'
          '要加在那邊，不是在這裡寫死。',
    );
  });

  test('Notist 只定義帶筆記語意的元件', () {
    // 無語意元件屬於 Kallopis。判準：類別名的前綴。
    //
    //   Nts*     筆記語意元件（本產品專有）
    //   Notist*  畫面與外殼組合
    //
    // 兩者以外的公開 widget 代表它其實是通用元件，應該搬去 Kallopis——
    // 留在這裡會讓第二個產品需要它時只能複製一份。
    final strays = <String>[];
    final declaration = RegExp(
      r'^class\s+(\w+)\s+extends\s+(?:Stateless|Stateful)Widget',
      multiLine: true,
    );

    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      for (final match in declaration.allMatches(file.readAsStringSync())) {
        final name = match.group(1)!;
        if (name.startsWith('_')) continue;
        if (name.startsWith('Nts') || name.startsWith('Notist')) continue;
        strays.add('$path  →  $name');
      }
    }

    expect(
      strays,
      isEmpty,
      reason:
          '這些公開 widget 既不是筆記語意元件也不是畫面組合：\n${strays.join('\n')}\n'
          '若它不帶筆記語意，它就是通用元件，屬於 Kallopis；'
          '留在 Notist 會讓下一個產品需要它時只能複製一份。',
    );
  });

  test('Notist 不自行定義風格，只繼承', () {
    // 允許以 Kallopis 的風格為基底做覆寫（copyWith／fromJson 都是繼承）；
    // 不允許從零建構一整套 KlpVisualStyle——那等於在產品端另開一套設計語言。
    final offenders = <String>[];

    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      final lines = file.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'\bKlpVisualStyle\s*\(').hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Notist 從零建構了 KlpVisualStyle：\n${offenders.join('\n')}\n'
          '風格一律由 Kallopis 繼承——要調整請用 copyWith 或 JSON 覆寫，'
          '以 Kallopis 出貨的風格為基底。',
    );
  });

  test('Notist 不保留 Kallopis 視覺別名與重複 Catalog', () {
    expect(Directory('lib/src/note').existsSync(), isFalse);
    expect(Directory('lib/catalog').existsSync(), isFalse);
    expect(File('lib/notist.dart').existsSync(), isFalse);
  });

  test('摺疊控制只使用 Flaticon 字型圖示', () {
    final source = File(
      'lib/src/krepis/notist_flow_block_chrome.dart',
    ).readAsStringSync();

    expect(source, contains('KlpIcons.disclosureTriangle'));
    expect(source, isNot(contains('▶')));
    expect(source, isNot(contains('▼')));
  });
}
