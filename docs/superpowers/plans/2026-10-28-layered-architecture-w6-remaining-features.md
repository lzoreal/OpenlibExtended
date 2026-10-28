# 分层架构迁移 · 第 6 阶段（W6 其余特性）实施计划

**Goal:** settings、instances、onboarding、shell（main/home/active downloads）、trending、webview、what's new 全部迁到 ViewModel/构造注入；`lib/` 中不再有 `ref.*`/`Consumer*`/`ProviderScope`。19 个使用 `ProviderScope` 的测试改为 `setupTestDi` 注入。

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md` §5、§6 W6

## Global Constraints

- 不改 UI 外观/文案/交互；保留下载、镜像、主题、导入行为
- `dart analyze lib/ test/` 无问题；`flutter test` 全绿（基线 468 passed / 18 skipped）
- 提交信息英文 conventional commits；工作目录 `D:/OpenlibExtended/.worktrees/refactor-layered-architecture`

## 状态归属

| 状态 | 归属 |
|---|---|
| themeMode / fontSizeScale / locale | `AppSettings`（唯一来源；settings/onboarding 写入，main 监听） |
| showManualDownloadButton / backgroundVerification / donationKey / userAgent / cookie | `AppSettings`（settings/onboarding 写入） |
| 书源启停与顺序 | `SearchRepository` + `SettingsViewModel` 本地快照 |
| 镜像 auto 模式、各服务实例列表 | `MirrorRepository` + `InstancesViewModel` |
| 镜像测速状态 | 共享 `MirrorLatencyNotifier` |
| 根标签 index | `ShellViewModel`（回调传给 search/download/home） |
| 进行中任务（徽标/横幅） | `ActiveDownloadsViewModel`（订阅 `DownloadRepository.updates`，100ms 节流） |
| 首页子标签 index | `HomePage` 本地 State |
| 趋势书单 / 分类书单 | `TrendingViewModel` / `CategoriesViewModel`（`TrendingRepository`、分类服务） |
| 引导页导入刷新 | `OnboardingViewModel.refreshLibrary()` |

## ViewModel 契约

**SettingsViewModel**（`ui/features/settings/view_models/`）：依赖 `AppSettings`、`SearchRepository`、`LibraryRepository`。暴露 themeMode/fontSizeScale/locale、showManual/background/donation/userAgent/cookie 读写（写 `AppSettings`，页面继续负责 DB 持久化）、enabledSources/sourceOrder + `loadSources`/`setEnabled`/`setSourceOrder`、`refreshLibrary()`（调用 `LibraryRepository.notifyChanged()`）。

**InstancesViewModel**：依赖 `MirrorRepository`、`MirrorLatencyNotifier`。暴露 autoMode、`Map<MirrorService,List<InstanceView>>`、loading、latency；命令 `load`/`setAutoMode`/`refreshAll`/`refresh`/`setEnabled`/`move`/`testLatency`，行为与现页面一致（刷新后重载各服务）。

**OnboardingViewModel**：依赖 `AppSettings`、`LibraryRepository`。themeMode/donationKey 读写 + `refreshLibrary()`。

**ShellViewModel**（`ui/features/shell/view_models/`）：依赖 `AppSettings`、`DownloadRepository`。暴露 themeMode/fontSizeScale/locale、`tabIndex`/`selectTab`、`activeDownloadCount`（流式、100ms 节流）、`resumeInterrupted()`；监听 AppSettings 与下载流。

**ActiveDownloadsViewModel**（同目录）：依赖 `DownloadRepository`，暴露 `List<DownloadTask> tasks` 与 pause/resume/cancel/retry；`ActiveDownloadsWidget` 增加可选 `viewModel`（默认 `getIt<DownloadRepository>()` 构造，页面自建自管）。

**TrendingViewModel / CategoriesViewModel / WhatsNewViewModel**：趋势/分类数据加载与刷新；分类页保留 `filtersEnabled` 写入（改走注入的 `AppSettings`）；What's New 的镜像刷新 + `enableAllProviders()` 走注入的仓库。

## 页面契约

- `SettingsPage`/`InstancesPage`/`OnboardingPage`/`HomePage`/`TrendingPage`/`CategoriesPage`/`WhatsNewPage` 均接受可选 `viewModel` 测试注入，默认 `fromDi`。
- `main.dart`：移除 `ProviderScope` 与全部 overrides；`MainScreen` 用 `ShellViewModel` + `ListenableBuilder`；`SearchPage(onManageSources: () => vm.selectTab(3))`、`DownloadCenterPage(onBrowseSearch: () => vm.selectTab(1))`、`HomePage(onOpenSearch: () => vm.selectTab(1))`。
- `ActiveDownloadsWidget` 不再使用 Riverpod（search 页无需改动调用点）。
- `webview_page.dart` 移除未使用的 Riverpod import（`href` 不是 `ref.`）。

## 任务拆分（文件所有权互斥）

- **S（settings）**：`settings_page.dart`、`settings_view_model.dart`、`settings_page_test.dart`；`LibraryRepository.notifyChanged()`。
- **I（instances）**：`instances_page.dart`、`instances_view_model.dart`、`instances_page_test.dart`、`mirror_latency_ui_test.dart`。
- **O（onboarding）**：`onboarding_page.dart`、`onboarding_view_model.dart`、`onboarding_sponsor_test.dart`。
- **H（shell）**：`main.dart`、`home_page.dart`、`active_downloads_widget.dart`、`shell_view_model.dart`、`active_downloads_view_model.dart`、`home_metrics_test.dart`、`bottom_nav_metrics_test.dart`、`tab_keep_alive_test.dart`。
- **T（trending/webview/whats new）**：`trending_page.dart`、`categories_page.dart`、`webview_page.dart`、`whats_new_page.dart`、三个 ViewModel、`category_listing_page_test.dart`、`whats_new_page_test.dart`。
- **整合（主 agent）**：DI 注册、删除 `state.dart` 中已无引用的 provider、`files.dart` 去 Riverpod、其余测试改 `setupTestDi`、全量验证、评审、提交。

## 验收

- `grep -rnE "ref\.|ConsumerWidget|ConsumerState|ProviderScope|StateProvider|ChangeNotifierProvider" lib --include=*.dart`（排除 data 层误报）→ 0
- 所有测试无 `ProviderScope`；`dart analyze` 无问题；`flutter test` 全绿
- 评审子 agent 复核主题/字号/语言即时生效、镜像页启停与测速、引导导入、标签切换与下载徽标、趋势/分类刷新

## Self-Review

- **Spec coverage：** W6 列出的全部页面 + 共享下载横幅；测试全面改为 get_it。
- **已知风险：** settings 页 1781 行且大量直接调用服务，本波只迁移状态引用，服务调用留待后续；主题来源切换必须保证设置页与主壳同步。
