# Swiss Grid UI 改造实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把现有 Flutter 界面从“近似原型”收敛到 `design/swiss_grid_spec.md` 定义的 4 列 / 4dp 基线体系：字阶只留 9 级、圆角只留 6 档、所有固定尺寸吸附 4dp。

**Architecture:** 新增 `lib/ui/swiss_grid.dart` 承载网格常量、文本 token 与 `GridMetrics`；`themes.dart` 把 M3 textTheme 角色映射到 9 级 token 并统一组件主题；各页面/共享组件按 token 替换裸 `TextStyle` 与硬编码尺寸。不改业务逻辑、不动网络/下载/数据库。

**Tech Stack:** Flutter 3.47.2 / Material 3 / Riverpod（仅测试注入用）。

**Spec:** `design/swiss_grid_spec.md`（19 屏原型 `design/ui_prototype.html`，按 G 叠加网格）

## Global Constraints

- 不新增依赖；不引入状态管理/样式库；沿用现有 `Theme.of(context)`。
- 用户可见文案必须走 `AppLocalizations`；本计划不新增文案（若新增，五份 ARB + `flutter gen-l10n`）。
- 颜色只来自 `colorScheme`；禁止新增十六进制常量。
- 宽度只能取 76 / 160 / 244 / 328（或内容驱动宽度，见 spec §6 豁免）。
- 固定高度、内外边距是 4 的倍数；常规间距是 8 的倍数。
- 字号只来自 9 级 token；`height = line / size`。
- 圆角只允许 8 / 12 / 16 / 20 / 28 / 999（1–4 的子元素除外）。
- 平台差异分支保留（Android/iOS/Windows/Linux）；不做 Web。
- **提交策略**：用户已明确授权本轮逐任务提交；每个实现者只暂存并提交本任务文件，不推送、不改写历史。
- 每任务完成必须跑：`dart analyze lib/ test/` 与 `flutter test`（可先跑该任务的测试文件）。

---

## 当前偏差清单（改造对象）

| 区域 | 现状 | 规格目标 | 位置 |
|---|---|---|---|
| 字号 | 141 处硬编码，23 种离散值（7.5–32） | 9 级 token | `lib/ui/**`、`lib/main.dart` |
| textTheme | display 32、headlineMedium 22、headlineSmall 18、titleLarge 22、titleMedium 16/1.4、labelLarge 14、labelMedium 12、labelSmall 11/1.2 w500 | 见 §2 字阶（26/20/16/14/13/12/11/10） | `lib/ui/themes.dart:98-190` |
| PageHeader | padding 16,14,16,12；eyebrow 11 w800 ls0.9；标题 26/1.12 w800；间距 3 | padding 16,16,16,12；eyebrow 10/16 w800 ls .15em；标题 26/32 w800；间距 4 | `lib/ui/components/page_header.dart:14-55` |
| 底部导航 | 指示胶囊 56×29 r15；图标 21；间距 3；标签 10/1.2 | 胶囊 56×32；图标 20；间距 4；标签 10/16 w700；总高 72 | `lib/main.dart:591-655` |
| 搜索框 | 高 58 | 高 48 r-pill | `lib/ui/search_page.dart:786-819`、组件内 `_SearchField` |
| 分段控件 | 高 46，padding 4，r23 | 高 44（选项 40），padding 2，字 12/20 w600 | `lib/ui/search_page.dart:950-970` |
| 芯片 | 高 46 | 高 32，字 11/16 w600 | `lib/ui/search_page.dart`（`_SelectableFilterChip` 等） |
| 结果行 | 缩略图 52×74 r11；标题 13/1.35；元信息 11；行高不固定 | 行 96（padding 8 0），缩略图 56×80 r12，书名 13/20 w700，元信息 11/16 | `lib/ui/components/search_result_card.dart:77-150` |
| 来源胶囊 | 高 34 | 高 32（高度吸附基线） | `lib/ui/components/source_journey_card.dart` |
| 详情封面 | 宽 110 | 112×168 r16，书名 16/24 w800 | `lib/ui/components/book_info_widget.dart:131-180` |
| 下载任务卡 | 缩略图高度 50/64 混用 | 缩略图 40×60 r12；进度条 4 高 r2 | `lib/ui/download_center_page.dart:573-660` |
| 设置行 | 无统一 min-height | min-height 64，padding 12 16，gap 12 | `lib/ui/settings_page.dart` |
| 热门海报 | 宽 126，r14 | 宽 128，封面 128×192 r16 | `lib/ui/trending_page.dart:104-123` |
| 分类格 | 高度不固定 | 高 64 r16，图标 32 r12 | `lib/ui/categories_page.dart`、`lib/ui/home_page.dart` |
| 圆角 | 14/19/23/11/13/6 等混用 | 8/12/16/20/28/999 | 多个组件 |
| 底部操作栏 | 无统一 84 高 | padding 12 16 24 | `lib/ui/components/detail_bottom_bar.dart` |

