# Notist 0.1.0-beta.1 Wave B readiness

## Immutable provider inputs

| Provider | Repository | Commit |
| --- | --- | --- |
| Kallopis | `https://github.com/MiuDog/Kallopis.git` | `ee42c3854d12cd7b4100b7b61697c90c938ce570` |
| Krepis | `https://github.com/MiuDog/Krepis.git` | `546891bc2663105f87cdcf94da6513a6c051d1cf` |

Notist 的 committed dependency metadata 只包含上述正式 GitHub URL 與 immutable commit。
本機離線驗證可以使用 process-local Git `insteadOf` 指向只含相同 Git object 的 mirror；不得把該
mirror 路徑、`dependency_overrides` 或 sibling checkout 寫入版本控制。

## CI readiness

Windows CI 從 fresh checkout 執行 metadata、provider pin、locked dependency resolution、format、
analyze、Krepis ABI/Debug build、Flutter tests 與 Windows Release build。Kallopis 與 Krepis 的上述
commit 尚未能從 GitHub 取得前，線上 CI 必然在 dependency fetch 階段失敗；本機 mirror 驗證不能
被記錄成遠端可重現的 CI 成功。

## Packaging hold

Packaging gate 必須包含 Notist README、release notes、Kallopis license/notices，以及 Krepis 自身
license 與 third-party licenses。Krepis `546891b` 已加入以 MiuDog 為權利人的專有私人 Beta 評估
授權及 fail-closed license gate；Notist 封裝仍必須逐項驗證並收入這些本文，缺任一項不得產生最終
ZIP、manifest 或 SHA-256。Kallopis 的 audited Lucide 授權來自
`assets/icons/ui_oval/LUCIDE_LICENSE.txt`，封裝時必須一併收入。

## 主畫面 golden 審查

Kallopis `ee42c38` 修正 `KlpStageHeader` 的雙 flex／`Spacer` 競合，將 action 穩定放到
title row trailing edge，避免長標題只能使用半寬。Notist 主畫面 golden 經人工審查後只更新
這一張：12,014 個差異像素中，10,714 個是核准的 action 水平移位，約 1,300 個是
已審核的 Lucide／icon raster 差異。審查證據：

- `evidence/notist-main-visual-before-ee42c38.png`
- `evidence/notist-main-visual-after-ee42c38.png`
- `evidence/notist-main-visual-diff-ee42c38.png`
