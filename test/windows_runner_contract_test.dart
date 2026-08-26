import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Windows runner 將最大化視窗限制在工作區', () {
    final source = File('windows/runner/win32_window.cpp').readAsStringSync();

    expect(source, contains('ptMaxPosition.x'));
    expect(source, contains('ptMaxPosition.y'));
    expect(source, contains('ptMaxSize.x'));
    expect(source, contains('ptMaxSize.y'));
    expect(source, contains('monitor_info.rcWork'));
    expect(source, contains('monitor_info.rcMonitor'));
  });

  test('Windows runner 首幀顯示不覆蓋 KlpApp 啟動最大化', () {
    final source = File('windows/runner/win32_window.cpp').readAsStringSync();

    expect(source, contains('IsZoomed(window_handle_)'));
    expect(source, contains('SW_SHOWMAXIMIZED'));
  });

  test('Windows runner 提供四邊四角 resize 與最小尺寸', () {
    final windowSource = File(
      'windows/runner/win32_window.cpp',
    ).readAsStringSync();
    final flutterSource = File(
      'windows/runner/flutter_window.cpp',
    ).readAsStringSync();

    for (final hitTest in <String>[
      'HTTOPLEFT',
      'HTTOPRIGHT',
      'HTBOTTOMLEFT',
      'HTBOTTOMRIGHT',
      'HTLEFT',
      'HTRIGHT',
      'HTTOP',
      'HTBOTTOM',
    ]) {
      expect(windowSource, contains(hitTest));
    }
    expect(windowSource, contains('IsZoomed(hwnd)'));
    expect(windowSource, contains('return HTCLIENT'));
    expect(windowSource, contains('ptMinTrackSize.x'));
    expect(windowSource, contains('ptMinTrackSize.y'));
    expect(windowSource, contains('FlutterDesktopGetDpiForMonitor'));
    expect(flutterSource, contains('call.method_name() == "setMinSize"'));
    expect(flutterSource, contains('WM_NCLBUTTONDOWN, HTCAPTION'));
  });

  test('Windows runner 接上 Markdown 選檔、拖放與啟動參數', () {
    final flutterSource = File(
      'windows/runner/flutter_window.cpp',
    ).readAsStringSync();
    final mainSource = File('windows/runner/main.cpp').readAsStringSync();

    expect(flutterSource, contains('GetOpenFileNameW'));
    expect(flutterSource, contains('DragAcceptFiles'));
    expect(flutterSource, contains('WM_DROPFILES'));
    expect(flutterSource, contains('openMarkdownFiles'));
    expect(mainSource, contains('set_dart_entrypoint_arguments'));
  });
}
