# M0 前後端盤點與驗證交接（可直接下發實作者）

狀態：Active（交接草稿）

本文件目標：將 Notist M0 由規劃收斂成可執行實作與獨立驗收前置資料。  
本階段不包含程式實作，僅明確可執行內容、缺口與證據規格。

## 1. 目前狀態與先決條件

- 依照 [Notist 功能里程碑修訂](notist-functional-milestones-20260907.md) 與 [追蹤](notist-functional-milestones-todo.md)，目前入口是 M0，M1–M11 保留目錄。
- 里程碑文件中指定：`M0.a–b` 先完成，M0.c–e 需核准後啟動。
- 首版需求仍以 [Notist 首版：專案、筆記與資料庫範圍修訂](notist-v1-management-database-scope.md) 為準。
- Kallopis 施工區與既有 API 不得修改。
- `AGENTS.md` 與技能規則要求：完成＝必有可追溯證據，需實機啟動成品與截圖，不能以歷史測試紀錄代替。

## 2. 供實作者接續的輸入（只列可核定項）

- 只做目標流程：Flow 既有完整流程（A1–A9）盤點與可驗證規格化。
- 不在此階段展開 M1 以後功能（專案管理/資料庫完整實作）。
- 不做 provider 修改，不做依賴升級，不做 Kallopis 改動。

## 3. M0.a 與 M0.b 執行清單（分工可交付）

### M0.a 基線與契約核對

1. 記錄此次 Notist 工作樹 HEAD、dirty 狀態、provider 來源、DLL 與版本資訊（含實際解析來源）。
2. 檢查 `lib/src/krepis/` 中目前使用的 FFI 入口與實際可解析符號。
3. 匯整既有驗收文件中的缺口：  
   - paragraph flow 的 IME/編輯路徑  
   - 保存、重啟、失敗恢復路徑  
   - 失敗/損毀/未查證案例
4. 產出未查證清單（每筆含：預期符號、現有證據、缺失證據、阻塞原因）。

### M0.b 需求與前後端路徑鎖定

1. 以 3 層鏈路補齊每個 A1–A9：  
   `UI入口 -> Notist controller/adapter -> provider 符號 -> persistence -> projection`
2. 每格提供文件/行號與 owner；缺口與 owner 不明者標「Blocked」不得硬編。
3. 補齊測試與驗證路徑（Notist 測試、provider 檢查、Windows build）。
4. 形成 `M0.c–e` 的人類核准包，內容至少包含：  
   - 白名單（修改檔案）  
   - 回退策略  
   - 負面案例與期望行為  
   - Windows 實機驗證成功條件

## 4. A1–A9 驗證矩陣（每項需明確前置與結果）

- A1 建立/命名/切換兩份 Flow 並驗證 Stage 單一與 ID 對應。
- A2 IME、split/merge、selection、undo/redo 真實 FFI 操作，不可用假鍵盤事件代替。
- A3 重啟後兩份文件內容一致且不串接。
- A4 保存失敗與 retry，失敗必可見、成功前不得偽造保存。
- A5 stale revision、損毀/未知版本、缺失來源按契約拒絕或可回復，不可靜默重置。
- A6 Verify 通過 + provider gate + 回歸，不得刪測試放行。
- A7 Windows 可執行檔存在且能啟動，附 hash、環境、操作前後對應截圖。
- A8 手寫入口與 Ink 快捷鍵不建立 Notist stroke；Krepis Ink 舊檔不得遺失。
- A9 Kallopis 不介入、必要缺件列入缺口清單並於獨立驗收中標註。

## 5. 產出物

- `tasks/notist-m0-contract-and-verification-plan.md`（新產物；M0 交接啟動文件）
- 對應於 `tasks/notist-m0-planning-prompt.md` 的實作者核准 prompt。
- 驗收者簽核清單：每項 A1–A9 的可執行指令、預期輸入、容許輸出、證據位置。

## 6. 失敗規則（紅線）

- 任一欄位出現「未查證」未列入缺口，視為紅線違反不得進入 M0.c。
- 若任一 A1–A9 未通過，M0 不得標 Complete，M1 不得啟動。
- 實機截圖必對應一個實際交互操作步驟，不得以 static/golden 替代。
