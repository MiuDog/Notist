import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../project/notist_flow_document.dart';

final class NotistQuickSearchPage extends StatefulWidget {
  const NotistQuickSearchPage({
    super.key,
    required this.documents,
    required this.onOpen,
  });

  final List<NotistFlowDocument> documents;
  final ValueChanged<String> onOpen;

  @override
  State<NotistQuickSearchPage> createState() => _NotistQuickSearchPageState();
}

final class _NotistQuickSearchPageState extends State<NotistQuickSearchPage> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final matches = query.isEmpty
        ? const <NotistFlowDocument>[]
        : widget.documents
              .where((document) {
                return document.title.toLowerCase().contains(query) ||
                    document.folderPath.toLowerCase().contains(query);
              })
              .toList(growable: false);

    return Padding(
      padding: EdgeInsets.all(context.klp.space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KlpTextField(
            autofocus: true,
            clearable: true,
            leadingIcon: KlpIcons.search,
            placeholder: '搜尋 Flow 標題與資料夾',
            onChanged: (value) => setState(() => _query = value),
            onClear: () => setState(() => _query = ''),
          ),
          SizedBox(height: context.klp.space.base),
          Expanded(
            child: query.isEmpty
                ? const KlpEmptyState(
                    icon: KlpIcons.search,
                    title: '快速搜尋',
                    message: '輸入 Flow 標題或資料夾名稱。全文搜尋等待 Krepis 專案查詢契約。',
                  )
                : matches.isEmpty
                ? const KlpEmptyState(
                    icon: KlpIcons.search,
                    title: '找不到 Flow',
                    message: '目前沒有符合的標題或資料夾。',
                  )
                : KlpScrollViewport(
                    child: Column(
                      children: [
                        for (final document in matches)
                          KlpListTile(
                            title: document.title.isEmpty
                                ? '未命名 Flow'
                                : document.title,
                            subtitle: document.folderPath.isEmpty
                                ? '專案根目錄'
                                : document.folderPath,
                            icon: KlpIcons.edit,
                            onPressed: () => widget.onOpen(document.rootId),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
