# Spec: absolute-golden-layout

狀態：Accepted（2026-08-24；2026-09-03 圖示資產政策修訂）

## Outcome

Notist 桌面 shell 完整仿作 `spec/references/notist-absolute-golden-layout.png` 的區域配置、資訊層級與互動位置；視覺風格不由 Notist 決定，全部使用 Kallopis 公開元件與 theme token。

2026-09-03 使用者明確指定 Kallopis 圖示預設一律使用 Flaticon 字型並棄用舊 SVG。此修訂只更新
圖示輪廓的 golden 像素，不改變本規格的區域、尺寸、位置與資訊層級。

## In scope

- 單一 Kallopis Window Header：Notist identity、側欄收合、快捷提示、Windows controls。
- 左側 Primary Sidebar：Flows identity、Journals／Notist AI／資產庫導覽、釘選／筆記 Explorer、本機狀態。
- 右側單一 Flow Stage：breadcrumb、Flow title／type、閱讀／輸入／手寫模式、頁面選單、Flow editor、保存與區塊狀態。
- 可拖曳並可收合的 268px 初始側欄；範圍 200–460px。
- 1600×1200 絕對 golden 與窄視窗 responsive contract。

## Out of scope

- 不修改 Krepis ABI、dogfood 格式、Flow transaction、selection、undo／redo、layout 或 persistence。
- 不實作 Journals、AI、資產庫的內容頁；這三項只維持附件指定的 sidebar selection。
- 不加入附件未出現的 Quick Search、Secondary Sidebar、Inspector、tabs 或 split Stage。
- 不從 Planist 複製色值、字型、圓角、陰影、控制高度或動畫。

## User-visible behavior

1. 啟動後只存在一個 Window Header；側欄收合按鈕貼齊 Primary Sidebar 右緣。
2. Header 左側顯示 Notist identity，右側顯示快捷提示及原生視窗控制。
3. Sidebar 頂部顯示 Flows identity 與本機使用者 avatar；其下固定排列 Journals、Notist AI、資產庫。
4. Journals 預設 selected；切換三個 sidebar destination 不卸載目前 Flow Stage。
5. `KlpFileExplorer` 固定建立「釘選」與「筆記」兩節；目前選取 Flow 投影至釘選，其餘真實 Flow 投影至筆記。沒有文件時顯示誠實 empty state。
6. Stage Header 顯示 `Flows / Flow`、真實 Flow title、`FLOW` 與閱讀／輸入／手寫／頁面選單動作。
7. Stage status 顯示真實保存狀態、Krepis block count 與「本機」；沒有資料時不製造成功或統計值。
8. 所有視覺元件均來自 `package:kallopis/kallopis.dart`；Notist 自行擁有的 widget 只負責 Flow／產品語意與 Klp 組合。

## Visual contract

- 區域順序不可改：Window Header → Primary Sidebar + resize handle + single Stage。
- Sidebar 初始寬度 268px，拖曳限制 200–460px；這是附件指定的產品布局常數，不是風格 token。
- Workbench 外距、pane gap、panel／stage surface、控制高度、文字、色彩、圓角與狀態效果全部沿用 Kallopis defaults。
- Stage content 保持單欄 Flow editor，不新增中央卡片、hero、統計格或裝飾背景。
- 絕對基準尺寸為 1600×1200；另在 1024×768 驗證不溢出。

## Architecture constraints

- Kallopis 擁有 `KlpWorkbenchWindowHeader`、`KlpSidebarIdentityHeader` 等無產品語意共用元件。
- Notist shell 只管理 sidebar width／visibility／destination selection 與 Flow projection。
- Krepis 仍是 title、block count、內容、保存與 editor state 的 authority。
- 一條視覺規則只能存在於 Kallopis；Notist 不寫色值、字型、圓角、控制高度或視覺 padding 常數。

## Failure and edge cases

- 無 Flow：Explorer 與 Stage 顯示 Kallopis empty state，status 不顯示已載入或虛構區塊數。
- 載入中／失敗：沿用既有 Kallopis loading／error state，shell 結構不位移。
- 保存失敗：顯示失敗與重試；不得仍標示成功。
- 窄視窗：Kallopis responsive shell 可收斂內容，但不可產生水平 overflow 或第二個 Stage。

## Acceptance criteria

1. Widget test 在 1600×1200 找到一個 `KlpWorkbenchWindowHeader`、`KlpPanelFrame`、`KlpFileExplorer`、`KlpStageFrame`，且只找到一個 Window Header。
2. Sidebar 初始寬度精確為 268px，包含 Flows、Journals、Notist AI、資產庫、釘選、筆記與本機 footer；找不到專案／工具 segmented switcher 或快速搜尋。
3. 點擊 Journals／Notist AI／資產庫只改 selected semantics；`workspace-project-page` 與目前 Flow editor 保持掛載。
4. 有真實文件時，Explorer 的釘選 section 只含 selected Flow，其餘文件位於筆記 section，選取 ID 來自 controller truth。
5. Stage Header 找到 `Flows`、`Flow`、真實 title、`FLOW`、三個 mode action 與頁面選單。
6. Stage status 的保存文字與 block count 來自 Krepis projection；無 projection 時不顯示假值。
7. 1600×1200 主畫面 matches `test/goldens/notist_main_visual.png`；基準更新必須對應本規格與使用者附件。
8. Kallopis `flutter analyze`／`flutter test`、Notist `Verify` 與 Windows Release build 全部 exit code 0。

## Verification

```powershell
C:\development\flutter\bin\flutter.bat test --update-goldens test/main_visual_golden_test.dart
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1
C:\development\flutter\bin\flutter.bat build windows --release
```
