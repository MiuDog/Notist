# 新交接 prompt：M0 現況收斂、契約補全與驗收準備

## 任務與角色

你接手的是已有部分實作與建置紀錄的 Notist M0。先閱讀 [最新狀態檢核](notist-current-state-review-20260907.md)，不要重做已存在的功能，也不要沿用舊報告把它們說成不存在。

本次交接只授權唯讀檢核及規劃／驗證文件補全，不授權修改程式、provider、測試、依賴、golden 或驗證腳本，不授權進入 M1。協調者仍只負責討論、計畫、prompt 與驗證規格；將需要程式修復的部分整理為下一份精確實作者交接包。若其他對話已有明確核准，逐項引用其原文、日期、範圍後再提出可承接範圍，不把文件內的 Active／已完成標籤當成人類授權。

目標：在不干涉 Kallopis、不遺失既有修改與資料的前提下，完成 M0.a–b 的具體契約、驗證案例與授權對照，使下一位實作者或獨立驗收者拿到後可逐項執行，不需再補模板。

## 必讀與邊界

1. 專案 `AGENTS.md`、`.agents/skills/agent-entry/SKILL.md`、`work-protocol`、`task-planning`；大檔先搜尋定位再分段讀。
2. [里程碑](notist-functional-milestones-20260907.md)、[追蹤](notist-functional-milestones-todo.md)、[首版範圍](notist-v1-management-database-scope.md)、[Kallopis 缺口](notist-kallopis-component-gaps.md)。
3. 現有 [契約計畫](notist-m0-contract-and-verification-plan.md)、[Runbook](notist-m0-execution-runbook.md)、[成品證據](notist-m0-executable-evidence.md)、[進度快照](notist-m0-progress-2026-09-07.md)。它們包含已知矛盾，必須逐項查核，不能照錄結論。

禁止讀改 Kallopis 施工工作樹、升降 pin、patch cache、委派 Kallopis 工作；只從 Notist 消費端與施工方提供的固定資料查證。不可 reset／checkout 還原／刪除目前產品差異，不自動提交。不得以降低 analyze 嚴格度、放寬格式或刪測試取得綠燈。

## 本次可修改的文件白名單

- `tasks/notist-m0-contract-and-verification-plan.md`：補齊具體契約與 A1–A9 案例。
- `tasks/notist-m0-execution-runbook.md`：以核實基準修訂後續執行流程，保留過去紀錄並標明適用性。
- `tasks/notist-functional-milestones-todo.md`：同步有證據的規劃狀態，不預勾產品功能完成。
- `tasks/notist-kallopis-component-gaps.md`：只補查證來源、缺口與受阻條件。
- 新增 `tasks/notist-m0-approval-and-evidence-matrix.md`：核准、版本、驗收差異對照。
- 新增 `tasks/notist-m0-scoped-repair-prompt.md` 與 `tasks/notist-m0-independent-verification-prompt.md`：具體修復與獨立驗收的後續草案，不自行執行。

既有文件修改前先保存逐檔備份與 hash；本次新產物若已存在，先讀取合併，不能覆蓋他人內容。若白名單外需修正文檔，列差異建議，不自行擴大。

## 依序完成的工作

### 1. 固定現況與證據等級

記錄目前 Notist HEAD、dirty 檔案與來源／腳本／依賴／成品 hash。讀取現有 SDK 路徑與已安裝版本資料；目前紀錄為 `D:\flutter\bin\flutter.bat`，不能直接使用已不存在的舊路徑。

將每個結論分成「本次直接查證」「其他執行者已記錄」「仍未查證」。exe 與 DLL hash 相符只證明檔案存在；列出整包 runtime／Flutter data 與來源版本仍需對應的證據。此次不建置、啟動或執行產品測試。

### 2. 釐清驗證基準與核准

- 比對 `tool/verify.ps1` 原 `--fatal-infos` 與目前 `--no-fatal-infos`，以及原 commit pin 與目前 `../Kallopis` path。列明變更、現有結果、核准原始來源與缺口。
- 紀錄中放寬後的 exit 0 保留為該條件下的結果，不可標 A6 完成。查無核准則維持 Blocked，提出恢復原驗收要求所需的具體修復範圍；此次不改回腳本，也不繼續放寬。
- 目前 path 來源無法證明不可變時，向交付資料索引查找施工方固定版本／相容證據；查無就列依賴阻塞，不進 Kallopis 自行製作證據。
- 任何 M1／M2 管理程式只當作已存在差異，列受影響路線與資料安全問題；不得因存在而追認其核准或完成，也不得直接回退刪除。

### 3. 補成真正完整的前後端契約

先處理最新檢核 R8–R11 的來源風險，產出具體驗證與最小修復提案，不改程式：

