# NTS-0001：產品定位與筆記 Runtime Ownership

## 狀態

Proposed（由 Planist ADR-0073、0074 蒸餾，尚未核准）

## 背景

Notist 已不再只是 Krepis 的平凡展示消費者。產品目標改為自由文件工作空間：一般使用者可在同一份
文件混合結構化區塊與手寫圖層；未來再加入團隊知識庫、正式工程規格、Journal、AI 與 MCP。

若把「筆記前端」整體交給 Kallopis，會讓視覺庫取得產品資訊架構與 UX policy；若把內容、selection、
undo 或 layout 留在 Notist，又會形成 Krepis 之外的第二份 truth。

## 選項

### A. 依 presentation、product composition、content truth 分層

Kallopis 提供無產品語意的視覺與互動契約，Notist 組合產品畫面與 UX，Krepis 保存內容與編輯 truth。

### B. Kallopis 擁有完整筆記產品前端

淘汰。Kallopis 將需要認識 Note、route、Journal、Folder policy、產品選單與權限狀態。

### C. Notist 自行實作編輯核心

淘汰。會複製 Krepis 的 node、selection、transaction、history、layout 或 ink 規則。

## 決定

採用 A，責任固定如下：

| Owner | 擁有 | 不擁有 |
|---|---|---|
| Krepis | node／object truth、stable content ID、schema／codec、layout、selection、transaction、history、undo、ink data 與運算 | Flutter theme、Notist 導覽與產品流程 |
| Kallopis | semantic token、theme、primitive、reusable component、無產品語意的 editor presentation／input contract、accessibility presentation | Note truth、產品 route、Journal policy、權限與 MCP schema |
| Notist | 專案與筆記 lifecycle、資訊架構、畫面組合、操作 policy、選單內容、輸入事件到 command 的接線、錯誤與 availability 呈現 | Krepis truth 的第二份實作、Kallopis primitive 的複製品 |

Notist 擁有產品專屬複合 Widget 不算架構偏移。判準是 Widget 是否只投影狀態及送出 command，而不是
檔案數量。跨產品真的重用整套 Krepis／Flutter 接線時，另評估 editor adapter；不以小機率重用為由污染
Kallopis。

## 後果

- Notist 可以建立 `NoteEditorSurface`、`NoteContextMenu` 等產品複合元件，但不得保存權威編輯狀態。
- Kallopis 元件 API 不得出現 Notist route、Journal、Folder policy 或 MCP 型別。
- 所有輸入最終走 Krepis 的 typed command；Kallopis 與 Notist 不保留 fallback algorithm。
- 舊 Planist 筆記行為只作 migration fixture，不直接複製 class、DTO、theme 常數或產品命名。

## Migration 與回退

1. 先建立 capability inventory，標示 `existing`、`in_progress`、`missing` 與唯一 owner。
2. 已有能力只補 consumer contract；缺口才在 owner repo 實作。
3. 以 stable ID、selection、layout、undo、clipboard、ink 與錯誤狀態 fixture 比對舊行為。
4. 新 contract 未完成時保留 reader，不刪除原資料；版本不相容一律 fail closed。

回退只切回前一個相容版本或 reader，不把 editor 演算法複製回 Notist。

## 核准條件

- [ ] 使用者明確接受三層 ownership 與依賴方向。
- [ ] Kallopis／Krepis 公開 contract 有 Notist consumer fixture。
- [ ] 搜尋證明 Notist 沒有第二份 node、selection、transaction、history、layout 或 ink truth。
