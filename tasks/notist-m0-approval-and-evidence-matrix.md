# M0 核准與證據矩陣（2026-09-07）

用途：明確標示 `M0` 何時仍 `Blocked`、每一類工作可在哪個閘門開始，以及什麼條件才可進入下一里程碑。  
本文件不以歷史輸出宣告執行結果；每次實際執行後才可回填證據欄位。

## 閘門分層

| 閘門 | 允許開始的工作 | 必要條件 | 不代表 |
| --- | --- | --- | --- |
| G0 計畫核准 | 已列白名單的 M0 修復實作與回歸測試 | 人類明確授權修復範圍；不觸及 M1、Kallopis 或使用者真實資料 | M0 已通過或 A 項已驗收 |
| G1 修復驗證 | 嚴格 Verify、受影響測試與 Windows 成品建置 | 修復已完成，且每項命令留存當次尾行與 exit code | A1–A9 實機驗收已完成 |
| G2 功能驗收 | 獨立驗收者執行 A1–A9 實機回放 | 每項有隔離 fixture、操作紀錄、截圖與可重播輸出 | 可自行進入 M1；仍須由人類確認 M0 結論 |

`A1–A9` 的 `Blocked` 狀態只阻止 `M0 Complete` 與 `M1-Ready`，不阻止已獲 G0 授權的 M0 修復工作。這可避免「必須先驗收完成才能實作修復」的循環。

## 核准原則

- 若任一 A 項目為 `Blocked` 或 `Unverified`，M0 不得轉為 `Ready for M1`。  
- `tool/verify.ps1` 的放寬結果只可標為 `Reference`，不得作為正式 A6 證據。  
- `RUNNING` 狀態僅視為程序資訊，不等於 A7 實機完成。  
- 僅實機回放＋可重播 log＋截圖＋`exit code` 可作為 `Verified`。

## M0 證據矩陣

| 項目 | 可接受證據 | 現況標記 | 缺口 | 是否阻塞 M0 |
| --- | --- | --- | --- | --- |
| A1 | A1 隔離與切換實機、兩種資料夾 fixture | Blocked | 無完整實機 + 截圖 | 是 |
| A2 | IME、selection、undo、redo 實機 | Blocked | 無完整操作錄影 | 是 |
| A3 | 重啟一致性比對表與前後截圖 | Blocked | 無完整比對 | 是 |
| A4 | 失敗保存 fixture、failed/retry/saved 視覺 | Blocked | 只靠測試紀錄不足 | 是 |
| A5 | stale/corrupt/missing source 實機流程 | Blocked | 未完成損壞與缺失來源實機 | 是 |
| A6 | verify 嚴格門檻尾行與 exit code | Blocked | 放寬門檻仍未核准 | 是 |
| A7 | exe hash 列表 + 啟動 + A1–A6 step 截圖 | Blocked | 缺少步驟截圖 | 是 |
| A8 | Notist Ink 入口停用與既有 Ink 保留 | Blocked | 無實機邊界驗證 | 是 |
| A9 | Kallopis 零介入、缺件清單追蹤 | Blocked | 缺口狀態未完備 | 是 |
| M0.a | 基線快照（dirty/provider/DLL） | Blocked | 多來源差異未整併 | 是 |
| M0.b | 契約欄位 owner/recovery 完備 | Blocked | 風險欄與責任欄尚未閉環 | 是 |
| M1-Ready | 所有 Bypass 條件清空 | Unverified | 任一項未完成即未達 | 是 |

## 導向決策

### 可否進入 M0.c 修復實作

- 可：修復白名單、資料回退策略與回歸案例均已在 M0 文件中列明，且有本次人類 G0 授權。
- 不可：修復會變更資料模型、進入 M1 範圍、修改 Kallopis，或需要刪改使用者真實資料。
- 不可：沒有可重放的失敗案例與回復預期；此時先補契約或測試，不以人工判斷代替。

### 可否判定 M0 Complete／進入 M1

