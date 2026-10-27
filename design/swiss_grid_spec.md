# Swiss Grid 规格 · OpenlibExtended 全站界面原型

> 依据 `design/ui_prototype.html`（21 屏）整理，所有数值都是 Flutter 可直接表达的逻辑像素（dp）。
> 打开原型按 **G**，或访问 `ui_prototype.html#grid`，可在任一屏上叠加 1:1 网格线。

---

## 0. 一句话

**360 dp 画板 · 16 dp 页边距 · 328 dp 版心 · 4 列 × 76 + 3 × 8 沟槽 · 4 dp 基线 · 8 dp 节奏。**

所有页面、所有组件都从这一条规则推导：宽度吸附列线，高度吸附 4 dp，字号的行高是 4 的倍数。

---

## 1. 网格

```
  0                16                                  344      360
  ├──── 16 ────────┼───────────────── 328 ──────────────┼────────┤
                   │                                    │
                   │◄─76─► 8 ◄─76─► 8 ◄─76─► 8 ◄─76─►   │
                   0      84     168     252     336    │
                   16     100     184     268            │
```

| 项 | 值 | 说明 |
|---|---|---|
| 画板宽 | 360 | 设备逻辑宽；状态栏 36 由系统绘制，不计入内容 |
| 页边距 | 16 | 左右各 16 |
| 版心 | 328 | `360 − 16 × 2` |
| 列数 | 4 | `(328 − 8 × 3) / 4 = 76` |
| 沟槽 | 8 | 列间距 |
| 列起点 x | 16 / 100 / 184 / 268 | 相对画板左边 |
| 基线 | 4 | 任何高度、间距的理论最小单位 |
| 节奏 | 8 | 常规间距、行距、卡片间距 |
| 强调线 | 32 | 主视觉块（封面、统计数字、大间距）的模数 |

**跨列宽**（所有卡片、按钮组只能取这四个宽度之一）：

| 跨列 | 宽度 | 用在哪 |
|---|---|---|
| 1 | 76 | 图标块、缩略图列、徽标 |
| 2 | 160 | 分类格、双列卡片、来源卡 |
| 3 | 244 | 大按钮组、统计卡 |
| 4 | 328 | 整行卡片、列表、搜索框、分段控件 |

**垂直节奏**（自上而下）：

| 段 | 高度 | 组成 |
|---|---|---|
| PageHeader（一级页） | 80 | `padding 16 / 16 / 12` + 小标签 16 + 4 + 标题 32 |
| AppBar（二级页） | 56 | `padding 12 / 16` + 图标按钮 40 |
| 区块间距 | 16 | `.section` 的 `margin-top` |
| 区块标题行 | 28 | 文字 20 + `margin-bottom 8` |
| 卡片间距 | 8 | 同组卡片垂直间距 |
| 列表行 | 96 / 64 | 结果行（缩略图 80 + 8×2）/ 设置行（min-height 64） |
| 底部导航 | 72 | `8 + 32 + 4 + 12 + 16` |
| 底部操作栏 | 84 | `12 + 48 + 24` |

---

## 2. 字阶

只有 9 级，每级行高都是 4 的倍数；字重只用 `400 / 500 / 600 / 700 / 800`。

| Token | Size | Line | Weight | 用途 |
|---|---|---|---|---|
| `display` | 34 | 40 | 800 | 原型展板大标题（App 内不用） |
| `title` | 26 | 32 | 800 | 一级页页面标题 |
| `headline` | 20 | 28 | 700 | 二级页标题、页面内大标题 |
| `subtitle` | 16 | 24 | 700 | 卡片主标题、弹层标题、详情书名 |
| `body` | 14 | 20 | 400 | 正文段落 |
| `bodyStrong` | 14 | 20 | 600 | 强调正文 |
| `label` | 13 | 20 | 700 | 列表主标题、按钮（主按钮用 13/20/800） |
| `caption` | 12 | 20 | 500 | 说明文字、表单值、副标题 |
| `micro` | 11 | 16 | 600 | 元信息、芯片、设置行副文案 |
| `badge` | 10 | 16 | 800 | 全大写小标签、导航标签、格式徽标 |

规则：

- 字距只在三处使用：小标签 `letter-spacing .15em`（全大写）；区块标签 `.06em`；大标题 `-0.6px`。其余一律 0。
- 数字统一 `font-variant-numeric: tabular-nums`，让进度、大小、计数在纵向对齐。
- 小于 10 的尺寸只剩一种例外：封面缩略图内的 8 px 假字（装饰，Flutter 用 8 sp 或直接省略）。

---

## 3. 间距 / 圆角 / 描边 / 阴影

