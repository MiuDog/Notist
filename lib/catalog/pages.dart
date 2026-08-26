import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

import '../src/stage/notist_canva_page.dart';
import '../src/stage/notist_flow_page.dart';
import '../src/stage/notist_sheet_page.dart';
import 'components.dart';
import 'model.dart';
import 'specimens/background_editor.dart';
import 'specimens/flow_demo.dart';
import 'specimens/editor_demos.dart';

final ntsFlowCatalogPage = NtsCatalogPage(
  label: 'Flow',
  title: 'Flow 區塊筆記',
  description: '集中查看文件區塊、內容種類、選取狀態與操作入口。',
  icon: KlpIcons.edit,
  specimens: [
    NtsCatalogSpecimen(
      name: 'NtsBlock',
      states: const ['default', 'hover', 'clicked', 'menu', 'readonly drag'],
      note: '所有 Flow 區塊共用六點操作鈕與互動高亮。',
      build: (_) => const NtsFlowCatalogDemo(),
    ),
    NtsCatalogSpecimen(
      name: 'NtsBlockCanvas',
      states: const ['default', 'clicked', 'menu', 'constrained'],
      build: (_) => const NtsBlockCanvasCatalogDemo(),
    ),
    NtsCatalogSpecimen(
      name: 'NotistFlowPage',
      states: const ['full page', 'responsive', 'plain background'],
      build: (context) => SizedBox(
        height: context.klp.space.pageLarge * 6,
        child: const NotistFlowPage(noteTitle: 'Catalog note'),
      ),
    ),
  ],
);

final ntsCanvaCatalogPage = NtsCatalogPage(
  label: 'Canva',
  title: 'Canva 空間筆記',
  description: '查看畫布頁面與背景編輯工具的點連、選取、刪除狀態。',
  icon: KlpIcons.container,
  specimens: [
    NtsCatalogSpecimen(
      name: 'NtsPageBackgroundEditor',
      states: const ['connect', 'select', 'delete', 'snap', 'Shift bypass'],
      build: (_) => const NtsBackgroundEditorSpecimen(),
    ),
    NtsCatalogSpecimen(
      name: 'NotistCanvaPage',
      states: const ['spatial', 'compact', 'dots background'],
      build: (context) => SizedBox(
        height: context.klp.space.pageLarge * 6,
        child: const NotistCanvaPage(noteTitle: 'Lamp ideas'),
      ),
    ),
  ],
);

final ntsSheetCatalogPage = NtsCatalogPage(
  label: 'Sheet',
  title: 'Sheet 表格筆記',
  description: '集中驗證空白、資料、選取、鍵盤移動、編輯與虛擬延伸。',
  icon: KlpIcons.grid,
  specimens: [
    NtsCatalogSpecimen(
      name: 'NtsSheetGrid',
      states: const ['empty', 'filled', 'selected', 'editing', 'extended'],
      build: (_) => const NtsSheetCatalogDemo(),
    ),
    NtsCatalogSpecimen(
      name: 'NotistSheetPage',
      states: const ['full page', 'responsive', 'grid background'],
      build: (context) => SizedBox(
        height: context.klp.space.pageLarge * 6,
        child: const NotistSheetPage(noteTitle: 'Shopping list'),
      ),
    ),
  ],
);

final ntsBackgroundsCatalogPage = NtsCatalogPage(
  label: 'Backgrounds',
  title: '筆記背景',
  description: '查看所有預設圖樣與可執行期調整的顏色、軸線、間距及縮放線寬。',
  icon: KlpIcons.grid,
  specimens: [
    NtsCatalogSpecimen(
      name: 'NtsPageBackground',
      states: const ['plain', 'ruled', 'dots', 'grid'],
      build: (_) => const _BackgroundGallery(),
    ),
    NtsCatalogSpecimen(
      name: 'NtsPageBackgroundRecipe',
      states: const ['RGBA', 'major axis', 'minor axis', 'fixed', 'scaled'],
      build: (_) => const NtsBackgroundRuntimeSpecimen(),
    ),
  ],
);

class _BackgroundGallery extends StatelessWidget {
  const _BackgroundGallery();

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return NtsCatalogGrid(
      children: [
        for (final style in NtsPageBackgroundStyle.values)
          NtsCatalogSample(
            label: style.name,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(klp.shape.card),
              child: NtsPageBackground(
                style: style,
                child: SizedBox(height: klp.space.pageLarge * 2),
              ),
            ),
          ),
      ],
    );
  }
}
