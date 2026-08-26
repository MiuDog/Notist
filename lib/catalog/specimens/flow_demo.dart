import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

part 'flow_multi_column.dart';
part 'flow_preview.dart';
part 'flow_structured_blocks.dart';
part 'flow_text_blocks.dart';

class NtsFlowCatalogDemo extends StatefulWidget {
  const NtsFlowCatalogDemo({super.key});

  @override
  State<NtsFlowCatalogDemo> createState() => _NtsFlowCatalogDemoState();
}

class _NtsFlowCatalogDemoState extends State<NtsFlowCatalogDemo> {
  String? _selectedBlock;
  var _firstTaskDone = true;

  @override
  Widget build(BuildContext context) {
    final gap = context.klp.space.itemGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KlpText('文字區塊', role: KlpTextRole.h3),
        SizedBox(height: gap),
        _block(
          id: 'paragraph',
          label: '一般段落',
          child: const KlpText('把訪談中的觀察整理成可閱讀、可重新排列的內容。'),
        ),
        _block(
          id: 'heading-1',
          label: 'H1 標題',
          child: const KlpText('研究摘要', role: KlpTextRole.h1),
        ),
        _block(
          id: 'heading-2',
          label: 'H2 標題',
          child: const KlpText('主要發現', role: KlpTextRole.h2),
        ),
        _block(
          id: 'heading-3',
          label: 'H3 標題',
          child: const KlpText('使用情境', role: KlpTextRole.h3),
        ),
        _block(
          id: 'heading-4',
          label: 'H4 標題',
          child: const KlpText('補充資料', role: KlpTextRole.h4),
        ),
        _block(
          id: 'bulleted-list',
          label: '項目列表',
          child: const _TextList(items: ['整理逐字稿', '標記共同問題', '安排下一輪驗證']),
        ),
        _block(
          id: 'numbered-list',
          label: '編號列表',
          child: const _TextList(
            items: ['建立假設', '設計測試', '回收結果'],
            numbered: true,
          ),
        ),
        _block(
          id: 'todo-list',
          label: '待辦列表',
          child: Column(
            children: [
              KlpCheckbox(
                value: _firstTaskDone,
                label: '整理訪談重點',
                onChanged: (value) => setState(() => _firstTaskDone = value),
              ),
              const KlpCheckbox(value: false, label: '分享研究摘要', onChanged: null),
            ],
          ),
        ),
        _block(
          id: 'toggle-list',
          label: '摺疊列表',
          child: const _CollapsibleListPreview(),
        ),
        _block(
          id: 'annotation-heading',
          label: '註解標題',
          child: _AnnotationHeading(gap: gap),
        ),
        SizedBox(height: context.klp.space.groupGap),
        const KlpText('特殊元件區塊', role: KlpTextRole.h3),
        SizedBox(height: gap),
        _block(
          id: 'columns',
          label: '多欄',
          child: const _ResizableColumnsPreview(),
        ),
        _block(id: 'table', label: '表格', child: const _EmptyTablePreview()),
        _block(
          id: 'image',
          label: '圖片',
          child: _ImagePreview(height: context.klp.space.pageLarge),
        ),
        _block(
          id: 'placeholder',
          label: 'PLACEHOLDER',
          child: const KlpRegionPlaceholder(
            label: 'Empty area',
            kindLabel: 'Placeholder',
            detail: '等待產品端指定要插入的內容。',
          ),
        ),
        _block(id: 'divider', label: '分隔線', child: const KlpDivider()),
        _block(id: 'database', label: '資料庫', child: const _DatabasePreview()),
      ],
    );
  }

  Widget _block({
    required String id,
    required String label,
    required Widget child,
  }) {
    return _FlowBlockPreview(
      key: ValueKey('flow-block-$id'),
      label: label,
      selected: _selectedBlock == id,
      onSelected: () => setState(() => _selectedBlock = id),
      onContentPressed: () {},
      child: child,
    );
  }
}
