# NTS-0002：Page Kind 與完整筆記能力範圍

## 狀態

Proposed（由 Planist ADR-0074、0075 蒸餾，尚未核准）

## 背景

舊 Planist 同時包含筆記、設計、Dashboard、規格治理與專案控制語意。Notist 接收「全部筆記功能」若沒有
封閉 vocabulary，會把所有舊工具與 Page kind 一併帶入，造成產品邊界重新膨脹。

## 選項

### A. v1 固定 Flow、Canva、Sheet

Slide 只保留 legacy reader／export；Design 交未來 Designist；Dashboard 與產品控制 projection 不屬筆記 Page。

### B. 將 Planist 所有舊 Page kind 一次移入

淘汰。會把不同 owner 的 schema、UI 與 MCP 工具混成一個產品。

## 決定

採用 A。canonical Page kind 為：

| Kind | 職責 |
|---|---|
| `flow` | 區塊式文件、Markdown／GFM、inline、embed、reference、長文與手寫 overlay |
| `canva` | 結構化節點的自由空間、連線、group、viewport、layer 與獨立 ink layer |
| `sheet` | 可互動網格、cell／range、公式與結構化表格投影 |

Page registry、持久化 kind、建立入口、搜尋 filter 與 MCP vocabulary 必須共用同一 closed enum。
`edgeless` 只作 legacy decoder 的一次性 `canva` mapping，不成為公開 alias。Slide 未另立 ADR 前不得建立、
編輯或提供 proposal 工具；未知 kind 保留 opaque payload 並明確回報不支援。

Notist 的筆記能力範圍包括：

- Folder／Note lifecycle、metadata、pin、offline、rename、move、reference、import／export。
- Flow／Canva／Sheet 的 authoring、selection、clipboard、transaction、history、layout、background 與 ink。
- 全文搜尋、quick capture、reference／backlink、template／blueprint 與 stable identity。
- Comment、proposal review、版本、Activity／Audit projection 與 agent collaboration surface。
- Legacy Page import、stable ID mapping、round-trip、unsupported report 與 rollback。

上述是產品能力，不代表全部由 Notist 實作：內容 truth 屬 Krepis，通用 presentation 屬 Kallopis，產品
policy 與 composition 屬 Notist。

## 後果

- Journal 是聚合排程與提醒的產品頁，不是第四種內容 Page kind；其來源仍指向既有文件與任務 identity。
- Design、Dashboard、Spec、Conformance、Repo 與 Governance 是否進 Notist，必須各自另立決策，不能藉由
  legacy import 偷渡。
- 新增 Page kind 必須同時定義 schema、persistence、UI、搜尋、MCP、migration 與 rollback，不能只加 route。

## Migration 與回退

先以 legacy corpus 驗證三種 kind 的 stable ID round-trip。Slide、Design、Dashboard 與未知 kind 保留原始
payload；任何轉換失敗都不覆寫來源。`edgeless` mapping 必須是版本化、單向且可產生 migration report。

## 核准條件

- [ ] 使用者重新確認 v1 closed enum 與 Slide Deferred。
- [ ] Krepis schema、Kallopis presentation、Notist registry 與 MCP vocabulary 使用相同 kind。
- [ ] 未知 kind、版本不相容與 corrupt payload 均有 fail-closed fixture。
