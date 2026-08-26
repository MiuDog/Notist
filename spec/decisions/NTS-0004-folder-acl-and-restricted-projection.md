# NTS-0004：Folder ACL 與受限內容 Projection

## 狀態

Proposed（由 Planist ADR-0030、0046 蒸餾，尚未核准）

## 背景

Notist 的 Primary Sidebar 下半部是 FileExplorer，未來還要支援團隊知識庫。若每篇筆記自行保存 ACL，使用者
無法由 Explorer 位置預測權限；若 Client 先載入完整資料再隱藏，搜尋、backlink、錯誤與 layout 都可能洩漏
受限內容。

## 選項

### A. Folder 作為唯一資源 ACL 容器

Folder 可巢狀；Page／Asset 是葉節點，使用一個 home Folder 決定有效 ACL，其他位置只作 shortcut。

### B. 每個 Page／Asset 自帶 ACL

淘汰。整理位置與實際權限分離，migration、Audit 與使用者預測都更困難。

### C. Client 載入全部資料後再顯示 restricted placeholder

淘汰。資料已越過 authority boundary，無法防止 side channel 與繞過。

## 決定

採用 A 作為候選模型：

- Folder 是 workspace-scoped、具有 stable ID、parent、order 與 ACL 的 entity；只有 Folder 可巢狀。
- Page、Asset 與其他資源不保存能覆寫 Folder 的 ACL；內容引用不形成 Explorer hierarchy。
- ACL v1 使用 stable identity group grant；`inherit` 取最近祖先，`custom` 完整取代繼承，不做隱式聯集。
- resource 只有一個 `homeFolderId` 決定 ACL，可有多個 placement／shortcut，但 shortcut 不參與權限計算。
- authority 對每次 list、open、search、backlink、export、AI、MCP 與 error 執行 permission filter；ID 被猜中
  或 stale cache 不得繞過。
- 受限 embed 只投影維持版面所需的最小 geometry 與 opaque restricted state，不提供 title、MIME、owner、
  thumbnail、原始 ID 或可推測內容的錯誤。
- 移動 home Folder、刪除 Folder 或改 ACL 必須先產生 access-diff preview，再以帶 revision、idempotency key
  與 confirmation token 的單一 authority transaction commit；任一 hidden target 無法安全表達時整筆拒絕。

## 後果

- FileExplorer 的階層同時成為主要整理模型與權限預測模型，但 shortcut 必須清楚區別。
- Folder move／delete 可能改變多人可見性，不能只在 Flutter tree 做本地 mutation。
- restricted projection 保留 geometry 會洩漏占用尺寸；這是明確取捨，需在安全評估重新核准。
- 個人模式仍可使用相同模型的單一 owner baseline，不需建立另一套資料格式。

## Migration 與回退

舊 Page ACL 只供 migration／Audit，不得和 Folder ACL 同時決定 production 權限。切換需要 dual-read parity、
真實 corpus 的 stable ID／body hash／reference／ACL report，以及 default-off rollback switch。無法證明 baseline
時 fail closed，不把內容自動掛到較寬鬆 root。

## 核准條件

- [ ] 使用者確認 Folder 是權限邊界，而不只是整理視圖。
- [ ] home Folder、shortcut、inherit／custom 與 group grant 語意完成專門 ADR 或 schema。
- [ ] hidden resource 在 listing、count、search、backlink、error、log、AI 與 MCP 均不洩漏存在性。