> 具体逐处替换在任务 3–9 中按文件列出；以 spec §4 的组件表为准。

---

## Task 1: Swiss Grid 常量与文本 token

**Files:**
- Create: `lib/ui/swiss_grid.dart`
- Test: `test/swiss_grid_test.dart`

**Interfaces:**
- Produces: `SwissGrid.{board,margin,gutter,columns,content,column,span2,span3,span4,unit,rhythm,emphasis,navbar,appbar,bottomBar}`
- Produces: `GridMetrics(width).{column,span(int)}`
- Produces: `SwissText.{title,headline,subtitle,body,bodyStrong,label,caption,micro,badge}` (static `TextStyle`)
- Produces: `swissText({size, line, weight, letterSpacing})`

- [ ] **Step 1: 写失败测试**

```dart
// test/swiss_grid_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/ui/swiss_grid.dart';

void main() {
  test('grid spans follow the 4-column board', () {
    const g = GridMetrics(360);
    expect(g.column, 76);
    expect(g.span(2), 160);
    expect(g.span(3), 244);
    expect(g.span(4), 328);
  });

  test('grid stays proportional on wider screens', () {
    const g = GridMetrics(840);
    expect(g.span(4), closeTo(808, 0.01)); // 840 - 16*2
    expect(g.span(2), closeTo(400, 0.01)); // (808 - 3*8)/4*2 + 8
  });

  test('text tokens keep line height as a multiple of the size', () {
    expect(SwissText.title.fontSize, 26);
    expect(SwissText.title.height, closeTo(32 / 26, 0.0001));
    expect(SwissText.title.fontWeight, FontWeight.w800);
    expect(SwissText.body.fontSize, 14);
    expect(SwissText.body.height, closeTo(20 / 14, 0.0001));
    expect(SwissText.badge.fontSize, 10);
    expect(SwissText.badge.height, closeTo(16 / 10, 0.0001));
    expect(SwissText.title.letterSpacing, -0.6);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/swiss_grid_test.dart`
Expected: FAIL（`swiss_grid.dart` 不存在）

- [ ] **Step 3: 实现常量文件**

