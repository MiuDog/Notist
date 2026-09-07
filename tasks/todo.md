# workspace-shell-routing 任務清單

> 本檔保留歷史工作區外殼的任務與完成紀錄。當前功能排程請見
> [功能里程碑修正版](notist-functional-milestones-20260907.md) 與
> [里程碑追蹤](notist-functional-milestones-todo.md)；修正版待核准，不沿用本檔的 Completed 作為新里程碑驗收。

狀態：Completed（2026-08-23；Q1 A、Q2 A、Q3 A 全部驗收通過）

## Task WSR-B: Capture the dirty-worktree baseline

**Description:** 在任何 implementation patch 前，擷取能區分既有 dirty 內容與本批 delta 的機械基線，輸出保留於任務執行紀錄，不在工作樹新增產物。

**Acceptance criteria:**

- [x] Notist、Kallopis、Krepis 都記錄 HEAD 與 `git status --short`。
- [x] 每個計畫修改檔都記錄存在狀態與 SHA-256；未追蹤檔不得只記錄目錄級 `??`。
- [x] Notist 凍結區與本批實際消費的 Kallopis public source 都記錄逐檔 SHA-256。

**Verification:**

- [x] Baseline record 能列出完整路徑、hash，且不存在的預計新增檔標記為 absent。
- [x] 基線擷取前尚未執行任何產品 implementation patch、formatter、golden update 或測試寫入。

**Dependencies:** 使用者核准本計畫。

**Files likely touched:** None。

**Estimated scope:** Extra small，read-only evidence。

## Task WSR-0: Align governance entry

**Description:** 將專案入口更新為已核准的 Notist 定位、三層 ownership 與目前可實作狀態；保留使用者既有 rename、Catalog 與 Verify 說明。

**Acceptance criteria:**

- [x] `AGENTS.md` 與 `README.md` 不再宣稱 Notist「刻意平凡」或 spike 2 前禁止實作。
- [x] 兩份文件都明定 Notist 組合／UX、Kallopis 通用視覺、Krepis 筆記資料與編輯 truth。
- [x] 既有 Notist rename、Catalog 與 Verify 內容未被回退。

**Verification:**

- [x] Read-back：`AGENTS.md`、`README.md`。
- [x] Diff review：只修改上述定位、ownership 與狀態段落。

**Dependencies:** WSR-B、使用者核准 Q3。

**Files likely touched:**

- `AGENTS.md`
- `README.md`

**Estimated scope:** Small，2 files。

## Task WSR-1: Define typed destinations

**Description:** 建立五個固定 workspace destinations 的唯一 typed registry，供 Sidebar、Workbench 與 Stage 共用。

**Acceptance criteria:**

- [x] Registry 順序精確為專案、快速搜尋、Journal、Notist AI、資產庫。
- [x] 五個 ID 與五個 labels 分別無重複。
- [x] Registry 不接受 document ID 或 page-kind prototype。

**Verification:**

- [x] Focused test：`C:\development\flutter\bin\flutter.bat test test/workspace_destination_test.dart`。

**Dependencies:** WSR-0。

**Files likely touched:**

- `lib/src/shell/notist_workspace_destination.dart`
- `test/workspace_destination_test.dart`

**Estimated scope:** Small，2 files。

## Task WSR-2: Compose truthful sidebar

**Description:** 以 destination registry 組出五個全寬導覽按鈕，並將下半部 hard-coded Explorer 改為無資料 source 時的 empty state。

**Acceptance criteria:**

- [x] 五個按鈕 semantics 順序與 registry 相同，selected state 由輸入 destination 控制。
- [x] 五個按鈕的 left、right、height 精確相同，維持全寬導覽幾何。
- [x] 空專案顯示 `NotistSidebarExplorer` 與「尚無文件」。
- [x] Production tree 找不到既有 hard-coded Folder／Note labels 與假新增 page-kind menu。

**Verification:**

- [x] Focused test：`C:\development\flutter\bin\flutter.bat test test/workbench_layout_test.dart`。

**Dependencies:** WSR-1。

**Files likely touched:**

- `lib/src/sidebar/notist_sidebar.dart`
- `lib/src/sidebar/notist_sidebar_explorer.dart`
- `test/workbench_layout_test.dart`

**Estimated scope:** Medium，3 files。

## Task WSR-3: Route one honest stage

