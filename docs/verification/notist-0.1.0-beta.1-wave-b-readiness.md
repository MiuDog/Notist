# Notist 0.1.0-beta.1 Wave B readiness

## Immutable provider inputs

| Provider | Repository | Commit |
| --- | --- | --- |
| Kallopis | `https://github.com/MiuDog/Kallopis.git` | `465c5fec9a2fb5691c7ca7388d61744a1e847def` |
| Krepis | `https://github.com/MiuDog/Krepis.git` | `1f35fab7409f04c75c11ba4077abd5cafa6ae497` |

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
license 與 third-party licenses。Krepis commit 目前沒有專案自身的 `LICENSE`；在授權裁決並加入
該 pinned provider 前，packaging 必須 fail closed，且不得產生最終 ZIP、manifest 或 SHA-256。
