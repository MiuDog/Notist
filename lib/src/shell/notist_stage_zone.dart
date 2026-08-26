/// Stage 目前在顯示哪一類內容。
///
/// 導覽入口與文件選取是**互斥**的：點導覽項目會清掉文件選取，點筆記會清掉導覽項目。
/// 少了這個區分，兩邊會各自以為自己還被選著，側欄同時亮兩個地方。
enum NotistStageZone {
  /// 顯示 [NotistWorkspaceDestination] 對應的入口畫面。
  destination,

  /// 顯示目前選取的 Flow 文件。
  document,
}
