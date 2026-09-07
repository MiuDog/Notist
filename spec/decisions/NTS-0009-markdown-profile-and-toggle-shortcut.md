# NTS-0009：Markdown profile 與 `> ` 摺疊快捷例外

## 狀態

Accepted（2026-09-03；使用者明確核准選項 A）

## 背景

Notist 需要以 Markdown 習慣快速建立註解、數學式、程式碼與摺疊內容，但「看起來像 Markdown」不等於
標準語法。CommonMark 0.31.2 將 `>` 定義為 blockquote、至少三個反引號或波浪號定義為 code fence、
三個以上同類 `*` 定義為 thematic break，並將 `<!-- ... -->` 視為 raw HTML comment。CommonMark 沒有
摺疊區段或 LaTeX 語法。

GitHub 文件另行支援 `<details>`／`<summary>` 摺疊區段，以及 `$...$`、`$$...$$` 與 `math` fenced
block 數學式。Notion 官方則把空白行開頭的 `> ` 定義成 toggle-list 輸入快捷，而不是交換格式。

既有匯入方案固定的 `cmark-gfm` `0.29.0.gfm.13` core registry 只登錄 table、strikethrough、autolink、
tagfilter 與 tasklist；官方原始碼沒有 math 或 details semantic extension。後續 provider contract 必須先以
prototype 驗證 extension／source-range 策略，不得假設 `cmark-gfm` 已提供不存在的 math API。

NTS-0006 已固定第一版只有單向 Markdown 匯入；本決策不能暗中加入 export、source-mode 或雙向無損
round-trip。

## 選項

### A：CommonMark 核心＋明載的 GitHub 擴充＋唯一 `> ` live-input 例外（建議）

- 貼上與檔案匯入依 CommonMark／指定 GitHub extension 解析。
- 只有直接在空白 Paragraph 鍵入 `> ` 時建立 toggle list；貼上與匯入 `> quote` 仍是 blockquote。
- toggle 的單向匯入格式採 `<details>`／`<summary>`。
- 不採 `-#`、`$$$$` 或六個 `*` code block 等未查證語法。

後果：兼顧可攜匯入與 Notion 式操作，但 Krepis 必須明確區分 input event 與 paste/import intent。

### B：只採 CommonMark

- `>` 一律是 blockquote。
- 摺疊與 LaTeX 不進入本次 Markdown 功能。

後果：互通邊界最單純，但不符合使用者已指定的 Notion 式摺疊操作，也無法完成數學式需求。

## 擬採決定

採 A。空白 Paragraph 的 live typing `> ` 必須建立 toggle list，而且它是唯一允許偏離 Markdown parser
的輸入快捷。貼上與檔案匯入仍依 CommonMark／已核准的 GitHub extension profile 解析。

語法與行為細節由 [SPEC-quick-input-blocks](../features/SPEC-quick-input-blocks.md) 約束；若該規格與本 ADR
衝突，以 Accepted ADR 的邊界為準並先修正規格。

## 後果

- Notist 擁有 live-input intent 與快捷政策；不自行解析或保存 Markdown AST。
- Krepis 擁有 CommonMark／GitHub extension 解析、toggle／comment／math schema、transaction、undo 與保存。
- Kallopis 只提供 toggle、comment fallback、code 與 math host 的通用視覺 primitive。
- raw HTML 永不執行；只映射明確 allowlist，未知或畸形內容保留 UTF-8 source 與 diagnostic。
- LaTeX／details parser 的具體技術方案留給 Krepis provider contract；在 prototype gate 通過前維持 unavailable。
- Markdown export、source-mode 與雙向 round-trip 維持 Deferred，不因本決策自動解凍。

## Migration 與回退

舊 reader 遇到新 kind 必須 fail closed，不得把內容靜默丟棄。任一 provider、ABI、consumer 或 Windows gate
失敗時，停用新輸入入口並保留既有 Paragraph／blockquote／code／thematic-break 行為；不把 parser 搬到 Flutter。

## 核准證據

- [x] 使用者明確指定 `> ` 是唯一硬性改成 Notion-style toggle 的輸入快捷。
- [x] 使用者核准完整選項 A。
- [x] 使用者授權依本 ADR 建立並實作 Krepis provider contract。

## 查證來源

- [CommonMark 0.31.2 specification](https://spec.commonmark.org/0.31.2/)
- [GitHub Docs: Organizing information with collapsed sections](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-collapsed-sections)
- [GitHub Docs: Writing mathematical expressions](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions)
- [Notion Help: Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts)
- [cmark-gfm core extension registry](https://github.com/github/cmark-gfm/blob/master/extensions/core-extensions.c)
