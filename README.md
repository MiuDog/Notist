# Notist

**可同時承載區塊與手寫圖層的個人／團隊知識工作區。**

Notist 面向需要自由筆記的學生、開發者與一般使用者。它以單一文件工作區開始，逐步提供
專案搜尋、排程統整、資產管理、AI 統整與可核准的工具操作；長期可成為專案計畫的真實來源。

## 這個專案為什麼存在

Notist 是 [Krepis](https://github.com/MiuDog/Krepis) 筆記核心的**第一個產品消費者**，它有三個作用：

1. **自由筆記產品。** Flow 最終同時支援 Notion 式可操作 Block 與獨立 Ink 圖層。
2. **知識工作區。** 專案 Sidebar 固定提供快速搜尋、Journal、Notist AI 與資產庫。
3. **核心驗證載體。** 真實產品持續驗證 Krepis 的內容、selection、transaction、undo、layout、
   persistence 與 authority 契約。

## 第一版邊界

- 中央一次只呈現一份文件或一個固定功能頁。
- 不提供 tabs、split、Secondary Sidebar 或 Inspector。
- 未完成能力顯示明確 empty／unavailable state，不使用假資料冒充完成。
- AI 讀取與統整先行；任何寫入都必須形成 Proposal 並由使用者核准。

完整能力、依賴與延後項目見 [`CAPABILITY-MAP.md`](CAPABILITY-MAP.md)。

## 架構

| 層 | 語言 | 理由 |
|---|---|---|
| 筆記內容、selection、transaction、undo、layout、persistence、Ink、note authority | **C++**（Krepis） | 唯一資料與編輯真相 |
| token、theme、排版、無產品語意共用元件 | **Flutter package**（Kallopis） | 跨產品視覺與通用互動 |
| 產品組合、Workspace state、route、互動政策、功能頁、AI UX | **Flutter app**（Notist） | 產品語意與體驗投影 |

Notist 可以有完整產品體驗，但不得複製 Krepis 的資料／編輯真相，也不得把產品語意推進 Kallopis。

## 目標平台

Windows 桌面是第一驗收平台；Linux、macOS、Android、iOS runner 目前保留，
不屬於 `0.1.0-beta.1` 的支援範圍。

## Windows 開發前置需求

- Windows 11 x64（第一驗收環境）。
- Flutter `3.44.4` stable 與 Dart `3.12.2`。
- Visual Studio 2022 Build Tools，安裝「使用 C++ 的桌面開發」工作負載。
- CMake 與 Windows 10/11 SDK（由上述 Visual Studio 工作負載提供）。

先用 Flutter doctor 確認 Windows toolchain：

```powershell
C:\development\flutter\bin\flutter.bat doctor -v
```

## 從原始碼建置

Wave A 候選版仍使用相鄰的 `Kallopis` 與 `Krepis` 工作副本。這是本機驗證用接入，
不是可重現發行契約；Wave B 必須改為人類核准的固定 Git ref 後才能發布 Beta。

```powershell
C:\development\flutter\bin\flutter.bat pub get
C:\development\flutter\bin\flutter.bat run --debug -d windows
```

## 元件型錄

Notist 自己擁有帶筆記語意的 `Nts` 元件與 Catalog；Kallopis 只提供 token 與通用視覺 primitive。
Catalog 集中呈現 Flow、Canva、Sheet、Backgrounds 在不同互動狀態與主題下的畫面：

```powershell
C:\development\flutter\bin\flutter.bat run --debug -t lib/catalog/main.dart -d windows
```

使用 VS Code 時，可在「執行與偵錯」選擇 `Notist (Flutter Debug)` 或
`Notist Catalog (Flutter Debug)`；兩者都會以 Flutter Debug Mode 啟動。

執行專案完整檢查：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tool/verify.ps1
```

## Private Beta 已知限制

- 第一版只驗收 Windows x64，且成品尚未進行程式碼簽章；Windows 可能顯示 SmartScreen 警告。
- 工作區同時只顯示一份文件，不提供 tabs、split、Secondary Sidebar 或 Inspector。
- 快速搜尋只搜尋 Flow 標題與資料夾；尚無全文或 Block identity 搜尋。
- Journal、資產庫與 Notist AI 目前是明確的 empty/unavailable 頁面，不會產生假資料。
- Block 層級刪除與跨 Block 文字拖選尚缺 Krepis provider command/projection。
- Ink 可進行 pointer preview 與 commit，但未提供 eraser、lasso 與多工具快捷鍵。
- 多人協作與雲端同步不在本 Beta 範圍；本機資料格式在 Beta 期間可能變動，
  升級前應備份 `%LOCALAPPDATA%\Notist\Flows`。

安裝、checksum 驗證與未簽章警告見
[`docs/releases/0.1.0-beta.1.md`](docs/releases/0.1.0-beta.1.md)；安全問題回報方式見
[`SECURITY.md`](SECURITY.md)。

## 狀態

目前準備 `0.1.0-beta.1+1` Windows Private Prerelease。Wave A 只整理產品 metadata 與文件；
固定 provider 依賴、乾淨 CI、發行 ZIP 與實機發行驗收尚待 Wave B 完成。
