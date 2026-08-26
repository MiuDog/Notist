# Notion Block 行為基準（2026-08-23）

## 狀態與用途

狀態：Baseline v1（官方文件查證；實機欄位尚未查證）

本文件固定 Notist 第一版研究參照，不會隨 Notion 後續更新自動改變。它是未來 Block UX 規格的輸入，
不是 Krepis command contract，也不代表下列 Block 功能已實作。

## 查證環境

| 欄位 | 值 |
|---|---|
| 擷取日期 | 2026-08-23 |
| 目標平台 | Windows 桌面／Web、英文 QWERTY 快捷鍵語意 |
| 主要來源 | Notion 官方 Help Center |
| 實機版本 | 未查證；本輪沒有可供驗收的已登入 Notion Desktop session |

## 已由官方文件確認

| 行為 | Notist baseline | 來源 | 狀態 |
|---|---|---|---|
| Block selection | `Esc` 選取目前 Block；已選取時 `Esc` 清除選取 | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| 鍵盤移動選取 | Block selected 時方向鍵切換；`Shift+Up/Down` 擴張選取 | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| 範圍選取 | `Shift+Click` 選取兩點間 Block | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Windows 單 Block toggle | `Alt+Shift+Click` 選取或取消整個 Block | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| 刪除 | Block selection 下 `Backspace` 或 `Delete` 刪除選取 Block | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| 複製 | `Ctrl+D` 複製選取 Block | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| 回到文字編輯 | Block selected 時 `Enter` 編輯其中文字 | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Block command menu | `Ctrl+/` 對一個或多個 Block 開啟變更／操作選單 | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Block reorder | `Ctrl+Shift+方向鍵` 移動選取 Block | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Todo toggle | `Ctrl+Enter` 修改目前 Block，包括勾選／取消 Todo | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Slash Menu | 輸入 `/` 顯示內容 Block menu；`Esc` 關閉 `/` menu | [Keyboard shortcuts](https://www.notion.com/help/keyboard-shortcuts) | 官方確認 |
| Block handle | hover 左側 handle；可拖放重排，menu 含 duplicate／move／delete 等 | [Writing and editing basics](https://www.notion.com/help/writing-and-editing-basics) | 官方確認 |
| Markdown conversion | 行首 `*`／`-`／`+`＋Space 為 bullet；`[]` 為 Todo；`#` 系列為 heading | [Customize and style](https://www.notion.com/help/customize-and-style-your-content) | 官方確認 |

## 未查證，不得成為實作規則

| 問題 | 狀態 | 後續驗證方式 |
|---|---|---|
| 空 Paragraph 按 Backspace 時跨 Block merge 的完整 kind matrix | 未查證 | 固定 Notion Desktop build 實機矩陣 |
| `Ctrl+A` 在文字、目前 Block、全頁之間的連續層級 | 官方文案不足 | Windows 實機逐次按鍵錄製 |
| 文字 selection 與 Block selection 間右鍵選單的精確項目與排序 | 未查證 | 兩種 selection 實機截圖／accessibility tree |
| drag handle 的 drop indicator、巢狀縮排與取消條件 | 未查證 | pointer 路徑矩陣與錄影 |
| IME composition 期間 Enter、Esc、Slash Menu 的優先順序 | 未查證 | Windows 繁中 IME 實機測試 |
| 多 Block selection 中混合不可轉換 kind 的 command availability | 未查證 | mixed-kind fixture 實機驗證 |

## Notist 採用規則

- 已確認項目只成為 UX baseline；仍須由 Krepis command contract 提供可被 authority 接受／拒絕的操作。
- 未查證項目一律不實作推測行為。
- 所有 UI、快捷鍵與右鍵入口最終必須送出同一 command registry。
- Block command contract 未完成前，本文件不得用來在 Notist 建立第二份 Block truth。

