# Security Policy

## 支援範圍

`0.1.0-beta.1` 是未簽章的 Windows Private Beta。只有當前候選版接受安全修正；
更早的 alpha 成品不再支援。

## 回報漏洞

請使用 GitHub repository 的「Security」→「Report a vulnerability」開啟私密回報。若候選倉庫尚未啟用
private vulnerability reporting，請透過倉庫擁有者已建立的私密聯絡管道回報；不要在 Issue、
Discussion 或其他公開頻道揭露。

回報應包含：

- 受影響的 Notist 版本與 Windows 版本。
- 最小重現步驟、預期與實際結果。
- 可能的影響，以及是否會造成本機資料遺失、未授權存取或程式碼執行。
- 如有需要，附上已移除個人資料的 log 或 proof of concept。

倉庫擁有者會先確認回報已收到，再透過同一私密管道說明分級、修正與揭露安排。
本 Beta 不承諾固定回應時間，但不會要求回報者公開實作細節。

## Beta 資料與簽章邊界

- Flow 與 session 資料保存在使用者的 Windows profile；Notist 本身不提供應用層加密。
- `0.1.0-beta.1` 不含雲端同步或多人協作服務。
- Windows 成品尚未簽章。只從核准的 Private Prerelease 下載，並使用與成品同時發布的
  `.sha256` 比對檔案雜湊。
