/// Notist 的**布局真相**。
///
/// 這份檔案是 `Notist.dc.html` 版面稿的逐項轉錄。每一個常數都對應稿件裡一個寫死的
/// 數字，並註明出處行號。它不是「建議值」，是驗收標準——`notist_layout_truth_test`
/// 會拿實際渲染出來的幾何與這裡逐項比對，**零容差**。
///
/// ## 為什麼是幾何而不是像素
///
/// HTML 與 Flutter 是兩套渲染引擎，字型光柵化與次像素處理不同，逐像素相同做不到，
/// 宣稱做得到只是空話。但**幾何相同做得到**：每一個盒子的寬、高、相對位移都必須
/// 等於稿件寫死的數字。「尺寸有差距」要擋的正是這個。
///
/// ## 為什麼不用 token 斷言
///
/// 既有的版面測試寫的是 `expect(sidebarRect.left - shellRect.left, compact)`
/// ——不管 `compact` 是多少都會通過。那種測試無法發現尺寸偏離稿件，只能發現
/// 「程式碼沒有照自己宣告的 token 走」。真相在稿件裡，所以斷言必須對著字面數字。
///
/// ## 未解析的兩個值
///
/// 稿件裡有兩處用了 DS 的 CSS 變數而非字面數字：`var(--space-2)` 與 `var(--space-4)`。
/// 對應的 token CSS 沒有隨稿件提供，因此**無法轉錄**。這兩處標為 [unresolvedSpace2]
/// 與 [unresolvedSpace4]，測試會明確跳過並在訊息中說明——猜一個數字寫進真相檔，
/// 等於讓驗收標準本身變成推測。
library;

/// 稿件的預覽視窗尺寸（`data-props` 的 `$preview`）。
const double previewWidth = 1382;
const double previewHeight = 864;

// ─────────────────────────────────────────────────────────────
// 外框
// ─────────────────────────────────────────────────────────────

/// 應用標題列高度。稿件第 15 行 `hint-size="100%,44px"`。
const double appHeaderHeight = 44;

/// 主體區左右與下方內距。稿件第 23 行 `padding:0 10px 10px`。
const double bodyPaddingHorizontal = 10;
const double bodyPaddingBottom = 10;

/// 主體區上方內距為 0——標題列與內容之間不留空隙。稿件第 23 行。
const double bodyPaddingTop = 0;

/// 側欄與 stage 之間的間距。稿件第 23 行 `gap:10px`。
const double paneGap = 10;

// ─────────────────────────────────────────────────────────────
// 側欄
// ─────────────────────────────────────────────────────────────

/// 側欄預設寬度。稿件第 253 行 `sidebarWidth:268`。
const double sidebarDefaultWidth = 268;

/// 側欄寬度上下限。稿件第 255 行 `Math.max(200,Math.min(460,...))`。
const double sidebarMinWidth = 200;
const double sidebarMaxWidth = 460;

/// 側欄內部各區塊的垂直間距。稿件第 31 行 `gap:6px`。
const double sidebarSectionGap = 6;

/// 身分列（資料夾圖示＋Flows＋頭像）的高度。稿件第 308 行 `height:36`。
const double sidebarBannerHeight = 36;

/// 身分列的水平內距與元素間距。稿件第 308 行 `padding:"0 10px"`、`gap:12`。
const double sidebarBannerPaddingHorizontal = 10;
const double sidebarBannerGap = 12;

/// 身分列與其下方導覽之間的間距。稿件第 308 行 `marginBottom:4`。
const double sidebarBannerMarginBottom = 4;

/// 身分列兩端的方形標記尺寸。稿件第 309、314 行 `width:24,height:24`。
const double sidebarBannerChipSize = 24;

/// 身分列資料夾圖示的字形尺寸。稿件第 310 行 `size:18`。
const double sidebarBannerIconSize = 18;

// ─────────────────────────────────────────────────────────────
// 導覽列
// ─────────────────────────────────────────────────────────────

/// 導覽項目的列高。稿件第 35、42 行 `height:36px`。
const double navItemHeight = 36;

/// 導覽項目的水平內距。稿件第 35、42 行 `padding:0 10px`。
const double navItemPaddingHorizontal = 10;

/// 導覽項目內圖示與文字的間距。稿件第 35、42 行 `gap:12px`。
const double navItemGap = 12;

/// 導覽項目之間的垂直間距。稿件第 32 行 `gap:2px`。
const double navItemSpacing = 2;

/// 導覽項目圖示格的尺寸。稿件第 36、43 行 `width:20px;height:20px`。

/// 導覽項目圖示**字形**的尺寸。稿件第 318 行 `PlnIcon,{size:18}`。
///
/// 格子（20px）與字形（18px）是稿件裡兩個不同的值：圖示放進一個 20px 見方的
/// grid 格，字形本身只有 18px。先前本檔只記錄格子尺寸，測試又拿它去量
/// `KlpIcon`——等於把兩者當成同一個值，字形因此比稿件大 2px 而沒有測試擋得住。
const double navItemIconGlyph = 18;

// ─────────────────────────────────────────────────────────────
// 側欄分區標題（釘選／筆記）
// ─────────────────────────────────────────────────────────────

/// 分區標題的列高。稿件第 51、58 行 `height:20px`。
const double sectionHeaderHeight = 20;

/// 分區標題的水平內距與元素間距。稿件第 51、58 行 `padding:0 12px`、`gap:6px`。
const double sectionHeaderPaddingHorizontal = 12;
const double sectionHeaderGap = 6;

