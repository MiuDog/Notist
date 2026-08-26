# Spec: project-document-flow

狀態：Implemented（2026-08-23；P1 production dogfood，非正式 P4 persistence）

## Objective

把已通過 Krepis 機器閘門的 Paragraph-only Flow Editor 接成 Notist 第一個 production dogfood `flow`
投影。Windows
使用者可以建立專案內文件、從 FileExplorer 開啟、直接編輯、關閉後重開並看到相同內容；所有文字、
selection、undo、layout 與保存結果都來自 Krepis，不使用 Flutter mirror state 冒充 authority。

本批仍使用 DOC-0003 可丟棄格式，不是正式 persistence schema，也不承諾 migration、跨版本相容、
協作 authority 或跨裝置 identity。

### User-visible behavior

1. 空專案提供「新增文件」；成功後建立一份 `flow` 文件並在單一 Stage 開啟。
2. FileExplorer 顯示真實文件投影；點擊文件切換目前文件，不建立 tabs 或 split。
3. Stage 內容掛載 Krepis Flow Editor，支援文字、IME、Enter split、Block 開頭 Backspace merge、游標、
   selection、undo／redo與滑鼠滾輪。
4. 文件標題在內容頂部編輯，FileExplorer 與 Stage header 投影同一 Krepis truth。
5. 狀態區分 `localLoaded`、`saving`、`saved` 與 `failed`；只有真實 save success 可顯示
   `saved`，失敗時保留最後成功版本並提供 retry。
6. 關閉並重開 Notist 後，文件 stable root ID、標題、Paragraph 順序與內容一致。

## Tech Stack

- Notist：Flutter `3.44.4`、Dart `3.12.2`、既有 `ffi ^2.2.0`。
- Krepis：C++20、既有 C ABI、display list、FlowEditor 與 dogfood codec。
- Kallopis：只消費 `lib/kallopis.dart` 的公開 Stage、Explorer、empty／status presentation。
- 本功能不新增 Dart package；native truth 與 persistence 不進入 Notist state model。

## Commands

Krepis provider gate：

```powershell
cmake --build build/msvc-x64 --config Debug
ctest --test-dir build/msvc-x64 -C Debug --output-on-failure
```

Notist consumer gate：

```powershell
& .\tool\verify.ps1
C:\development\flutter\bin\flutter.bat run --debug -d windows
```

## Project Structure

- Krepis `include/krepis/`、`src/`：Flow root／首段標題投影、dogfood persistence 與 C ABI。
- Notist `lib/src/project/`：專案與目前文件的產品 lifecycle／projection（planned）。
- Notist `lib/src/krepis/`：只擴充既有 native adapter，不保存第二份內容 truth。
- Notist `lib/src/sidebar/`、`lib/src/stage/`：FileExplorer、Stage route 與保存狀態投影。
- 兩倉 `tests/`／`test/`：provider contract、FFI consumer fixture、widget 與 Windows smoke。

## Code Style

Krepis 的公開 command 必須 revision-aware、fail closed，C ABI 只使用固定寬度 C 型別與明確 ownership。
Notist 只保存目前 route／document stable ID，不保存 Paragraph、selection、undo 或 layout mirror。所有註解
使用繁體中文；identifier 與測試名稱使用英文。

## Testing Strategy

1. Provider unit：stable Flow root、首段標題投影、一般文字 rename、undo 與 dogfood round-trip。
2. C ABI：root info、title buffer sizing、ABI version、struct size、錯誤碼與 lifetime。
3. Consumer widget：空專案、新建、Explorer 投影、單一 Stage、切換文件與真實 save-state。
4. Existing editor regression：IME、split／merge、undo／redo、hit-test、scroll 與 display list 全數保留。
5. Windows manual：完成 Krepis P1 尚未勾選的七項實機驗收，不以 widget test 代替注音與重開驗收。

## Boundaries

- Always：Krepis 是內容與文件 metadata truth；Notist 只送 intent、保存 stable ID 與投影結果。
- Ask first：改 dogfood format version、更新 golden、增加第三方 dependency。
- Never：把 `NotistFlowPage` prototype 直接當 production 文件；用固定 title／`Saved`；在 Flutter 複製
  Paragraph、selection、undo、layout 或 persistence algorithm。

### Frozen areas

- Canva／Sheet prototype 與 Catalog。
- Quick Search、Journal、AI、Assets runtime。
- Ink、collaboration、permission、MCP 與正式 P4 authority。
- Kallopis primitive／token API；除非另有已核准供應者計畫，不得修改。

## Success Criteria

1. Provider test 證明 Flow root ID 與第一個 Paragraph 標題來自同一 revision，rename 使用一般文字
   transaction／undo，保存重開後 root 與標題不變。
2. Consumer widget test 從空專案新增文件後，只存在一個 Flow Stage，FileExplorer 與 header 顯示同一
   title，production tree 不含 Flow／Canva／Sheet prototype。
3. 真實 FFI／Windows fixture 依序輸入文字、Enter、跨 Block Backspace、undo、redo，重開後 Paragraph 順序與
   UTF-8 內容逐 byte 相同。
4. 保存失敗 fixture 顯示 `failed` 且保留最後成功 revision；retry 成功後才顯示 `saved`。
5. 未選文件或 native bridge 不可用時顯示明確 empty／unavailable，不建立假文件或 fallback editor。
6. Krepis Debug 測試尾行為 `100% tests passed, 0 tests failed`；Notist Verify exit code 為 0。
7. Windows 實機驗收留下空專案、新增、Unicode／IME、split／merge、undo／redo、保存、重開與保存失敗
   的通過／失敗記錄；任何一項未通過時不得宣告本批完成。

## Resolved Questions

1. 第一個 production Page kind 只有 `flow`；Canva／Sheet 維持 prototype。
2. 正式文件使用 Krepis Flow layout；Notist 不重寫編輯器。
3. 先完成真實 Flow lifecycle 與 persistence，再開始 Markdown runtime。
4. 專案資料使用 app-managed local project，不在首次啟動要求選資料夾。
