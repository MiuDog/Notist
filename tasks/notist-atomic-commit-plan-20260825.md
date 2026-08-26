# Notist 原子 Commit 分組建議（2026-08-25）

## 目的

本文件只對 `codex/flow-runtime` 目前 140 項 dirty entries 提出可審查分組。
除 Wave A release-scoped 變更外，所有內容都在本任務開始前已存在；本任務不替其他實作者
確認來源，也不建立 commit。

## 不得進入 commit

- `dist/`：舊 alpha ZIP 與解壓縮成品；是 stale build output，不是 Beta source truth。
- `test/failures/`：Flutter golden 失敗診斷圖；只作本機排錯。
- `build/`、`.dart_tool/`：生成檔，應繼續由 ignore 政策排除。
- 任何無法對應核准 spec／ADR 的 binary、golden 或 platform 變更。

## 建議順序

### 1. `docs(governance): establish Notist ownership and approved contracts`

候選路徑：

- `AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`.agents/`、`.mcp.json`、`.vscode/`。
- `CAPABILITY-MAP.md`、`spec/decisions/`、`spec/features/`、`spec/references/`。
- 與功能核准直接對應的非發行 `tasks/` 文件。

前置：逐份確認 ADR 狀態與人類核准紀錄；不得將 Proposed 改成 Accepted。

### 2. `feat(platform): rename product shells and install Notist artwork`

候選路徑：

- `android/`、`ios/`、`linux/`、`macos/` 中的 package identity、runner metadata 與 app icons。
- `windows/runner/resources/app_icon.ico`、`design/app_icon/`。
- `windows/CMakeLists.txt`、`windows/runner/CMakeLists.txt`、`windows/runner/Runner.rc` 中的 Notist 名稱部分。

前置：平台 binary 變更必須對應同一 master asset；非 Windows runner 尚未驗收，
不得在 commit message 宣稱已支援。

### 3. `feat(windows): implement custom workbench window behavior`

候選路徑：

- `windows/runner/flutter_window.*`、`windows/runner/win32_window.*`、`windows/runner/main.cpp`。
- `test/windows_runner_contract_test.dart`。

前置：獨立審視 maximize、resize、Markdown file intent 與啟動參數，不與品牌圖檔合併。

### 4. `feat(catalog): add Notist-owned note components and visual catalog`

候選路徑：

- `lib/catalog/`、`lib/notist.dart`、`lib/src/note/`。
- `lib/src/stage/notist_canva_page.dart`、`notist_flow_page.dart`、`notist_sheet_page.dart`
  中只供 Catalog 的 prototype。
- `test/catalog_*`、`test/nts_*`、`test/note_component_ownership_test.dart`、
  `test/note_page_visual_golden_test.dart`與對應 golden。

前置：確認生產 runtime 沒有把 Canva／Sheet prototype 當成真實文件。

### 5. `feat(workspace): compose the single-stage workspace shell`

候選路徑：

- `lib/main.dart`、`lib/src/shell/`（不含 session persistence）。
- `lib/src/sidebar/`、`lib/src/stage/notist_stage.dart`、`notist_flow_stage_actions.dart`。
- workspace layout、routing、spacing、visual composition 與 main golden tests。

前置：`lib/src/sidebar/notist_sidebar.dart` 的 Wave A generic identity 應另以 partial hunk 納入第 9 組。

### 6. `feat(project): add local Flow lifecycle and Markdown intake`

候選路徑：

- `lib/src/project/`、`lib/src/markdown/`。
- project store/controller/lifecycle、Markdown intent/source/paste/import 測試與相關 Windows contract hunk。

前置：原生 provider 所需 fixture 必須是測試資料，不可放進 runtime assets。

### 7. `feat(editor): consume Krepis ABI 1.7 Block editing and Ink`

候選路徑：

- `lib/src/krepis/`。
- `test/krepis_*`、`test/notist_block_*`、`test/notist_flow_*`、`test/save_state_projection_test.dart`、
  `test/text_edit_diff_test.dart`與 `test/support/`。

前置：使用 Krepis 候選 SHA 重跑真實 DLL consumer，並確認沒有 Notist fallback authority。

### 8. `feat(workspace): persist session state and search Flow metadata`

候選路徑：

- `lib/src/shell/notist_session_state.dart`、`lib/src/search/`與對應 composition hunk。
- `test/notist_session_state_test.dart`、`test/notist_quick_search_page_test.dart`、
  `test/workspace_destination_test.dart`。

前置：文件只可宣稱 title/folder search，不可宣稱全文搜尋。

### 9. `chore(release): prepare Notist 0.1.0-beta.1 metadata`

本 Wave A 可確認路徑／partial hunks：

- `pubspec.yaml`：產品 description 與 `0.1.0-beta.1+1`；依賴變更不屬本組。
- `windows/runner/Runner.rc`：Beta fallback 版本；Notist rename 屬第 2 組。
- `lib/src/sidebar/notist_sidebar.dart`：`Notist 工作區 N` generic identity；route hunk 屬第 5 組。
- `tool/check_release_metadata.ps1` 與 `tool/verify.ps1` 的 metadata gate。

此組需 `git add -p` 或先將依賴分組建立前置 commits；不得整檔 stage 混入未確認變更。

### 10. `docs(release): document the 0.1.0-beta.1 candidate`

候選路徑：

- `README.md`、`CHANGELOG.md`、`SECURITY.md`。
- `docs/releases/0.1.0-beta.1.md`。
- `docs/verification/notist-0.1.0-beta.1-wave-a.md` 與對應 fresh-profile PNG。
- `tasks/github-private-beta-release-plan-20260825.md` 及本分組文件。

前置：保留 Wave A 未發布標記；等 Wave B 真實 ZIP/SHA-256 產生後再更新成已發布說明。

## 提交紀律

1. 每組先對應核准 spec／ADR，再使用指定路徑或 `git add -p`。
2. 每個 commit 後檢查 `git diff --cached --stat` 與 `git diff --cached`。
3. 出現不同責任、來源不明 binary 或尚未核准契約時，取消該檔 stage 並請人類裁決。
4. 在 Kallopis／Krepis 候選 SHA 進入 Wave B 前，不建立對外 tag 或 GitHub Release。
