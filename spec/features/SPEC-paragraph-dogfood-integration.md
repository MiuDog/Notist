# Spec: paragraph-dogfood-integration

狀態：Implemented（2026-08-23；P1 production dogfood）

## Outcome

Windows 使用者在 Project destination 取得由 Krepis authority 驅動的 Paragraph dogfood Flow 專案。
使用者可建立、列出與切換多份本機 Flow；每份 Flow 的 stable root ID 與標題投影由 Krepis 提供，
Notist 只擁有 app-managed 目錄、排序與目前 route。文件可輸入文字、使用中文 IME、Enter、Backspace、
undo／redo，並以 Krepis 暫存格式保存及重開。此切片是 production dogfood，不代表正式 persistence schema。

## In scope

- Project Stage 掛載唯一的 `NotistFlowEditor`，其餘四個固定 destination 維持 unavailable page。
- 空專案、新增 Flow、Explorer 清單、stable root selection 與同一標題 truth 的產品投影。
- Krepis C ABI 投影主要 Flow root ID 與第一個 Paragraph 標題，並進行 ABI minor 協商。
- `KrepisEditorController.open` 必須接受明確 `filePath`，且新檔預設內容為空字串。
- Flutter widget test 可注入 opener，驗證 open request、loading、load failure 與 retry，不載 native DLL。
- 移除 editor 的任意 fallback；native 啟動或載入失敗時使用 Kallopis error state。
- 將 `NotistFlowPage` 收斂成純 Catalog fixture，保留既有視覺內容但不再包住 native editor。
- 保存投影區分 idle、localLoaded、saving、localSaved、failed；只有真實 native save
  成功才能進入 localSaved，只載入既有檔時投影 localLoaded。
- 保存失敗不丟棄已被 Krepis 接受的記憶體內容，顯示失敗並允許重試相同文件路徑。
- Project Stage 底部 status slot 投影 dogfood 保存狀態，文案明示「本機測試暫存」。
- 建立固定日期的 Notion Windows／QWERTY Block 行為基準；官方來源未確認的項目標示未查證。

## Out of scope

- 不建立正式 P4 Project／Folder／Page schema；本批僅有 Notist-owned local directory lifecycle。
- 不建立獨立 title metadata 或 rename command；標題就是第一個 Paragraph 的一般文字 transaction。
- 不把 dogfood codec 宣稱為正式 persistence，不新增 migration 或相容性承諾。
- 不實作 Todo、多種 Block、Slash Menu、Block handle、多 Block selection 或右鍵命令。
- 不接 Ink、Quick Search substrate、AI model／MCP、Journal 資料或協作 authority。
- 不修改 Kallopis、native runner、Page-kind ADR、Canva／Sheet prototype；Krepis 僅擴充 Flow
  root／標題投影與 ABI 1.1，Flow prototype 只做解除 native coupling 的必要遷移。

## User-visible behavior

1. 啟動後預設 Project destination；空專案在 Explorer 與 Stage 顯示新增 Flow 動作。
2. 新增成功後才發布 Explorer item，並在單一 Stage 開啟空白第一個 Paragraph；
   「未命名 Flow」只是非持久化 placeholder。
3. 開啟成功後中央呈現真實 Krepis Flow editor；Explorer 與 Stage header 投影同一 Krepis 標題。
4. native DLL 缺失、檔案損毀或讀取失敗時顯示「無法開啟本機測試文件」與重試動作。
5. 編輯造成保存失敗時，editor 保持可見，底部顯示「本機測試暫存失敗」與重試動作。
6. 保存成功後只顯示「本機測試暫存已保存」，不得顯示正式同步、協作或一般化 `Saved`。
7. 離開 Project destination 時 editor 被 dispose；返回時以相同路徑重新開啟。

## Functional and data contracts

```dart
final class KrepisEditorOpenRequest {
  const KrepisEditorOpenRequest({
    required this.filePath,
    this.initialText = '',
  });

  final String filePath;
  final String initialText;
}

typedef KrepisEditorOpener = Future<KrepisEditorAuthority> Function(
  KrepisEditorOpenRequest request,
);

enum NotistLocalSaveState { idle, localLoaded, saving, localSaved, failed }
```

- `filePath` 由 Notist composition root 注入；controller 不讀隱藏的全域 dogfood path。
- `rootId` 是 Krepis 主要 Flow 128-bit ID 的 32 位小寫 hex；不得由檔名或排序推導。
- Notist create／load 必須序列化或 generation-safe；發布前拒絕重複 root ID。
- 路徑不存在才呼叫 initialize；既存但 corrupt／版本不相容的檔案 fail closed，不得覆寫。
- 內容、selection、caret、revision、undo／redo 與 display list 只來自 Krepis authority。
- Notist save projection 以 localLoaded 投影已載入的最後成功檔案；saving／localSaved／failed
  只接收真實 save attempt 事件，不從 load 推測保存成功。
