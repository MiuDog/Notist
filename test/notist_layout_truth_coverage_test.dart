import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 布局真相的覆蓋率閘門。
///
/// `notist_layout_truth.dart` 逐項轉錄了版面稿的每一個尺寸。但一條沒有被任何測試
/// 斷言到的真相，只是擺著好看——它不會擋下任何偏差，卻讓人以為那一項已經受控。
///
/// 這道閘門要求：真相檔裡每一個常數都必須出現在斷言測試裡。目前尚未斷言的部分以
/// 棘輪列管，數量只能下降。
void main() {
  test('真相檔裡的每一條都要被斷言，未斷言的數量只能下降', () {
    // 目前尚未斷言的條目數。Journals、資產庫與部分 Stage 細節在 Notist 尚未實作，
    // 沒有可斷言的對象；把它們列管而不是刪掉真相，是為了讓「還差什麼」看得見。
    //
    // 實作補上後請把 baseline 一併調低。
    const baseline = 40;

    final truth = File(
      'test/layout_truth/notist_layout_truth.dart',
    ).readAsStringSync();
    final assertions = File(
      'test/notist_layout_truth_test.dart',
    ).readAsStringSync();

    final declared = RegExp(
      r'^const\s+(?:double|String)\s+(\w+)\s*=',
      multiLine: true,
    ).allMatches(truth).map((match) => match.group(1)!).toList();

    expect(declared, isNotEmpty, reason: '解析不到任何真相常數，這道閘門本身失效了');

    final unasserted = declared
        .where(
          (name) =>
              !RegExp('truth[.]$name(?![A-Za-z0-9_])').hasMatch(assertions),
        )
        .toList();

    expect(
      unasserted.length,
      lessThanOrEqualTo(baseline),
      reason:
          '未被斷言的真相從 $baseline 增加到 ${unasserted.length}：\n'
          '${unasserted.join('、')}\n'
          '新增真相就要同時新增斷言，否則那一條擋不住任何東西。',
    );

    // 降下去後忘記調低 baseline，棘輪會停在舊刻度上，之後的回退就不會被擋下。
    expect(
      unasserted.length,
      greaterThanOrEqualTo(baseline - 5),
      reason: '已降到 ${unasserted.length}，請把 baseline 一併調低到這個數字。',
    );
  });
}
