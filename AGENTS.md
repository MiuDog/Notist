# Jotist — Agent 作業入口（AGENTS.md）

Jotist 是**一個刻意平凡的筆記 app**，Flutter 撰寫，是 [Krepis](https://github.com/MiuDog/Krepis)
基座庫的第一個消費者。Dart 程式碼在 `lib/`，各平台外殼在 `windows/`、`linux/`、`macos/`、
`android/`、`ios/`。

本檔為通用入口（Codex 等工具原生讀取；CLAUDE.md / GEMINI.md 內容應與本檔一致或直接指向本檔）。

## 你必須遵守的規範（按順序讀）

1. `.agents/skills/agent-entry/SKILL.md` — 入口：角色判定、任務分型、硬規則、衝突裁決（最先讀）。
2. `.agents/skills/work-protocol/SKILL.md` — 執行紀律與回報合約（所有任務必讀）。
3. 依任務型態加讀：`task-planning` / `task-development` / `task-delivery`；需求模糊先讀 `human-intent`；
   可派 subagent 的指揮側加讀 `model-dispatch`。

## 硬規則摘要（完整版在上述技能）

- 完成＝證據（測試輸出尾行、exit code、來源引用）；「應該可以」不是完成。
- 同一錯誤最多修兩次，第三次帶完整失敗軌跡回報或升級。
- 大檔（>200 行或大小不明）先內容搜尋定位再分段讀，不整檔讀。
- 查不到的事實標「未查證」，嚴禁編造 API、路徑、來源。

### 本專案特有硬規則

- **平凡是這個專案的功能，不是缺陷。** Jotist 的作用是逼 Krepis 的 API 停在「筆記」抽象層。
  **它變複雜就失去作用。**
- **刻意不做**（這是紀律，不是待辦）：規格工程、conformance、治理迴圈、repo binding、
  code anchor、workflow 定義與匯出、任何「聰明」的組織功能。需要這些的產品是 Planist。
- **Flutter 這一層必須維持薄。** 只做：把 Krepis 的版面結果畫出來、把輸入事件轉成 command、
  ink 快速路徑的實際繪製。**在此累積權威性邏輯是架構偏移的徵兆**——資料、版面、selection、
  undo、authority 一律屬於 Krepis。
- **註解一律繁體中文**，identifier、測試名稱、`expect` 的 `reason` 維持英文。

## 環境事實

實測於 2026-08-16，Windows 11 Home 26200。**只增不猜。**

| 項目 | 值 |
|---|---|
| Flutter SDK | `C:\development\flutter`（`bin\flutter.bat`） |
| **flutter 不在 PATH 上** | 必須用完整路徑呼叫 |
| 建立參數 | `--org io.github.miudog --project-name jotist` |
| 目標平台 | windows、linux、macos、android、ios |

```
C:\development\flutter\bin\flutter.bat run -d windows
```

## 目前狀態

**骨架階段，尚未進入實作。**

**Krepis 的 spike 2（C++ 版面引擎 ↔ Flutter 的 FFI 每次按鍵往返延遲）通過前不要在此撰寫實作。**
該 spike 不通過則整個 C++ 核心架構不成立，本專案會需要重新設計。

## 規則衝突時

依 `agent-entry` 的「規則衝突裁決」節（使用者當下指示 > 本檔 > agent-entry 與 work-protocol
> 各任務型 skill > 模板）；裁決不了就用 human-intent 的批次提問格式問人類。
