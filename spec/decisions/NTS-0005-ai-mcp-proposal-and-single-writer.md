# NTS-0005：AI／MCP Proposal 與單一 Writer

## 狀態

Proposed（由 Planist ADR-0034、0038、0075 蒸餾，尚未核准）

## 背景

Notist 未來以 MCP 向 AI 提供專案知識與工程規格。若 MCP 直接開啟 Krepis persistence，或內建 AI、外部 AI
與人類各有一條寫入路徑，permission、版本、Audit、undo 與畫面狀態會分岔。

## 選項

### A. AI／MCP 是 actor，所有寫入走同一 Authority

讀取使用 capability-filtered projection；一般寫入建立 node-anchored proposal，核准後才由 authority 套用。

### B. MCP 直接寫 Krepis storage

淘汰。形成第二 writer，繞過 typed transaction、permission、conflict、Activity 與 Audit。

### C. 直接複製 Planist 全部 MCP 工具

淘汰。會把 Planist 的產品控制、Dashboard、Spec、Repo、Governance 與其他 owner 語意帶進 Notist。

## 決定

採用 A：

- MCP 預設 `disabled`；使用者明確啟用後才揭露 discovery 與工具。
- `readOnly` 只允許 list／search／read；一般 write 建立 proposal；`trusted` 可依明示 policy 自動套用，但仍
  保存 proposal、caller identity、結果、Activity 與 Audit。
- 人類、內建 AI、外部 MCP client 共用 actor identity、permission、typed transaction、proposal、rate／size
  limit 與 Audit，不建立平行 grant model。
- MCP 不直接開啟 Krepis persistence，不自行提升 capability，不背景喚醒未執行的 Notist。
- unknown kind／node、stale revision、超限、部分失敗、版本不相容與資料拒讀一律 fail closed。
- listing、search、backlink、count、錯誤與 log 不得洩漏無權限內容存在性。
- 同一時刻只有一個 note MCP tool owner 與一個 authority writer；owner cutover 以 discovery revision、版本 pin
  與 rollback 證據完成。

Notist MCP 的候選模組為 `workspace` 的 note／folder lifecycle 子集、`notes`、`doc`、`sheet`、`canva` 與
`collaboration`。工具名稱與 schema 仍須獨立規格；本 ADR 不核准完整工具清單。

## 後果

- 外部 Codex 可在沒有內建 AI Provider 時使用 Notist MCP，但仍需使用者明示啟用與 capability。
- UI 必須呈現 proposal pending、accepted、rejected、stale、conflict 與 unavailable，而不是只顯示 AI 已完成。
- Planist dogfood direct mode 不得移植到 production。
- MCP availability 失敗只影響對應 capability，不能讓 Notist 本地筆記無法啟動。

## Migration 與回退

先抽 tool ownership manifest 與共同 fixtures，再做 read-only shadow listing、proposal write，最後切 tool owner。
切換失敗時關閉 Notist MCP capability並 pin 前一 adapter；不得刪 legacy data或讓兩邊同時接受寫入。

## 核准條件

- [ ] 使用者確認 disabled／readOnly／proposal／trusted 四級行為及 trusted 的適用邊界。
- [ ] discovery、permission、proposal、stale revision、Audit、single-writer cutover 與 rollback 有端到端證據。
- [ ] Codex 真實完成 list／search／read／propose／status／review 驗收。
