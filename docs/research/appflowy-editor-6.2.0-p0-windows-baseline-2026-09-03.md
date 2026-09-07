# AppFlowy Editor 6.2.0 P0 Windows 行為基準（2026-09-03）

狀態：Baseline in progress（研究專用相容補丁已通過 build／test／Windows 實機啟動；原生 UI 操作矩陣待完成）

本文件供 Notist 與 Krepis 實作者記錄固定 AppFlowy Editor 版本的可觀察行為。讀完後應能重現目前的
相容性阻塞、已採用的研究補丁，以及同一組 cases 的自動化與 Windows 實機證據。本文件不定義
Krepis command 語意；尚未由對應層級證據覆蓋的觀察仍維持 `U`。

## 固定環境

| 欄位 | 值 | 證據狀態 |
|---|---|---|
| 擷取日期 | 2026-09-03 | 已確認 |
| 作業系統 | Windows 11 | 已確認；本輪未重新記錄完整 build number |
| Flutter | 3.44.2 stable，revision `c9a6c48423` | Flutter tool `--version` 已確認 |
| Dart | 3.12.2 | Flutter tool `--version` 已確認 |
| Package | `appflowy_editor 6.2.0` | `dart pub cache add` exit code 0 |
| Package SHA-256 | `c2367acdd93c7eeefaf6c58e5fed1a1c62cf02b8368102b786b5c6a0d1c583cf` | Dart hosted cache hash |
| Patched package | `6.2.0+notist-baseline.1` | 只用於研究，不得進入 Notist runtime |
| Patched tree SHA-256 | `cc7704e9025a997645b0f3ec68b74e4f27ec054973f06bba832e7e39ab494335` | 847 files；算法見下方 |
| Compatibility patch | [patch](evidence/appflowy-editor-6.2.0-notist-baseline.1.patch) | `git apply --check --reverse` exit code 0 |
| Package declared Flutter range | `>=3.32.0` | 官方 package `pubspec.yaml` |
| 測試程式 | 隔離於 ignored `build/research/appflowy_editor_6_2_0` | 已建立；不屬 Notist runtime |
| Windows 成品 | `build/research/appflowy_editor_6_2_0/build/windows/x64/runner/Debug/appflowy_editor_baseline.exe` | build exit code 0 |
| 實機截圖 | [Windows runtime](../verification/evidence/appflowy-editor-6.2.0-patched-baseline-2026-09-03.png) | PID 28840 啟動後以 `PrintWindow` 只擷取該視窗；SHA-256 `7efa765523915bfa72e8e4d4cd047a041effb2b5f18f49fbe5d924d7bc260035` |

官方 package archive 含 `example/windows/`、`EditorState.blank`、`markdownToDocument`、`AppFlowyEditor`、
`FloatingToolbar` 與 `EditorScrollController`。研究程式使用公開 API；另以隔離副本套用一項編譯相容補丁，
官方 hosted cache 未被修改。

Patched tree hash 算法：以官方 hosted-cache 的 847 個檔案路徑為固定 file set，每個 patched 檔案先取
SHA-256，以相對路徑排序成 `fileSHA256␠␠relative/path`，使用 LF 連接後，再對整段 UTF-8 manifest 取
SHA-256。`pub get` 後的 29 個 generated files 不納入 source hash。

## 相容性阻塞

### 重現 1：Flutter widget test

結果：exit code 1。

```text
The non-abstract class 'DeltaTextInputService' is missing implementations for these members:
 - TextInputClient.onFocusReceived
```

### 重現 2：Windows Debug build

結果：exit code 1；`flutter_assemble.vcxproj` 由相同 Dart compile error 停止。

```text
delta_input_service.dart(7,7): error G76B49859:
The non-abstract class 'DeltaTextInputService' is missing implementations for these members
```

Flutter 3.44.2 的 `TextInputClient` 已提供 `bool onFocusReceived() => false`；AppFlowy Editor 6.2.0 的
`DeltaTextInputService` 沒有對應實作。`flutter analyze --fatal-infos` 顯示 `No issues found!`，但 test 與
Windows assemble 仍失敗，因此 analyze 不能取代實際編譯 gate。

