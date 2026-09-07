# Notist M0 契約與驗證計畫（A1–A9）

## 目的

本文件用於完成 `M0.a–M0.b` 的規格收斂。  
目前 `M0` 仍為 `Blocked`，不得進入 M1。

## 目前判定（需保留）

- `M0`：仍未通過。  
- `A1–A9`：不可僅靠測試紀錄、檔案存在或 process running 判定通過。  
- `tool/verify.ps1` 以 `--no-fatal-infos` 得到的成功，不得等同原始驗收標準（`--fatal-infos`）。  
- 專案隔離、刪除、釘選與異常恢復的風險仍需「資料損失不可回退」級別的實機證據。  
- 缺少 A1–A9 全量實機逐步操作截圖與重放 log。

## 文件對照（不修改既有內容）

本文件以以下文件為約束，優先採用更嚴格版本：
- `tasks/notist-m0-reconciliation-prompt.md`（本次唯一行動邊界）
- `tasks/notist-current-state-review-20260907.md`
- `tasks/notist-m0-execution-runbook.md`
- `tasks/notist-m0-executable-evidence.md`
- `tasks/notist-m0-progress-2026-09-07.md`

衝突原則：有矛盾時，優先以「未查證保留 Blocked」為預設。

## A1–A9 最小可驗證契約清單

每一項都必須有：可重放案例、輸入、輸出、失敗行為、截圖、command log/exit code。  
本節先定義 `M0` 收斂層級，不代表實作完成。

### A1 兩份資料隔離＋切換（專案/筆記不交叉）

- 成功標準：在相同 root 內放置兩個隔離資料目錄，任一檔案變更不得污染對方。  
- UI：Stage 僅呈現當前 active 對象（單 Stage）。  
- 失敗標準：誤開、混載入、錯誤清單不明確、針對錯目標覆寫。  
- 當前狀態：未完整實機證據，標記 `Blocked`。

### A2 IME 與文字編輯

- 成功標準：實機以繁中 IME 完成字組提交/取消，並在 split/merge/selection/undo/redo 上仍保持一致。  
- 失敗標準：以合成事件替代真實輸入、輸入結果不可重建、撤銷與 cursor 不一致。  
- 當前狀態：缺少實機重播＋截圖，標記 `Blocked`。

### A3 保存後重啟一致性

- 成功標準：保存前後的 ID/title/content bytes 與重啟後讀取值逐項比對一致。  
- 失敗標準：重啟後以快取回填或順序/映射錯置。  
- 當前狀態：有測試參照，但未補齊實機/截圖，標記 `Blocked`。

### A4 保存失敗與重試

- 成功標準：失敗時 UI 顯示 `failed`，不誤寫 saved 狀態；重試成功才轉為 saved。  
- 失敗標準：失敗狀態不可回覆、重試不一致或資料遺失。  
- 當前狀態：僅有部份自動化訊息，缺少實機 fixture 與重開一致性，標記 `Blocked`。

### A5 程式損毀／版本衝突／來源遺失

- 成功標準：  
  - stale revision：不得無條件覆蓋，需明確提示並保留可回退路徑。  
  - 損壞來源：辨識不可讀類型並降級到 `unavailable` 或 `failure`。  
  - 缺失來源：不可創建假資料隱式修復。  
- 當前狀態：controller 層有相關測試，但未形成獨立實機驗收（含 fixture、影像、重放指令），標記 `Blocked`。

### A6 驗收門檻

- 成功標準：  
  - 以授權版本的 verify 設定為基準（不得用放寬等效替代）。  
  - `exit code`、`tail lines`、每一步輸出尾行可追溯。  
  - 無跳過且無隱性 pass。  
- 當前狀態：`--no-fatal-infos` 視為放寬情境，不能當作 A6 完成。標記 `Blocked`。

### A7 可執行成品

- 成功標準：Windows exe path、hash、啟動證據、A1–A6 行為已按步截圖。  
- 失敗標準：只有 exe 產物或 process running。  
- 當前狀態：存在 exe 與啟動紀錄，但缺少 A1–A6 實機逐步截圖，標記 `Blocked`。