**间距阶梯**：`4 / 8 / 12 / 16 / 24 / 32`（20 仅用于区块内的大间隔，如对话框按钮行上方）。

**圆角阶梯**（只允许这六档）：

| Token | 值 | 用在哪 |
|---|---|---|
| `r-xs` | 8 | 勾选框、格式徽标、小方块 |
| `r-sm` | 12 | 图标容器、缩略图、输入框内嵌块 |
| `r-field` | 16 | 分类格、封面、列表缩略图容器 |
| `r-card` | 20 | 卡片、任务卡 |
| `r-sheet` | 28 | 对话框、底部弹层 |
| `r-pill` | 999 | 胶囊按钮、芯片、分段控件、搜索框 |

**描边**：`1 px`，颜色 `outlineVariant`。卡片、输入框、分段控件外框共用。

**阴影**：只有两级，都极轻。

| Token | 值 | 用在哪 |
|---|---|---|
| `sh-1` | `0 1px 2px rgba(33,28,23,.05)` | 卡片、芯片、输入框 |
| `sh-3` | 更大扩散 | 浮动层（底部弹层、对话框、封面大图） |

> 阴影色从主题取（`colorScheme.shadow.withValues(alpha: .05)`），不要新增十六进制常量。

---

## 4. 组件规格

| 组件 | 尺寸 / 关键值 |
|---|---|
| **PageHeader** | `padding 16 16 12`；小标签 10/16 w800 全大写 `.15em`；标题 26/32 w800 `-0.6px`；两者间距 4 |
| **AppBar** | 高 56；`padding 12 16`；返回图标按钮 40×40 r12；标题 20/28 w700 |
| **卡片** | r20，`padding 16`，1px 描边，`sh-1`；同组间距 8；紧凑版 `padding 12 16`，列表版 `padding 8 16` |
| **卡片头** | `gap 12`，`margin-bottom 12`；标题 14/20 w700；副标题 11/16 |
| **区块标题** | `margin-bottom 8`；标题 13/20 w800；右侧计数 11/16 |
| **区块标签** | 11/16 w800，主色，`.06em`，`margin 20 0 8` |
| **搜索框** | 高 52，r-pill，`padding 0 16`，1px 描边，`sh-1`；提示字 12/20 |
| **芯片** | 高 32，r-pill，`padding 0 12`，字 11/16 w600，`gap 8`；徽标方块 20×20 r8 |
| **分段控件** | 外框 `padding 2`，选项高 40，总高 44，r-pill，字 12/20 w600 |
| **主按钮** | 高 48，r-pill，`padding 0 20`，字 13/20 w800 |
| **小按钮** | 高 40，`padding 0 16`，字 12/20 w800 |
| **图标按钮** | 40×40 r12；图标 20×20（小号 16） |
| **设置行** | `min-height 64`，`padding 12 16`，`gap 12`；图标容器 32×32 r12；主 13/20 w700；副 11/16；右侧值 12 w600 |
| **结果行** | `padding 8 0`，`gap 12`，行间 1px 分隔线；缩略图 56×80 r12；书名 13/20 w700；元信息 11；格式徽标 10/16 w800 `padding 0 8` r8 |
| **分类格** | 高 64，r16，`padding 8`，`gap 8`；图标 32 r12；名称 12/20 w700；计数 11/16 |
| **热门海报** | 宽 128（32 模数），封面 128×192 r16 `padding 12`；书名 11/16 w600，`margin-top 4`；横滑条 `padding 2 16 4`、`gap 12` |
| **详情头部** | `padding 8 16`，`gap 16`；封面 128×192 r16；书名 16/24 w800；作者 12/20 |
| **下载任务卡** | r20，`padding 16`；缩略图 64×96 r12；标题/元信息、状态、进度、来源/操作分块；进度条 4 高 r2 |
| **底部操作栏** | `padding 12 16 24`，顶部渐变到背景 |
| **底部导航** | 高 72；`padding 8 16 16`；指示胶囊 56×32；图标 20；标签 10/16 w700；`gap 4` |
| **底部弹层** | 顶部圆角 28；`padding 12 16 24`；把手 36×4 r2 `margin 4 auto 16`；标题 16/24 w800；选项 `padding 12 0` |
| **对话框** | r28，`padding 24`；图标块 48×48 r16 `margin-bottom 16`；标题 16/24 w800；正文 12/20；按钮行 `margin-top 20`，`gap 8`，等分 |

---

## 5. Flutter 复现

### 5.1 常量

`lib/ui/swiss_grid.dart`（新增一个常量文件，不引入依赖）：

