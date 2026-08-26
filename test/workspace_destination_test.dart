import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/shell/notist_workspace_destination.dart';

void main() {
  test('sidebar destinations keep the absolute golden order', () {
    expect(
      NotistWorkspaceDestination.values.map((destination) => destination.label),
      ['快速搜尋', 'Journals', 'Notist AI', '資產庫'],
    );
  });

  test('sidebar destination ids and labels are unique', () {
    final destinations = NotistWorkspaceDestination.values;
    final ids = destinations.map((destination) => destination.id).toSet();
    final labels = destinations.map((destination) => destination.label).toSet();

    expect(ids, hasLength(destinations.length));
    expect(labels, hasLength(destinations.length));
  });
}
