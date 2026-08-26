# paragraph-dogfood-integration 任務清單

狀態：Implementation Complete（2026-08-23；Windows 人工 IME／shortcut 驗收待完成）

## PDI-B Baseline

- [x] 三倉 HEAD／status 已記錄。
- [x] 計畫修改檔的存在狀態與 diff 已記錄。
- [x] Kallopis、prototype／Catalog 凍結區與 Krepis DOC-0004 白名單已確認。

## PDI-0 Behavior baseline

- [x] 固定 Windows／QWERTY／2026-08-23 查證條件。
- [x] 官方可驗證規則包含來源；未能官方驗證者標示未查證。
- [x] baseline 不冒充 Block command implementation。

## PDI-1 Tests RED

- [x] Project composition tests RED。
- [x] open lifecycle loading／failure／retry tests RED。
- [x] save projection互斥與 retry tests RED。

## PDI-2 Open contract

- [x] open request 使用 explicit path 與 blank initial text。
- [x] controller 不再讀隱藏 dogfood path或英文 seed。
- [x] corrupt existing file 維持 fail closed。

## PDI-3 Honest lifecycle

- [x] loading 與 load failure 使用 Kallopis view states。
- [x] retry 重送相同 request。
- [x] stale future 完成後 dispose，不建立第二 authority。
- [x] 不再渲染任意 fallback／假筆記。

## PDI-4 Save projection

- [x] localLoaded 與 saving／localSaved／failed 分離；保存狀態只由真實 save attempt 事件驅動。
- [x] save failure 保留 editor 與 dirty authority revision。
- [x] retry 對同一 authority／path 保存。

## PDI-5 Production composition

- [x] 只有 Project route 掛載 dogfood editor。
- [x] 非 Project routes 維持 honest unavailable。
- [x] shell 仍為單 Stage、無 tabs／split／secondary。

## PDI-6 Verification

- [x] 主畫面 Golden 固定 loading state 並完成視覺檢查。
- [x] Focused tests 通過。
- [x] `tool/verify.ps1` exit code 0。
- [ ] Windows native/manual 驗證：自動化及 save failure 已通過；人工 IME／undo／redo／merge 待驗。
- [x] Fresh-context review 無程式 blocker；僅保留需人類操作的 Windows 驗收門檻。
- [x] Spec／plan／todo 狀態與證據回寫完成。

## PDI-7 Flow lifecycle hardening

- [x] 空專案不顯示虛假的 save status，新增失敗可見且可重試。
- [x] load／create single-flight，load-create race 不遺失已建立 Flow。
- [x] concurrent create 不會配置或發布兩份同一路徑文件。
- [x] duplicate stable root ID fail closed，不發布歧義 Explorer item。
- [x] 文件切換／open failure／dispose 使舊 save retry 失效。

## PDI-8 Identity and ABI

- [x] 128-bit root ID 一律正規化為 32 位小寫 hex，high-bit fixture 通過。
- [x] Flow projection C ABI minor version 已更新並在 extension lookup 前協商。
- [x] struct size、ready state、capacity 與 version mismatch 負面測試通過。
