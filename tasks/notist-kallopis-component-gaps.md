# Notist 首版 Kallopis 元件需求與缺口清單（收斂版）

更新：2026-09-07。  
本文件為缺口追蹤用途，不授權改動 Kallopis，亦非 provider 契約。  
未查證前不得宣告「缺件已確認」。

## 共同規則

- 無法查證：Notist 有需求但還沒能從固定來源取得證據。  
- 已確認可消費：需附公開入口、固定版本、必要互動與可用性。  
- 確認缺件：需列舉具體互動差距與受阻步驟。  
- Blocked：只列受阻里程碑；不以展示圖片或口頭敘述關閉缺口。  
- 本文件不改 Kallopis、也不要求 Notist 自行改公共元件 API。

## 缺口總表（A1–A9 相關）

| ID | Notist 使用情境 | 缺口類型 | 查證來源 | 當前狀態 | 下一步 | LastCheckedAt | SourceOwner | EvidencePath | BlockedBy | Workaround | ReadyForM1 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| KC-01 | 專案建立、進入、切換 | 待查證 | `notist-v1-management-database-scope.md`、A1–A3 實機規格 | 待查證 | 由 Notist M1 交接後補元件能力回報 | 2026-09-07 | Notist | `docs/verification/m0/a1` | 缺少雙案場景實機錄影與切換回歸報告 | 無 | 否 |
| KC-02 | 刪除專案／頁面與影響確認 | 待查證 | `tasks/notist-current-state-review-20260907.md`、M0 合約項 | 待查證 | 明確列出確認/阻斷邏輯與失敗回滾 | 2026-09-07 | Notist | `docs/verification/m0/a5`、`tasks/notist-current-state-review-20260907.md` | A5 僅有 controller-level 測試，缺實機 source loss fixture | controller 覆蓋不足 | 否 |
| KC-03 | 資料導覽與單層/巢狀顯示 | 待查證 | `notist-m0-current-state-review-20260907.md` | 待查證 | 以實機導覽結果驗證每種互動是否可組合 | 2026-09-07 | Notist | `docs/verification/m0/a1` | 目前僅部份 UI/單元測試，缺 A1 實機回放 | 同上 | 無 | 否 |
| KC-04 | Database 欄位／值編輯互動 | 待查證 | `notist-v1-management-database-scope.md` | 待查證 | 保留 Notist owner；待 M3–M4 規格核准 | 2026-09-07 | Notist | `tasks/notist-v1-management-database-scope.md` | M4 scope 未授權 | 規格未授權 | 否 |
| KC-05 | 篩選、排序、視圖規則 | 待查證 | `notist-v1-management-database-scope.md` | 待查證 | 以 M5 規格補齊 query/執行模型 | 2026-09-07 | Notist | `tasks/notist-v1-management-database-scope.md` | M5 scope 未授權 | 規格未授權 | 否 |
| KC-06 | 視圖切換與組件行為 | 待查證 | 產品需求文件 | 待查證 | M6 之前不得提進度 | 2026-09-07 | Notist | `tasks/notist-functional-milestones-20260907.md` | M6 scope 未授權 | 規格未授權 | 否 |
| KC-07 | 刪除、恢復、空資料與失敗提示 | 待查證 | `tasks/notist-m0-contract-and-verification-plan.md` A5 | 待查證 | 明確失敗不可破壞資料，補回復流程 | 2026-09-07 | Notist | `docs/verification/m0/a5` | A5 實機 fixture 未完整 | controller 測試不足以代替 | 否 |
| KC-08 | Ink 快取／輸入路由邊界 | 已確認缺件（Notist 端） | A8 邊界規格 | 已確認缺件 | Notist 確認停用入口與 handoff 路徑 | 2026-09-07 | Notist | `docs/verification/m0/a8` | 尚無 A8 實機錄影與邊界收斂證據 | 無 | 否 |
| KC-09 | 文件 header 的唯讀／編輯／手寫三態切換 | 已確認缺件（Kallopis 端） | `KlpPhaseToggle` 公開 API：僅提供整組 `enabled`，選項沒有個別 disabled 狀態 | 已確認缺件 | Kallopis 提供單一 phase option 的 disabled 樣式、語意與不可點擊行為 | 2026-09-07 | Kallopis | `lib/src/controls/toggle/klp_phase_toggle.dart` | 手寫必須誠實禁用，不能假裝可切換 | Notist 暫以三個等尺寸 inline icon button 呈現，其中手寫為 disabled | 否 |
| KC-10 | Sidebar 與 Stage panel header 等高且容納標準按鈕 | 已確認缺件（Kallopis 端） | `KlpDockHeader.extent` 固定為 32；`KlpPanelHeader` 上下各有 `tight` 4px padding，`iconButton` 為 32px | 已確認缺件 | Kallopis 提供一致的 compact panel header extent，或讓 `KlpPanelHeader` 可選用 Dock header 密度 | 2026-09-07 | Kallopis | `lib/src/shell/docking/klp_dock_header.dart`、`lib/src/shell/panel/klp_panel_header.dart`、`lib/src/theme/klp_spacing_theme.dart` | 32px header 無法同時容納 32px 按鈕與上下 padding | Notist 暫固定 Stage header 為 32px，維持與 Sidebar 等高；按鈕仍使用標準 Kallopis 元件 | 否 |

## 目前狀態摘要

- 本輪不做「缺件已解」標註。  
- 本輪可補的是 `Notist` 消費端對照與證據缺口欄位。  
- `Kallopis` 角色邊界仍維持：資料、authority、selection、transaction 不下沉到 Kallopis。  
- 任何 M1 之後需求不得依本文件直接提早放行。

## 交接欄位（每次補齊時必填）

- `LastCheckedAt`  
- `SourceOwner`（Notist / Kallopis / Provider）  
- `EvidencePath`（文件、截圖或實機錄影）  
- `BlockedBy`（驗證、授權、資源）  
- `Workaround`（若有，須註記為暫時性）  
- `ReadyForM1`（是／否）

## 本輪結論

此文件未提供可直接開發或過關的 API 清單。  
所有後續進度仍由 `notist-m0-contract-and-verification-plan.md` 與 `notist-functional-milestones-todo.md` 對齊後決定。
