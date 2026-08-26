# NTS-0003：協作 Authority、交易、衝突與離線同步

## 狀態

Proposed（由 Planist ADR-0029、0030、0032、0035、0036、0041、0045 蒸餾，尚未核准）

## 背景

Notist 未來支援多人協作。若 Client、MCP 與同步服務能各自排序或直接寫 storage，同一份文件會出現多個
truth；若以 generic JSON patch 當 canonical mutation，stable node identity、permission、undo 與 conflict
語意也無法被審查。

## 選項

### A. 單一 Authority 排序 stable-ID typed transaction

所有 actor 經同一 writer；Host 排序、驗證、持久化並投影結果。離線使用有期限的 capability package。

### B. Client 最後寫入勝出或 generic JSON patch

淘汰。會把 array index、重放順序與整份覆寫誤當文件語意，且難以提供可稽核 conflict／revert。

### C. 第一版直接採全域 CRDT

延後。需另證明它能涵蓋 Flow、Canva、Sheet、typed transaction、permission 與 migration，不由「多人」自動推出。

## 決定

採用 A，保留以下 invariant：

1. command 包含 command ID、actor／device、resource、base version 與 registry 已知的 typed steps。
2. idempotency identity 至少包含 actor、device、command ID；同 key 不同 canonical payload 必須拒絕。
3. 多 step transaction 完整驗證後一次 commit，不暴露 partial state。
4. Host order 與 resource version 分離；Client 只能 optimistic projection，不能決定最終順序。
5. 不同 semantic unit 可 rebase；同 unit 真衝突建立可稽核 Conflict，未明確解決前不得繼續分叉。
6. Revert 新增 typed inverse transaction，不重寫歷史。
7. persistence 使用單一 writer，event、idempotency receipt、cursor、authority epoch／fence 在同一 durable
   transaction 更新；restart 必須 replay 收斂。
8. canonical command／event 使用版本化、bounded、exact-consumption representation；digest 表示內容 identity
   與 lineage，不是 signature 或 authorization。
9. offline capability 綁定 workspace、actor、device、scope、base cursor、authority epoch、revocation epoch 與
   expiry；Project 只能縮短或停用，不能延長系統上限。
10. credential locator 與私鑰容器資訊只留在受保護 Client identity boundary，不進 Flutter、log、Audit、MCP
    或 authority public DTO。跨 Client store 與 authority 的 rotation 使用 durable saga，uncertain 不得刪 key。

Planist 的 View 30 天／Edit 7 天只是來源決策，不在本 ADR 直接接受。Notist 必須以實際風險、使用情境與
測試重新裁決數值；在此之前 offline edit 維持未定。

## 後果

- 自動儲存狀態必須區分 local accepted、authority pending、synced、conflict 與 failure；不能只顯示「已儲存」。
- Collaboration 不是 UI Store 合併；所有 query、search、export、AI 與 MCP 都消費 permission-filtered projection。
- 自有 canonical frame 需要跨語言 golden vector、fuzz、版本 reader 與容量上限。
- 真衝突的可寫範圍與解決 UX 尚未裁決，不得由 Client 默默採最後寫入勝出。

## Migration 與回退

先以 default-off shadow authority 驗證 command、restart、duplicate、reorder、drop、collision、disk-full 與
conflict fixture。切換前保留舊 reader；切換後停止新 collaboration 不得刪除 event log、降低 revocation epoch
或遺失 unknown typed step bytes。舊 codec reader 必須維持到明確 migration 完成。

## 核准條件

- [ ] 使用者接受 Host-ordered typed transaction，並另行裁決 conflict 可寫範圍與 offline lease。
- [ ] crash consistency、single writer、idempotency、restart replay 與 canonical golden vectors有可重現證據。
- [ ] malformed、unknown、oversized、stale、duplicate、collision 與 permission bypass 全部 fail closed。
