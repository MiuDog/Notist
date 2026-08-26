import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

class NtsBlockCanvasCatalogDemo extends StatefulWidget {
  const NtsBlockCanvasCatalogDemo({super.key});

  @override
  State<NtsBlockCanvasCatalogDemo> createState() =>
      _NtsBlockCanvasCatalogDemoState();
}

class _NtsBlockCanvasCatalogDemoState extends State<NtsBlockCanvasCatalogDemo> {
  var _selected = 1;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return SizedBox(
      height: klp.space.pageLarge * 3,
      child: NtsBlockCanvas(
        constrained: true,
        children: [
          Positioned(
            left: klp.space.section,
            top: klp.space.section,
            child: _CanvasBlock(
              label: '研究題目',
              selected: _selected == 0,
              onSelected: () => setState(() => _selected = 0),
            ),
          ),
          Positioned(
            left: klp.space.pageLarge * 2,
            top: klp.space.pageLarge,
            child: _CanvasBlock(
              label: '待驗證假設',
              selected: _selected == 1,
              onSelected: () => setState(() => _selected = 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasBlock extends StatefulWidget {
  const _CanvasBlock({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  State<_CanvasBlock> createState() => _CanvasBlockState();
}

class _CanvasBlockState extends State<_CanvasBlock> {
  final _menuController = KlpContextMenuController();

  @override
  Widget build(BuildContext context) {
    return KlpContextMenu(
      controller: _menuController,
      label: 'Block actions',
      items: [
        KlpMenuItemData(label: 'Duplicate', onPressed: () {}),
        KlpMenuItemData(label: 'Delete', onPressed: () {}),
      ],
      child: NtsBlock(
        selected: widget.selected,
        handleLabel: '${widget.label} actions',
        onHandlePressed: _menuController.openAt,
        onSelected: widget.onSelected,
        onContentPressed: () {},
        child: KlpText(widget.label),
      ),
    );
  }
}

class NtsSheetCatalogDemo extends StatefulWidget {
  const NtsSheetCatalogDemo({super.key});

  @override
  State<NtsSheetCatalogDemo> createState() => _NtsSheetCatalogDemoState();
}

class _NtsSheetCatalogDemoState extends State<NtsSheetCatalogDemo> {
  final _cells = <(int, int), String>{
    (0, 0): '工作項目',
    (0, 1): '狀態',
    (0, 2): '負責人',
    (1, 0): '整理訪談',
    (1, 1): '進行中',
    (1, 2): 'Yun',
    (2, 0): '更新原型',
    (2, 1): '待處理',
    (2, 2): 'Kai',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.klp.space.pageLarge * 5,
      child: NtsSheetGrid(
        cellValueAt: (row, column) => _cells[(row, column)],
        onCellCommitted: (row, column, value) {
          setState(() => _cells[(row, column)] = value);
        },
      ),
    );
  }
}
