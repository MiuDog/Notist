# Changelog

本專案的重要變更記錄於此。格式參照 Keep a Changelog，版本號依循 Semantic Versioning。

## [0.1.0-beta.1] - Unreleased

### Added

- Windows-first 單文件知識工作區，包含 Primary Sidebar、FileExplorer 與單一 Stage。
- 由 Krepis ABI 1.8 提供資料真相的 Flow Block 編輯、visual geometry、undo/redo、保存與 Ink capture。
- Shift 多選、拖曳排序、same-ID Block 轉換、Todo toggle、Slash Menu 與右鍵選單。
- 以 Flow 標題與資料夾為範圍的快速搜尋。
- 可選擇保留上次導覽狀態或使用初始狀態。

### Changed

- 產品名稱、Windows runner 與 Flutter package 統一為 Notist。
- 新建 profile 使用通用 Notist 識別，不顯示開發者個人名稱。

### Fixed

- Backspace 刪除、Ctrl+Z undo 與 Ctrl+Y redo 由編輯 authority 處理。

### Removed

- 從 fresh-profile UI 移除開發者個人識別資訊。

[0.1.0-beta.1]: https://github.com/MiuDog/Notist/releases/tag/v0.1.0-beta.1