同一錯誤已由兩條獨立路徑確認。依專案重試上限，在選定相容策略前不得第三次盲目 build。

### 採用方案與解除結果

採用方案 A。官方 6.2.0 原樣失敗證據保留不變；研究副本只新增
`bool onFocusReceived() => false`，與 Flutter 3.44.2 的 `TextInputClient` default 一致，並改版本標記。

解除結果：

- `flutter analyze --fatal-infos`：exit code 0，`No issues found! (ran in 4.0s)`。
- `flutter test --reporter expanded`：exit code 0，`+7: All tests passed!`；[測試紀錄](evidence/appflowy-editor-6.2.0-p0-test-results-2026-09-03.txt)。
- package-owned selection／text command／paste targeted suite：exit code 0，`+24: All tests passed!`；同一測試紀錄。
- 完整 package suite：exit code 1，`+905 -1`；唯一觀察到的失敗是 selection performance
  `212ms < 150ms` 門檻，未放寬也未修改該測試。同次 1000-child first-selection 為 88ms。
- `flutter build windows --debug`：exit code 0，產出 `appflowy_editor_baseline.exe`。
- Windows 實機：PID 28840、`HasExited=False`、window title `appflowy_editor_baseline`；截圖可讀，取證後已關閉程序。

這些結果只證明 `6.2.0+notist-baseline.1`，不得改寫為官方 6.2.0 原樣支援 Flutter 3.44.2。

原生鍵盤自動化曾以 `SetForegroundWindow` 與 `WScript.Shell.AppActivate` 各嘗試一次；兩次都沒有讓
Flutter Editor 接收事件，畫面維持 `Transactions: 0`、`Selection: none`。依相同錯誤最多修兩次的規範，
本輪停止自動化重試並刪除無操作證據；這不能視為 AppFlowy 行為失敗，只代表原生 UI cases 仍是 `U`。

## P0 behavior cases

### 記錄規則

- AppFlowy 實測欄只記錄畫面、文件內容、selection、transaction 與 undo 的可觀察結果。
- 無法由 UI 或公開 observer 證明的內部行為標 `U`，不得由 source code 推測。
- 每個 case 至少留下開始、操作後與 undo 後證據；IME case 另記輸入法與 composition 狀態。
- 「Notist 採用」必須在 AppFlowy 實測後另行裁決為 `adopt`、`adapt` 或 `reject`。

