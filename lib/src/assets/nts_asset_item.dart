/// Notist 專案模組。

library;

import 'package:flutter/foundation.dart';

/// 資產庫裡的一份檔案。
///
/// **筆記語意**的型別：什麼算「資產」、怎麼分類、大小怎麼呈現，都是這個產品的決定。
@immutable
class NtsAssetItem {
  const NtsAssetItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.sizeLabel,
    required this.whenLabel,
    this.shape = NtsAssetShape.square,
  });

  final String id;
  final String name;

  /// 產品自訂的類別字串，例如「圖片」「音訊」。庫不規定分類法。
  final String kind;

  /// 已格式化的大小，例如 `3.4 MB`。單位與進位屬於產品與語系。
  final String sizeLabel;

  /// 已格式化的時間，例如「2 天前」。
  final String whenLabel;

  final NtsAssetShape shape;
}

/// 預覽縮圖的長寬比。
///
/// 刻意只有三種而不是任意數值：讓瀑布流的節奏由一組固定的比例決定，而不是每個項目
/// 各給一個高度——後者會讓版面失去規律，也讓縮圖尺寸變成散在資料裡的風格值。
enum NtsAssetShape { tall, square, wide }
