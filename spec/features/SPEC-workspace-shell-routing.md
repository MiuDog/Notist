# Spec: workspace-shell-routing

狀態：Superseded（2026-08-24；由 `SPEC-absolute-golden-layout.md` 取代）

> 本文件保留 2026-08-23 的歷史路由決策；目前 shell 與視覺契約一律以
> [`SPEC-absolute-golden-layout.md`](SPEC-absolute-golden-layout.md) 為準。

## Objective

建立 Notist 第一個不冒充資料完成的桌面工作區垂直切片。Windows 使用者啟動 App 後，能看見已確認的 Primary Sidebar 組合，並在單一中央 Stage 間切換五個固定目的地。

本模組只建立組合、導覽與誠實狀態。尚未具備資料契約的功能顯示 empty／unavailable state；不使用假筆記、展示頁、固定保存成功或假統計填滿畫面。

### User-visible behavior

1. Primary Sidebar 依序顯示專案識別 Header、32px token 驅動的「專案／工具」雙區切換與內容區；專案區直接顯示 Flow FileExplorer，工具區依序顯示快速搜尋、Journal、Notist AI、資產庫。
2. FileExplorer 必須使用 `KlpFileExplorer`；沒有真實文件 source 時顯示「尚無 Flow」empty state。
3. 點擊任一固定入口，只替換中央 Stage；畫面永遠沒有 tabs、split、Secondary Sidebar 或 Inspector。
4. 第一次啟動預設顯示專案首頁 empty state。
5. Stage Header 使用 Kallopis 兩行識別元件，依序顯示真實專案／目的地與文件名稱；沒有文件時不顯示假文件操作。
6. Stage 底部以 `KlpStatusBar` 呈現本機狀態並保留 `workspace-status-slot` key；沒有真實保存結果時只顯示未啟用／未建立，不顯示假成功、字數、協作或同步資訊。
7. Window Header 只由 `KlpApp` 建立一次；Notist 不傳入自訂 `windowHeader`，也不在其外再加垂直 padding。

## Tech Stack

- Flutter `3.44.4` stable、Dart `3.12.2`。
- Kallopis path dependency：只使用 `lib/kallopis.dart` 的公開 API。
- 本模組不呼叫 Krepis，也不新增 package dependency。
- 固定目的地使用 Notist-owned typed enum／registry；文件 ID 不屬於固定目的地，也不進入本模組。

## Commands

完整驗證：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1
```

如核准更新三張 golden，產生新的主畫面與隔離 prototype 基準：

```powershell
C:\development\flutter\bin\flutter.bat test --update-goldens test/main_visual_golden_test.dart test/note_page_visual_golden_test.dart
```

Windows 人工檢查：

```powershell
C:\development\flutter\bin\flutter.bat run --debug -d windows
```

## Project Structure

- `lib/src/shell/`：固定目的地 contract 與 Workbench 選取狀態。
- `lib/src/sidebar/`：Primary Sidebar 組合及 FileExplorer empty／data projection。
- `lib/src/stage/`：單一 Stage 的 header、目的地內容與 status slot。
- `lib/src/stage/notist_*_page.dart`：Flow／Canva／Sheet prototype；本模組不改，僅供 Catalog 使用。
- `test/`：destination、composition 與負面路徑 widget tests。
- `test/goldens/`：已核准的 1400×900 主畫面基準。

## Code Style

使用 typed destination 作唯一 registry，避免在 Sidebar、Workbench 與 Stage 重複 route string：

```dart
enum NotistWorkspaceDestination {
  project(id: 'project', label: '專案'),
  quickSearch(id: 'quick-search', label: '快速搜尋');

  const NotistWorkspaceDestination({required this.id, required this.label});

