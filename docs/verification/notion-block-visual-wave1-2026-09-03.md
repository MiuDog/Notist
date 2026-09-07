# Notion-like Block 視覺蒸餾 Wave 1 驗證

狀態：完成（2026-09-03）

## 交付範圍

- Krepis `8016095d50d3f8cfc91a2dd86cbfd543ee87ed7d` 新增文字與整 Block selection 的明確模式，
  並以 ABI 1.10 投影到 consumer；Block selection 在穩定刪除命令完成前拒絕文字輸入、Enter、Backspace
  與 IME composition。
- Notist 只消費 provider selection mode，不保存第二份選取真相；內容點擊維持文字模式，六點把手才要求
  Block selection。
- Block chrome 預設隱藏六點把手，只在 hover、keyboard focus 或 selected 顯示；selected 使用 Kallopis
  公開 selection surface，不在 Notist 寫入字面顏色或圓角。
- Krepis 尚未提供 revision-aware insert command，因此沒有顯示可點擊的新增入口。

## 機械證據

| Gate | 結果 |
|---|---|
| Krepis `flow_editor` 與 `block_core_abi_consumer` | 2/2 passed；exit code 0 |
| Flutter 真實 ABI 1.10 DLL consumer | 1/1 passed；exit code 0 |
| Wave 1 目標 widget／lifecycle／ABI／semantic tests | 21/21 passed；exit code 0 |
| Block chrome hover／focus／selection tests | 5/5 passed；exit code 0 |
| Notist 完整 `tool/verify.ps1 -BuildWindowsRelease` | 157/157 tests passed；Debug 與 Release build 成功；exit code 0 |
| Dart format | 136 files，0 changed |
| Flutter analyze `lib test` | No issues found |
| `git diff --check` | exit code 0 |

Krepis 全量 Debug `ALL_BUILD` 曾被執行環境同時存在 `Path`／`PATH` 鍵阻擋；Wave 1 直接相關 targets
與 C ABI consumer 已獨立通過，而 Notist 完整 Verify 又從固定 GitHub commit 成功完成 Debug／Release
原生整合建置。此環境問題沒有被改寫成通過。

## Windows 成品

| 檔案 | SHA-256 |
|---|---|
| `build/windows/x64/runner/Release/notist.exe` | `c53f42e1b5fdfc4b43de2a3734a55ad42bc7ef15ad7f189d3fbb9178264d093a` |
| `build/windows/x64/runner/Release/data/app.so` | `f57262556d42fbe3d94a04d7dbd7d0c417d59e7bacbdb4b8a6acb415f2db2180` |
| `build/windows/x64/runner/Release/krepis_c.dll` | `599ddf77460ef2bd04f78626ecdb548c063906851077a226a524d1e5304181c6` |

## Windows 實機視覺證據

使用者由 Windows 互動桌面手動啟動同一 Release 成品，PID 5456；畫面載入既有真實 Flow `1231`，
不是 hard-coded fixture、widget test 或 golden。由於 Flutter 自繪視窗未提供可辨識的
`MainWindowHandle`，截圖以人類將 Notist 維持前景、工具延遲擷取完整桌面的方式取得。

| 狀態 | 證據 | SHA-256 | 觀察 |
|---|---|---|---|
| default／text caret | [實機圖](evidence/notist-block-wave1-default-2026-09-03.png) | `1748073dc298c6cbd72d300cff8bb1b9a3216adc4a65d286df162a09693fe282` | 第一個 Block 有 caret，左側 chrome 不常駐 |
| hover | [實機圖](evidence/notist-block-wave1-hover-2026-09-03.png) | `c56bdd6832ec04d2fd1bc774e1e05230916370c9239e4a01ffa4f8542afe4162` | 第一個 Block 左側顯示更多與六點把手 |
| Block selected／menu open | [實機圖](evidence/notist-block-wave1-selected-2026-09-03.png) | `e5c1f799815a361237ee8ed04f5149d0fc53ce901e2ad2b36d4e9d13d4e2bbc4` | 面狀 highlight 生效；選單依 V3-A 分流文字與區塊操作；未完成的刪除命令誠實顯示不可用 |

keyboard focus 顯示時機由 `nts_block_test.dart` 的 Windows widget 行為測試證明；實機嘗試時 provider
仍維持 Block selected，畫面無法隔離純 focus 狀態，因此該圖已刪除且沒有列為證據。

## 啟動診斷補充

同一 Release 成品依序以直接執行、一般桌面視窗及使用者核准的 Explorer 互動桌面方式啟動。三次程序
PID 分別為 41212、27232、22988；程序皆存活並載入 `notist.exe`、`flutter_windows.dll` 與
`krepis_c.dll`，但 `MainWindowHandle` 為 0，系統列舉的頂層視窗數也為 0。

這是代理程序建立 GUI 的桌面隔離限制，不是 Release 無法顯示：使用者手動啟動後畫面正常。診斷時
誤擷取到前景 Codex／Designist／VS Code 的圖片均已立即刪除，未納入證據；也沒有以 widget／golden
圖替代上述三張實機圖。
