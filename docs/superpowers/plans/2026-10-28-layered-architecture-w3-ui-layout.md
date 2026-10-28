# 分层架构迁移 · 第 3 阶段（W3 UI 目录重排）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `lib/ui/` 一次性重排为 `ui/core/` + `ui/features/<feature>/{views,widgets}/`，只移动文件与改写 import，不做任何代码逻辑、Widget 树或文案改动。

**Architecture:** 共享主题与跨 feature 组件进 `ui/core/`；页面进所属 feature 的 `views/`；只被单个 feature 使用的组件进该 feature 的 `widgets/`。文件归属以当前 import 使用方为准，见下方映射表。

**Tech Stack:** Flutter 3.47.2、Dart >=3.3.0 <4.0.0（本阶段无新依赖）

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md` §3、§6 W3

## Global Constraints

- 纯移动：文件内容除 `import` 行外零改动；不重命名类/Widget/方法；不动文案与主题
- 不引入新依赖；不改 `pubspec.yaml`；不改 `lib/data/`、`lib/state/`、`lib/app/`
- 全部 import 是 `package:openlib/ui/...` 绝对路径，无相对 import，可机械替换
- 每任务结束 `dart analyze lib/ test/` 无问题且 `flutter test` 全绿
- 真实网络用例保持 skip
- 提交信息英文 conventional commits
- 工作目录：`D:/OpenlibExtended/.worktrees/refactor-layered-architecture`（分支 `refactor/layered-architecture`）

## 当前基线

- `flutter test` = 453 passed / 18 skipped；`dart analyze lib/ test/` 无问题
- `lib/ui/` 现有 19 个页面/工具文件 + `components/` 25 个 + `onboarding/1 个`
- 61 个文件、172 行 import 指向 `package:openlib/ui/`

## 目标结构

```text
lib/ui/
├── core/
│   ├── themes.dart  motion.dart  swiss_grid.dart  open_book.dart
│   └── components/            # 跨 feature 共享组件
└── features/
    ├── shell/views/home_page.dart
    ├── shell/widgets/{bottom_nav_bar,content_width,swiss_grid_overlay}.dart
    ├── search/views/search_page.dart
    ├── search/widgets/{edge_fade,mirror_latency_hint}.dart
    ├── results/views/results_page.dart
    ├── results/widgets/{search_result_card,source_journey_card,visible_builder}.dart
    ├── book_detail/views/book_info_page.dart
    ├── library/views/{download_center_page,mybook_page}.dart
    ├── settings/views/{settings_page,about_page}.dart
    ├── instances/views/instances_page.dart
    ├── onboarding/views/onboarding_page.dart
    ├── trending/views/{trending_page,categories_page}.dart
    ├── webview/views/{webview_page,challenge_solver_page}.dart
    └── whats_new/views/whats_new_page.dart
