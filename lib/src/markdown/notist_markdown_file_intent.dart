import 'package:flutter/services.dart';

typedef NotistMarkdownPathsHandler = Future<void> Function(List<String> paths);

class NotistMarkdownFileIntent {
  NotistMarkdownFileIntent({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('notist/file_intent');

  final MethodChannel _channel;

  Future<String?> pick() => _channel.invokeMethod<String>('pickMarkdownFile');

  void listen(NotistMarkdownPathsHandler handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openMarkdownFiles') return;
      final paths = (call.arguments as List<Object?>)
          .whereType<String>()
          .toList();
      if (paths.isNotEmpty) await handler(paths);
    });
  }

  void dispose() => _channel.setMethodCallHandler(null);
}
