# Notion-like Block 視覺蒸餾 Wave 2 驗證紀錄

狀態：進行中（2026-09-03）

## 驗證目標

供 Notist／Krepis 維護者判斷 Wave 2 selection correctness 是否已有可執行證據，以及哪些整體 gate
仍未關閉。未通過的 gate 不得以本紀錄宣稱 Wave 2 完成。

## 已通過

- Krepis provider 固定為 commit `d39c1cdf92faa6f6301ff19229aa21602f5bfe56`，ABI 1.11。
- Krepis `krepis.flow_editor` 與 `krepis.c_abi` 測試通過；完整 provider 測試為 103/104，唯一未啟動項目
  `krepis.editing_session` 受 Windows application control policy 阻擋。
- 真實 `krepis_c.dll` consumer 測試通過，證明 Notist 可取得 ABI 1.11 文字 selection rect。
- `flutter test test/notist_flow_editor_lifecycle_test.dart`：`00:01 +18: All tests passed!`
- `flutter analyze --fatal-infos lib test`：`No issues found! (ran in 7.1s)`
- Windows Debug：`Built build\windows\x64\runner\Debug\notist.exe`
- Windows Release build exit code 0；成品位於
  `build\windows\x64\runner\Release\notist.exe`。
- 使用者裁決所有圖示預設一律使用 Flaticon 字型並棄用舊 SVG；Kallopis 圖示資產與來源測試 6/6 通過。
- Notist golden 測試已顯式載入 Flaticon Regular／Thin 字型，避免私用區字碼被誤畫成缺字方框；主畫面
  圖示基準依裁決更新後，主畫面、Canva 與 Sheet 共 3/3 通過，shell 幾何不變。
- Notist 完整 `flutter test`：`+162 ~1: All tests passed!`；唯一 skip 是需要外部 Krepis ABI 1.11 DLL
  的既定 native gate，該 gate 已由前述真實 DLL 專項測試另行通過。
- Windows Release 重建成功：`Built build\windows\x64\runner\Release\notist.exe`。實際啟動後 Flaticon
  圖示可正常辨識，運行證據為
  [`evidence/notist-flaticon-release-2026-09-03.png`](evidence/notist-flaticon-release-2026-09-03.png)。

## 尚未通過

- Provider pin gate：`pubspec.yaml` 目前以 `path: ../Kallopis` 使用本機視覺工作樹，未固定到核准 commit。
- Format gate：`dart format --output=none --set-exit-if-changed lib test` 回報 6 個檔案會被改寫；使用者要求
  程式碼以 tab 縮排，與 Dart 官方 formatter 的空格輸出衝突，未擅自批次改寫。
- Kallopis 完整測試目前為 315 項通過、34 項失敗；失敗分布在 inventory、既有元件尺寸／色彩與其他
  golden，屬同一工作樹內尚未收斂的並行視覺重構。Flaticon 圖示專項與 Kallopis analyze 已個別通過，
  但在 Kallopis 全套關閉前不宣稱上游整體完成。
- Windows Release 實機 selection 截圖與繁中 IME 操作紀錄尚未補齊。

## Wave 2 行為範圍

- 文字 selection 使用 Krepis 逐行 geometry，不以整 Block highlight 冒充。
- 單一／連續 Block selection 使用 Kallopis selected surface。
- stale geometry 只清除 transient overlay，保留最後有效 authority snapshot。
- `Esc`、方向鍵、`Shift+Click`、`Enter` 依已核准 Notion-like 狀態轉換；composition 期間不攔截。

## 結論

Wave 2 的 provider、consumer、互動測試與可執行建置已成立，但完整 Verify 與實機視覺 gate 尚未關閉，
狀態維持「進行中」。