```dart
abstract final class SwissGrid {
  static const double board = 360;     // 设计画板
  static const double margin = 16;     // 页边距
  static const double gutter = 8;      // 沟槽
  static const int columns = 4;
  static const double content = 328;   // board - margin * 2
  static const double column = 76;     // (content - gutter * 3) / columns
  static const double span2 = 160;
  static const double span3 = 244;
  static const double span4 = 328;

  static const double unit = 4;        // 基线
  static const double rhythm = 8;      // 节奏
  static const double emphasis = 32;   // 强调线

  static const double navbar = 72;
  static const double appbar = 56;
  static const double bottomBar = 84;
}
```

### 5.2 列宽在运行时算

设备宽不一定是 360，但列结构必须保留：

```dart
class GridMetrics {
  const GridMetrics(this.width); // 传 LayoutBuilder 的 maxWidth，即整屏宽
  final double width;

  double get column =>
      (width - SwissGrid.margin * 2 - SwissGrid.gutter * (SwissGrid.columns - 1)) /
      SwissGrid.columns;

  double span(int n) => column * n + SwissGrid.gutter * (n - 1);
}

// 用 LayoutBuilder 取实际宽度
LayoutBuilder(builder: (context, c) {
  final g = GridMetrics(c.maxWidth);
  return SizedBox(width: g.span(2), child: ...); // 2 列块
});
```

等价的网格布局（分类格、双列卡片）：

```dart
LayoutBuilder(builder: (context, c) {
  final g = GridMetrics(c.maxWidth);
  return GridView.count(
    crossAxisCount: 2,
    mainAxisSpacing: SwissGrid.gutter,
    crossAxisSpacing: SwissGrid.gutter,
    // 高度钉死 64，宽度随屏宽变化，所以比例要算出来
    childAspectRatio: g.span(2) / 64,
    padding: const EdgeInsets.symmetric(horizontal: SwissGrid.margin),
    children: genreTiles,
  );
})
```

### 5.3 文字样式

`height` 在 Flutter 里是行高**倍数**，所以要用 `line / size`：

```dart
TextStyle swissText({
  required double size,
  required double line,
  FontWeight weight = FontWeight.w400,
  double letterSpacing = 0,
}) =>
    TextStyle(
      fontSize: size,
      height: line / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

final title = swissText(size: 26, line: 32, weight: FontWeight.w800, letterSpacing: -0.6);
final body = swissText(size: 14, line: 20);
final micro = swissText(size: 11, line: 16, weight: FontWeight.w600);
```

在 `ThemeData` 里映射到 `textTheme`（`titleLarge` = 26/32 等），页面不要写裸 `TextStyle`。

### 5.4 网格叠加层（调试用）

原型的 G 键在 Flutter 里用一个 `CustomPainter` 复刻，`kDebugMode` 下才挂：

```dart
class SwissGridOverlay extends CustomPainter {
  const SwissGridOverlay({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final g = GridMetrics(size.width);
    final col = Paint()..color = (dark ? Colors.white : Colors.black).withValues(alpha: .06);
    final base = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: .05)
      ..strokeWidth = 1;

    for (var i = 0; i < SwissGrid.columns; i++) {
      final x = SwissGrid.margin + i * (g.column + SwissGrid.gutter);
      canvas.drawRect(Rect.fromLTWH(x, 0, g.column, size.height), col);
    }
    for (double y = 0; y < size.height; y += SwissGrid.unit) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), base);
    }
  }

  @override
  bool shouldRepaint(covariant SwissGridOverlay old) => old.dark != dark;
}
```

挂载：`MaterialApp.builder` 里包一层 `Stack`，最后放 `IgnorePointer(child: CustomPaint(painter: SwissGridOverlay(...)))`。

