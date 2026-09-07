/// Notist Primary Sidebar 固定入口。

library;

enum NotistWorkspaceDestination {
  search(id: 'search', label: '快速搜尋'),
  journals(id: 'journals', label: 'Journals'),
  ai(id: 'ai', label: 'Notist AI'),
  assets(id: 'assets', label: '資產庫');

  const NotistWorkspaceDestination({required this.id, required this.label});

  final String id;
  final String label;
}
