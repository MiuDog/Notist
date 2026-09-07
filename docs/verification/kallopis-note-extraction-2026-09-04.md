# Kallopis Note 元件遷移驗證

狀態：視覺迭代中的 Note／背景遷移批次已可觀察（2026-09-04）；依產品指示，golden test 暫停且不列入本輪閘門。

## 真相邊界

- Kallopis 是 Note 視覺與通用互動的真相來源，現已擁有 Block、Ink preview、Sheet Grid、Primary Sidebar、File Explorer、導覽與單一 Stage 工作台元件。
- Notist 只組合畫面、路由、產品命令與狀態投影；舊的 Ink preview、Sheet Grid 與 Page Background 公開名稱只保留相容 alias，不再維護第二份實作。
- Krepis 仍是內容、schema、selection、transaction、undo、layout、Ink 與 persistence 的唯一資料／編輯真相。
- Flaticon 字型仍是預設圖示來源，未恢復舊 SVG。

## 本輪遷移

- `KlpNoteInkPreview`：Kallopis 繪製消費端提供的 Ink 點位，不接管手勢、hit testing 或保存。
- `KlpSheetGrid`：Kallopis 提供選取、方向鍵移動、Enter／雙擊編輯、提交 callback 與邊界擴充；cell 值仍由消費端控制。
- `KlpPageBackground`：Kallopis 統一提供 plain、ruled、dots、grid 四種 theme-aware 頁面底層；Flow、Canva、Sheet 正式頁面已改為直接使用此公開元件。
- `KlpPageBackgroundRecipe`／`KlpPageBackgroundPainter`／`KlpPageBackgroundEditor`：背景 recipe、viewport、point／line painter 與 connect／select／delete 通用互動已完整移到 Kallopis；Notist 原本五個內部實作檔已刪除。
- Catalog 的 Note 專區已加入可操作的背景編輯器、四種背景、Ink、Sheet Grid 及完整 Note 工作台組合，啟動時預設開啟此頁；編輯器 specimen 已移到首位方便觀察。
- Kallopis 的 Identity Header、Sidebar Navigation 與 Status Indicator 已補上極窄寬度收斂，Notist 不需另做產品側補丁。
- 摺疊內容控制已移除 `▶`／`▼` 文字符號，改用 Kallopis Flaticon disclosure icon，尺寸與定位讀取 Kallopis token。

## 非 golden 驗證

- Kallopis root：`+359: All tests passed!`，exit code 0。
- Kallopis Catalog：`+17: All tests passed!`，exit code 0。
- Notist 背景與邊界相關測試：`+22: All tests passed!`；Docking／Sidebar 樣式與布局契約：`+21: All tests passed!`。
- Notist 全部非 golden 測試目前為 `+162 ~1 -1`：唯一失敗是既有布局真相覆蓋棘輪仍有 44 條未斷言、門檻為 40；唯一略過項目需要外部 Krepis ABI 1.11 DLL。此失敗不是背景元件的功能或渲染失敗，也沒有以調高門檻掩蓋。
- Kallopis root、Catalog 與 Notist `lib/`／`test/` analyze：`No issues found!`。Notist 無參數 analyze 另會掃入 Windows build 內的 Krepis spike 原始碼，現有 68 筆第三方 lint，不列為本批產品原始碼結果。
- Kallopis Catalog Windows Release 已建立並啟動；`data/app.so` SHA-256：`6FEE2B24739195B9E54D3442DFD6BD8933C8CCFAEDCA9038974FED0C1D68B2A9`。
- Notist Windows Release 已建立並啟動；`data/app.so` SHA-256：`849AA483C59EAE899289BF0191C1FBCBFEE3538DFA64F0144D5955A32D323C58`。

## 實機證據

- [Kallopis Note Catalog runtime](../../../Kallopis/docs/verification/kallopis-note-catalog-runtime-2026-09-04.png)，SHA-256 `C81348A571439E1AEAB840F29B0A610BEBD2D0EAE7A5D5DB21854E32F7388B41`。
- [Kallopis Sheet Grid runtime](../../../Kallopis/docs/verification/kallopis-note-sheet-grid-runtime-2026-09-04.png)，SHA-256 `E6F642CF1458B636A12B6668BAC6C068C629C5F2E13F0BF67418D3F6C6C34437`。
- [Kallopis Page Background runtime](../../../Kallopis/docs/verification/kallopis-page-background-runtime-2026-09-04.png)，SHA-256 `FA72912C5C377723E77EDAED012242BF89D4DCD1039444570878A0A82CA976F3`。
- [Kallopis Background Editor runtime](../../../Kallopis/docs/verification/kallopis-background-editor-runtime-2026-09-04.png)，SHA-256 `A17BAC6876BDB21DE54B459AB0D0B70F4203430BFE1CAD88FB8B9C1AAF8E74B6`。
- [Notist visual convergence runtime](evidence/notist-visual-convergence-runtime-2026-09-04.png)，SHA-256 `0EA116DE850DCD9BEE319F4D84C002A99D482E0B9223EBA9D14F883FFF03DA21`。

## 結論

Notist 的可重用 Note 視覺與通用互動已以 Kallopis 為單一來源；本輪把 Page Background 的資料 recipe、繪製與通用編輯互動一併搬離 Notist，並提供可直接觀察與操作的 Catalog 樣本。產品語意與 Krepis authority 邊界沒有下沉。視覺仍可持續迭代，待產品確認穩定後再恢復 golden 基準。