```dart
// lib/ui/swiss_grid.dart
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

abstract final class SwissGrid {
  static const double board = 360;
  static const double margin = 16;
  static const double gutter = 8;
  static const int columns = 4;
  static const double content = board - margin * 2;
  static const double column = 76;
  static const double span2 = 160;
  static const double span3 = 244;
  static const double span4 = 328;

  static const double unit = 4;
  static const double rhythm = 8;
  static const double emphasis = 32;

  static const double navbar = 72;
  static const double appbar = 56;
  static const double bottomBar = 84;
}

class GridMetrics {
  const GridMetrics(this.width);

  final double width;

  double get column =>
      (width - SwissGrid.margin * 2 - SwissGrid.gutter * (SwissGrid.columns - 1)) /
      SwissGrid.columns;

  double span(int n) => column * n + SwissGrid.gutter * (n - 1);
}

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

abstract final class SwissText {
  static final title = swissText(size: 26, line: 32, weight: FontWeight.w800, letterSpacing: -0.6);
  static final headline = swissText(size: 20, line: 28, weight: FontWeight.w700);
  static final subtitle = swissText(size: 16, line: 24, weight: FontWeight.w700);
  static final body = swissText(size: 14, line: 20);
  static final bodyStrong = swissText(size: 14, line: 20, weight: FontWeight.w600);
  static final label = swissText(size: 13, line: 20, weight: FontWeight.w700);
  static final caption = swissText(size: 12, line: 20, weight: FontWeight.w500);
  static final micro = swissText(size: 11, line: 16, weight: FontWeight.w600);
  static final badge = swissText(size: 10, line: 16, weight: FontWeight.w800);
}
```

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/swiss_grid_test.dart`
Expected: PASS（3 个用例）

- [ ] **Step 5: 静态检查**

Run: `dart analyze lib/ test/`
Expected: No issues found

---

## Task 2: Theme 字阶与组件主题

**Files:**
- Modify: `lib/ui/themes.dart:98-190`（textTheme）
- Modify: `lib/ui/themes.dart`（appBarTheme / cardTheme / inputDecorationTheme / chipTheme / filledButtonTheme / dialogTheme / bottomSheetTheme / navigationBarTheme）
- Test: `test/theme_swiss_test.dart`

**Interfaces:**
- Consumes: `SwissText.*`, `SwissGrid.*`（Task 1）
- Produces: textTheme 角色映射，后续任务直接用角色

- [ ] **Step 1: 写失败测试**

```dart
// test/theme_swiss_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  test('text theme maps the nine Swiss tokens', () {
    final t = lightTheme.textTheme;
    expect(t.headlineMedium!.fontSize, 26);
    expect(t.headlineMedium!.height, closeTo(32 / 26, 0.0001));
    expect(t.headlineMedium!.fontWeight, FontWeight.w800);
    expect(t.headlineSmall!.fontSize, 20);
    expect(t.headlineSmall!.height, closeTo(28 / 20, 0.0001));
    expect(t.titleMedium!.fontSize, 16);
    expect(t.titleMedium!.height, closeTo(24 / 16, 0.0001));
    expect(t.bodyMedium!.fontSize, 14);
    expect(t.bodyMedium!.height, closeTo(20 / 14, 0.0001));
    expect(t.labelLarge!.fontSize, 13);
    expect(t.labelLarge!.height, closeTo(20 / 13, 0.0001));
    expect(t.bodySmall!.fontSize, 12);
    expect(t.bodySmall!.height, closeTo(20 / 12, 0.0001));
    expect(t.labelSmall!.fontSize, 11);
    expect(t.labelSmall!.height, closeTo(16 / 11, 0.0001));
    expect(t.labelMedium!.fontSize, 10);
    expect(t.labelMedium!.height, closeTo(16 / 10, 0.0001));
  });

  test('component themes use the six radii', () {
    expect(lightTheme.cardTheme.shape, isA<RoundedRectangleBorder>());
    final card = lightTheme.cardTheme.shape! as RoundedRectangleBorder;
    expect(card.borderRadius, BorderRadius.circular(20));
    expect(lightTheme.dialogTheme.shape, isA<RoundedRectangleBorder>());
    final dialog = lightTheme.dialogTheme.shape! as RoundedRectangleBorder;
    expect(dialog.borderRadius, BorderRadius.circular(28));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/theme_swiss_test.dart`
Expected: FAIL（字号仍为 22/18/16/14/14/12/11）

- [ ] **Step 3: 重写 textTheme 映射**

`themes.dart` 中用 `base.textTheme.copyWith(...)` 精确设置（每项都显式给 `fontSize/height/fontWeight/letterSpacing`，`height = line/size`）：

| 角色 | token |
|---|---|
| `headlineMedium` | title 26/32 w800 −0.6 |
| `headlineSmall` | headline 20/28 w700 |
| `titleMedium` | subtitle 16/24 w700 |
| `titleSmall` | bodyStrong 14/20 w600 |
| `bodyMedium` | body 14/20 w400 |
| `labelLarge` | label 13/20 w700 |
| `bodySmall` | caption 12/20 w500 |
| `labelSmall` | micro 11/16 w600 |
| `labelMedium` | badge 10/16 w800 |

`displayLarge/displayMedium/titleLarge/bodyLarge` 保留但收敛（display 34/40 w800、titleLarge 26/32 w800、bodyLarge 16/24 w400、displayMedium 20/28 w700），供旧代码过渡；Task 9 sweep 后确认无滥用。

组件主题同步：

- `appBarTheme.toolbarHeight = SwissGrid.appbar`（56），标题 `headline`；
- `cardTheme.shape` r20，`margin: EdgeInsets.zero`；
- `inputDecorationTheme` 高 48（`contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`）；
- `chipTheme` 高 32，字 11/16 w600；
- `filledButtonTheme`/`elevatedButtonTheme` 高度 48（small variant 40 由页面显式）；
- `dialogTheme` r28，`titleTextStyle = subtitle`，`contentTextStyle = caption`；
- `bottomSheetTheme` 顶部 r28；
- `navigationBarTheme.height = 72`；
- 阴影统一 `sh-1`：`CardTheme.elevation = 1` + `shadowColor: scheme.shadow.withValues(alpha: 0.05)`（芯片/输入框用 `BoxShadow` 时同参数；浮动层 `sh-3` 用 elevation 3）。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/theme_swiss_test.dart && dart analyze lib/ test/`
Expected: PASS + No issues found

---

## Task 3: PageHeader / SectionHeader / PillTabs

**Files:**
- Modify: `lib/ui/components/page_header.dart`
- Modify: `lib/ui/components/section_header.dart`
- Modify: `lib/ui/components/pill_tabs.dart`
- Test: `test/header_metrics_test.dart`

**Interfaces:**
- Consumes: `SwissGrid.margin`、`SwissText.title`、`SwissText.micro`

- [ ] **Step 1: 写失败测试**

```dart
// test/header_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/page_header.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('page header uses 16/16/16/12 and a 26/32 title', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: PageHeader(eyebrow: 'EYEBROW', title: 'Title')),
    ));
    final title = tester.widget<Text>(find.text('Title'));
    expect(title.style!.fontSize, 26);
    expect(title.style!.height, closeTo(32 / 26, 0.0001));
    final eyebrow = tester.widget<Text>(find.text('EYEBROW'));
    expect(eyebrow.style!.fontSize, 10);
    expect(eyebrow.style!.letterSpacing, closeTo(1.5, 0.001)); // .15em of 10
    final pad = tester.widget<Padding>(find.ancestor(of: find.text('Title'), matching: find.byType(Padding)).first);
    expect(pad.padding, const EdgeInsets.fromLTRB(16, 16, 16, 12));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/header_metrics_test.dart`
Expected: FAIL（当前 padding 16,14,16,12；eyebrow 11/0.9）

- [ ] **Step 3: 改实现**

- `page_header.dart`：默认 `padding: EdgeInsets.fromLTRB(16, 16, 16, 12)`；eyebrow 用 `SwissText.badge` + `letterSpacing: 1.5` + `primary`；标题用 `SwissText.title` 且 `maxLines: 1`；eyebrow 与标题间距 `4`；action 左侧间距 `8`。
- `section_header.dart`：标题 13/20 w800、右侧计数 11/16、`margin-bottom 8`。
- `pill_tabs.dart`：外框 `padding 2`、选项高 40、总高 44、字 12/20 w600。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/header_metrics_test.dart test/localization_ui_test.dart`
Expected: PASS

---

## Task 4: 底部导航

**Files:**
- Create: `lib/ui/components/bottom_nav_bar.dart`（从 `main.dart` 的 `_FloatingDock` 抽出，公开供测试）
- Modify: `lib/main.dart`（改用 `BottomNavBar`）
- Test: `test/bottom_nav_metrics_test.dart`

**Interfaces:**
- Consumes: `SwissGrid.navbar`、`SwissText.badge`
- Produces: `BottomNavBar({required int selectedIndex, required ValueChanged<int> onSelected, required int downloadCount})`（内部自取 `AppLocalizations`）

- [ ] **Step 1: 写失败测试**

```dart
// test/bottom_nav_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/bottom_nav_bar.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('bottom navigation is 72 tall with a 56x32 indicator', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 0,
          onSelected: (_) {},
          downloadCount: 0,
        ),
      ),
    ));
    final bar = find.byType(BottomNavBar);
    expect(tester.getSize(bar).height, 72);
    final pill = find.byKey(const ValueKey('nav-indicator')).first;
    expect(tester.getSize(pill), const Size(56, 32));
    final label = tester.widget<Text>(
      find.descendant(of: bar, matching: find.byType(Text)).first,
    );
    expect(label.style!.fontSize, 10);
    expect(label.style!.height, closeTo(16 / 10, 0.0001));
  });
}
```

> 标签文案随测试 locale 变化（默认 en），因此断言取 `BottomNavBar` 内第一个 `Text` 的样式，不写死中文。

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/bottom_nav_metrics_test.dart`
Expected: FAIL（`bottom_nav_bar.dart` 不存在）

