# Notion-like Block 視覺六態基準（2026-09-03）

狀態：Wave 0 complete；V1-A、V2-A、V3-A 已核准，未查證欄位維持 `U`

## 目的

本文件供 Notist、Krepis 與 Kallopis 實作者在不複製 AppFlowy 產品語意的前提下，對照 Block editor
六種可觀察狀態。讀完後應能判斷每一態的 authority、採用來源、可立即實作部分與必須先關閉的 gate。

## 固定參照

| 參照 | 固定版本／日期 | 可用證據 | 限制 |
|---|---|---|---|
| Notist | 2026-09-03 working tree | [Windows Release 實機截圖](../verification/evidence/notist-markdown-semantic-blocks-2026-09-03.png)、repository tests | 截圖是 empty workspace，不冒充六態實機證據 |
| Notion | Baseline v1，2026-08-23 | [官方文件行為基準](notion-block-behavior-baseline-2026-08-23.md) | 實機版本、右鍵項目排序與 drag indicator 仍未查證 |
| AppFlowy Editor | 6.2.0+notist-baseline.1 | [Windows patched baseline](appflowy-editor-6.2.0-p0-windows-baseline-2026-09-03.md)、[實機截圖](../verification/evidence/appflowy-editor-6.2.0-patched-baseline-2026-09-03.png) | 研究補丁只補 Flutter 相容；原生 UI 操作矩陣尚未完成 |
| Kallopis | Git ref `ee42c3854d12cd7b4100b7b61697c90c938ce570` | 公開 `KlpStateHighlight`、`KlpPressable`、`KlpCommandMenu`、`KlpEditorToolbar` | Notist 不得複製字面 style 值 |

## 六態採用矩陣

| 狀態 | Notist 現況 | Notion baseline | AppFlowy 參考價值 | 採用 | Authority／gate |
|---|---|---|---|---|---|
| `default` | Krepis display list 畫內容；`NtsBlockChrome` 的六點把手常駐 | Block handle 在 hover 左側出現 | 單欄 editor 與 overlay 組合可參考，精確密度為 `U` | `adapt`：乾淨畫布，不常駐工具 chrome | 內容/layout 為 Krepis；顯示時機為 Notist；視覺為 Kallopis |
| `hover` | `KlpPressable` 有通用 hover，但 Flow chrome 未以整塊 hover 控制把手 | hover 左側 handle 已由官方文件確認 | hover 動畫與命中回饋可參考，原生畫面為 `U` | `adapt`：依 V1-A 顯示新增入口與把手 | insert command 未存在時不得顯示可操作新增入口 |
| `text editing` | pointer placement、caret rect、IME 與單 Block selection 已由 Krepis 投影 | 內容點擊進入文字編輯；精確 caret style 未固定 | composition、selection 與 toolbar lifecycle 可參考 | `adapt`：保留 Krepis 輸入真相，只改善回饋 | F01 IME 實機矩陣；不得以 hover 遮住 text hit-test |
| `block selected` | text endpoints 被同時拿來推導 Block range；目前以逐 Block outline 顯示 | `Esc` 選取 Block、`Enter` 回文字編輯已由官方文件確認 | selection surface 與 action feedback 可參考 | `adapt`：依 V2-A 改為 Kallopis 面狀 highlight | 需要明確區分 text selection 與 Block selection mode，不能由 endpoint 猜測 |
| `menu open` | Slash Menu 與六點／context menu 已接同一 registry；format toolbar 缺失 | Slash 與 Block command 已確認；右鍵精確項目為 `U` | caret/selection overlay 定位、翻轉及鍵盤 roving 可參考 | `adapt`：依 V3-A 按 surface 分流，仍共用 registry | F14 未關閉前 format action 不可操作；右鍵排序維持 `U` |
| `dragging` | stable range move、drag preview 與 drop indicator 已接；edge auto-scroll 未驗證 | handle 可拖放已確認；indicator／取消條件為 `U` | drag feedback 與 auto-scroll 可參考 | `adapt`：保留 Krepis stable ID move，不複製 node model | F09 viewport auto-scroll、cancel、stale revision 實機 gate |

## 已核准視覺決策

| ID | 決定 | 對既有行為的影響 |
|---|---|---|
| V1-A | Block chrome 只在 hover、keyboard focus、selected 或 dragging 時顯示 | 取代常駐六點把手；觸控／鍵盤必須保留可達入口 |
| V2-A | 整 Block selection 使用 Kallopis 輕量面狀 highlight | 取代每個 Block 的獨立 outline；連續範圍不得偽裝成文字 selection |
| V3-A | 六點選單與文字右鍵按 surface 分流，共用同一 command registry | 文字右鍵不再無條件開 Block menu；精確排序待實機證據 |

## 實作出口

### 可立即進入 Wave 1

- 使用 Kallopis 公開 `KlpStateHighlight` 取代 Notist 自畫 selection border。
- 建立可測的 Block chrome visibility 狀態，預設不顯示、hover/focus/dragging 顯示。
- 保留目前 caret-anchored `KlpMenuLayout.resolvePosition` 與共用 command registry。

### 必須先關閉的 gate

- **Block selection mode：** 現有 `KrepisTextSelectionProjection` 只有 text endpoints，無法證明目前是文字
  selection 或整 Block selection。Notist 不得只看 anchor/focus block ID 猜測。
- **新增入口：** 尚未查得 revision-aware insert Block command；入口維持不存在，不做 disabled 假按鈕。
- **跨 Block 文字 highlight：** F05 geometry 尚缺，Wave 2 前不得在 Flutter 估算文字矩形。
- **浮動格式工具列：** F14 range mark command 尚缺；`KlpEditorToolbar` 只能在 command gate 完成後投影。
- **右鍵精確排序：** Notion 與 AppFlowy 原生實機皆未查證，第一輪只做 surface 分流，不猜項目。

## Wave 0 驗收核對

1. 六態均記錄 Notist 現況、Notion baseline、AppFlowy 參考價值、採用決策與 authority：通過。
2. V1-A、V2-A、V3-A 均可回鏈到使用者核准規格：通過。
3. 未由原生 UI 證明的密度、右鍵排序、drag indicator、IME 優先序均標 `U` 或未查證：通過。
4. 沒有把 AppFlowy 加入 production dependency，也沒有改 Krepis／Notist runtime：通過。
5. 下一 Wave 的立即項目與 provider gates 已分離：通過。
