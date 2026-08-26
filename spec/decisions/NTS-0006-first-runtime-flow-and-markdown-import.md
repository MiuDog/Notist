# NTS-0006：第一個正式 Flow runtime 與 Markdown 匯入邊界

## 狀態

Accepted（2026-08-23；使用者明確同意先接正式 Flow 文件，再做單向 Markdown 匯入）

## 背景

Krepis 的 Paragraph-only Flow Editor 已通過機器閘門，Notist 也已有 Windows FFI、TextInput 與
display list adapter，但 production Stage 仍只呈現 empty state。若同時把 Flow、Canva、Sheet 與完整
Markdown authoring 一次接入，會把尚未核准的 Page kind、Block schema 與 persistence 綁成一個不可驗收
的大批次。

Markdown 也不能只在 Flutter 建立 AST 或 HTML preview。那會讓 Notist 保存第二份內容 truth，繞過
Krepis 的 stable ID、transaction、selection、undo、layout 與 persistence。

## 決定

### D1：第一個正式 runtime 只建立 `flow`

- `page-kind-decision` 以本決策關閉；第一個可建立、開啟與編輯的 Page kind 固定為 `flow`。
- `flow` 的第一個垂直切片使用 Krepis Flow layout。Notist 只擁有專案／文件 lifecycle、route、輸入
  policy 與狀態呈現。
- Canva／Sheet 保留 Catalog prototype；在 NTS-0002 另行核准且各自 schema gate 關閉前，不進入
  production 建立入口或 canonical persistence。
- NTS-0002 仍維持 Proposed；本決策不代替其三種 Page kind closed enum 裁決。

### D2：Markdown 第一版是單向結構化匯入

- Notist 接收剪貼簿文字或 `.md` 檔案，將原始 UTF-8 與使用者 intent 交給 Krepis。
- Krepis 解析 Markdown，產生 native Block／inline mark fragment，並以單一原子 transaction 插入或建立
  文件；stable ID、selection、undo 與 persistence 都由 Krepis 決定。
- 第一版不把原始 Markdown 當 authority，不承諾無損 round-trip，也不把 HTML 當中介格式。
- 不支援的語法必須保留為可見純文字並附 structured diagnostic；不得靜默丟棄內容。
- 原始 HTML 不執行、不建立 WebView，也不直接送往 Flutter HTML renderer。

### D3：先完成正式 Flow，再開始 Markdown runtime

順序固定為：`project-document-lifecycle` → `paragraph-editing` → `content-persistence` →
`block-command-contract`／`block-persistence-contract` → `markdown-import-render`。不得用 Flutter-only
Markdown preview 跳過 Block gate。

## 後果

- Notist 能先以已通過機器閘門的 Flow Editor 開始真實 dogfood，Markdown 不阻擋第一個正式文件。
- Markdown parser 與 AST-to-fragment mapping 屬 Krepis；clipboard／file picker、進度、錯誤與 fallback UX
  屬 Notist；視覺 token 與通用元件仍屬 Kallopis。
- `.md` 匯入後的文件以 Krepis native schema 保存。未來若要 source-mode 或無損 `.md` round-trip，必須
  另立決策，不能把第一版匯入快取升格為 authority。

## Migration 與回退

正式 Flow 接線失敗時，production Stage 回到既有 empty state，保留 Krepis dogfood 檔與 Catalog
prototype。Markdown 匯入失敗時，不發布半份 transaction；來源剪貼簿或 `.md` 檔不被修改。若 parser
或 schema gate 未通過，只停用「貼上為 Markdown／匯入」入口，不回退已可用的純文字 Flow。

## 核准證據

- [x] 使用者同意先完成正式 Flow 文件接線。
- [x] 使用者同意 Markdown 第一版採匯入後自動渲染，不承諾原始 `.md` 無損 round-trip。
- [x] Canva／Sheet 未因本次同意而被推定核准。
