# Notist 第一版可執行證據（暫態）

## 目標
記錄目前可直接覆蓋 M0 A7 的可執行交付證據，並同步標示未完成門檻。

## 已完成證據

- Flutter 解析路徑：
  - `Get-Command flutter` → `D:\flutter\bin\flutter.bat`
- 建置（成功）：
  - Debug：`D:\flutter\bin\flutter.bat build windows --debug`
  - 產出：`D:\Projects\Notist\build\windows\x64\runner\Debug\notist.exe`
  - SHA256：`A95F19937993962A933380D96FD10A26EB8DEC092C92AE43D3AFD6734DCCBE1C`
  - 啟動：`Start-Process` 啟動 `PID=33196`，保持 RUNNING
  - Release：`D:\flutter\bin\flutter.bat build windows --release`（386.8s）
  - 產出：`D:\Projects\Notist\build\windows\x64\runner\Release\notist.exe`
  - SHA256：`23F0CBC9299A09C5BC95B3D639DC78B501A002FE8F1B38746B84AC46CEEECC7A`
  - 啟動：`Start-Process` 啟動 `PID=18520`，保持 RUNNING
- 主要測試命令（通過，exit code 0）：
  - `D:\flutter\bin\flutter.bat test test/flow_project_lifecycle_test.dart test/project_paragraph_composition_test.dart test/notist_flow_editor_lifecycle_test.dart test/save_state_projection_test.dart test/krepis_abi_identity_test.dart`
  - 輸出尾行：`All tests passed!`
  - 覆蓋能力：A1（Flow 生命週期）、A3（保存與開啟鏈）、A4（失敗恢復）、A6（editor lifecycle 兼容）
  - 主要訊息：`flow_project_lifecycle_test.dart` 有完整 Flow 切換與建立/貼上流程；`save_state_projection_test.dart` 通過保存失敗與 stale session 測試；`notist_flow_editor_lifecycle_test.dart` 有 composition 與 selection 路徑日志
- 補充測試（通過，exit code 0）：
  - `D:\flutter\bin\flutter.bat test test/save_state_projection_test.dart`
  - 尾行：`All tests passed!`
  - A5 補充：`stale document session cannot publish state or retry`
  - `D:\flutter\bin\flutter.bat test test/notist_project_controller_test.dart`
  - 尾行：`All tests passed!`（待重跑驗證）
  - `D:\flutter\bin\flutter.bat test test/notist_session_state_test.dart`
  - 尾行：`All tests passed!`
  - 覆蓋能力：M0 session-state 邊界（重開、舊格式回退）
  - `D:\flutter\bin\flutter.bat test test/notist_kallopis_boundary_test.dart`
  - 尾行：`All tests passed!`
  - A9 補充：Kallopis 邊界不超出 Notist 語意

## 阻塞與待補

- `tool/verify.ps1` 已更新 `check_provider_pins.ps1`，可同時驗證 commit pin 與 `../Kallopis` path 依賴；`Kallopis` 目前仍以本機 path 進行驗證門檻。
- `tool/verify.ps1` 尚未在最新腳本下完成完整重放，建議先重跑 `tool/verify.ps1` 補上 exit code 與輸出尾行。
- M0 A8 還缺：
  - 手寫停用與 Ink 邊界的實機/快照證據
- 已補：
  - 單元測試層已新增 `notist_flow_ink_test.dart`：`Stylus pointer does not create Ink when Notist stage disables it`
  - `notist_project_controller_test.dart`：新增 `stale revision / corrupt source / missing source` 載入失敗行為測試
- M0 A1–A6 A9 尚缺：
  - 行為鏈路驗證清單
  - 實機互動案例（含截圖）與重播結果
  - provider/API 全量核對

## 當前里程碑影響

- 可將 `M0.a` 的建置與啟動證據視為部分完成，`A7` 可先補齊為通過。
- 其餘項目仍待 M0.c~M0.e 實作/驗收才能宣告 `M0` 完成、進入 `M1`。

## 本輪追加驗證結果（2026-09-07 後續）

- verify 重跑（含 Release）
  - 命令：`pwsh -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1 -FlutterPath D:\flutter\bin\flutter.bat -BuildWindowsRelease`
  - pin 檢查：通過（Kallopis 本機 path + Krepis commit）
  - 格式檢查：通過
  - 靜態分析：`flutter analyze --fatal-infos` 仍回報大量資訊等級告警，整體以 exit code 1 中止
- 測試重跑（通過）
  - 命令：`D:\flutter\bin\flutter.bat test test/flow_project_lifecycle_test.dart test/project_paragraph_composition_test.dart test/notist_flow_editor_lifecycle_test.dart test/save_state_projection_test.dart test/notist_session_state_test.dart test/notist_kallopis_boundary_test.dart test/krepis_abi_identity_test.dart`
  - 尾行：`All tests passed!`
- Windows debug 重建與啟動（通過）
  - 命令：`D:\flutter\bin\flutter.bat build windows --debug`
  - 產出：`D:\Projects\Notist\build\windows\x64\runner\Debug\notist.exe`
  - SHA256：`A95F19937993962A933380D96FD10A26EB8DEC092C92AE43D3AFD6734DCCBE1C`
  - 啟動：`PID=30788`，觀察到 RUNNING

## A6 當前狀態

- `tool/verify.ps1` 目前只差資訊等級 static analyze 門檻，功能核心（pin 檢查、格式、build、test）已可重播；A6 僅在嚴格門檻下未通過。

## 本輪追加驗收更新（verify 已完整通過）
- verify 重跑（更新）
  - 命令：`pwsh -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1 -FlutterPath D:\flutter\bin\flutter.bat -BuildWindowsRelease`
  - 結果：exit code 0
  - 指標：
    - Provider pin 通過（本機 path + Krepis commit）
    - format：無變更
    - 靜態分析：目前仍為 info 導向阻塞，僅透過 `--no-fatal-infos` 可通過
    - Windows Debug 建置成功
    - 全量 test 成功：尾行 `All tests passed!`
    - Windows Release 建置成功
- release 產物：`D:\Projects\Notist\build\windows\x64\runner\Release\notist.exe`
- release hash：`23F0CBC9299A09C5BC95B3D639DC78B501A002FE8F1B38746B84AC46CEEECC7A`

## 本輪 verify strict 重跑（更新）

- 命令：`pwsh -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1 -FlutterPath D:\flutter\bin\flutter.bat`
- 格式檢查輸出：`D:\Projects\Notist\tmp-notist-verify-strict.log`
- 結果：`exit code 1`
- 尾行摘要：
  - `format` 步驟完成，檢查無變更
  - `analyze` 步驟以 `--fatal-infos` 失敗，尾行訊息指出仍有大量資訊告警
- Blocker：目前 `--analyze --fatal-infos` 因資訊級告警未過；不採用放寬版本作為 A6 通過。
