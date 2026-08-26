import 'dart:io';

abstract final class NotistFlowProjectPath {
  static String resolve() {
    final override = Platform.environment['NOTIST_FLOW_PROJECT_PATH'];
    if (override != null && override.isNotEmpty) return override;

    final base = Platform.environment['LOCALAPPDATA'];
    if (base == null || base.isEmpty) {
      throw StateError('找不到 LOCALAPPDATA，不能建立本機 Flow 專案路徑');
    }

    return Directory(
      '$base${Platform.pathSeparator}Notist${Platform.pathSeparator}Flows',
    ).path;
  }
}
