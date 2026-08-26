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

## 硬規則摘要（完整版在上述技能）

- 完成＝證據（測試輸出尾行、exit code、來源引用）；「應該可以」不是完成。
- 每個可交付版本完成前，必須產出可執行編譯成品、在目標實機環境啟動，並附上該成品的實際運行截圖；golden／widget test 截圖不得替代實機證據。
- 同一錯誤最多修兩次，第三次帶完整失敗軌跡回報或升級。
- 大檔（>200 行或大小不明）先內容搜尋定位再分段讀，不整檔讀。
- 查不到的事實標「未查證」，嚴禁編造 API、路徑、來源。

### 本專案特有硬規則

- **Notist 擁有產品組合與使用者體驗。** Workspace route、Sidebar、功能頁、選單內容、快捷鍵政策、
  AI session／proposal 與保存／協作狀態投影留在本專案。
- **Kallopis 只提供無產品語意的視覺與通用互動。** Notist 消費 `lib/kallopis.dart` 公開入口；
  Note、Block、Ink、Chat 或保存狀態模型不得下沉到 Kallopis。
- **Krepis 是筆記資料與編輯真相。** 內容、schema、selection、transaction、undo、layout、
  persistence、Ink 與 note authority 不得在 Flutter 複製第二份。
- **未完成能力必須誠實呈現。** 沒有真實資料／結果時使用 empty、unavailable、saving 或 failure；
  禁止以 hard-coded notes、展示頁、固定 `Saved` 或假統計冒充完成。
- **第一版中央只有一個 Stage。** 不做 split；tabs 不是第一版範圍；Secondary Sidebar／Inspector
  只有另立規格並核准後才能加入。
- **註解一律繁體中文**，identifier、測試名稱、`expect` 的 `reason` 維持英文。

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

跨倉 capability map 已於 2026-08-23 核准，功能依 `CAPABILITY-MAP.md`、`spec/features/` 與
`tasks/` 的核准閘門分批實作。Krepis Paragraph-only Flow Editor 的 machine gate 已通過；尚未完成的
Block、Ink、authority 契約仍必須先在提供者層關閉對應 gate，不能由 Notist 代作。

## 規則衝突時

依 `agent-entry` 的「規則衝突裁決」節（使用者當下指示 > 本檔 > agent-entry 與 work-protocol
> 各任務型 skill > 模板）；裁決不了就用 human-intent 的批次提問格式問人類。
