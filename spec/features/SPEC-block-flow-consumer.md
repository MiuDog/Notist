# Block Flow consumer

狀態：Implemented，workspace Verify pending（2026-08-24；本批精準 gates 通過，全域 gate 被同時新增的
Sidebar layout truth tests 與既有 golden 差異攔下）

## Outcome

Notist 以 Krepis C ABI 1.2 讀取 Flow Block 的 kind、attributes、inline marks、stable ID 與文字，並把
它們保留為唯讀畫面投影。所有修改仍透過 Krepis revision-aware command；Notist 不建立第二份內容、
selection、layout、persistence 或 undo authority。

## In scope

- 升級 Notist 的 Krepis ABI negotiation 至 1.2。
- 建立固定寬度 Block／inline mark FFI bindings 與 immutable Dart projection。
- 在 editor refresh 時依 `block_count` 讀回真實 Block 清單。
- 提供單一 revision-aware Block range replace adapter，成功後沿用既有保存流程。
- Flow 頁面可根據真實目前 Block 顯示 Block chrome；內容仍由 Krepis display list 繪製。

## Out of scope

- 跨 Block 文字 selection、Shift 多選與框選。
- 拖曳排序、保留 stable ID 的 move／convert 與完整 command registry。
- 由 Flutter 自行排版 Heading、清單、Todo、Quote、Code 或 Divider。
- Slash Menu、完整右鍵選單、Markdown UX 與正式 P4 persistence。

## Architecture constraints

- Krepis 是 Block record、revision、selection、transaction、undo、layout 與 persistence 的唯一權威。
- Dart models 只能由 C ABI query 建立；不得自行推導或修補未知 kind／mark。
- ABI struct size、enum 值、buffer sizing 與錯誤狀態必須 fail closed。
- UI 只能顯示 provider 已公開的能力；未公開操作不得以 no-op 選單冒充完成。

## Failure and edge cases

- ABI 低於 1.2、未知 Block kind／mark、錯誤 struct size 或 UTF-8 解碼失敗時，文件開啟失敗。
- stale revision 或任何無效 Block input 必須保持舊 snapshot，且不得啟動保存。
- 空 Flow、零長文字與沒有 marks 的 Block 必須可投影。

## Acceptance criteria

1. FFI layout test 精確驗證 Block input、Block info、mark input 與 mark info 的大小。
2. ABI identity test 要求 major 1、minor 2。
3. projection test 證明八種 Block kind、五種 mark kind、stable ID 與 attributes 不被 Dart 重新解釋。
4. controller consumer test 經真實 ABI 讀回多個 Blocks，順序、文字、info 與 marks 與 provider fixture 相同。
5. invalid kind、invalid mark、stale replace 皆 fail closed，舊 snapshot 與保存狀態不變。
6. Krepis 全部 CTest 與 Notist Verify exit code 0。

## Verification evidence

- Krepis：`cmake --preset msvc-x64`、Debug build、完整 CTest。
- Notist：`tool/verify.ps1`；若宿主 PATH 干擾該入口，須修復入口後再宣告本批完成。
