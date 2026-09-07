/// Notist 專案模組。

library;

import 'package:flutter/services.dart';
import 'package:kallopis/kallopis.dart';

/// 載入 Kallopis 圖示字型，避免 golden 測試把私用區字碼畫成缺字方框。
Future<void> loadKallopisIconFonts() async {
  final regularIcons =
      FontLoader('packages/kallopis/${KlpIcon.regularFontFamily}')..addFont(
        rootBundle.load(
          'packages/kallopis/assets/fonts/FlaticonUIcons-RegularRounded.ttf',
        ),
      );
  await regularIcons.load();

  final thinIcons = FontLoader('packages/kallopis/${KlpIcon.thinFontFamily}')
    ..addFont(
      rootBundle.load(
        'packages/kallopis/assets/fonts/FlaticonUIcons-ThinRounded.ttf',
      ),
    );
  await thinIcons.load();
}
