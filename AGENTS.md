# Notist — Agent 作業入口（AGENTS.md）

Notist 是 Flutter 撰寫的個人／團隊知識工作區，也是 [Krepis](https://github.com/MiuDog/Krepis)
筆記核心的第一個產品消費者。產品以 Windows 桌面為第一驗收平台，服務需要自由筆記的學生、
開發者與一般使用者；Dart 程式碼在 `lib/`，各平台外殼在 `windows/`、`linux/`、`macos/`、
`android/`、`ios/`。

本檔為通用入口（Codex 等工具原生讀取；CLAUDE.md / GEMINI.md 內容應與本檔一致或直接指向本檔）。

## 你必須遵守的規範（按順序讀）

1. `.agents/skills/agent-entry/SKILL.md` — 入口：角色判定、任務分型、硬規則、衝突裁決（最先讀）。
2. `.agents/skills/work-protocol/SKILL.md` — 執行紀律與回報合約（所有任務必讀）。
3. 依任務型態加讀：`task-planning` / `task-development` / `task-delivery`；需求模糊先讀 `human-intent`；
   可派 subagent 的指揮側加讀 `model-dispatch`。
4. [`docs/architecture/frontend-boundaries.md`](docs/architecture/frontend-boundaries.md) — 前端 authority、
   筆記元件位置、Kallopis 公開 API 分級及 theme／environment／l10n 傳遞（所有開發 agent 必讀）。

## 硬規則摘要（完整版在上述技能）

- 完成＝證據（測試輸出尾行、exit code、來源引用）；「應該可以」不是完成。
- 每個可交付版本完成前，必須產出可執行編譯成品、在目標實機環境啟動，並附上該成品的實際運行截圖；golden／widget test 截圖不得替代實機證據。
- 同一錯誤最多修兩次，第三次帶完整失敗軌跡回報或升級。
- 大檔（>200 行或大小不明）先內容搜尋定位再分段讀，不整檔讀。
- 查不到的事實標「未查證」，嚴禁編造 API、路徑、來源。

### 本專案特有硬規則

- **Notist 擁有產品組合與使用者體驗。** Workspace route、Sidebar、功能頁、選單內容、快捷鍵政策、
  AI session／proposal 與保存／協作狀態投影留在本專案。
- **Kallopis 只提供無產品語意的視覺與通用互動。** 新程式依責任使用
  `kallopis_foundation.dart`、`kallopis_theme.dart` 或 `kallopis_experimental.dart`；
  `kallopis.dart` 只保留既有相容。Note、Block、Ink、Chat 或保存狀態模型不得下沉到 Kallopis。
- **Krepis 是筆記資料與編輯真相。** 內容、schema、selection、transaction、undo、layout、
  persistence、Ink 與 note authority 不得在 Flutter 複製第二份。
- **前端架構契約不得被繞過。** 筆記呈現元件集中在 `lib/src/components/note/`；Notist 只能 import
  Kallopis 的公開入口，禁止 `package:kallopis/src/...`。每次架構變更都必須執行
  `test/frontend_architecture_boundary_test.dart`，不得以新增例外規避失敗。
- **未完成能力必須誠實呈現。** 沒有真實資料／結果時使用 empty、unavailable、saving 或 failure；
  禁止以 hard-coded notes、展示頁、固定 `Saved` 或假統計冒充完成。
- **第一版中央只有一個 Stage。** 不做 split；tabs 不是第一版範圍；Secondary Sidebar／Inspector
  只有另立規格並核准後才能加入。
- **註解一律繁體中文**，identifier、測試名稱、`expect` 的 `reason` 維持英文。
- **第一版優先範圍依最新產品指示。** Notist 暫時移除手寫入口與操作，Krepis Ink 能力與既有資料保留；
  第一版必須涵蓋專案建立／進入／刪除、筆記建立／編輯／釘選／刪除、不可巢狀資料夾及可巢狀頁面。
  頁面採資料庫形式，包含自訂欄位、篩選、排序與多種視圖；詳細契約、owner 與視圖種類仍需逐步規劃及核准。
- **跨倉修改必須維持 authority。** Kallopis 的通用能力與公開 API 變更必須遵守
  [前端架構契約](docs/architecture/frontend-boundaries.md)；產品元件不得藉跨倉重構回流 Kallopis。
  缺少但尚未實作的通用元件記入[元件缺口清單](tasks/notist-kallopis-component-gaps.md)。
- **里程碑必須串行完成。** 每一步先完整規劃前端、核心或服務、資料契約、保存、錯誤恢復與測試路線，
  在適用範圍核准後，依「提供者實作 → 消費者接線 → 整合功能測試 → Windows 可執行成品實際啟動與截圖 → 獨立驗收」推進。
  當步功能完整性驗收有 fail、blocked 或未查證項目，不得進入下一里程碑；提供者單測、mock、golden 或歷史結果皆不能代替當步整合與實機證據。

## 環境事實

實測於 2026-08-16，Windows 11 Home 26200。**只增不猜。**

| 項目 | 值 |
|---|---|
| Flutter SDK | `C:\development\flutter`（`bin\flutter.bat`） |
| **flutter 不在 PATH 上** | 必須用完整路徑呼叫 |
| 建立參數 | `--org io.github.miudog --project-name notist` |
| 第一驗收平台 | Windows 桌面；其他 runner 保留但不屬目前 UI 驗收範圍 |

```
C:\development\flutter\bin\flutter.bat run -d windows
```

## 目前狀態

目前里程碑入口為 [功能里程碑修正版](tasks/notist-functional-milestones-20260907.md)，
執行狀態見 [里程碑追蹤](tasks/notist-functional-milestones-todo.md)。修正版目前是待核准草案；
舊 capability map 的核准只保留原責任與依賴效力，不代表新里程碑或功能完整性已核准、已完成。
2026-09-07 首版管理與資料庫需求見 [第一版範圍修訂](tasks/notist-v1-management-database-scope.md)；
需求已由使用者提出，不等於詳細方案或待裁決 ADR 已核准。

跨倉 capability map 已於 2026-08-23 核准，功能依 `CAPABILITY-MAP.md`、`spec/features/` 與
`tasks/` 的核准閘門分批實作。Krepis Paragraph-only Flow Editor 的 machine gate 已通過；尚未完成的
Block、Ink、authority 契約仍必須先在提供者層關閉對應 gate，不能由 Notist 代作。

## 規則衝突時

依 `agent-entry` 的「規則衝突裁決」節（使用者當下指示 > 本檔 > agent-entry 與 work-protocol
> 各任務型 skill > 模板）；裁決不了就用 human-intent 的批次提問格式問人類。