- [ ] **Step 3: 改实现**

- 抽出 `BottomNavBar`（保留现有 4 个 Tab、下载徽标、选中态逻辑与无障碍语义）；
- 容器总高 72：`padding: EdgeInsets.fromLTRB(16, 8, 16, 16)`，内部 32 指示 + 4 + 16 标签；
- 指示胶囊 56×32（`ValueKey('nav-indicator')`），圆角 16；图标 20；标签 `SwissText.badge`（10/16 w700）；
- 选中胶囊 `primaryContainer`，未选中透明；`main.dart` 改为引用新组件。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/bottom_nav_metrics_test.dart && flutter test test/settings_page_test.dart`
Expected: PASS（设置页断言仍通过）

---

## Task 5: 搜索页尺寸

**Files:**
- Modify: `lib/ui/search_page.dart`（搜索框 48、分段 44、芯片 32、间距 8 的倍数）
- Test: `test/search_metrics_test.dart`

**Interfaces:**
- Consumes: `SwissGrid`、`SwissText`、`GridMetrics`（分类栏不需要）

- [ ] **Step 1: 写失败测试**

```dart
// test/search_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/search_page.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('search field is 48 high and mode switch is 44', (tester) async {
    await tester.view.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.view.reset());
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SearchPage(),
      ),
    ));
    await tester.pump();
    expect(tester.getSize(find.byType(SearchBar)).height, 48);
    expect(tester.getSize(find.byKey(const ValueKey('search-mode-switch'))).height, 44);
  });
}
```

> 实现时给分段控件加 `key: ValueKey('search-mode-switch')`；芯片断言用 `FilterChip` 或现有 chip 类型，高度 32。

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/search_metrics_test.dart`
Expected: FAIL（58 / 46）