- 不可：任一 `A1–A9`、`M0.a` 或 `M0.b` 為 `Blocked` 或 `Unverified`。
- 不可：任一項缺少驗證者、時間戳、輸出尾行、隔離 fixture 或必要實機截圖。
- 可：所有項目均為 `Verified`，並由獨立驗收依 `notist-m0-independent-verification-prompt.md` 留下當次證據。

## 記錄欄位落位（2026-09-07）

| 項目 | ReviewedBy | ReviewDate | BlockedReason | EvidencePath | ExitCode | NextAction |
| --- | --- | --- | --- | --- | --- | --- |
| A1 | `notist` | 2026-09-07 | 未完成實機雙專案隔離 fixture + screenshot 重放 | `docs/verification/m0/a1` | 未產出 | 補齊 A1 實機操作並附 step log |
| A2 | `notist` | 2026-09-07 | 僅有 controller/Widget 測試，未做實機 IME 真實編輯 | `docs/verification/m0/a2` | 未產出 | 補齊 IME/selection/undo/redo 實機回放 |
| A3 | `notist` | 2026-09-07 | 僅重啟一致性測試，缺少程序關閉與程序重啟比對截圖 | `docs/verification/m0/a3` | 未產出 | 補齊重開前後逐項比對截圖與 log |
| A4 | `notist` | 2026-09-07 | 缺失 failure/retry/final saved 的實機存檔錯誤 fixture | `docs/verification/m0/a4` | 未產出 | 補齊失敗輸入、失敗截圖與 retry 重放 |
| A5 | `notist` | 2026-09-07 | 僅有 `controller-level` 測試，缺少 stale/corrupt/missing 實機 fixture | `docs/verification/m0/a5` | 未產出 | 補齊三件 fixture 與復原證據 |
| A6 | `notist` | 2026-09-07 | 格式檢查 `--set-exit-if-changed` 回傳 1（工作樹有可格式化差異） | `tmp-notist-verify-strict.log` | 1 | 修正格式化差異後再重跑 strict |
| A7 | `notist` | 2026-09-07 | 缺少 A1–A6 實機操作截圖與逐步操作 log | `docs/verification/m0/a7` | 以 `--no-fatal-infos` 可通過（本地紀錄） | 重跑嚴格 verify 後補齊逐步截圖 |
| A8 | `notist` | 2026-09-07 | 僅有 unit test 符號未含實機手寫入口與既有 Ink 保全 | `docs/verification/m0/a8` | 未產出 | 以實機行為與 fixture 補齊 |
| A9 | `notist` | 2026-09-07 | `Kallopis` 來源來源無可追溯不可變證明鏈 | `tasks/notist-kallopis-component-gaps.md` | 未產出 | 更新每筆缺口 `LastCheckedAt/SourceOwner/BlockedBy` |
| M0.a | `notist` | 2026-09-07 | dirty/provider/DLL 與 git/hash 仍未定義為單一來源快照 | `tasks/notist-current-state-review-20260907.md` | 未產出 | 以本輪快照補齊版本與 hash 來源 |
| M0.b | `notist` | 2026-09-07 | owner/recovery 欄位仍不完整 | `tasks/notist-m0-contract-and-verification-plan.md` | 未產出 | 補齊責任、回復與不可跨越條件 |
| M1-Ready | `notist` | 2026-09-07 | 任一 A/Bypass 未完成 | `tasks/notist-m0-approval-and-evidence-matrix.md` | 未產出 | 待全部項目 `Verified` 後解除阻塞 |

## 下一步

1. 以 G0 核對 scoped repair 白名單與人類授權，再實作 M0 修復。  
2. 以 G1 重跑嚴格 Verify 與受影響測試，不可以歷史測試報告替代。  
3. 以 G2 交由獨立驗證者執行 A1–A9 實機回放。  
4. 所有項目補齊後再回填矩陣並提交 `notist-functional-milestones-todo.md`。
