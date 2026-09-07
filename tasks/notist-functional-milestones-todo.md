# Notist 功能里程碑追蹤

更新：2026-09-07。規劃來源：[功能里程碑修訂](notist-functional-milestones-20260907.md)。  
目前 `M0 = Blocked`，`M1–M11 = Queued`。  
未經實機重播與可驗證文件，不得以執行紀錄視為完成。

## 本輪入口

供交接使用：
- [M0 現況收斂與驗證 prompt](notist-m0-reconciliation-prompt.md)
- [M0 契約與驗證計畫](notist-m0-contract-and-verification-plan.md)
- [M0 實作與驗收 Runbook](notist-m0-execution-runbook.md)
- [Kallopis 元件缺口清單](notist-kallopis-component-gaps.md)

## M0（第一版收斂，僅文件與核准鏈）

- [ ] M0.a：版本與基線（dirty、provider、DLL、契約差異）完成核准更新。  
- [ ] M0.b：A1–A9 檢核表、責任 owner 與失敗恢復條件完成。  
- [ ] M0.b：`--no-fatal-infos` 改版結果僅記為放寬證據，不能作為 A6 通過。  
- [ ] M0.b：專案隔離、刪除、釘選與回復風險（R8–R11）補齊。  
- [ ] A1：隔離資料與單 Stage 切換實機重播完成。  
- [ ] A2：IME、split、merge、selection、undo、redo 實機重播完成。  
- [ ] A3：保存後重啟一致性實機重播完成。  
- [ ] A4：保存失敗、failed 投影、retry 成功後 saved 的實機重播完成。  
- [ ] A5：stale/corrupt/missing source 實機重播完成。  
- [ ] A6：唯一驗收流程與原始 exit code / 尾行齊備。  
- [ ] A7：Windows exe 清單、hash、A1–A6 實機逐步截圖完成。  
- [ ] A8：Ink 停用邊界與既有 Ink 保留實機完成。  
- [ ] A9：Kallopis 零介入與缺件清單證據完成。  
- [ ] M0.e：獨立驗收與差異審查提交後，M0 可由 `Blocked` 轉 `Ready for M1`。

## M1–M11（排程）

- [ ] M1：專案建立、進入、切換、刪除與恢復。  
- [ ] M2：單層資料夾、筆記建立、編輯、釘選、移動、刪除。  
- [ ] M3：資料庫頁面與巢狀頁面導覽。  
- [ ] M4：自訂欄位與記錄值管理。  
- [ ] M5：篩選、排序與設定保存。  
- [ ] M6：多視圖一致性與配置。  
- [ ] M7：Block／Todo 操作與持久化。  
- [ ] M8：貼上與匯入流。  
- [ ] M9：搜尋與回到定位。  
- [ ] M10：恢復與位置同步。  
- [ ] M11：首版完整管理與資料庫交付。

## 核准邏輯

- 任一 `[ ]` 均視為 `Blocked`，不得直接啟動下一里程碑。  
- A6 與 A7 任何缺口一律影響 M0 狀態，直到有獨立驗收回填。  
- 只要文件與現場錄影/截圖不符，`M0` 仍維持 `Blocked`。
