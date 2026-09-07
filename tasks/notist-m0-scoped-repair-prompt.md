# M0 Scoped Repair Prompt（供實作者）

## 適用範圍

本提示只負責補齊 `M0.a–M0.b` 的缺口，不包含 M1 實作。  
禁止修改 Kallopis、provider、外部 API 參數。

## 先決條件

- 使用者未取消 `M0` 阻塞。  
- 已確認：
  - `A6 放寬門檻不等於通過`
  - `A1–A9 實機證據仍未完整`
  - `專案隔離/刪除/釘選失敗回復有未驗證風險`
- 取得三份最新文件：
  - `notist-m0-contract-and-verification-plan.md`
  - `notist-m0-execution-runbook.md`
  - `notist-m0-approval-and-evidence-matrix.md`

## 需要補齊的後續工作（逐項產出，不做推測）

1. 在契約文件補齊每項 A 的 evidence owner、失敗回復、不可跨越條件。  
2. 在 runbook 補齊每項可重播步驟的 fixture 命名、操作順序、截圖張數、清理機制。  
3. 在 `notist-kallopis-component-gaps.md` 補齊每個缺口的 `LastCheckedAt`、`SourceOwner`、`BlockedBy`。  
4. 在 `notist-functional-milestones-todo.md` 將可追溯訊息與待補項目對齊。  
5. 產出一份 A1–A9 實機證據目錄樹（a1 ~ a9）作為交付規格，要求都含 `stdout log`、`截圖`、`exit code`。  
6. 將 `M0` 目前狀態維持為 `Blocked`，只在全部驗證完成且驗收通過後才解除。

## 禁止事項

- 不得把 `RUNNING`、既有 hash、或 mock 測試結果當通過證據。  
- 不得自行將 `--no-fatal-infos` 結果視為 A6 完成。  
- 不得新增或刪除欄位超出目前里程碑範圍。  
- 本文件先鎖定本階段授權邊界與實作項目；實作必須回到對應執行記錄補齊。

## 交接輸出格式（實作者完成後）

- `notist-m0-scoped-repair-prompt.md` 完成狀態回報。  
- 更新 4 份受管文件路徑與變更摘要。  
- `approval matrix` 的每行 `EvidencePath/ExitCode/BlockedReason/NextAction`。  
- 實機驗證尚未開始前，不要提交為「done」。