/// 分區標題的展開箭頭尺寸。稿件第 52、59 行 `width:10px;height:10px`。
const double sectionHeaderCaretSize = 10;

/// 「筆記」分區與其上方樹之間的間距。稿件第 58 行 `margin-top:8px`。
const double sectionHeaderTopMargin = 8;

/// 樹狀清單項目之間的間距。稿件第 50 行 `gap:2px`。
const double treeItemSpacing = 2;

// ─────────────────────────────────────────────────────────────
// 側欄寬度拖曳把手
// ─────────────────────────────────────────────────────────────

/// 拖曳感應區的寬度。稿件第 69 行 `width:10px`。
const double resizerHitWidth = 10;

/// 拖曳感應區的負外距——它疊在間距上，不額外佔用版面。稿件第 69 行 `margin:0 -10px`。
const double resizerNegativeMargin = -10;

/// 拖曳把手本身的尺寸。稿件第 70 行 `width:2px;height:28px`。
const double resizerHandleWidth = 2;
const double resizerHandleHeight = 28;

// ─────────────────────────────────────────────────────────────
// 側欄收合／展開按鈕
// ─────────────────────────────────────────────────────────────

/// 收合與展開按鈕的尺寸。稿件第 18、28 行 `size="{{ 32 }}"`。
const double sidebarToggleSize = 32;

/// 收合狀態下，展開按鈕距視窗左緣的距離。稿件第 17 行 `left:86px`。
const double sidebarToggleCollapsedLeft = 86;

/// 展開狀態下，收合按鈕相對側欄右緣的位移。稿件第 27 行 `right:2px;top:-40px`。
const double sidebarToggleExpandedRight = 2;
const double sidebarToggleExpandedTop = -40;

// ─────────────────────────────────────────────────────────────
// Stage：文件區
// ─────────────────────────────────────────────────────────────

/// 文件捲動區的內距。稿件第 77 行 `padding:8px 0 40px`。
const double docScrollPaddingTop = 8;
const double docScrollPaddingBottom = 40;

/// 文件內容的最大寬度。稿件第 78 行 `max-width:780px`。
const double docMaxWidth = 780;

/// 區塊之間的間距。稿件第 78 行 `gap:2px`。
const double docBlockGap = 2;

/// 文件內容的左負位移。稿件第 78 行 `margin-left:calc(var(--space-4) - 60px)`。
///
/// 依賴 [unresolvedSpace4]，因此只記錄那個 `- 60px` 的部分。
const double docLeftOffsetFromSpace4 = -60;

// ─────────────────────────────────────────────────────────────
// Stage：Journals
// ─────────────────────────────────────────────────────────────

/// 兩欄之間的間距。稿件第 85 行 `gap:16px`。
const double journalsColumnGap = 16;

/// Journals 的上下內距。稿件第 85 行 `padding:4px var(--space-4) 16px`。
const double journalsPaddingTop = 4;
const double journalsPaddingBottom = 16;

/// 月曆格線間距。稿件第 91 行 `gap:4px`。
const double calendarGridGap = 4;

/// 星期列的高度。稿件第 93 行 `height:18px`。
const double calendarWeekdayHeight = 18;

/// 日期格的最小高度與內距。稿件第 97、105 行 `min-height:74px;padding:6px`。
const double calendarCellMinHeight = 74;
const double calendarCellPadding = 6;

/// 日期格內項目的間距。稿件第 97、105 行 `gap:3px`。
const double calendarCellGap = 3;

/// 待辦列的內距與間距。稿件第 119 行 `padding:6px 4px;gap:9px`。
const double todoRowPaddingVertical = 6;
const double todoRowPaddingHorizontal = 4;
const double todoRowGap = 9;

/// 待辦核取方塊的尺寸。稿件第 120 行 `hint-size="16px,16px"`。
const double todoCheckboxSize = 16;

/// 排程列的內距與間距。稿件第 132 行 `padding:7px 10px;gap:10px`。
const double scheduleRowPaddingVertical = 7;
const double scheduleRowPaddingHorizontal = 10;
const double scheduleRowGap = 10;

/// 排程列時間欄的固定寬度。稿件第 133 行 `width:42px`。
const double scheduleTimeWidth = 42;

// ─────────────────────────────────────────────────────────────
// Stage：資產庫
// ─────────────────────────────────────────────────────────────

/// 瀑布流的欄寬與欄距。稿件第 164 行 `columns:170px;column-gap:12px`。
const double assetsColumnWidth = 170;
const double assetsColumnGap = 12;

/// 資產卡片之間的垂直間距。稿件第 166 行 `margin:0 0 12px`。
const double assetsCardSpacing = 12;

/// 資產卡片下方文字區的內距。稿件第 170 行 `padding:9px 10px 11px`。
const double assetsMetaPaddingTop = 9;
const double assetsMetaPaddingHorizontal = 10;
const double assetsMetaPaddingBottom = 11;

// ─────────────────────────────────────────────────────────────
// 無法轉錄的值
// ─────────────────────────────────────────────────────────────

/// 稿件用了 `var(--space-2)`（第 32 行），對應的 token CSS 未隨稿件提供。
const String unresolvedSpace2 =
    '稿件第 32 行的 nav 水平內距是 var(--space-2)，token CSS 未提供，無法轉錄成數字。';

/// 稿件用了 `var(--space-4)`（第 78、85、157、163 行），同樣未提供。
const String unresolvedSpace4 =
    '稿件第 78/85/157/163 行的內距是 var(--space-4)，token CSS 未提供，無法轉錄成數字。';
