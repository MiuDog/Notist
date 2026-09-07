/// Notist 專案模組。

library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/markdown/notist_markdown_file_intent.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('notist/file-intent-test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('picker returns the native Markdown path', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => r'C:\研究.md');
    final intent = NotistMarkdownFileIntent(channel: channel);

    expect(await intent.pick(), r'C:\研究.md');
  });

  test('drop paths preserve native order', () async {
    final received = <String>[];
    final intent = NotistMarkdownFileIntent(channel: channel);
    intent.listen((paths) async => received.addAll(paths));

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('openMarkdownFiles', ['a.md', 'b.md']),
          ),
          (_) {},
        );

    expect(received, ['a.md', 'b.md']);
    intent.dispose();
  });
}
