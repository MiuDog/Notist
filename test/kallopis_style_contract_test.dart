/// Notist 專案模組。

library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kallopis 是風格的唯一決定者；Notist 只能以「語意」表達意圖。
///
/// 這份契約是**機械檢查**，不是慣例宣示。它掃描整個 `lib/`，
/// 讓違規在 CI 就失敗，而不是等人在 review 或實機使用時發現。
///
/// 為什麼要機械化：風格分岔是**靜默**的——程式碼編得過、測試會通過、
/// 畫面也畫得出來，只是跟其他控制項長得不一樣。等到有人察覺時，
/// 分岔通常已經散佈到數十個檔案。
///
/// 判準：**數值與呈現方式屬於 Kallopis；Notist 只說「這是什麼」，不說「長什麼樣」。**
void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);

  /// 掃描整份檔案內容並回推行號。
  ///
  /// **刻意不逐行掃描**：Dart 的慣用格式會把建構子參數換行，
  /// 例如 `SizedBox.square(\n  dimension: 24,`。逐行比對永遠看不到跨行的樣式，
  /// 契約會安靜地漏掉最常見的寫法——這個漏洞是靠對契約本身注入違規才發現的。
  List<String> scan(
    RegExp pattern, {
    bool Function(String context)? allow,
    Set<String> exemptSuffixes = const {},
  }) {
    final hits = <String>[];
    for (final file in dartFiles) {
      final normalized = file.path.replaceAll(r'\', '/');
      if (exemptSuffixes.any(normalized.endsWith)) continue;

      final content = file.readAsStringSync();
      for (final match in pattern.allMatches(content)) {
        // 取匹配所在的整行作為 allow 判斷依據與錯誤訊息。
        final lineStart = content.lastIndexOf('\n', match.start) + 1;
        var lineEnd = content.indexOf('\n', match.start);
        if (lineEnd < 0) lineEnd = content.length;
        final line = content.substring(lineStart, lineEnd).trim();

        if (allow != null && allow(line)) continue;

        final lineNumber =
            '\n'.allMatches(content.substring(0, match.start)).length + 1;
        hits.add('$normalized:$lineNumber  $line');
      }
    }
    return hits;
  }

  test('不得使用 Flutter Material 的互動元件', () {
    // 「按壓與 hover 怎麼呈現」是風格決定，屬於 Kallopis。
    // 自行組合 Material／InkWell 會讓該控制項的互動視覺與其他控制項分岔，
    // 且 Kallopis 日後調整互動樣式時不會跟著變。改用 KlpPressable。
    final hits = scan(RegExp(r'\b(Material|InkWell|Ink)\('));
    expect(
      hits,
      isEmpty,
      reason: '改用 KlpPressable 等 Kallopis 互動元件：\n${hits.join('\n')}',
    );
  });

  test('不得出現字面顏色', () {
    // 顏色一律取自 context.klpColors，使主題切換與對比度保證能一次生效。
    final hits = scan(
      RegExp(r'Color\(0x|Colors\.(?!\w*\bklp)'),
      allow: (line) {
        // klpColors.* 是語意 token，不是字面色。
        return line.contains('klpColors') || line.contains('klp.color');
      },
    );
    expect(
      hits,
      isEmpty,
      reason: '改用 context.klpColors 的語意色：\n${hits.join('\n')}',
    );
  });

  test('不得出現字面間距、圓角與尺寸', () {
    // 數值必須來自 klp.space / klp.shape，否則設計系統調整時不會生效。
    // `\s` 涵蓋換行，因此跨行的建構子參數也會被抓到。
    final hits = scan(
      RegExp(
        r'(EdgeInsets\.\w+\(\s*[\d.]|'
        r'BorderRadius\.circular\(\s*[\d.]|'
        r'dimension:\s*[\d.])',
        multiLine: true,
      ),
    );
    expect(
      hits,
      isEmpty,
      reason: '改用 klp.space / klp.shape 的 token：\n${hits.join('\n')}',
    );
  });

  test('不得自行指定字體樣式', () {
    // 字級與字重屬於排版系統。Krepis display 檔案例外是二進位欄位；
    // math host 只呼叫 Kallopis 明載供 TextSpan 混排的 role resolver。
    final hits = scan(
      RegExp(r'TextStyle\(|fontSize:|fontWeight:|fontFamily:'),
      exemptSuffixes: {
        'lib/src/krepis/krepis_display.dart',
        'lib/src/krepis/krepis_display_decoder.dart',
        'lib/src/components/note/notist_note_math_host.dart',
      },
    );
    expect(hits, isEmpty, reason: '改用 Kallopis 的排版語意：\n${hits.join('\n')}');
  });

  test('production app 沿用 KlpApp 的預設視覺', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('return KlpApp('));
    expect(source, isNot(contains('visualStyle:')));
    expect(source, isNot(contains('theme:')));
    expect(source, isNot(contains('darkTheme:')));
  });

  test('主導覽與停駐框架使用 Kallopis 控制項', () {
    final sidebarSource = File(
      'lib/src/sidebar/notist_sidebar.dart',
    ).readAsStringSync();
    final workbenchSource = File(
      'lib/src/shell/notist_workbench.dart',
    ).readAsStringSync();

    expect(sidebarSource, isNot(contains('KlpNoteIdentityHeader(')));
    expect(workbenchSource, contains('KlpRailMenuEntry('));
    expect(workbenchSource, contains('KlpRailButtonEntry('));
    expect(workbenchSource, contains('NotistWorkbenchSurface('));
    expect(workbenchSource, isNot(contains('IstWorkbenchScreen(')));
    expect(workbenchSource, contains('KlpDockPanel('));
    expect(sidebarSource, isNot(contains('selectionBackground')));
  });

  test('契約本身有涵蓋範圍', () {
    // 防止 lib/ 被搬走或掃描邏輯壞掉時，這份契約靜默變成空檢查。
    expect(dartFiles.length, greaterThan(50), reason: '掃描到的 Dart 檔案過少，契約可能已失效');
  });
}
