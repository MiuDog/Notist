import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

typedef NotistFlowEditorBuilder =
    Widget Function(BuildContext context, String filePath);

class NotistProjectPage extends StatelessWidget {
  const NotistProjectPage({
    super.key,
    required this.filePath,
    required this.editorBuilder,
    this.onCreate,
  });

  final String filePath;
  final NotistFlowEditorBuilder editorBuilder;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    if (filePath.isEmpty) {
      return Center(
        key: const ValueKey('workspace-project-page'),
        child: KlpEmptyState(
          icon: KlpIcons.folder,
          title: '尚無 Flow',
          message: '建立 Flow 後，內容會顯示在這裡。',
          action: onCreate == null
              ? null
              : KlpButton(label: '新增 Flow', onPressed: onCreate),
        ),
      );
    }
    final klp = context.klp;

    // 實作準則 §5.2：正文容器 padding 8/0/40、最大寬 780，且**左邊界必須與 Stage
    // 標題對齊**。
    //
    // 區塊編輯器內建 60px 的左側 handle 留白，外層要用負左邊距抵掉，否則正文會比
    // 標題縮進一大截——截圖上就是這個現象。準則明文禁止改成給編輯器 maxWidth，
    // 那會讓它置中而多出一段縮排。
    // 往左位移正好一個握把留白，正文左緣就落在容器左緣——而容器與 Stage 標題
    // 共用同一個 space.base 內距，所以對齊是結構性的，不是湊出來的數字。
    final gutterCompensation = -klp.space.documentHandleGutter;

    return Padding(
      key: const ValueKey('workspace-project-page'),
      padding: EdgeInsets.only(
        top: klp.space.compact,
        bottom: klp.space.documentTrailingSpace,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Transform.translate(
          offset: Offset(gutterCompensation, 0),
          child: SizedBox(
            width: klp.geometry.layout.documentContentMaximumWidth,
            child: editorBuilder(context, filePath),
          ),
        ),
      ),
    );
  }
}