### A8 Ink 邊界

- 成功標準：Notist 不新增/stroke，不改 Krepis data truth，且既有 Ink 在保存/重開下不損失。  
- 失敗標準：新增非授權 stroke 或誤觸發手寫入口。  
- 當前狀態：缺少實機驗證與截圖，標記 `Blocked`。

### A9 Kallopis 邊界

- 成功標準：Notist 保持消費者位階，不變更 Kallopis；固定元件缺口可追溯與獨立證據。  
- 失敗標準：以舊結果替代缺口核對，或未區分 Notist 與 Kallopis 職責。  
- 當前狀態：需補齊 `notist-kallopis-component-gaps.md` 最新證據欄位，標記 `Blocked`。

## 風險與責任對照（M0 需先填）

- `owner`：每一項需明列負責人（Notist / Provider / Kallopis / 審核）  
- `source of truth`：不能以 UI 測試推導 provider 實體真相。  
- `recovery`：刪除、釘選、隔離錯誤場景需標明失敗後下一步行為與資料安全性。  
- `rollback`：任何非預期資料遺失一律視為阻塞，不得以「看起來正常」繞過。

## M0 契約執行順序

1. 固定現況：`m0-current-state-review` 重新核定證據缺口。  
2. 將 `--no-fatal-infos` 視為放寬結果，註明為 `A6-not-true`。  
3. 先補 A5 與專案隔離/刪除/釘選失敗回復測試場景的實機證據。  
4. 生成所有 A1–A9 實機步驟與截圖規格。  
5. 以 `notist-m0-approval-and-evidence-matrix.md` 做核准與進度鎖定。  
6. 僅在前述皆 `Verified` 後才可提出 M1 入場提案。

## 已列入本輪重跑的資料安全回歸案例

下列案例已在目前來源中出現；它們是 G1 自動化回歸的必要輸入，不得以舊輸出標記為通過。每次修復後，執行者必須重跑對應測試並將當次尾行與 exit code 放入 `docs/verification/m0/` 的預計輸出位置。

| 案例 | fixture 與操作 | 不可改變的結果 | 現有測試來源 | 當前證據狀態 |
| --- | --- | --- | --- | --- |
| C1 工作區隔離 | 建立 `研究`、`.git`、`build` 與 `.hidden` 四個直屬目錄後列出專案 | 只顯示根目錄專案與 `研究`；保留資料夾不會成為專案 | `test/notist_workspace_project_store_test.dart` 的 `lists root project plus visible project folders only` | 待本輪重跑 |
| C2 工作區刪除 | 建立並選取 `專案A`，再刪除它 | 專案目錄消失，active path 回到 root；未知名稱不拋出刪除副作用 | `test/notist_workspace_project_store_test.dart` 的 delete 與 active-project 兩案 | 待本輪重跑 |
| C3 釘選 metadata 失敗 | 以同名 `.tmp` 目錄阻斷 session 寫入，要求釘選 | 文件投影與 pinned id 都回復未釘選，原 `.krdf` 保留 | `test/notist_project_controller_test.dart` 的 `keeps pin projection and session state on pin persistence failure` | 待本輪重跑 |
| C4 刪除 metadata 失敗 | 以同名 `.tmp` 目錄阻斷 pin session 寫入，要求刪除已載入 Flow | 文件投影、選取與 pin 集合回復，原 `.krdf` 由 backup 還原 | `test/notist_project_controller_test.dart` 的 delete failure case | 待本輪重跑 |
| C5 讀取失敗保全 | 依序讓 loader 回報 stale revision、FormatException 與 FileSystemException | 已穩定 documents 與 selected root 保持可用，error 反映實際失敗 | `test/notist_project_controller_test.dart` 的 stale、corrupt、missing 三案 | 待本輪重跑 |

這五案不能取代 A1、A4、A5 的實機證據：它們只證明程式層回復契約在隔離 fixture 下可自動重放。

## 未完成即不准前進

若任一項仍為 `Blocked` 或 `Unverified`，`M0` 狀態維持 `Blocked`，不得進入 M1。

