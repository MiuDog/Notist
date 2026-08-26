# Paragraph dogfood Windows 驗證記錄

日期：2026-08-23  
平台：Windows 11 Home 26200，Flutter 3.44.4，Dart 3.12.2  
範圍：Notist P1 production dogfood；不是 P4 正式 persistence schema。

## Baseline

- Notist HEAD：`f6d3b52927d633c58359f150037a06cd896d8c77`。
- Krepis HEAD：`4260bc87be10af8600a5ff7c5df770f94fe1076b`。
- Kallopis HEAD：`ba21c01cdcc92a8610285813d1cadbf5622b4810`。
- 三倉開工時均非 clean；本切片保留使用者與並行工作的既有 delta，未建立 commit。
- 本切片未修改 Kallopis；Krepis delta 限於 Flow root／首段標題投影、C ABI 1.1、
  DOC-0004 與對應測試。Notist prototype／Catalog 只做解除 production native coupling 的調整。

## 機器驗證

- Notist focused lifecycle／identity／save tests：`+20 All tests passed!`。
- Notist 完整 `tool/verify.ps1`：`Formatted 83 files (0 changed)`、`No issues found!`、
  `+78 All tests passed!`，exit code 0。
- 空白建立修正後 focused lifecycle tests：`+12 All tests passed!`。
- Krepis Debug provider gate：`100% tests passed, 0 tests failed out of 34`。
- ABI 負面測試包含舊／新 minor、unopened state、struct size、buffer capacity 與 null
  pointer；Dart fixture 驗證 high-bit root ID 為 32 位小寫 hex。

## Windows 實機驗收

| 項目 | 結果 | 證據 |
|---|---|---|
| 空專案 | 通過 | Explorer 與 Stage 同時顯示「尚無 Flow」與「新增 Flow」，無虛假保存狀態。 |
| 建立空白 Flow | 通過 | 建立後第一個 Paragraph 內容為空；Explorer／header 只顯示「未命名 Flow」placeholder。 |
| 標題同源投影 | 通過 | 在首段輸入 `abc`後，內容、Stage header 與 Explorer 同步顯示 `abc`。 |
| Paragraph split | 通過 | `Enter` 後輸入 `y`，呈現兩個可操作段落，標題仍由第一段投影。 |
| 保存與重開 | 通過 | 底部顯示「本機測試暫存已保存」；終止程式並以同專案路徑重開後，`abcx` 與第二段 `y` 均還原。 |
| 保存失敗／retry | 通過 | 實機以移動中的父目錄強制寫入失敗；editor 保留 `adbc`，失敗與 retry 狀態可見，retry 不覆蓋記憶體內容。 |
| Unicode／IME／undo／redo／跨段 merge | 機器 gate 通過；人工實機待驗 | Windows 自動輸入工具無法傳送 IME composition 與 modifier chord；UTF-8／composition、split／merge、undo／redo 已由 Krepis native tests 與 Notist consumer tests 驗證，但不冒充人工 Windows 實機證據。 |

## 失敗邊界

- native DLL 缺失、corrupt／unsupported 檔案與 ABI minor 不相容均 fail closed，不呈現 fallback 假筆記。
- 切換文件、open failure 與 dispose 會終止舊 save session，過期 retry 無法寫入新文件。
- load／create single-flight，concurrent create、load-create race 與 duplicate root 都有負面測試。

## 結論

P1 production dogfood 程式、機器 gate 與可自動化的 Windows 驗收已完成；IME、modifier
shortcut 與跨段 merge 仍需人類在 Windows 視窗實際操作後，才能宣告完整人工驗收。本切片可用於
本機開發與 dogfood，但不代表 MVP1 全體、P4 正式 schema、migration、協作 authority、
Block／Ink／Search 或 Notist AI 已完成。

## 2026-08-24 鍵盤回歸修正

- 使用者實機回報：Backspace 無法刪除，`Ctrl+Z` 可用但 `Ctrl+Y` 無效。
- 根因：Notist 只在段首且非第一段時處理 Backspace，其他位置把事件丟回平台；
  shortcut map 只有 `Ctrl+Z` 與 `Ctrl+Shift+Z`。
- 從 Planist 僅蒸餾通用輸入規則：Backspace 處理 KeyDown／KeyRepeat，Windows redo 加入
  `Ctrl+Y`；未複製 Planist controller、DTO、theme 或 APOS 產品語意。
- RED 證據：Backspace 預期 2 次、實際 0 次；`Ctrl+Y` 預期 1 次、實際 0 次。
- GREEN 證據：`test/notist_flow_editor_lifecycle_test.dart` 尾行 `+5: All tests passed!`。
- 靜態分析：`No issues found!`。
- 完整測試其餘 82 項通過，但主畫面 Golden 因本任務之外的 11.92% 視覺差異失敗；
  本鍵盤修正不更新 Golden。