```

归属说明：

- `about_page` 只由 `settings_page` 打开 → 归 settings
- `categories_page` 是 `home_page`/`trending_page` 共用的分类列表 → 归 trending
- `whats_new_page` 由 `main.dart` 直接打开 → 独立 feature（与 W6 的 what's new 迁移对齐）
- `file_buttons_widget`/`detail_bottom_bar`/`delete_dialog_widget`/`share_icon` 被 book_detail 与 library 共用 → core
- `content_width` 按 spec §3 归 shell（尽管被多页引用，W3 不调整这种引用）

## 完整映射表（old → new，均相对 `lib/ui/`）

页面与工具：

| old | new |
|---|---|
| `themes.dart` | `core/themes.dart` |
| `motion.dart` | `core/motion.dart` |
| `swiss_grid.dart` | `core/swiss_grid.dart` |
| `open_book.dart` | `core/open_book.dart` |
| `home_page.dart` | `features/shell/views/home_page.dart` |
| `search_page.dart` | `features/search/views/search_page.dart` |
| `results_page.dart` | `features/results/views/results_page.dart` |
| `book_info_page.dart` | `features/book_detail/views/book_info_page.dart` |
| `download_center_page.dart` | `features/library/views/download_center_page.dart` |
| `mybook_page.dart` | `features/library/views/mybook_page.dart` |
| `settings_page.dart` | `features/settings/views/settings_page.dart` |
| `about_page.dart` | `features/settings/views/about_page.dart` |
| `instances_page.dart` | `features/instances/views/instances_page.dart` |
| `onboarding/onboarding_page.dart` | `features/onboarding/views/onboarding_page.dart` |
| `trending_page.dart` | `features/trending/views/trending_page.dart` |
| `categories_page.dart` | `features/trending/views/categories_page.dart` |
| `webview_page.dart` | `features/webview/views/webview_page.dart` |
| `challenge_solver_page.dart` | `features/webview/views/challenge_solver_page.dart` |
| `whats_new_page.dart` | `features/whats_new/views/whats_new_page.dart` |

组件：

| old | new |
|---|---|
| `components/active_downloads_widget.dart` | `core/components/active_downloads_widget.dart` |
| `components/book_card_widget.dart` | `core/components/book_card_widget.dart` |
| `components/book_info_widget.dart` | `core/components/book_info_widget.dart` |
| `components/delete_dialog_widget.dart` | `core/components/delete_dialog_widget.dart` |
| `components/detail_bottom_bar.dart` | `core/components/detail_bottom_bar.dart` |
| `components/error_widget.dart` | `core/components/error_widget.dart` |
| `components/file_buttons_widget.dart` | `core/components/file_buttons_widget.dart` |
| `components/inline_hint.dart` | `core/components/inline_hint.dart` |
| `components/language_names.dart` | `core/components/language_names.dart` |
| `components/page_header.dart` | `core/components/page_header.dart` |
| `components/pill_tabs.dart` | `core/components/pill_tabs.dart` |
| `components/search_source_meta.dart` | `core/components/search_source_meta.dart` |
| `components/section_header.dart` | `core/components/section_header.dart` |
| `components/settings_row.dart` | `core/components/settings_row.dart` |
| `components/share_icon.dart` | `core/components/share_icon.dart` |
| `components/snack_bar_widget.dart` | `core/components/snack_bar_widget.dart` |
| `components/tab_keep_alive.dart` | `core/components/tab_keep_alive.dart` |
| `components/bottom_nav_bar.dart` | `features/shell/widgets/bottom_nav_bar.dart` |
| `components/content_width.dart` | `features/shell/widgets/content_width.dart` |
| `components/swiss_grid_overlay.dart` | `features/shell/widgets/swiss_grid_overlay.dart` |
| `components/edge_fade.dart` | `features/search/widgets/edge_fade.dart` |
| `components/mirror_latency_hint.dart` | `features/search/widgets/mirror_latency_hint.dart` |
| `components/search_result_card.dart` | `features/results/widgets/search_result_card.dart` |
| `components/source_journey_card.dart` | `features/results/widgets/source_journey_card.dart` |
| `components/visible_builder.dart` | `features/results/widgets/visible_builder.dart` |

## 任务拆分（文件所有权互不重叠，可并行）

### Task 1: core + shell（owner A）

**移动：** 映射表中 `core/` 全部 21 个文件与 `features/shell/` 4 个文件。
**改写：** 上述 25 个文件内部的 `package:openlib/ui/...` import；改完后 `components/` 目录应为空并删除，`lib/ui/` 下只允许剩 `core/`、`features/`。

### Task 2: search + results + book_detail（owner B）

**移动：** `search_page`、`edge_fade`、`mirror_latency_hint`、`results_page`、`search_result_card`、`source_journey_card`、`visible_builder`、`book_info_page`（8 个）。
**改写：** 这 8 个文件内部的 import。

### Task 3: library + settings + instances + onboarding + trending + webview + whats_new（owner C）

**移动：** 映射表中这 7 个 feature 的 11 个文件。
**改写：** 这 11 个文件内部的 import；删除空的 `lib/ui/onboarding/`。

### Task 4: test/（owner D）

**改写：** `test/` 下所有 `package:openlib/ui/...` 路径，按映射表替换；不改测试逻辑。

### Task 5: main.dart + 文档（owner E）

**改写：** `lib/main.dart` 的 ui import；`AGENTS.md`、`HANDOVER.md` 中的 `lib/ui/...` 路径（含行号引用，行号不变）。

### Task 6: 验收

- [ ] `grep -rn "package:openlib/ui/components\|ui/onboarding/\|ui/themes.dart\|ui/motion.dart\|ui/swiss_grid.dart\|ui/open_book.dart" lib test` 无输出（除新 `core`/`features` 路径外）
- [ ] `grep -rnE "ui/(home_page|search_page|results_page|book_info_page|download_center_page|mybook_page|settings_page|about_page|instances_page|trending_page|categories_page|webview_page|challenge_solver_page|whats_new_page)\.dart" lib test` 无输出
- [ ] `dart analyze lib/ test/` 无问题
- [ ] `flutter test` 全绿（期望 453 passed / 18 skipped；`dart analyze lib/ test/` 已通过）
- [ ] `git diff --stat` 只出现 rename 与 import/文档行改动；抽查 `git diff -M` 确认无逻辑改动

## Self-Review

- **Spec coverage：** 覆盖 spec §3 目标树的 `core/` 与全部 `features/`（含 spec 未列出的 `about`/`categories`/`whats_new`，按引用关系归入 settings/trending/独立 feature）。
- **Placeholder scan：** 映射表覆盖全部 44 个移动文件，无遗漏。
- **已知风险：** `content_width` 归 shell 后仍被其他 feature 引用（按 spec）；core 组件 `error_widget` 引用 `features/webview` 的页面（历史遗留，W4–W6 处理）。