**Description:** Workbench 只保存目前 destination，Stage 呈現真實 header、唯一 keyed empty page 與空 status slot，移除 production page-kind 推定。

**Acceptance criteria:**

- [x] 第一次啟動顯示專案 destination；點擊五個入口只替換中央單一 Stage 內容。
- [x] 所有 destination 下都找不到 Flow／Canva／Sheet prototype、假 Breadcrumb、`KlpStatusBar` 或假統計。
- [x] 每個 destination 的 Stage Header 精確顯示目前 label；`KlpStageFrame.status` 非 null 且存在唯一 `workspace-status-slot` key。
- [x] `KlpWorkbenchShell.secondaryVisible == false`，`KlpTabs`、`KlpSplitLayout` 與 `secondary-pane-resize-handle` 都不存在。
- [x] Canva／Sheet visual tests 直接渲染 prototype fixture，不再點擊 production 假筆記。

**Verification:**

- [x] Focused tests：`C:\development\flutter\bin\flutter.bat test test/workbench_layout_test.dart test/note_page_types_test.dart`。
- [x] Manual check：以 Windows Debug 點擊五個入口，確認沒有假資料與額外 pane。

**Dependencies:** WSR-2。

**Files likely touched:**

- `lib/src/shell/notist_workbench.dart`
- `lib/src/stage/notist_stage.dart`
- `test/workbench_layout_test.dart`
- `test/note_page_types_test.dart`
- `test/note_page_visual_golden_test.dart`

**Estimated scope:** Medium，5 files。

## Checkpoint: Behavioral contract

- [x] WSR-1 至 WSR-3 focused tests 全部通過。
- [x] Production runtime 不再 import 三個 prototype pages。
- [x] `lib/catalog/**` 與三個 prototype page 檔案沒有變更。
- [x] 使用者核准後才進入 WSR-4。

## Task WSR-4: Update the approved visual baseline

**Description:** 為已核准的新 workspace shell 更新主畫面 golden，並為隔離後的 Canva／Sheet prototype fixture 更新必要 master。

**Acceptance criteria:**

- [x] 1400×900 master 顯示五個正確入口、空 Explorer 與單一 Stage。
- [x] Master 中沒有舊假筆記、假 `Saved` 或 Flow／Canva／Sheet 展示內容。
- [x] Canva／Sheet masters 由隔離 prototype fixture 產生，不包含 production Sidebar、route 或假保存狀態。
- [x] 未放寬 threshold、刪除 golden test 或用 failure image 取代 master。

**Verification:**

- [x] Update：`C:\development\flutter\bin\flutter.bat test --update-goldens test/main_visual_golden_test.dart test/note_page_visual_golden_test.dart`。
- [x] Focused tests：`C:\development\flutter\bin\flutter.bat test test/main_visual_golden_test.dart test/note_page_visual_golden_test.dart`。
- [x] Visual review：人工檢查三張 master。

**Dependencies:** WSR-3、使用者核准 Q2。

**Files likely touched:**

- `test/goldens/notist_main_visual.png`
- `test/goldens/notist_canva_page.png`
- `test/goldens/notist_sheet_page.png`

**Estimated scope:** Medium，3 files。

## Task WSR-5: Run the single Verify and review the diff

**Description:** 執行專案唯一 Verify，並確認實際 diff 沒有越過核准範圍或吞入其他工作。

**Acceptance criteria:**

- [x] `tool/verify.ps1` exit code 為 0，format、analyze、test 三段都有成功尾行。
- [x] 開工前後三倉 status 與計畫檔／凍結區 SHA-256 比較沒有計畫外 delta。
- [x] Frozen areas 沒有本批新增變更。
- [x] 實際 diff 逐條對應 SPEC 與 WSR-0 至 WSR-4。

**Verification:**

- [x] Verify：`pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1`。
- [x] Baseline compare：重跑開工前相同的三倉 status、計畫檔與凍結區 SHA-256 清單。
- [x] Diff review：選擇性檢查本任務列出的檔案，並與 baseline delta 對照。

**Dependencies:** WSR-4。

**Files likely touched:** None。

**Estimated scope:** Extra small，verification only。

## Checkpoint: Complete

- [x] SPEC success criteria 全部通過。
- [x] 唯一 Verify 通過。
- [x] Fresh-context diff review 沒有 blocker。
- [x] 交付回報列出修改檔案、驗收證據、已知限制與下一步。
