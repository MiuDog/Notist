# Notist 決策紀錄

本目錄保存 Notist 的架構決策。每份 ADR 只處理一個決策主題；`Proposed` 只能作為規劃輸入，取得使用者
明確核准後才能改為 `Accepted` 並據此實作。

## 目前決策

| ADR | 狀態 | 主題 |
|---|---|---|
| [NTS-0001](NTS-0001-product-and-note-runtime-ownership.md) | Proposed | 產品定位與筆記 runtime ownership |
| [NTS-0002](NTS-0002-page-kinds-and-note-capabilities.md) | Proposed | Page kind 與完整筆記能力範圍 |
| [NTS-0003](NTS-0003-collaboration-authority-and-offline-sync.md) | Proposed | 協作 authority、交易、衝突與離線同步 |
| [NTS-0004](NTS-0004-folder-acl-and-restricted-projection.md) | Proposed | Folder ACL 與受限內容投影 |
| [NTS-0005](NTS-0005-ai-mcp-proposal-and-single-writer.md) | Proposed | AI／MCP proposal 與單一 writer |
| [NTS-0006](NTS-0006-first-runtime-flow-and-markdown-import.md) | Accepted | 第一個正式 Flow runtime 與 Markdown 單向匯入邊界 |

## Planist 來源快照

以下來源讀自 `C:\Projects\planist` 的未提交工作樹。快照基準為 `main`／
`6e3a38a31ed1e383c2b807c0f495f50c90619c59`，擷取日期為 2026-08-23。原 ADR 的 `Accepted` 狀態只代表
Planist 當時的決策；移入 Notist 後不自動繼承，因此本目錄的蒸餾稿均保持 `Proposed`。

| Planist ADR | SHA-256 | 蒸餾去向 |
|---|---|---|
| `0073-product-module-ownership-and-decision-archive.md` | `E802E4B8317FD7100250E44F863C312372292CD6807B1A3B438C65AC82DFA14F` | NTS-0001 |
| `0074-note-runtime-externalization-and-cutover.md` | `A5E75B55D4C24A713D8FD3F6EBA17CDF21D07AC923F817331F0675C0EEAE0B78` | NTS-0001、NTS-0002 |
| `0075-notist-note-capabilities-page-kinds-and-mcp.md` | `556D644A719B74DFF33E64BC0DF18875B8B35969D038DF1CA50F7289A1162AA7` | NTS-0002、NTS-0005 |
| `0029-authority-package-transport-and-persistence-topology.md` | `9536695FF97AF8D64FC0F92223D594818919CAC22711723D0B7B4AD195B6CBC7` | NTS-0003 |
| `0030-identity-root-device-credentials-and-secret-storage.md` | `B29F6211BE9A487F1A2A4FDB7A46981AF98A67EC9985217DD1BDEE8A807060AE` | NTS-0003、NTS-0004 |
| `0032-host-ordered-typed-transactions-and-offline-leases.md` | `55034F5CBA12D85976EF1513A567534A7B82FA8DA143BF57E4E23A37B22F2E7D` | NTS-0003 |
| `0034-ai-capability-grants-executor-relay-and-usage.md` | `52542423F34B83EED80ACF08896B3623AFD482CA12D13632303B2A407A5719B4` | NTS-0005 |
| `0035-authority-sqlite-persistence.md` | `62A04F9857F1FEFB5FA31CE21A28D3BEE91EC959DB9EAAC36C6B11A31ABDF178` | NTS-0003 |
| `0036-authority-canonical-frame-and-event-digest.md` | `1F2AAA4E96A07A2C0F45BBA6633676720399129F758ABF9581141DEC2A4C0355` | NTS-0003 |
| `0038-mcp-inbound-adapter.md` | `9367D64D6FB1FE9AFDEA1F3FA344C480C7D1CBD23524930410C2F3B38BB3D2B9` | NTS-0005 |
| `0041-cpp-authority-host-backend.md` | `CF280C84859E31E254BBAA332D5576BC229A1B26D9AFAAEA60086DE696C4FE58` | NTS-0003 |
| `0045-client-device-key-locator-and-rotation-saga.md` | `9606F89554D68AE7AC9C4427917B2683A24643576BDA90B15588EC2CF21955BE` | NTS-0003 |
| `0046-folder-authority-and-restricted-resource-projection.md` | `7E4253505526801C09BD7E8CC085D82E2CA3CF05929D21A4B0F0E60C84344947` | NTS-0004 |

## 蒸餾原則

- 保留安全 invariant、被否決方案、migration 與 rollback gate，不複製 Planist 產品名詞。
- 不把 Planist 的 `Accepted` 狀態、實作完成度或 rollout 宣稱帶入 Notist。
- Krepis、Kallopis、Notist 與未來 Shared Platform 各自維持單一 ownership，不建立第二份權威規則。
- 舊來源消失後，以本表的完整 hash 判斷外部備份是否為同一份文件。
