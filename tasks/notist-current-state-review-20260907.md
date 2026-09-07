# Notist 當前狀態檢核與下一次交接依據

日期：2026-09-07；此快照晚於同日 M0 progress／executable-evidence 的追加紀錄。
本輪只讀 Notist 文件、源碼、依賴宣告及成品 hash；未修改程式、未執行產品測試／建置／實機操作，也未存取 Kallopis 施工工作樹。

## 判定

**M0 尚未完成，不可開始下一里程碑。** 已有部分實作、測試通過紀錄與本機成品；仍缺精確契約、完整 A1–A9 實機證據與可追溯的驗收基準。現在應收斂既有成果，不重做最初盤點，也不把管理功能的程式存在當作 M1／M2 通過。

下一份交接文件：[M0 收斂與驗證交接 prompt](notist-m0-reconciliation-prompt.md)。新 prompt 取代「從零盤點」作為下一次入口；舊計畫與原始執行紀錄保留供追溯。

## 已核實的目前狀態

| 項目 | 本輪直接觀察 | 限制 |
| --- | --- | --- |
| HEAD | `446914a9658c73289ca89dde1d49fef7e4372151` | 工作樹有未提交修改，HEAD 不是本次成品完整來源識別 |
| Flutter | 命令解析為 `D:\flutter\bin\flutter.bat`，該路徑存在；入口文件的 `C:\development\flutter\bin\flutter.bat` 本輪查無檔案 | 新執行者應重新核對 SDK 版本與路徑，不改寫歷史環境紀錄 |
| Notist Ink | [Flow editor](../lib/src/krepis/notist_flow_editor.dart) 有預設 `inkEnabled = false` 與 capture gate | 不代表全部生產入口／快捷鍵與舊 Ink 保存已驗收 |
| 管理能力 | 已新增 [workspace project store](../lib/src/project/notist_workspace_project_store.dart)，[project controller](../lib/src/project/notist_project_controller.dart) 有 delete／setPin 等操作；[document projection](../lib/src/project/notist_flow_document.dart) 有 isPinned | 上輪「沒有 pin 狀態」已過時；真實隔離、失敗原子性與 owner 契約仍需驗證 |
| Kallopis 來源 | [pubspec](../pubspec.yaml) 與 [lockfile](../pubspec.lock) 使用 `../Kallopis` path | 宣告相同 path 不代表固定施工版本，核准及不可變來源證據待查 |
| 驗證腳本 | [verify](../tool/verify.ps1) 第 103 行為 `--no-fatal-infos`；[pin check](../tool/check_provider_pins.ps1) 新增接受本機 path | 與原嚴格 gate 不同；不能用新 exit 0 推定原驗收條件已通過 |

## 成品存在與 hash（本輪重算）

| 相對於專案根的路徑 | SHA-256 |
| --- | --- |
| `build/windows/x64/runner/Debug/notist.exe` | `A95F19937993962A933380D96FD10A26EB8DEC092C92AE43D3AFD6734DCCBE1C` |
| `build/windows/x64/runner/Release/notist.exe` | `23F0CBC9299A09C5BC95B3D639DC78B501A002FE8F1B38746B84AC46CEEECC7A` |
| `build/windows/x64/runner/Debug/krepis_c.dll` | `3370F63FFDBE83D2F7F22A102A628091E5733FBAA80436BC508164DA3B85450F` |
| `build/windows/x64/runner/Release/krepis_c.dll` | `15BBB977B27409DE6D64432AEE7A34180BEF4AF620B47D7047956D65847CD056` |

兩個 exe hash 與 [既有成品紀錄](notist-m0-executable-evidence.md) 相同。這只證明檔案存在及 hash 相符；Flutter 執行還依賴資料目錄與其他 runtime 檔案，單一 exe hash 不足以證明目前 Dart 源碼已包含於成品，也不證明使用者操作通過。

## 需要收斂的問題

