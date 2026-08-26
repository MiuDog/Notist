# Spec: markdown-file-intent

狀態：Implementation complete；功能與 Windows Release 已驗證（2026-08-24；Phase 7）

## Outcome

Windows 使用者可從既有 Kallopis 頁面選單選擇 `.md`、把 `.md` 拖入 Notist，或以 `.md` 路徑啟動
Notist；三種入口都讀取同一份來源 bytes，建立新 Flow，並沿用 Phase 6 的 Krepis Markdown transaction、
保存與 Explorer 發布路徑。

## In scope

- Windows 原生 `.md` open-file dialog，不新增 Flutter file-picker 或 Markdown dependency。
- Windows `WM_DROPFILES` 與 Dart entrypoint arguments。
- 來源副檔名、一般檔案、8 MiB 上限與嚴格 UTF-8 驗證。
- 檔名 stem 作新 Flow 初始標題；Explorer 選取資料夾仍決定建立位置。
- 成功保存後才發布並選取新 Flow；來源 `.md` 永不修改。
- 頁面選單只以 `KlpContextMenu`、`KlpMenuItemData` 與既有 `KlpIconButton` 組合。

## Out of scope

- 寫入 Windows Registry、安裝程式層的預設檔案關聯或 single-instance 轉送。
- 多檔批次進度 UI、重複檔案偵測、watch、同步、export 與 Markdown source mode。
- 修改 Krepis parser／transaction、Kallopis token／元件或 Flow persistence schema。

## Behavior and architecture

1. View 只把「選檔」轉為 intent；Windows dialog 與 drop 由 runner adapter 提供。
2. `NotistProjectController` 在配置 Flow 路徑前先讀取、驗證來源，再把 UTF-8 與 stem 傳給既有 importer。
3. 來源不合法、超過 8 MiB、不是 `.md`、讀取失敗或 Krepis 匯入失敗時，不發布新 Flow。
4. 有選取資料夾時新 Flow 建立於該資料夾；無資料夾 intent 時建立於專案根目錄。
5. 啟動參數與拖放可包含多個路徑，必須依輸入順序逐一處理，不平行爭用 create operation。
6. runner 只傳 UTF-8 路徑，不讀 Markdown、不保存產品狀態。

## Impact analysis

- Domain／infra：新增 Markdown source reader 與 typed source；不讓 `dart:io` 進入 View。
- State：project controller 新增 file import command，並讓 importer 接收初始 title。
- View：Workbench 接入 file intent；Stage 的既有 menu icon 開啟 Kallopis context menu。
- Windows：新增 `notist/file_intent` method channel、native dialog 與 `WM_DROPFILES`。
- Security：所有外部路徑在 I/O 邊界驗證；來源只讀，大小在配置目的 Flow 前檢查。
- Data：Flow schema 不變；檔名 stem 成為既有第一個 title paragraph。

## Acceptance criteria

1. source reader tests 證明合法 Unicode `.md` 可讀，來源 bytes 前後一致。
2. 非 `.md`、不存在、目錄、超過 8 MiB 與畸形 UTF-8 均 fail closed。
3. controller tests 證明 stem 傳入 importer、選取資料夾生效，失敗時不發布文件。
4. widget test 證明既有頁面 menu icon 開啟 `KlpMenu`，選檔後建立並選取新 Flow。
5. platform-channel tests 證明 picker 回傳路徑、drop paths 依序送入同一 handler。
6. Windows runner contract test 證明 open dialog、`DragAcceptFiles`、`WM_DROPFILES` 與 Dart arguments 接線存在。
7. Notist 不新增 Markdown parser／file-picker package，且畫面不新增自訂視覺元件。
8. Phase 7 target tests、真實 ABI consumer、Krepis CTest 與 Windows Release build 全部 exit code 0。

## Verification evidence（2026-08-24）

- Phase 7 source／channel／controller／widget／runner contract：`25` tests passed（加入 menu 驗收後重跑）。
- `flutter analyze --fatal-infos`：`No issues found!`。
- Windows Release：`build/windows/x64/runner/Release/notist.exe` 建置成功。
- 全套測試的功能項目通過；仍有另一工作流負責的三個 visual golden，以及同步新增但 Kallopis 尚未提供
  `KlpStageTitleLayout` 的 `stage_title_wrapping_test.dart`，均非本 Phase 7 變更。