  final String id;
  final String label;
}
```

Dart 排版以 `dart format` 為準；程式註解使用繁體中文，identifier 與測試名稱使用英文。元件色彩、間距、圓角、字體與動效只取自 Kallopis token／公開元件。

## Testing Strategy

1. Unit contract：目的地固定為五項，ID／label 唯一且順序固定。
2. Widget composition：驗證 Sidebar 雙區切換高度、工具按鈕順序、selected state、單一 Stage、empty Explorer 及五個目的地切換。
3. Negative assertions：production tree 不得出現舊假筆記、Flow／Canva／Sheet prototype、額外 Window Header 或假保存／同步文字。
4. Visual regression：只在使用者核准後更新主畫面 golden，並把 Canva／Sheet golden 改成直接渲染 Catalog-owned prototype 的隔離 fixture；不得放寬 threshold 或刪除測試。
5. 完成證據只採唯一 `Verify` 的 exit code 與輸出尾行。

## Boundaries

- Always：只使用 Kallopis 公開入口；所有目的地由單一 typed registry 供應；未完成能力使用明確 empty／unavailable state；保留現有 dirty worktree 的不相關變更。
- Ask first：更新 golden、新增 dependency、改 Krepis C ABI、接受或改寫 NTS ADR。
- Never：把文件 ID 當固定 feature route；在 runtime 保存 hard-coded Folder／Note truth；用 Flow／Canva／Sheet prototype 冒充功能頁；在沒有真實結果時顯示 `Saved`、字數、同步或協作狀態。

### Frozen areas

- `C:\Projects\Krepis\**`
- `C:\Projects\Kallopis\**`（本批僅解除 `KlpStageHeader` 公開元件；使用者已於 2026-08-23 明確核准）
- `lib/src/krepis/**`
- `lib/src/note/**`
- `lib/src/stage/notist_flow_page.dart`
- `lib/src/stage/notist_canva_page.dart`
- `lib/src/stage/notist_sheet_page.dart`
- `lib/catalog/**`
- 平台 runner、圖示、package dependency 與五份 NTS ADR

## Success Criteria

1. 測試讀取目的地 registry，精確得到 `專案 → 快速搜尋 → Journal → Notist AI → 資產庫`，且 ID／label 無重複。
2. 1400×900 widget test 找到一個 `NotistWorkbench`、`NotistSidebar`、`NotistStage`，確認「專案／工具」切換器高度等於 Kallopis dense segmented token，並確認 `KlpWorkbenchShell.secondaryVisible == false`。
3. Widget test 經由雙區切換逐一點擊五個入口；每次只存在對應 destination key，前一個 destination key 消失，Sidebar selected semantics 同步。
4. 空專案 widget test 找到 `NotistSidebarExplorer` 與「尚無文件」empty state，production tree 找不到任何舊 hard-coded Folder／Note label。
5. 所有 destination 下都找不到 `NotistFlowPage`、`NotistCanvaPage`、`NotistSheetPage`、`KlpBreadcrumb`、`KlpTabs` 與 `KlpSplitLayout`；找到 `KlpStageHeader`、`KlpStatusBar` 與唯一 `workspace-status-slot` key。
6. 所有 destination 下都找不到 `Saved`、`words`、`cards`、`rows`、`synced` 等假成功／統計文字。
7. 每個 destination 的 Stage Header 精確顯示專案／目的地與目前真實 title，上一個 title 不再作為 header。
8. `NotistApp` 只渲染一個高度等於 `windowToolbarHeight` 的 `KlpWindowHeader`，且 `KlpAppScreen` 不提供第二個 window header。
8. 既有 Catalog contract tests 仍涵蓋 Flow／Canva／Sheet／Backgrounds prototype；Canva／Sheet golden 不再透過 production Explorer 或假 note route 建立 fixture。
9. `pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1` exit code 為 0。

## Resolved Questions

1. Q1 A：第一批預設目的地為「專案」。
2. Q2 A：核准更新三張 golden，Canva／Sheet 遷成隔離 prototype fixture。
3. Q3 A：同批更新 `AGENTS.md`／`README.md` 的產品定位、ownership 與實作狀態。