| Case | Matrix | 前置狀態 | 操作 | 必須觀察 | AppFlowy 結果 | Notist 採用 |
|---|---|---|---|---|---|---|
| AF-F01-01 | F01 | 空 Paragraph、繁中注音 IME | 依序輸入「測試中文」並 commit | composition 中間文字、caret、commit 後內容、transaction 數 | Partial：核心 composition range 與 CJK commit delta 通過；原生注音 UI 為 U | adapt：delta 契約可參考，原生 IME gate 保留 |
| AF-F01-02 | F01 | composition 進行中 | 按 Enter、Esc 各一次 | 是提交、換行、取消或關閉 overlay；有無重複字 | U：待原生 UI 操作 | 待裁決 |
| AF-F03-01 | F03 | 空 Paragraph | 連續輸入 `abc`，一次 Ctrl+Z，再 Ctrl+Y | typing transaction 次數、undo/redo 粒度、caret | Partial：單次 insert undo 可恢復內容與 selection；typing grouping／redo 為 U | adapt：保留 Krepis transaction boundary |
| AF-F03-02 | F03 | 兩個 Paragraph | 在第二段開頭 Backspace，再 Ctrl+Z | merge 結果、selection、是否一次恢復兩段 | U：待原生 UI 操作 | 待裁決 |
| AF-F05-01 | F05 | 兩個含 Unicode 的 Paragraph | 從第一段中間拖到第二段中間 | anchor/focus 方向、跨 Block highlight、selection endpoints | Partial：核心 selection 依序回傳三段切片；drag geometry 為 U | adapt：端點模型可參考，geometry 仍由 Krepis 提供 |
| AF-F05-02 | F05 | caret 在第一段中間 | Shift+Down／Shift+Right 擴張到第二段 | 鍵盤 selection geometry、viewport scroll、方向反轉 | U：待原生 UI 操作 | 待裁決 |
| AF-F07-01 | F07 | 跨兩段文字 selection | Delete，再 Ctrl+Z | 文字與中間 Blocks 如何刪除/合併、caret、undo 原子性 | Partial：跨三段 delete 合併邊界文字、只留一段並收合 selection；UI undo 為 U | adapt：以 Krepis revision-aware command 實作 |
| AF-F07-02 | F07 | 整 Block／連續 Blocks selected | Backspace 與 Delete 各測一次 | remaining document、合法 caret、空文件規則 | Partial：官方套件 collapsed／single／multi／nested delete tests 通過；整 Block 原生 UI 為 U | 待裁決 |
| AF-F14-01 | F14 | 單 Block 非收合文字 selection | 切換 bold、italic、strike、code、link | marks overlap、selection 保留、每項 undo 粒度 | Partial：跨兩段 bold 套用且 selection 保留；其餘 marks／UI undo 為 U | adapt：採 range mark command，不複製 EditorState |
| AF-F14-02 | F14 | caret selection | 啟用 bold 後輸入文字，再關閉 bold | stored mark 範圍、後續輸入是否繼承、undo grouping | Partial：官方 stored-style toggle test 通過；原生 UI 與 undo grouping 為 U | adapt：stored mark 概念可參考，boundary 由 Krepis 定義 |
| AF-F21-01 | F21 | AppFlowy 跨 Block selection | Ctrl+C 貼到純文字 editor | plain text newline 與 list marker 表現 | Partial：核心 copy 保留跨段 LF；外部 editor／list marker 為 U | adapt：保留標準 plain text fallback |
| AF-F21-02 | F21 | 外部 plain text／Markdown／HTML 樣本 | Ctrl+V 與 Ctrl+Shift+V | 產生的 Blocks/marks、selection、一次 undo、未知內容 fallback | Partial：官方 plain／HTML／unformatted／multi-node paste tests 通過；Markdown／外部快捷鍵／undo 為 U | adapt：格式化與純文字入口分離，unknown fallback 待定 |

## 解除阻塞選項（決策記錄）

### A. 研究專用相容補丁（已採用）

將官方 package 複製到隔離研究目錄，只補上與 Flutter 3.44.2 default 相同的
`bool onFocusReceived() => false`，並把版本標記為 `6.2.0+notist-baseline.1`。保留原始 archive hash、
補丁 diff 與 patched tree hash，所有結果都標示「patched baseline」，不得宣稱官方 6.2.0 原樣通過。

取捨：最快取得 Windows 行為資料，但 focus 行為多了一個研究補丁，F01 與 focus-related cases 必須保留
此限制。

### B. 並存相容 Flutter SDK

另裝 Flutter 3.38.x，不修改目前 Notist SDK，也不修改 AppFlowy package；用相同 package hash 建立基準。
實際可用的 3.38.x patch 與下載 SHA-256 尚未查證。

取捨：最接近官方宣告的原始套件環境，但需要大型 SDK/engine 下載，且與 Notist 現行 3.44.2 不同；
蒸餾後仍須驗證 Krepis/Notist 的 3.44.2 行為。

### C. 等待上游相容版本

保持本文件 blocked，直到 AppFlowy 官方發布支援 Flutter 3.44.2 的 package，再另行裁決是否重設 baseline。

取捨：沒有本地補丁，但阻塞整個 P0 實機研究，且違反目前「第一 Wave 前固定 6.2.0」的決策。

## 驗收出口

解除阻塞後，只有同時具備以下證據才可把狀態改成 `Baseline in progress`：

1. package、SDK 與任何 compatibility patch 都有 SHA-256／diff。
2. `flutter analyze --fatal-infos`、widget test、Windows Debug build 全部 exit code 0。
3. Windows 成品實際啟動，畫面明確顯示 package、Flutter、Dart 與 P0 case IDs。
4. 實際運行截圖可讀，且不是 widget/golden test 畫面。
5. 每個 P0 case 未實測欄仍標 `U`，不得以成功啟動畫面冒充行為完成。

上述五項已滿足，因此狀態改為 `Baseline in progress`。要改成 `Baseline complete`，仍須完成表中所有
原生 UI 操作與外部 clipboard cases，並各自留下操作後與 undo 後證據。
