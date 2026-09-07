# NTS-0009 Markdown profile 驗證紀錄

日期：2026-09-03

## 結果

NTS-0009 選項 A 已完成 provider、consumer、persistence、Windows Release 與實機啟動 gate。

| Gate | 證據 |
|---|---|
| Krepis provider | MSVC Release build 540/540，exit code 0 |
| Krepis regression | CTest 104/104，exit code 0 |
| Krepis immutable pin | `5a0bc4d1b47d336f2d2d4abb335d3d4b41d1b56e`；遠端 `codex/markdown-quick-input` 已驗證為相同 SHA |
| Notist native consumer | 真實 ABI 1.9 `krepis_c.dll` 測試通過，未 skip |
| Notist regression | Flutter test 154/154，exit code 0 |
| Static analysis | `lib` 與 `test`：No issues found，exit code 0 |
| Windows Release | `build/windows/x64/runner/Release/notist.exe`，build exit code 0；SHA-256 `c53f42e1b5fdfc4b43de2a3734a55ad42bc7ef15ad7f189d3fbb9178264d093a` |
| Krepis runtime | `build/windows/x64/runner/Release/krepis_c.dll`；SHA-256 `1607ee2c6f7ca0763906edbaf2e386f1b1274ad34b958f3704aacd736357987d` |
| 實機 smoke | PID 6648、`HasExited=False`、window title `notist`、1536×816 |
| 實機截圖 | [Notist Windows runtime](evidence/notist-markdown-semantic-blocks-2026-09-03.png)；SHA-256 `e8fa6a5bc547a1cd046f941f268f6db8c73bddf705ceb9e9e2a26b7f398078c6` |

## 語意邊界

- `<!-- comment -->` 是 CommonMark raw HTML comment；`-#` 不提供自訂語法。
- 貼上與匯入的 `> quote` 仍是 blockquote；只有空白 Paragraph 直接鍵入 `> ` 會建立 toggle。
- `$...$` 是 inline math，`$$...$$` 與 fenced `math` 是 display math；`$$$$` 維持普通文字。
- 至少三個反引號或 `~` 才是 code fence；`******` 維持 thematic break。

實機截圖使用空白、隔離前的真實使用者工作區，因此誠實呈現「尚無 Flow」，沒有以 hard-coded note 冒充資料。
功能語意、原子 transaction、undo、ABI 與 save/reopen 由上述 native provider 與 consumer gates 驗證。