- Retry 只對同一個 authority 與同一路徑重試保存；不得以重新 open 覆蓋記憶體 revision。
- Save projection 必須綁定文件 session；文件切換、open failure 與 dispose 會使舊 retry 失效。
- Windows Backspace 的 KeyDown 與 KeyRepeat 都必須轉成 Krepis authority intent；IME composition
  進行中不可拆走輸入法的刪除鍵。
- Windows redo 同時支援 `Ctrl+Y` 與 `Ctrl+Shift+Z`，兩者都使用同一 Krepis history truth。

## Visual contract

- loading 使用 `KlpLoadingState`；load failure 使用 `KlpErrorState`。
- Stage status 使用 `KlpStatusIndicator` 與 Kallopis semantic tokens，不寫死顏色、間距或時長。
- save failure retry 位於 status slot，editor surface 不被 error page 取代。
- 第一版仍只有單一 Stage；無 tabs、split、Secondary Sidebar 或 Inspector。

## Architecture constraints

- Notist 只擁有 app-managed directory、清單排序、route、open request、save projection 與錯誤文案。
- Krepis 是 Paragraph content、edit、selection、undo、render 與 dogfood file 的唯一 authority。
- Widget tests 只可注入 pending／throw opener 或 UI projection；不得製造假的 Krepis 內容成功證據。
- 真實編輯與 persistence 只能由 Windows DLL integration／人工驗收宣告通過。
- `NotistFlowPage`、`NotistCanvaPage`、`NotistSheetPage` 仍只供 Catalog／fixture 使用；Flow fixture
  不得建立 native authority。

## Failure and edge cases

- 非 Windows：明確 unavailable，不嘗試載入 DLL。
- DLL 缺失：load failure＋retry，不顯示 fallback 筆記。
- 路徑含 Unicode 或空格：完整傳入 native，不自行轉碼或拆解。
- corrupt／unsupported file：fail closed，原檔 hash 不變。
- save failure：刷新 authority snapshot、保留 dirty revision、顯示 retry；不得宣稱 rollback。
- route 快速切換：過期 open future 完成後必須 dispose，不得 setState 或留下第二 authority。
- 並行 create／load-create race：只執行一個建立流程，不得讓成功落盤的 Flow 從 UI 消失。
- duplicate root：整個 load／create fail closed，不發布含歧義 ID 的 Explorer projection。
- ABI 舊版：在 lookup Flow projection extension 前先拒絕不支援的 minor version。

## Acceptance criteria

1. Widget test 捕捉 Project editor request，精確得到明確路徑與 `initialText == ''`。
2. pending opener 時只找到 loading state；找不到舊 Flow prototype 與英文展示內容。
3. opener throw 時找到 load error 與 retry；retry 對完全相同 request 發出第二次 open。
4. 五個 destination 中只有 Project 掛載 Paragraph dogfood host，且 shell 仍無 tabs／split／secondary。
5. save projection test 證明 idle／localLoaded／saving／localSaved／failed 文案互斥，
   未收到成功事件前不出現 localSaved。
6. Windows 實機證明空白新檔、中文 IME、Enter、段首 Backspace、undo／redo、保存及重開一致。
7. Windows 實機證明不可寫路徑顯示 save failure，retry 不丟失記憶體內容。
8. Notion behavior baseline 每條規則包含來源、查證狀態、平台與擷取日期。
9. 1400×900 主畫面 Golden 顯示可重現的 editor loading 與本機測試暫存狀態，不使用 fake ready authority。
10. `tool/verify.ps1` exit code 0，format、analyze、全部 tests 均成功。
11. Project lifecycle tests 證明 concurrent create、load-create race、create failure 與 duplicate root fail closed。
12. Krepis ABI tests 證明 minor version、struct size／capacity／ready validation；Dart test 證明 high-bit root
    正規化為 32 位 hex。

## Verification evidence

完整記錄見 [`docs/verification/paragraph-dogfood-windows-2026-08-23.md`](../../docs/verification/paragraph-dogfood-windows-2026-08-23.md)。

```powershell
C:\development\flutter\bin\flutter.bat test test/project_paragraph_composition_test.dart test/notist_flow_editor_lifecycle_test.dart test/save_state_projection_test.dart
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1
C:\development\flutter\bin\flutter.bat run --debug -d windows
```
