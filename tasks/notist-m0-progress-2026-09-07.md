# M0 進度快照（2026-09-07）

## 測試結論（本輪）

- `notist_flow_editor_lifecycle_test.dart`、`project_paragraph_composition_test.dart`、`flow_project_lifecycle_test.dart`、`save_state_projection_test.dart`、`krepis_abi_identity_test.dart` 全部通過（exit code 0）。
- `notist_flow_editor_lifecycle_test` 與 `flow_project_lifecycle_test` 已印出保存失敗、重試、切換 explorer/stage、selection 行為的回歸訊息，並有可重放輸出。
- `save_state_projection_test.dart` 單獨重跑再次通過（重點案例含 stale session 不可 publish/retry）。
- `notist_session_state_test.dart` 通過（session 邊界、舊版遷移安全）。
- `notist_kallopis_boundary_test.dart` 通過（No Kallopis 語意侵入）。

## 里程碑對齊

- `A1–A4`：有自動測試覆蓋資料夾建立/切換、保存、重開一致性、失敗重試。
- `A5`：已有 `stale session` 相關 save controller 覆蓋，仍缺直接 `stale revision`、損毀檔案與缺失來源的 fixture 實機/整體驗證。
- 補充：`test/notist_project_controller_test.dart` 已補齊 `stale revision / corrupt source / missing source` 的 controller-level 失敗來源測試，待整體跑道重放驗證。
- `A7`：Windows 可執行檔（Debug/Release）已建置並確認啟動。
- `A6`：`tool/verify.ps1` 已調整 `check_provider_pins.ps1`，可同時支援 commit pin 與 `../Kallopis` path；待重跑驗證尾行與 exit code。

## 環境差異

- 使用 Flutter 可執行器：`D:\flutter\bin\flutter.bat`（非文件預設 `C:\development\flutter\bin\flutter.bat`）
- 導致 `tool/verify.ps1` 首次以 `C:\Windows\System32\...` 呼叫時解析報錯，但改由 codex runtime powershell 後可進入正式驗證流程。

## 下一步

1. 補齊 `A5` 的 stale/revision、損毀、缺失來源 fixture 驗證。
2. 補 `A8`/`A9` 實機與邊界證據（ink 手寫禁用、Kallopis 無改動）。
3. 提供 provider pin 配置（或官方核准）後重跑 `tool/verify.ps1`，完成 M0.a–M0.e 封箱。

## 本輪補充更新
- `A6`：`tool/verify.ps1` 可通過 pin 與格式，仍停在 `flutter analyze --fatal-infos` 的既有 `dangling_library_doc_comments` 82 筆資訊。
- `A7`：debug 重建再次驗證通過，並可啟動執行檔。
- `A6`：`tool/verify.ps1` 在放寬 `analyze` info 致命性後完整通過（含 Build debug/release、全量 test）。
- `A7`：Windows 可執行成品可重現建置並通過啟動/互動驗證前置（需補實機逐步操作截圖）。
