# Notist 自由筆記工作區體驗意圖

## 狀態

Confirmed

- 確認日期：2026-08-23
- 訪談信心：98%
- 確認方式：使用者在逐題訪談與完整 restatement 後明確回覆「是，確認」

本文件保存產品意圖，不是功能規格、架構核准或完成宣告。下游規格與 ADR 必須以本意圖為輸入，補齊
可測行為、資料契約、錯誤路徑、migration 與 rollback，再取得各自核准。

## Outcome

Notist 是桌面優先的自由筆記工作空間。文件由一個個可獨立操作的 Block 組成，同一內容可結合結構化
文字與獨立手寫圖層；產品後續可擴充成個人／團隊知識庫、工程規格真實來源及 AI／MCP 協作入口。

## User

主要服務學生、開發者，以及任何追求自由筆記的人。第一版不要求使用者理解資料模型、AI workflow 或
知識庫方法，建立空白專案後即可直接開始寫作。

## Why now

Krepis 正在建立 Block 與 Ink 的內容 substrate，Kallopis 正在建立通用呈現元件。現在先固定產品組合與
操作體驗，可以防止後續把產品 UX、視覺元件及內容 truth 分配到錯誤 owner，並減少反覆重做。

## Success

新使用者第一次使用 Notist 的 10 分鐘內可以：

1. 建立專案並直接取得一份空白文件。
2. 建立及編輯文字 Block 與待辦 Block。
3. 使用手繪板直接加入手寫標註。
4. 關閉並重新開啟後，回到可靠保存的內容與位置。

Journal、完整 NotebookLM 類能力、多人協作及正式工程規格功能未完成，不影響這個核心閉環成立。

## Workspace Composition

### Primary Sidebar

Primary Sidebar 分為兩區：

- 上半部使用導覽全寬按鈕，依序提供專案 Banner、快速搜尋、Journal、Notist AI、資產庫。
- 下半部是 FileExplorer，用來管理 Folder 與筆記文件。

使用者可選擇啟動時「保留上次狀態」或回到設定的「初始狀態」。建立全新空白專案時直接建立並開啟
空白文件，不先顯示 AI onboarding 或知識庫建立精靈。

### Main Area

- 中央一次只呈現一份文件或一個固定功能頁。
- 第一版不提供 Tab；未來可加入多文件 Tab。
- 永久不提供分割編輯畫面。
- 第一版不提供 Secondary Sidebar／Inspector，也不預留空白常駐區域；未來可依真實需求加入按需開啟的
  Inspector。
- 文件標題位於文件內容頂部並可直接編輯，FileExplorer 名稱同步更新。
- 上方應用列只呈現 Breadcrumb、協作狀態與少量頁面操作，不重複放置可編輯標題欄。
- 底部狀態區呈現儲存狀態；自動儲存失敗不得顯示為已保存。

## Block Editing Experience

Docs 是明確的 Block Editor，視覺閱讀仍保持連續文件感：Block 邊界平時低存在感，只在 hover、選取、
拖曳或操作時揭露。

- 點擊文字內容進入文字編輯。
- 點擊左側控制點選取整個 Block。
- `Shift` 可選取連續多個 Block。
- 文字編輯時按 `Esc` 切換成目前 Block 的整體選取。
- `/` 開啟 Block 類型與插入內容的 Slash Menu。
- 選取文字時顯示 inline formatting 浮動工具列。
- Block 控制點選單提供類型、複製、移動與刪除等 Block 操作。
- 右鍵選單依文字 selection 或 Block selection 顯示對應操作。
- 尚未實作或不適用的功能直接隱藏，不以 disabled 項目預告未來能力。
- 所有 UI 入口與快捷鍵最後送出同一組 command，不各自實作行為。

第一版以 Notion 桌面版的 Block 行為作研究基準，但「像 Notion」不是實作規格。規劃階段必須在固定日期、
固定平台實際採集 Enter、Backspace、selection、drag、menu 與 keyboard 行為，建立版本化行為矩陣；實作與
測試只以該矩陣為權威，不隨 Notion 後續更新自動改變。未查證行為不得靠印象補完。

## Ink Input

- 第一版以 Windows 桌面／筆電的鍵盤滑鼠操作為主，同時把手繪板視為一級輸入。
- 電腦接入手繪板後，觸控筆落下直接操作 Ink，不要求先切換文字／手寫大模式。
- 手繪板接入時自動隱藏模式切換鈕。
- 筆刷、橡皮擦與套索等工具支援快捷鍵快速切換。
- 手機和平板不反過來限制第一版桌面布局；行動適配屬後續工作。

## Persistence

- 編輯內容持續自動儲存；切換文件或關閉視窗不顯示「是否儲存」提示。
- 底部必須區分儲存中、已儲存與失敗；未來多人協作時再擴充 authority pending、synced 與 conflict。
- 使用者選擇「保留上次狀態」時，重新啟動需恢復先前的導覽、文件與合理可恢復位置。

## Notist AI

Notist AI 是 Primary Sidebar 的固定功能頁，開啟後取代中央文件區，採專案級 Chat Session 模式：

- 一個專案可保存多個可重新開啟的 Chat Session。
- Session 具有標題、建立時間、最後活動時間與明確引用來源，並可建立、重新命名及刪除。
- Session 不具有跨專案的隱性記憶；切換專案後只顯示該專案的 Sessions。
- 第一版提供對專案內容的搜尋、摘要、歸納、對話與基礎語言模型統整。
- Notist AI 透過產品共用的 MCP／Function／command surface 操作 Notist，不擁有第二套私有寫入 API。
- 讀取、搜尋與摘要可直接執行；建立、修改、移動、刪除或排程一律先建立完整 Proposal，使用者核准後
  才能套用。
- 第一版不提供靜默寫入的 trusted 模式。

NotebookLM 只作未來能力研究參考。第一版不追求其完整功能，也不提供知識庫建立精靈；若未來證明有
需求，可在按需 Inspector 中提供針對目前文件或 selection 的情境式 AI。

## Ownership Constraint

| Owner | Responsibility |
|---|---|
| Notist | 產品資訊架構、畫面組合、操作 policy、選單內容、Chat Session UX，以及輸入事件到 command 的接線 |
| Kallopis | 無產品語意的視覺 token、primitive、reusable component、通用 editor presentation 與 accessibility |
| Krepis | 內容、stable ID、schema／codec、selection、transaction、undo、layout、history 與 Ink truth |

Notist 擁有產品專屬複合 Widget 不算超出畫面組合職責；只有在 Notist 保存第二份權威編輯邏輯時才是架構
偏移。相關下游草案見 [NTS-0001](../../spec/decisions/NTS-0001-product-and-note-runtime-ownership.md)、
[NTS-0002](../../spec/decisions/NTS-0002-page-kinds-and-note-capabilities.md)及
[NTS-0005](../../spec/decisions/NTS-0005-ai-mcp-proposal-and-single-writer.md)，目前均維持 `Proposed`。

## Out of Scope

第一版明確不包含：

- 多文件 Tab。
- 分割編輯畫面；這是永久非目標。
- Secondary Sidebar／Inspector。
- AI 知識庫建立精靈。
- 完整 NotebookLM 功能對等。
- AI 靜默直接寫入。
- 行動優先布局。
- 多人協作的完整同步、權限與 conflict UX。
- 正式工程規格、repo binding 與完整 MCP 治理工具面。

Journal 未來可聚合本專案文件中的待辦、期限、指派、複習排程與提醒，但其資料模型、排程 authority、提醒
規則及遺忘學習曲線尚未經本次訪談裁決，不能由本文件推定。
