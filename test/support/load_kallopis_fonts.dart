/// 載入設定頁 golden 所需的完整 Kallopis 字型。

library;

import 'package:flutter/services.dart';
import 'package:kallopis/kallopis.dart';

import 'load_kallopis_icon_fonts.dart';

Future<void> loadKallopisFonts() async {
	await loadKallopisIconFonts();
	final sans = FontLoader(KlpTypography.sansFamily)
		..addFont(
			rootBundle.load('packages/kallopis/assets/fonts/NotoSansTC-Variable.ttf'),
		);
	final mono = FontLoader(KlpTypography.monoFamily)
		..addFont(
			rootBundle.load('packages/kallopis/assets/fonts/IBMPlexMono-Regular.ttf'),
		)
		..addFont(
			rootBundle.load('packages/kallopis/assets/fonts/IBMPlexMono-Medium.ttf'),
		)
		..addFont(
			rootBundle.load(
				'packages/kallopis/assets/fonts/IBMPlexMono-SemiBold.ttf',
			),
		);
	await Future.wait([sans.load(), mono.load()]);
}