- 專案 root／直屬目錄被列為專案、又遞迴掃描筆記的隔離矛盾：設計含兩專案與普通資料夾的 fixture，明確列出每個專案應可見與不可見的筆記、刪除影響範圍與舊資料 mapping。
- 現有 deleteFlow／setPin／metadata 寫入的部分成功：針對刪檔後 metadata 失敗、pin 寫入失敗、損壞 metadata 與 rename 中斷，各列磁碟、投影、錯誤回饋及重開預期；不能把錯誤訊息當成資料回退。
- 單層限制與舊深層筆記載入並存：列所有舊筆記可見性、遷移／唯讀策略與當前測試預期衝突，不以隱藏深層內容當成遷移。
- 逐項核對進度紀錄宣稱存在的 Ink 停用／管理測試是否真的出現在目前來源；記錄實際案例內容，不能只引用名稱或過去尾行。

上述路線已有部分 M1／M2 程式，但此次只檢核它對目前資料安全與 M0 基線的影響。需要擴大修復範圍時列入核准包，不能自行跨里程碑實作。

對 A1–A9 每項填實際檔案行號與下列欄位：前端操作 → controller／adapter → 精確 provider 符號及簽名 → 輸入／revision／transaction → 持久化行為 → 成功／失敗投影 → 現有測試 → 缺少的測試。

不是只寫「Krepis load/save」或「需要補行號」；查不到就寫明已查範圍、具體缺口與 owner。未知 API 不能自行命名。新增資料庫 owner 與 schema 問題屬後續，不把整個 M1–M6 設計變成 M0 前置。

### 4. 寫出 A1–A9 可重放驗證規格

| 案例 | 必須具體定義 |
| --- | --- |
| A1 | 隔離現有本機資料目錄內兩份筆記、不同 ID、命名／切換與單 Stage；不以新建 Flow 冒充專案建立 |
| A2 | 真實繁中 IME 提交／取消、split／merge、selection、undo／redo 的輸入與預期字串／位置；人工操作不以合成事件取代 |
| A3 | 保存後結束程序再重啟，兩文件 ID／title／內容與順序逐項比對；不能只重建 controller |
| A4 | 可重現寫入失敗的隔離 fixture、最後成功檔 hash 不變、failed 顯示、retry 成功才 saved，重開後內容一致 |
| A5 | 真實 provider stale revision、截斷／未知版本文件、缺失來源；每類失敗碼、UI 結果與不可改變的檔案／revision。mock loader 拋錯與 stale session 不能替代 |
| A6 | 核准且可追溯的嚴格 Verify／必要 provider gates、完整尾行和 exit code、所有必要案例零失敗零略過 |
| A7 | 與測試相同來源／runtime 的 Windows 成品、完整檔案清單及 hash、A1–A5 和 A8 實機逐步操作紀錄與截圖；RUNNING 不足以通過 |
| A8 | 列出所有 Ink 入口／快捷鍵／stylus 路線，Notist 不新增 stroke；以既有 Ink fixture 驗證文字編輯保存仍保留 Ink。沒有保全契約就明確唯讀禁止覆寫，不刪 Krepis 能力 |
| A9 | Kallopis 固定交付來源、核准範圍、零介入證據與必要缺件清單；產品邊界單測不能證明來源不可變或 Kallopis 零修改 |

每列都包含 fixture 建立方法、輸入、預期 UI／資料結果、執行者、必要指令、log／截圖輸出路徑與失敗清理方法。資料只用新隔離 fixture，不能刪改使用者真實專案。未建的 fixture／log 路徑標「預計產出」，不能假稱存在。

### 5. 產生兩份可審查的後續 prompt

**實作者草案**：只列已確認 M0 缺口、精確程式／測試白名單、前後端修改路線、驗收與回退。若缺乏核准，明寫「待核准，不可執行」；已涵蓋的授權引用原文，不重複索取。必要修復牽涉新資料模型或 M1 範圍時，先列裁決，不擅自擴大 M0。

**獨立驗收草案**：要求 fresh-context 驗收者親自執行核准的檢查及實機操作；有必要測試失敗、略過、缺少原始證據或仍用未核准放寬基準就不得 Pass。不要在驗收 prompt 中預告「實作者已完成，請確認」。

## 本次完成條件與回報

本次完成＝M0.a–b 規劃內容具體可用、R1–R11 每項有證據或明確阻塞、兩份後續 prompt 能直接供人類審閱、文件連結可解析且無矛盾。M0 不因此 Complete，M1–M11 仍不得啟動。

回報只包含：狀態結論、已核實／未核實差異、A1–A9 覆蓋表、待裁決項目、後續 prompt 路徑、文件檢查尾行與 exit code。明列「本次未寫程式、未跑產品測試」。禁止再交只有標題、待填欄位或泛稱「需要實機驗證」的文件。
