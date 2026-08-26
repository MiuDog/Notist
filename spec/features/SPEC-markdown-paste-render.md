# Spec: markdown-paste-render

狀態：Implementation complete；功能／provider／Windows Release 已驗證，視覺 golden 由另一工作流處理
（2026-08-24；Phase 6）

## Outcome

使用者在目前 Flow 按下 `Ctrl+V` 後，剪貼簿文字由 Krepis 原生 Markdown parser 轉成 native Flow
Blocks，以單一 revision-aware transaction 發布，並由既有 display list 自動渲染與保存。
`Ctrl+Shift+V` 保留純文字貼上入口。若 `Ctrl+V` 發生在 Explorer，Notist 建立一份新 Flow：
有選取資料夾時建立於該資料夾，否則建立於專案根目錄；成功保存後才發布到 Explorer。

## In scope

- Windows／Flutter clipboard text intent。
- `Ctrl+V` 貼上並格式化；`Ctrl+Shift+V` 貼上純文字。
- Krepis C ABI 接收 UTF-8、base revision、Block 位置與時間戳。
- 8 MiB、UTF-8、stale revision 驗證與單筆 undo／redo。
- 匯入後沿用既有 Flow projection、display list 與本機保存。
- fallback diagnostic 數量投影；不在 Flutter 解析 Markdown。
- Explorer 焦點貼上建立新 Flow，並依選取資料夾或專案根目錄配置路徑。
- 專案資料夾由 store 掃描並投影成 `KlpFileExplorer` 樹狀節點。

## Out of scope

- `.md` 檔案選擇器、拖放與檔案關聯；保留給下一階段。
- Markdown source mode、export、雙向 round-trip、HTML 執行、網路資產與 Mermaid。
- Table、Todo、image 的完整 native mapping 與逐 byte source-slice diagnostic。
- 修改 Kallopis 視覺規則或 Flow persistence schema。

## Behavior and architecture

1. Notist 只讀取剪貼簿並傳遞使用者 intent；Markdown 語法與 Blocks 由 Krepis 決定。
2. Krepis 在發布前完成大小、UTF-8、revision 與 fragment 驗證；失敗時文件不可部分改變。
3. 空白 Flow 的目前 Block 由匯入 Blocks 取代；非空 Flow 在目前 Block 後插入。
4. 成功後同一 authority snapshot 立即提供新 Blocks；既有 renderer 與 save projection 自動接續。
5. 格式化貼上整批只增加一筆 undo；純文字貼上沿用既有文字 transaction。
6. Explorer 貼上不修改目前 Flow；它配置新路徑、開啟空 Flow、呼叫同一 Markdown authority、
   保存成功後才發布新文件並選取它。
7. Explorer 的資料夾選取是建立位置 intent；選取 Flow 則切換文件並清除資料夾 intent。
8. store 只接受專案內既有相對資料夾；拒絕絕對路徑、`..` 與離開專案根目錄的連結。

## Impact analysis

- Provider：Krepis `flow_editor`、C ABI、Markdown parser 與 provider/consumer tests。
- Consumer：Notist FFI binding、authority interface、Flow editor shortcut、project store/controller、
  `KlpFileExplorer` 語意組合與 widget tests。
- Public API：新增一個 append-only C ABI entry 與 Dart authority command；不改既有 struct layout。
- Data/security：不新增 Flutter AST 或 HTML renderer；來源剪貼簿不修改、不落第二份權威資料。
- UI：不新增自訂視覺元件；資料夾與文件都由 `KlpFileExplorer` 組合，Notist 只擁有產品語意與焦點路由。

## Acceptance criteria

1. Krepis C ABI 測試把 heading、list 與 inline marks 一次匯入，revision 只增加一次。
2. 匯入 100 Blocks 只增加一筆 undo；一次 undo／redo 可完整回復。
3. stale revision、超過 8 MiB 與不合法 UTF-8 都 fail closed，Block count／revision 不變。
4. Notist widget test 證明 `Ctrl+V` 呼叫 Markdown command，`Ctrl+Shift+V` 呼叫純文字 command。
5. 格式化貼上成功後 snapshot Blocks 由 authority 更新，既有 Flow renderer 保持唯一呈現路徑。
6. Notist 不增加 Markdown parser／HTML renderer dependency。
7. Krepis Debug CTest、Notist Verify 與 Windows Release build 全部 exit code 0。
8. project store 測試證明 nested Flow 可載入，指定資料夾與根目錄配置正確，路徑穿越被拒絕。
9. controller/widget 測試證明 Explorer 貼上建立新 Flow；選取資料夾時落在該資料夾，未選取時落在根。
10. 匯入或保存失敗時不發布新 Flow，既有文件與選取保持不變。

## Next phase readiness

下一階段只需在 Notist 增加 `.md` file intent（選擇器、拖放或檔案關聯）並把檔案內容送入本階段已完成的
project lifecycle；parser、atomic transaction、diagnostic count、渲染與保存路徑沿用本 Phase 6 契約，
不再新增 Markdown authority。

## Verification evidence（2026-08-24）

- Krepis WSL Debug build ＋ CTest：`44/44` passed，包含 `krepis.markdown_parser` 與
  `krepis.markdown_import_c_abi`。
- Krepis Windows Release：`build/Release/krepis_c.dll` 建置成功。
- Notist target regression：`34` tests passed；Explorer/store/controller 子集合 `20` tests passed。
- Notist real Windows ABI 1.3 consumer：`1` test passed。
- Notist `flutter analyze --fatal-infos`：`No issues found!`。
- Notist Windows Release：`build/windows/x64/runner/Release/notist.exe` 建置成功。
- Notist 全套測試：`110` passed、`1` native gate skipped、`3` 個既有視覺 golden 失敗；依使用者分工，
  golden 回饋由另一 AI 修正，不屬於本 Phase 6 功能變更。
