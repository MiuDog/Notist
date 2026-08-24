import 'package:flutter/foundation.dart';

import 'notist_stage_zone.dart';
import 'notist_workspace_destination.dart';

/// Notist 絕對 golden shell 的互動狀態。
final class NotistWorkbenchController extends ChangeNotifier {
  factory NotistWorkbenchController({
    double primaryWidth = initialPrimaryWidth,
    bool primaryVisible = true,
    NotistWorkspaceDestination destination =
        NotistWorkspaceDestination.journals,
  }) {
    return NotistWorkbenchController._(
      primaryWidth,
      primaryVisible,
      destination,
    );
  }

  NotistWorkbenchController._(
    double primaryWidth,
    this._primaryVisible,
    this._destination,
  ) : _primaryWidth = primaryWidth.clamp(
        minimumPrimaryWidth,
        maximumPrimaryWidth,
      );

  /// 附件指定的產品布局寬度，不是 Kallopis 視覺 token。
  static const double initialPrimaryWidth = 268;
  static const double minimumPrimaryWidth = 200;
  static const double maximumPrimaryWidth = 460;

  double _primaryWidth;
  bool _primaryVisible;
  NotistWorkspaceDestination _destination;
  NotistStageZone _zone = NotistStageZone.document;

  double get primaryWidth => _primaryWidth;
  bool get primaryVisible => _primaryVisible;
  NotistWorkspaceDestination get destination => _destination;

  /// Stage 目前顯示哪一類內容。
  NotistStageZone get zone => _zone;

  void resizePrimary(double width) {
    final next = width.clamp(minimumPrimaryWidth, maximumPrimaryWidth);
    if (next == _primaryWidth) return;

    _primaryWidth = next;
    notifyListeners();
  }

  void togglePrimary() {
    _primaryVisible = !_primaryVisible;
    notifyListeners();
  }

  void selectDestination(NotistWorkspaceDestination destination) {
    // 即使目的地沒變也要處理：使用者可能是從文件切回同一個入口。
    final unchanged =
        destination == _destination && _zone == NotistStageZone.destination;
    if (unchanged) return;

    _destination = destination;
    _zone = NotistStageZone.destination;
    notifyListeners();
  }

  /// 切回文件。點側欄的筆記時呼叫——導覽項目的選取會一併解除。
  void showDocument() {
    if (_zone == NotistStageZone.document) return;

    _zone = NotistStageZone.document;
    notifyListeners();
  }
}