### 5.5 一级页骨架

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        PageHeader(eyebrow: l10n.discoverEyebrow, title: l10n.homeTitle, action: searchButton),
        Expanded(child: content),
      ],
    ),
  ),
  bottomNavigationBar: const NavigationBar(height: SwissGrid.navbar, ...),
)
```

`PageHeader` 内部固定 `padding: EdgeInsets.fromLTRB(16, 16, 16, 12)`，并 `Align(alignment: Alignment.centerLeft)`——原型的左右边缘必须重合，任何 `padding: 0 4px` 这类微缩进都要去掉。

### 5.6 逐屏映射

| 屏 | 结构 | Flutter 承载 |
|---|---|---|
| 01 发现 | PageHeader + PillTabs + 海报横滑 + 2 列卡片 | `TabBarView` + `SizedBox(height:192)` 横滑 `ListView` + `GridView.count(2)` |
| 02 分类 | PageHeader + 搜索框 + 分段 + 4×2 分类格 + 推荐卡 | `GridView.count(2)`，高度钉 64，比例由 `GridMetrics` 算 |
| 03 / 18 / 19 搜索 | 固定页头 + 搜索框 + PillTabs + 列表/表单 | `Column` + `TabBarView`（两个独立 `ListView`） |
| 04 / 05 结果 | AppBar + 结果头 + 来源芯片 + 筛选 + `ListView` | `CustomScrollView` + `SliverList` |
| 06 详情 | AppBar + hero + 信息卡 + 简介 + 底部操作栏 | `CustomScrollView` + `bottomNavigationBar: SafeArea(child: 按钮行)` |
| 07 / 08 下载中心 | PageHeader + PillTabs + 总览卡 + 统计 3 列 + 任务卡 | `Column` + `TabBarView`（三个独立 `ListView`）+ `Row(children: 3 × Expanded)` |
| 09 无结果 | AppBar + 空态 + 来源状态卡 | `Center` + 卡片 |
| 10–14 设置 | PageHeader + PillTabs + 分组卡（`setrow` 列表） | `SegmentedButton`（或自绘胶囊）+ `Card` 内 `Column(children: setRows)` |
| 15 镜像 | AppBar + 分组卡 + 单选 | `RadioListTile` 定制到 64 高 |
| 16 底部弹层 | `showModalBottomSheet` | `shape: RoundedRectangleBorder(borderRadius: 28 顶角)` |
| 17 对话框 | `AlertDialog` | `shape: 28 圆角`，`titlePadding/contentPadding: 24` |

---

## 6. 已知豁免

这些图形**不**进入网格体系，属于有意保留：

1. **1 px 描边**：卡片、分段控件外框会让内部内容偏移 1 px（`16 → 17`）。Flutter 的 `BorderSide` 同样内缩，属于平台一致的渲染行为，不要为此加补偿。
2. **内容驱动的宽度**：芯片、按钮、格式徽标、底部弹层选项的宽度由文字决定，只保证高度吸附基线。
3. **横向滚动区域**：封面轮播的 128 宽是 32 模数（强调线）而非列宽；来源芯片行同理，因为滚动位置连续，无法吸附列线。
4. **封面色块上的缩略文字**：8 px 仅作色块标签，不参与字阶。
5. **状态栏**：36 高、左右 24 内边距，由系统或 `SafeArea` 处理，不进入版心。
6. **子元素圆角**：电池、进度条、滑杆、弹层手柄按自身长宽取 `1–4`，不是 UI 圆角；原型外层 40 px 是展示用的设备边框，App 内不存在。
7. **卡片内的等分槽位**：下载中心的三列统计（进行中 / 已完成 / 失败）必须在视觉上等价，所以按 `(卡片内宽 − 2 × gap) / 3` 等分，只保证高度 64 与 gap 8 吸附基线。

> 收敛结果：字号从 23 种离散值收到 12 种（其中 27 / 34 只出现在原型的展示层，8 是封面假字），圆角从 19 种收到 9 种（六档 + 上面两类豁免）。脚本见 `design/_work/metrics.py`。

---

## 7. 验收清单

- [ ] 任意页面左右内容边缘距屏幕边 **16**，且左右对称（原型的 8 px 边框是展示用，App 内没有）。
- [ ] 所有卡片、按钮组宽度 ∈ `{76, 160, 244, 328}`。
- [ ] 所有固定高度、内外边距是 **4 的倍数**；常规间距是 8 的倍数。
- [ ] 所有文字样式来自上表 9 级，`height = line / size`。
- [ ] 颜色只来自 `Theme.of(context).colorScheme`（主题源 `lib/ui/themes.dart`）。
- [ ] 圆角只用 `8 / 12 / 16 / 20 / 28 / pill` 六档（子元素 1–4 与机身 40 除外）。
- [ ] 底部导航高 72，图标 20，标签 10/16。
- [ ] 打开原型按 G，元素边缘与网格线重合。

---

## 8. 证据

| 文件 | 内容 |
|---|---|
| `design/ui_prototype.html` | 20 屏原型，按 G 叠加网格 |
| `design/_shots/before_full.png` | 改造前首屏 |
| `design/_shots/after_full.png` | 改造后首屏 |
| `design/_shots/after_grid.png` | 改造后首屏 + 1:1 网格 |
| `design/_shots/grid_01_05.png` | 发现 / 分类 / 搜索三屏 + 网格 |
| `design/_shots/grid_07_09.png` | 下载中心 + 来源诊断 + 网格 |
| `design/_shots/grid_10_14.png` | 设置五屏 + 网格 |
| `design/_work/audit.py` | 几何审计脚本（149 个有形块仍离网格，多为内容驱动宽度） |
