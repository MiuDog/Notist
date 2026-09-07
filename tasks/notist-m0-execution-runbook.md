# M0 實作與驗收 Runbook（文件收斂版）

## 目標

本文件供下一位執行者與獨立驗收者使用。  
本文件覆蓋契約、修復與驗收接續節點。實作可在有授權的階段直接執行。

## 進場規則（硬限制）

- `M0` 尚未通過前，不得啟動 M1。  
- `A1–A9` 未完成全量實機證據前，任何 checklist 勾選都視為未完成。  
- `tool/verify.ps1` 在放寬訊息嚴重度（例如 `--no-fatal-infos`）後可得的綠燈，不能視為 A6 完成。  
- `RUNNING` 僅表示程序存活，不等於互動驗證完成。  
- 任何文件內容不得以「已查核」取代「有截圖+log+尾行+exit code」。

## 開工前最小核准清單

1. 讀取並確認以下文件版本：
  - `tasks/notist-m0-reconciliation-prompt.md`
  - `tasks/notist-m0-contract-and-verification-plan.md`
  - `tasks/notist-m0-progress-2026-09-07.md`
  - `tasks/notist-kallopis-component-gaps.md`
2. 在 `tasks/notist-functional-milestones-todo.md` 標示本步驟為「規劃整合」而非「實作完成」。  
3. 明確記錄本次執行者與日期。  
4. 任何不一致，先回到規劃文件，不得自行改進口徑。

## A1–A9 文件化執行清單（獨立可重放）

每項都需提交：
- fixture 路徑（不可使用真實使用者資料）
- 實際操作步驟
- 預期 UI 與資料輸出
- 失敗行為與清理
- 截圖或錄影連結
- 指令輸出尾行與 `exit code`

### A1 兩份資料隔離

1. 建立隔離目錄 `D:\Projects\Notist\docs\verification\cases\a1`。  
2. 建立兩個獨立資料集合，分別寫入不同 Note ID、不同 title。  
3. 切換活躍對象時，確認 stage 一律只呈現一筆。  
4. 驗證互不污染後再關閉紀錄。  
5. 證據：截圖 4 張（切換前、切換後、保存前、保存後）。

### A2 IME 與文字編輯

1. 在 A1 中的某筆真實輸入場景以 IME 進行中文編輯。  
2. 記錄提交、取消、split、merge、selection、undo/redo。  
3. 對照資料輸出 bytes 是否正確。  
4. 證據：每個子步驟至少一張截圖 + input/revision log。

### A3 重開一致性

1. 儲存兩筆內容，關閉並重啟後讀回。  
2. 比對 ID / title / 內容。  
3. 重開前後資料順序與映射一致。  
4. 證據：前後對照表 + 截圖。

### A4 保存失敗／重試

1. 以可重現失敗的儲存 fixture 建立錯誤環境。  
2. 觸發一次保存失敗，確認 failed 投影、錯誤訊息。  
3. 以 retry 成功為唯一轉為 saved 的條件。  
4. 重啟後比對最後成功內容。  
5. 證據：失敗截圖、retry 截圖、重啟後讀取結果。

### A5 Stale、損壞、缺失來源

1. 分別執行三種 fixture：  
  - stale revision  
  - corrupted source  
  - missing source  
2. 每個 fixture 至少一筆操作必須達成「不可靜默修復」。  
3. 確認 UI 行為與資料持久化結果一致。  
4. 證據：每類至少 1 張截圖與輸出記錄。

### A6 Verify 門檻

1. 在有明確授權前提下，記錄 verify 運行條件。  
2. 檢查是否有放寬參數，並標記為放寬/非放寬。  
3. `exit code` 與所有尾行需可讀。  
4. 若以非嚴格方式運行，結果僅可列為參考，不可通過。  
5. 證據：command log + 命令與尾行。

### A7 可執行成品

1. 紀錄 Debug / Release exe 及 hash。  
2. 啟動可見頁面後，補齊 A1–A6 的逐步操作截圖。  
3. A7 不以「成功啟動」作唯一條件。  
4. 證據：exe 清單、hash、截圖集、啟動 log（含時間）。

### A8 Ink 邊界

1. 確認 Notist 入口、快捷鍵、stylus 路線不新增 stroke。  
2. 用既有 Ink fixture 驗證文字保存與重開仍保留 Ink。  
3. 證據：截圖＋行為說明。

### A9 Kallopis 邊界

1. 核對 `tasks/notist-kallopis-component-gaps.md` 每一筆缺口是否有來源記錄。  
2. 未獲得可追溯核准前不能宣告通過。  
3. 證據：缺口更新紀錄 + 受限說明。

## 路徑與輸出約定

- 主要 evidence 根目錄建議 `docs/verification/m0/`。  
- 每個 A 項目放在獨立子資料夾 `a1`~`a9`。  
- 每次輸出加日期戳 `YYYYMMDD_HHMMSS`。  
- 文件回報應同時註明：  
  - 總體狀態 `Verified / Blocked / Unverified`
  - 缺失欄位與原因

## 狀態更新規則

- `tasks/notist-functional-milestones-todo.md` 僅在實機證據補齊且被認可後更新。  
- 任一項仍為 `Blocked`，不得在 runbook 中勾選完成。  
- 只要發現與歷史文件衝突，必須先同步修訂而非補齊 checkbox。