- [ ] **Step 3: 改实现**

- 搜索框：`SizedBox(height: 48)` / `contentPadding` 上下 12；提示字 `caption`；
- 分段：总高 44，外框 padding 2，选项 40；字 `caption` w600；
- 芯片：高 32，`padding 0 12`，字 `micro`；芯片行 `spacing 8`；
- 建议列表：行高 48，间距吸附 4/8；主操作按钮 48 高；
- 高级搜索字段：高 48，标签 `micro`，值 `caption`；
- 所有 `fontSize:` 字面量替换为 `SwissText.*`（本文件范围内）。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/search_metrics_test.dart test/search_suggestions_test.dart test/localization_ui_test.dart`
Expected: PASS

---

## Task 6: 结果页与结果行

**Files:**
- Modify: `lib/ui/components/search_result_card.dart`
- Modify: `lib/ui/components/source_journey_card.dart`
- Modify: `lib/ui/results_page.dart`（筛选行、间距）
- Test: `test/result_row_metrics_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
// test/result_row_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/ui/components/search_result_card.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('result row is 96 high with a 56x80 cover', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: SearchResultCard(
            data: BookData(title: 'Book', author: 'Author', link: 'https://x', md5: 'm'),
            onTap: () {},
          ),
        ),
      ),
    ));
    final cover = find.byKey(const ValueKey('result-cover'));
    expect(tester.getSize(cover), const Size(56, 80));
    expect(tester.getSize(find.byType(SearchResultCard)), const Size(360, 96));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/result_row_metrics_test.dart`
Expected: FAIL（52×74，行高约 90）

- [ ] **Step 3: 改实现**

- 行：`SizedBox(height: 96)`，`padding: EdgeInsets.symmetric(vertical: 8)`，行间 1px 分隔线；
- 封面：56×80，r12；
- 书名 `label`（13/20 w700，2 行省略）；元信息 `micro`；格式徽标 `badge` 10/16 w800，r8，`padding 0 8`；
- 来源胶囊：高 32，字 `micro`，`padding 0 12`；
- 结果页筛选芯片高 32、`spacing 8`；heading 用 `headline`；提示卡片间距 8；
- 本文件所有 `fontSize:` 字面量替换为 token。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/result_row_metrics_test.dart test/results_page_test.dart`
Expected: PASS（结果页既有行为断言不变）

