# Block interaction

狀態：Notist ABI 1.4 consumer implemented；stable delete／text geometry 仍 gated
（2026-08-25）

## Outcome

Notist 以單一產品 command registry 組合 Block handle、右鍵選單與 Slash Menu，讓相同操作在不同
入口具有一致名稱、分組、可用性與風險提示。Notist 只保存短暫的畫面互動狀態；selection、Block
順序、kind、transaction、undo 與 persistence 仍以 Krepis 為唯一權威。

## In scope

- 建立 Notist-owned Block command id、surface、group、可用性與 unavailable reason。
- Block handle 與右鍵選單改由同一 registry 投影。
- 建立可重用的 Slash Menu presenter，和右鍵選單讀取同一 registry。
- 為 handle 預留 gated drag callbacks；沒有 Krepis move capability 時不得開始拖曳。
- 已有真實 command（目前為建立副本）保持可操作；未有 provider command 的項目明確停用。
- 消費 ABI 1.4 stable selection、move、convert 與 revision-matched applicability。
- 單 Block 與連續多 Block drag 只送 stable ID range／target affinity，不送 transient position。

## Out of scope

- 在 Flutter 保存跨 Block selection、Block 順序或轉換後 kind。
- 用 `replace_flow_blocks` 模擬 stable move、reorder 或 convert。
- 在 Krepis 尚未公開 endpoint hit-test／selection geometry 前啟用跨 Block 文字拖選。
- 在沒有可提交 command 前，讓停用選項產生 no-op 或樂觀畫面假象。

## User-visible behavior

- Block handle 與右鍵點擊開啟相同的產品操作選單。
- 「建立副本」可用，並交由既有 Krepis revision-aware adapter 執行。
- 移動與 Block 類型轉換依同 revision applicability 啟用；刪除仍在 stable delete provider gate
  通過前停用。
- 在 Block 開頭或空白後輸入 `/` 時，Slash Menu 依「基本區塊」與「進階區塊」分組；項目名稱與
  可用性來自相同 registry。
- Handle drag 顯示 Kallopis preview／drop indicator，抬起後送 stable range move。
- Todo context command 以 same-ID convert 切換完成狀態。
- Slash convert 會移除觸發字元、以最新 revision 轉換並關閉選單。

## Architecture constraints

- command registry 屬於 Notist 產品狀態，不得下沉至 Kallopis。
- Kallopis 只負責 menu、command menu、handle 與 tokenized visuals。
- action callback 只可呼叫 Krepis authority 或 Notist composition intent，不得直接修改投影。
- unavailable reason 必須是 registry 資料的一部分，避免各入口自行編寫而分岔。

## Failure and edge cases

- Provider capability 缺失時，所有依賴該 capability 的入口必須同時停用。
- 未知 Block kind 不得被 registry 自行推導為其他 kind。
- action 執行被 authority 拒絕時，沿用 editor 的失敗復原，不改動舊 snapshot。
- 拖曳被取消時不得送出 move intent。

## Acceptance criteria

1. 同一 command id 在 context menu 與 Slash Menu 的 label、caption 與 enabled 狀態一致。
2. Stable move／convert 依 ABI applicability 啟用；delete 在 provider command 出現前提供 unavailable reason。
3. handle／右鍵的「建立副本」仍只呼叫一次 Krepis authority。
4. Slash Menu 以 Kallopis `KlpCommandMenu` 呈現 registry 分組，停用項目不可觸發 callback。
5. Shift 選取保存 anchor/focus 方向，畫面只由 stable endpoints 推導連續 Block 範圍。
6. 格式化、靜態分析與受影響測試通過；全域 Verify 若被既有失敗攔下須附可重現證據。

## Verification evidence

- `flutter test test/notist_block_command_registry_test.dart`
- `flutter test test/notist_flow_editor_lifecycle_test.dart`
- `.vscode` 的 `Verify` task 所指向入口

2026-08-25：Notist 已以真實 ABI 1.4 DLL 驗證 stable selection round-trip、same-ID convert 與 stable
range move；context／Slash 共用 registry，Todo toggle 與 drag feedback 已接線。Block delete 與跨 Block
文字拖選仍分別等待 delete command 與 endpoint hit-test／selection geometry，不得以 position replace 模擬。
