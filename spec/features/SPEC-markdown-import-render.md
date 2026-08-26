# Spec: markdown-import-render

狀態：Approved（2026-08-23；使用者核准 A/A/A，仍依賴 Block contract）

## Objective

讓 Windows 使用者把 Markdown 文字貼入目前 Flow，或把 `.md` 檔匯入成新的 Flow；Krepis 將內容以
單一原子 transaction 轉成 native Block／inline marks，既有 layout 與 display list 在下一個有效 frame
自動渲染。第一版是單向匯入，不把原始 `.md` 或 Flutter Markdown AST 當 authority。

### User-visible behavior

1. 在 Flow 游標處貼上可辨識的 Markdown，可選「貼上並格式化」；完成後成為可正常編輯的 Blocks。
2. 匯入 `.md` 會建立新的 Flow；成功前不出現在 Explorer，成功後以檔名 stem 作初始標題。
3. 整次貼上／匯入只有一筆 undo；undo 後文件與 selection 回到操作前 revision。
4. 不支援的語法保留為可見純文字，並顯示可展開 diagnostic；不得無聲丟資料。
5. 使用者可改用「貼上純文字」；自動偵測不得讓一般 prose 無法原樣貼上。

## Tech Stack

- Parser 候選固定為 GitHub 官方 `cmark-gfm` `0.29.0.gfm.13`；實作前以完整 release commit SHA 鎖定
  `FetchContent`，不得只用 branch 或浮動 tag。
- 只消費 C AST API：`cmark_parser_new`／`cmark_parser_feed`／`cmark_parser_finish`、`cmark_iter_new`
  與 core extension registration；不呼叫 HTML renderer。
- 官方 core extensions 已包含 table、strikethrough、autolink、tagfilter、tasklist；是否映射成 native
  Block 仍由本規格的支援矩陣決定，不因 parser 能解析就自動宣稱產品支援。
- Krepis 依既有 FND-0003 使用 CMake `FetchContent`；Notist 不新增 Markdown package。

官方查證：

- https://github.com/github/cmark-gfm/releases/tag/0.29.0.gfm.13
- https://github.com/github/cmark-gfm/blob/master/src/cmark-gfm.h
- https://github.com/github/cmark-gfm/blob/master/extensions/core-extensions.c

## Supported Syntax

第一版 native mapping：Paragraph、ATX／Setext heading 1–6、unordered／ordered list、blockquote、fenced／
indented code block、thematic break、soft／hard break、emphasis、strong、strikethrough、inline code、link
與 autolink。

第一版 fallback：table、task list、image、raw HTML、footnote、自訂 directive 與未知 extension。每個
fallback 保存原始 source slice 為純文字 Block 並附 diagnostic code；raw HTML 永不執行。

## Project Structure

- Krepis `include/krepis/markdown_import.hpp`（planned）：輸入、diagnostic、fragment 與 import result contract。
- Krepis `src/markdown_import.cpp`（planned）：cmark AST → native fragment mapping。
- Krepis document／transaction／C ABI：revision-aware atomic apply 與一筆 undo。
- Notist `lib/src/markdown/`（planned）：clipboard／`.md` file intent、進度、diagnostic 與 plain-text fallback。
- 兩倉 tests：CommonMark/GFM fixture、惡意／邊界輸入、C ABI、widget 與 persistence round-trip。

## Code Style

Parser AST 只存在於 import 邊界，離開 mapper 前必須轉成 Krepis typed fragment。任何 raw pointer 都由
RAII wrapper 管理；任何 import error 都在 publish 前返回。Notist 不檢查 Markdown 語法細節，只根據
typed result 顯示成功、fallback 或 failure。

## Testing Strategy

1. Parser mapping table：每種支援 node 都有最小、巢狀與 Unicode fixture。
2. Losslessness：所有 fallback fixture 將原始 UTF-8 source slice 逐 byte 保留在可見文字中。
3. Atomicity：解析錯誤、超限、stale revision、OOM simulation 都不得發布部分 Blocks。
4. History：整份 import 一次 undo／redo；selection 與 stable ID 行為由 provider test 鎖定。
5. Security：raw HTML、`javascript:` link 與畸形 UTF-8 不執行、不開啟、不穿越 C ABI unchecked span。
6. Consumer：貼上格式化、貼上純文字、`.md` 匯入、diagnostic 與保存重開 widget／Windows smoke。

## Boundaries

- Always：原始 bytes 先經大小與 UTF-8 驗證；parser output 經 Krepis validation 後才發布；匯入是一筆
  typed transaction。
- Ask first：擴充支援矩陣、提高大小上限、允許 HTML、增加網路抓圖、承諾 Markdown round-trip。
- Never：在 Flutter 保存 Markdown AST／HTML authority；執行 raw HTML／script；解析失敗後部分套用；
  為通過 fixture 而丟棄未知 source。

### Frozen areas

- Markdown source-mode、雙向無損 round-trip 與 export。
- Table／Todo native schema、image asset pipeline、remote fetch、MDX、Mermaid execution。
- Canva／Sheet、Ink、collaboration、AI／MCP proposal。

## Success Criteria

1. Provider table-driven tests 對支援矩陣的每種 syntax 產生預期 Block kind、attrs、inline mark range 與
   UTF-8 text；巢狀 list／blockquote 不得遺失順序。
2. Table、task list、image、raw HTML、footnote 與未知 extension fixture 的原始 UTF-8 在 fallback Blocks
   中逐 byte 可重建，且每項至少一個 diagnostic。
3. 一次貼上 100 個 Blocks 後，undo 一次精確回到原 revision，redo 一次恢復同一語意內容；中間沒有
   可觀察的半份 document。
4. 超過核准上限、畸形 UTF-8、stale revision 與 parser allocation failure 都回傳 typed failure，文件
   revision、selection、undo depth 與保存檔不變。
5. Notist widget test 對同一 clipboard payload 可分別選擇格式化與純文字，兩者產生不同但可預期的
   Krepis command，Flutter 不包含 Markdown parser dependency。
6. 匯入 `.md` 成功後重開，native Block／inline mark 語意一致；原始 `.md` 檔 hash 不變。
7. Krepis Debug／ASan／TSan provider gates 與 Notist Verify 全部 exit code 0。

## Resolved Questions

1. 第一版採單向匯入，不承諾無損 Markdown source round-trip。
2. Parser 位於 Krepis；Notist 只擁有 clipboard／file UX。
3. 不支援語法保留純文字與 diagnostic，不靜默丟資料。
4. 匯入 `.md` 建立新的 Flow，檔名 stem 作初始 title。
5. 單次 Markdown 上限為 8 MiB；超過即 fail closed。
