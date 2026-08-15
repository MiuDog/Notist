# Jotist

**一個刻意平凡的筆記 app。**

`jot` ＝ 隨手快速記下。這個 app 的性格就是這個字：**求快、不講究、不特殊**。

## 這個專案為什麼存在

Jotist 是 [Krepis](https://github.com/MiuDog/Krepis) 基座庫的**第一個消費者**，它有三個作用：

1. **介面的逼迫函數。** 一個不需要規格工程、不需要治理的消費者，會逼 Krepis 的 API 停在
   「筆記」這個抽象層，而不是讓特定產品的概念漏進基座。
2. **驗證載體。** 一個每天真的會被使用的版本，才會暴露抽象設計中真正的錯誤。
3. **「筆記決策 vs 產品決策」的判準。** 判斷任何決策該不該進 Krepis 時，問一句：
   **Jotist 需不需要？**

## 刻意不做

**這份清單是這個專案的紀律，不是待辦。**

- 規格工程、conformance、治理迴圈
- repo binding、code anchor
- workflow 定義與匯出
- 任何「聰明」的組織功能

需要這些的產品是 Planist，不是 Jotist。**Jotist 變複雜就代表它失去了作用。**

## 架構

| 層 | 語言 | 理由 |
|---|---|---|
| 資料、版面、selection、undo、authority | **C++**（Krepis） | 錯誤會靜默，必須可人工審查 |
| 呈現、輸入事件、ink 快速路徑繪製 | **Flutter** | 錯誤可見，不需審查 |

Flutter 這一層應維持**薄**。任何在此處累積的權威性邏輯都是架構偏移的徵兆。

## 目標平台

Windows、Linux、macOS、Android、iOS。

## 建置

```
flutter run -d windows
```

## 狀態

骨架階段。**Krepis 的 spike 2（FFI 邊界延遲實測）通過前不進入實作**——該 spike
不通過則整個 C++ 核心架構不成立，此處會需要重新設計。
