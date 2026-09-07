/// Notist 專案模組。

library;

import 'package:characters/characters.dart';

final class TextReplacementRange {
  const TextReplacementRange({
    required this.prefix,
    required this.oldEnd,
    required this.newEnd,
  });

  final int prefix;
  final int oldEnd;
  final int newEnd;
}

/// 以 grapheme cluster 找單一 replacement；回傳值是平台需要的 UTF-16 offset。
TextReplacementRange findTextReplacement(String oldText, String newText) {
  final oldClusters = oldText.characters.toList(growable: false);
  final newClusters = newText.characters.toList(growable: false);
  var matchingPrefix = 0;
  while (matchingPrefix < oldClusters.length &&
      matchingPrefix < newClusters.length &&
      oldClusters[matchingPrefix] == newClusters[matchingPrefix]) {
    matchingPrefix += 1;
  }
  var matchingSuffix = 0;
  while (matchingSuffix < oldClusters.length - matchingPrefix &&
      matchingSuffix < newClusters.length - matchingPrefix &&
      oldClusters[oldClusters.length - matchingSuffix - 1] ==
          newClusters[newClusters.length - matchingSuffix - 1]) {
    matchingSuffix += 1;
  }
  final prefix = oldClusters
      .take(matchingPrefix)
      .fold<int>(0, (length, cluster) => length + cluster.length);
  final oldSuffixLength = oldClusters
      .skip(oldClusters.length - matchingSuffix)
      .fold<int>(0, (length, cluster) => length + cluster.length);
  final newSuffixLength = newClusters
      .skip(newClusters.length - matchingSuffix)
      .fold<int>(0, (length, cluster) => length + cluster.length);
  return TextReplacementRange(
    prefix: prefix,
    oldEnd: oldText.length - oldSuffixLength,
    newEnd: newText.length - newSuffixLength,
  );
}
