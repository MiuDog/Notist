# M0 前後端路線盤點與驗證計畫交接 prompt

狀態：待交接；本文件供人類交給規劃執行者使用，不是已派工或程式實作授權。
只處理 [M0 計畫](notist-functional-milestones-20260907.md) 的 M0.a–b，後續里程碑維持目錄。

## 目標與動機

你負責把 Notist 現有 Flow 完整流程的草案補成可實作、可驗收的前後端計畫。流程為 Notist 停用手寫後，在既有隔離本機資料目錄建立兩份 Flow、命名與切換、繁中 IME 編輯、split／merge／selection／undo／redo、保存、程序重啟後重開，以及保存失敗後 retry。

先讀 `AGENTS.md`、`.agents/skills/agent-entry/SKILL.md`、`work-protocol` 與 `task-planning`。本階段只讀取程式並撰寫規劃與驗證文件，禁止修改產品、provider、測試程式、相依鎖檔與 golden；不提交、不發布、不啟動任何程式碼實作 agent。

## 輸入與邊界

- 閱讀本目錄的 `notist-functional-milestones-20260907.md` 與 `notist-functional-milestones-todo.md`，按 A1–A9 展開驗證。
- 首版需求以 `notist-v1-management-database-scope.md` 為準，Kallopis 缺件只補 `notist-kallopis-component-gaps.md`。完整專案管理在 M1，不能以新建 Flow 代替。
- 舊資料來源：`project-document-flow-and-markdown-plan-20260823.md`、`../docs/verification/paragraph-dogfood-windows-2026-08-23.md` 及後續 verification 記錄。
- 工作樹有大量未提交變更；只讀盤點 Notist／Krepis HEAD、狀態與必要檔案 hash；不查改 Kallopis 施工工作樹，保留所有人的修改。
- 大檔先搜尋定位再分段讀取；未知 API、版本與 runtime 行為明確標「未查證」。不得用歷史紀錄代替當前實跑結果。
- 本階段允許新增 `tasks/notist-m0-contract-and-verification-plan.md`，並在原 M0 計畫及追蹤清單追加該產物連結與規劃狀態；不勾選實作或功能通過。

## 工作內容

1. 查實 Notist 實際解析的 Krepis 版本、公開入口與 DLL 來源；Kallopis 僅從 Notist 消費端與施工方提供資料查證固定公開版本，不介入其工作樹，區分宣告 pin、解析來源與已建成品。找不到的列阻塞，不猜測 sibling checkout 已被消費。
2. 為每個 M0 操作建立完整鏈路表：使用者入口 → Notist controller／adapter → 精確 provider 符號與簽名 → schema／revision／transaction／undo → persistence → UI projection。每格附檔案與行號；沒有介面的格子標缺口與 owner。
3. 區分「已存在待驗證」「需修復」「需新增 provider 契約」「需人類裁決」。若需改程式，提出精確白名單與預期修改，不動手。
4. 把 A1–A9 寫成可重現案例：前置環境、隔離 fixture、操作／輸入、預期 UI 與資料結果、失敗時不得改變的狀態、證據位置。涵蓋手寫入口／快捷鍵／stylus 不產生 Ink、Krepis Ink 保留與舊檔不遺失、Kallopis 零修改，以及 IME composition、保存失敗／retry、stale revision、損壞／未知版本、缺失來源與重啟一致性。
5. 列既有測試與缺少的測試；查證 Notist／Krepis 唯一 Verify（Kallopis 僅使用施工方交付的相容性證據） 與 Windows 建置／啟動方法。指令需要已驗證的參數；本階段不執行 build 或 runtime 測試，不能填入猜測的通過結果。
6. 寫出後續實作 prompt 與獨立驗收 prompt 草案，兩者都限定 M0，附目標、核准前置、白名單、驗收與回報合約。實作 prompt 不得以本次交接視為核准；新增範圍先交人類裁決。

## 驗收條件

- M0 每條功能流程都有完整前端／核心／資料／恢復／測試路線及可追溯來源。
- 每個未知項目都有影響與處理方式，不以虛構 API 補表；存在未決前提時，實作狀態保持 Blocked／Awaiting approval。
- 每條 A1–A9 都有可操作的測試方法與明確通過／失敗判準，Windows 成品與實際操作截圖不可由 golden 取代。
- 修改範圍只有規劃文件，沒有改程式、執行實作或提前展開 M1。

## 回報格式

只回報產物路徑、前後端缺口摘要、待裁決問題、驗證覆蓋對照與文件檢查結果。清楚列「未執行功能測試／未實作」，不要宣稱 M0 Complete。驗收證據日後必須附測試指令、尾行、exit code、成品與 provider hash、Windows 實機操作記錄和截圖。