| ID | 發現與來源 | 下一步處理 |
| --- | --- | --- |
| R1 | [成品紀錄](notist-m0-executable-evidence.md) 第 76–88 行與 [進度](notist-m0-progress-2026-09-07.md) 第 33 行稱 Verify 完整通過，但明載透過放寬 info 致命性；原 M0 A6 禁止放寬門檻過關 | 留存兩套指令與結果，查對是否有明確 gate 變更核准；沒有就不接受為 A6，提出修復原分析問題的精確計畫，不再降低標準 |
| R2 | [成品紀錄](notist-m0-executable-evidence.md) 第 53 行建議 A7 通過，卻在第 48 行仍缺實機案例；本輪在 tasks／docs/verification 可見的截圖清單中未找到可對應本次 M0 A1–A5、A8 的逐步證據 | A7 保持未通過；程序 RUNNING 與 exe hash 不替代操作截圖。其他位置若有證據須提供可查證路徑，不能推論完全不存在 |
| R3 | [契約計畫](notist-m0-contract-and-verification-plan.md) 第 80–137 行仍多為填表要求與流程標題，缺精確 provider 簽名、fixture 預期和白名單 | M0.a–b 尚未完整鎖定；補具體表格，不再產生只有「需補」的新模板 |
| R4 | [Runbook](notist-m0-execution-runbook.md) 第 26–28、117 行接受 path／新 analyze gate；最新範圍文件卻要求固定 provider 且不介入 Kallopis | 不自動修改或還原 path／pin。追溯既有核准與施工方交付版本，無法固定則阻塞依賴的驗收；不進 Kallopis 代修 |
| R5 | [追蹤](notist-functional-milestones-todo.md) 原摘要仍稱成品 hash 待記錄、測試未執行，但已有其他執行者的測試與成品紀錄 | 區分「歷史記錄已執行」「本輪核實檔案」「目前未獨立重跑」；不直接勾選功能完成 |
| R6 | 管理功能源碼已涉及 M1／M2，但目前 M0 尚無完整關閉證據 | 保留全部既有修改，逐項標註里程碑與核准來源；凍結擴充，不重置或刪掉既有成果，也不追認下一步完成 |
| R7 | 父子頁面共用 schema／頁內獨立資料庫、欄位型別、視圖組合與刪除恢復尚未裁決 | 留在後續目錄；不阻塞與其無關的 M0 補驗，也不預設資料庫答案 |
| R8 | [workspace store](../lib/src/project/notist_workspace_project_store.dart) 第 41–54 行把 root 和其全部直屬目錄都視為專案，而 [project store](../lib/src/project/notist_project_store.dart) 第 29 行遞迴讀取 .krdf | 高優先來源風險：root 可能混入子專案筆記、普通資料夾被視為專案。先定義並驗證掃描／刪除隔離；未實跑，不宣稱已發生資料損失 |
| R9 | [controller](../lib/src/project/notist_project_controller.dart) 第 362–375 行先刪筆記檔再寫 pin；第 395–402 行先更新 pin 投影再寫檔；第 759、774 行有 pin 讀失敗回空及刪舊檔後 rename | 對現有寫入路線提出失敗原子性、損壞保留與中斷恢復驗證。文件已刪而 metadata 保存失敗，不能僅用錯誤欄位代表操作已回退 |
| R10 | [project store](../lib/src/project/notist_project_store.dart) 第 57、106 行限制單層，但仍遞迴載入筆記；[既有測試](../test/notist_project_store_test.dart) 第 40 行仍期待巢狀資料夾 | 新邏輯與既有測試預期存在衝突，舊深層筆記可見性待驗；不能沿用先前「全量通過」作為目前版本結論 |
| R11 | [目前 Ink 測試](../test/notist_flow_ink_test.dart) 的案例明確啟用 Ink；本輪搜尋現有 test 未找到 setPin／deleteFlow／createProject／deleteProject 呼叫 | 舊紀錄中的新增停用／管理覆蓋不能直接套用現在工作樹；以實際案例內容核對覆蓋，搜尋未找到不等於證明所有測試皆缺乏該行為 |

R8–R11 是唯讀源碼審查的風險與差異，不是本輪執行失敗結果。若修復涉及 M1／M2，先提出對 M0 的影響與精確範圍裁決，不能藉修復名義直接展開後續里程碑。

## A1–A9 現況

| 條件 | 目前可以說的結果 | 尚缺 |
| --- | --- | --- |
| A1 建立與切換 | 有源碼與其他執行者自動測試通過紀錄 | 隔離資料下真實成品雙筆記操作與 ID／投影對照 |
| A2 IME／編輯 | 有 composition／selection 測試紀錄 | 真實繁中 IME、取消／提交、split／merge／undo／redo 操作證據 |
| A3 重開一致性 | 有保存／載入測試紀錄 | 真正程序重啟後兩份文件資料一致證據 |
| A4 保存失敗／retry | 有 save-state 測試紀錄 | 真實檔案保存失敗前後 hash、retry 與 UI 狀態證據 |
| A5 不合法來源 | 紀錄稱新增 controller-level failure tests | 真實 provider stale revision、損壞／未知版本／缺失來源 fixture；不能以 stale session 替代 stale revision |
| A6 完整 gate | 紀錄稱放寬後 exit 0 | gate／provider 授權對照、原嚴格基準或正式核准替代基準下完整重放 |
| A7 成品實機 | 本輪核實 exe／DLL 存在及 hash | 整包與源碼版本關聯、操作記錄、逐案例實機截圖 |
| A8 Ink 停用／保全 | 源碼有預設停用 gate，紀錄稱有 stylus 測試 | 全入口停用與既有 Ink 文字保存不丟資料的真實 fixture／實機證據 |
| A9 Kallopis | 目前 Notist 依賴本機 path，已有邊界測試紀錄 | 施工方固定交付／核准資料；邊界測試不證明工作樹零改動或來源不可變 |

本表沒有任何一項被升格為完整 Pass。產品實測本輪未執行；不把原始測試紀錄視為虛假，也不把它們當成足夠的整合驗收。

## 本輪文件交付驗收

- 需求對照：更新當前狀態、保留既有成果、生成新的可交接 prompt。
- 範圍：只新增本報告與 prompt，更新追蹤入口和狀態摘要；原始執行紀錄保留。
- 文件檢查與獨立審查結果由本輪回報提供，與產品 A1–A9 驗收分開。