---

## Task 7: 书籍详情

**Files:**
- Modify: `lib/ui/components/book_info_widget.dart`
- Modify: `lib/ui/components/detail_bottom_bar.dart`
- Modify: `lib/ui/book_info_page.dart`（AppBar 标题 `headline`）
- Test: `test/book_info_metrics_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
// test/book_info_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('detail hero cover is 112x168 and title is 16/24 w800', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BookInfoWidget(
          data: BookData(title: 'Book Title', author: 'Author', link: 'https://x', md5: 'm'),
          source: 'LibGen',
        ),
      ),
    ));
    expect(tester.getSize(find.byKey(const ValueKey('detail-cover'))), const Size(112, 168));
    final title = tester.widget<Text>(find.text('Book Title'));
    expect(title.style!.fontSize, 16);
    expect(title.style!.height, closeTo(24 / 16, 0.0001));
    expect(title.style!.fontWeight, FontWeight.w800);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/book_info_metrics_test.dart`
Expected: FAIL（110 宽，19/12.5 字号）

- [ ] **Step 3: 改实现**

- 封面 112×168 r16；hero `padding 8 16`，`gap 16`；
- 书名 `subtitle` 16/24 w800；作者 `caption`；
- 信息卡 r20 `padding 16`，行间距 8，标签 `micro`、值 `caption`；
- 底部操作栏高 84：`padding: EdgeInsets.fromLTRB(16, 12, 16, 24)`，主按钮 48 高 r-pill，字 13/20 w800；
- 文件内 `fontSize:` 字面量全部替换。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/book_info_metrics_test.dart test/book_info_selection_test.dart`
Expected: PASS

---

## Task 8: 下载中心 / 设置 / 镜像 / 关于

**Files:**
- Modify: `lib/ui/download_center_page.dart`（统计 64、任务缩略图 40×60、进度条 4）
- Modify: `lib/ui/settings_page.dart`（设置行 min-height 64、`padding 12 16`、图标容器 32 r12）
- Modify: `lib/ui/instances_page.dart`（镜像卡行高与字阶）
- Modify: `lib/ui/about_page.dart`（字阶）
- Modify: `lib/ui/components/delete_dialog_widget.dart`、设置页内 `AlertDialog`（r28、padding 24、标题 `subtitle`、正文 `caption`）
- Create: `lib/ui/components/settings_row.dart`（可复用设置行）
- Test: `test/settings_row_metrics_test.dart`、`test/download_task_metrics_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
// test/settings_row_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/settings_row.dart'; // 实现时从 settings_page 抽出

