import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/stage/notist_stage_identity_header.dart';

void main() {
  testWidgets('Notist requests complete wrapping for the Stage title', (
    tester,
  ) async {
    const title =
        '這是一個需要依照舞台可用寬度完整自動換行而且不能顯示省略號的文件標題，'
        '即使標題需要三行以上也必須完整保留所有內容';
    await tester.pumpWidget(
      const KlpApp(
        showWindowHeader: false,
        home: SizedBox(
          width: 220,
          height: 480,
          child: KlpStageFrame(
            header: NotistStageIdentityHeader(title: title),
            content: SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();

    final header = tester.widget<KlpStageHeader>(find.byType(KlpStageHeader));
    final minimumHeight = tester
        .element(find.byType(KlpStageHeader))
        .klp
        .space
        .chromeHeader;
    expect(header.wrapTitle, isTrue);
    expect(
      tester.getSize(find.byType(KlpStageHeader)).height,
      greaterThan(minimumHeight),
    );
    expect(find.text(title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
