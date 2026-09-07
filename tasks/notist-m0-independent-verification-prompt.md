# Notist M0 獨立驗收提示（A1–A9）

## 角色與要求

執行者需使用乾淨環境、全新上下文。  
驗收範圍為 `M0.a–M0.b` 的基線／契約完整性，以及 `A1–A9` 的實作後功能證據；不得判定或啟動 M1。  
本驗收對應核准矩陣的 G1 與 G2。G0 只授權修復實作，不是功能驗收通過證據。  
不得接受：
- 僅有 unit test output  
- 未提供實機截圖  
- 只因 `--no-fatal-infos` 成功便標 A6 通過  
- process `RUNNING` 當作操作完成

## 文件邊界

請先讀：
- `notist-m0-contract-and-verification-plan.md`
- `notist-m0-execution-runbook.md`
- `notist-m0-approval-and-evidence-matrix.md`
- `notist-functional-milestones-todo.md`
- `notist-kallopis-component-gaps.md`

## 核心驗收規則

- `M0.a` 必須有當次 baseline、provider 與成品來源紀錄；`M0.b` 必須有 owner、回復與不可跨越條件。  
- 每項 A1–A9 必須有：
  - Fixture 建立方式
  - 重播步驟
  - 實機截圖（至少一段）
  - 指令輸出尾行與 exit code
  - 失敗行為與回復結果
- 輸出最終判定：`Verified / Blocked / Unverified`。

## A1–A9 驗收明細

- A1：兩份資料隔離後 Stage 單一，保存不交叉。  
- A2：IME、split/merge/selection/undo/redo 在實機可再現。  
- A3：保存後關閉重啟，ID/title/content 比對一致。  
- A4：保存失敗 fixture 產生 failed，retry 後才變 saved，資料仍留。  
- A5：stale、損壞、缺失來源三類 case 一律不可靜默修復。  
- A6：驗收腳本以嚴格門檻運行，並附原始尾行。  
- A7：exe hash 與啟動證據完整，並補上 A1–A6 操作截圖。  
- A8：Notist 不新增手寫 stroke，既有 Ink 保持。  
- A9：Kallopis 介面仍保有 consumer 邊界，缺件清單對應完整。

## 輸出交付

- 逐項 A1–A9 的判定結果與失敗原因。  
- 每項 evidence 的 path 與檔名。  
- `notist-m0-approval-and-evidence-matrix.md` 全欄回填。  
- `notist-functional-milestones-todo.md` 只在 Verified 完成後更新。  

若任一項為 `Blocked` 或 `Unverified`，最終結果為 `M0=Blocked`，且不得提出 M1 需求。