void main() {
  testWidgets('settings row is at least 64 high', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SettingsRow(
          icon: Icons.language,
          title: '语言',
          subtitle: '界面文字，立即生效',
          trailing: Text('中文'),
        ),
      ),
    ));
    expect(tester.getSize(find.byType(SettingsRow)).height, greaterThanOrEqualTo(64));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/settings_row_metrics_test.dart`
Expected: FAIL（`SettingsRow` 不存在 → 抽出组件）

- [ ] **Step 3: 改实现**

- 抽出可复用的 `SettingsRow`（`lib/ui/components/settings_row.dart`），min-height 64，`padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`，`gap 12`，图标容器 32×32 r12，主 13/20 w700，副 11/16，右值 12 w600；设置页与镜像页改用它。
- 下载中心：三列统计块高 64、gap 8、等分；任务卡缩略图 40×60 r12，进度条 4 高 r2，任务卡 r20 `padding 12 16`；完成列表行 64。
- 对话框：`shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))`，`titlePadding/contentPadding: EdgeInsets.all(24)`，按钮行 `margin-top 20`、`gap 8`。
- 关于页字阶收敛（标题 `headline`、正文 `caption`/`body`）。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/settings_row_metrics_test.dart test/download_center_page_test.dart test/settings_page_test.dart test/instances_page_test.dart`
Expected: PASS（必要时把既有测试断言的间距更新为规格值，但不得删断言）

---

## Task 9: 首页 / 分类 / 热门 + 全站收口

**Files:**
- Modify: `lib/ui/home_page.dart`（分类格 64 高、`GridMetrics`）
- Modify: `lib/ui/categories_page.dart`（分类格 64、详情网格间距 8）
- Modify: `lib/ui/trending_page.dart`（海报 128×192、r16）
- Modify: `lib/main.dart`（挂载默认关闭的调试网格）
- Modify: 其余仍含 `fontSize:` 字面量的文件（sweep）
- Create: `lib/ui/components/swiss_grid_overlay.dart`（`kDebugMode` 调试网格）
- Test: `test/home_metrics_test.dart`、`test/no_stray_metrics_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
// test/home_metrics_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/open_library.dart' show TrendingBookData;
import 'package:openlib/state/state.dart' show getTrendingBooks;
import 'package:openlib/ui/themes.dart';
import 'package:openlib/ui/trending_page.dart';

void main() {
  testWidgets('trending poster is 128 wide with a 192-high cover', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => [
              TrendingBookData(title: 'Book', thumbnail: ''),
            ]),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: TrendingPage()),
      ),
    ));
    await tester.pumpAndSettle();
    final poster = find.byKey(const ValueKey('trending-poster')).first;
    expect(tester.getSize(poster).width, 128);
    expect(tester.getSize(find.byKey(const ValueKey('trending-cover')).first).height, 192);
  });
}
```

```dart
// test/no_stray_metrics_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UI code has no stray fontSize literals outside tokens', () {
    final files = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final offenders = <String>[];
    for (final file in files) {
      if (file.path.endsWith('swiss_grid.dart') ||
          file.path.endsWith('themes.dart') ||
          file.path.endsWith('error_widget.dart') /* monospace 调试输出 */) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'fontSize:\s*[0-9]').hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/home_metrics_test.dart test/no_stray_metrics_test.dart`
Expected: FAIL（126 宽 / 192 不存在 key / 多处 fontSize）

- [ ] **Step 3: 改实现**

- 热门海报：宽 128，封面 128×192 r16，书名 `micro`，`margin-top 4`；横滑 `padding 2 16 4`，`gap 12`（`trending_page.dart`，补 `ValueKey('trending-poster'/'trending-cover')`）。
- 分类格（首页 4×2 与分类页）：高 64 r16，`padding 8`，图标 32 r12，名称 12/20 w700，计数 11/16；用 `GridMetrics` 算 `childAspectRatio`。
- 首页区块间距 16、卡片间距 8；标题 `headline`/`label` 按语义取 token。
- **全站 sweep**：对 `lib/ui/**` 内剩余 `fontSize:` 逐处按语义替换为 `SwissText.*` 或 textTheme 角色；圆角只留六档；图标按钮统一 40×40 r12（小号 16）；把非 4 倍数的高度/间距改为 4 的倍数。
- 新增 `SwissGridOverlay`（spec §5.4），在 `MaterialApp.builder` 中仅 `kDebugMode` 挂 `IgnorePointer`；默认关闭，用 `--dart-define=SWISS_GRID=true` 打开，避免影响正常调试截图。

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/home_metrics_test.dart test/no_stray_metrics_test.dart`
Expected: PASS

- [ ] **Step 5: 全量回归**

Run: `dart analyze lib/ test/ && flutter test`
Expected: Analyze 无问题；测试全绿（含既有 287 条，仅允许因几何断言更新而修改断言值，不允许删除用例）

---

## Task 10: 实机视觉验收

**Files:**
- 无代码改动（除非验收发现问题）
- 产物：`build/swiss_*.png`

- [ ] **Step 1: Windows 构建**

```bash
export PATH="/d/OpenlibExtended/build/tools:$PATH"
flutter build windows --release
```

Expected: `√ Built build\windows\x64\runner\Release\OpenlibExtended.exe`

- [ ] **Step 2: 逐屏截图**

用 `build/print_window.ps1`（DPI aware）在 1280×720 逻辑窗口截：发现 / 分类 / 搜索空态 / 搜索输入 / 高级搜索 / 结果 / 详情 / 下载中心 / 设置四页 / 镜像 / 对话框。

- [ ] **Step 3: 对照 spec §7 验收清单逐条勾选**

特别核对：左右边缘 16；文字只来自 9 级；固定尺寸 4 倍数；圆角六档；导航 72/图标 20/标签 10/16。

- [ ] **Step 4: Android 真机抽查**

```bash
flutter build apk --debug -Pkotlin.incremental=false
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n dev.wath.openlibextended/.MainActivity
```

截 3 屏（发现 / 结果 / 设置）确认字阶与间距在移动端同样成立。

- [ ] **Step 5: 记录未覆盖项**

把无法验证或有意保留的偏差写进交付说明（例如 spec §6 的豁免项）。

---

## 风险与边界

1. **测试耦合**：`results_page_test`、`download_center_page_test` 等在 390×844 视口断言文案；几何变化可能导致溢出。计划要求更新断言值，不删除用例。
2. **中文回退字体**：本计划与字体修复无关；Windows 字体族已在 `themes.dart` 固定为 `Microsoft YaHei UI`，本改造不得移除该设置。
3. **桌面宽屏**：`ContentWidth` 保留（840/900）；Swiss 网格按实际 `maxWidth` 计算列宽，桌面仍然收窄居中。
4. **既有功能不变**：不合并/删除任何页面与设置项；只改视觉度量与字阶。
5. **提交**：用户已授权本轮逐任务提交；每个实现者只提交本任务文件，不提交工作区中的既有改动，不推送。
