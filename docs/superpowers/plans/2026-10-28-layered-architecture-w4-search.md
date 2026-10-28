# 分层架构迁移 · 第 4 阶段（W4 search 特性迁移）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 search 页面从 Riverpod 迁到 `SearchViewModel`（ChangeNotifier）+ `ListenableBuilder`，清除 `lib/ui/features/search/**` 里全部 68 处 `ref.*`；流式结果、建议、镜像测速提示的行为与文案不变。

**Architecture:** 搜索页拥有的临时状态进 ViewModel；跨页面共享的筛选状态进 `AppSettings`（ChangeNotifier，get_it 单例），Riverpod 里保留只读派生 provider 直到 W5/W6；镜像测速控制器从 `state.dart` 抽到 data 层并注册为单例，搜索页与镜像页共用；趋势书单抽成 `TrendingRepository`，供 provider 与 ViewModel 共用。

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md` §5（ViewModel 与 DI）、§6 W4

## Global Constraints

- Flutter 3.47.2；不引入新依赖；不用代码生成
- 不改 UI 外观、文案、动画时长；不改建议防抖 420ms、镜像 24h 过期与提示逻辑
- 每任务结束 `dart analyze lib/ test/` 无问题且 `flutter test` 全绿（基线 453 passed / 18 skipped）
- 真实网络用例保持 skip
- 提交信息英文 conventional commits
- 工作目录：`D:/OpenlibExtended/.worktrees/refactor-layered-architecture`（分支 `refactor/layered-architecture`）

## 状态归属（W4 后的唯一来源）

| 状态 | 归属 | 持久化 |
|---|---|---|
| `query`（搜索框内容） | ViewModel | 无 |
| `selectedSource`（来源胶囊） | ViewModel | 无（结果页从路由参数拿） |
| `suggestions` / `suggestionsLoading` / 防抖计时器 / 请求序号 | ViewModel | 无 |
| `recentSearches` | ViewModel + `RecentSearchStore` | DB（`recentSearches` 偏好） |
| `enabledProviders` / `sourceOrder` | ViewModel（启动时读 `SearchRepository`） | 仓库已有 |
| `trending`（Try these 建议） | ViewModel（`TrendingRepository`） | 无 |
| 镜像测速状态（readings/testing） | `MirrorLatencyNotifier`（get_it 单例，VM 监听并转发通知） | DB（24h TTL） |
| `filters`（type/sort/fileType/language/year） | `AppSettings` | 搜索页改值时写 `PreferencesRepository` |
| `searchAuthor` / `searchPublisher` | `AppSettings` | 无（与现状一致） |
| `filtersEnabled` | `AppSettings` | 无（与现状一致） |
| Tab 模式 / TextEditingController / FocusNode / TabController | 页面 | 无 |
| 切换根标签到设置页 | 页面回调 `onManageSources`（main 注入） | 无 |

W4 完成后删除：`searchQueryProvider`、`selectedSourceState`（仅搜索页使用）；`recentSearchesProvider` 与 `RecentSearchesNotifier`（VM 接管）。保留且改为只读派生：`selectedTypeState`、`selectedSortState`、`selectedFileTypeState`、`selectedLanguageState`、`selectedYearState`、`searchAuthorProvider`、`searchPublisherProvider`、`enableFiltersState`。

## 契约

### AppSettings（`lib/app/app_settings.dart`）

新增字段（构造参数带默认值，避免改现有测试）：`String searchAuthor = ''`、`String searchPublisher = ''`、`bool filtersEnabled = true`。

新增方法：

```dart
void setFilter(SearchFilterKind kind, String value); // 只改内存 + notify
void resetSearchFilters();                            // 5 个筛选回默认 + author/publisher 清空 + notify
void setSearchAuthor(String value);
void setSearchPublisher(String value);
void setFiltersEnabled(bool value);
```

`SearchFilters` 增加 `copyWith`（`lib/data/models/search_filters.dart`）。

### state.dart（迁移期桥接）

```dart
final appSettingsProvider = ChangeNotifierProvider<AppSettings>((ref) => getIt<AppSettings>());
final selectedTypeState = Provider<String>((ref) => ref.watch(appSettingsProvider).filters.type);
// sort/fileType/language/year、searchAuthor/searchPublisher、enableFiltersState 同理
final mirrorLatencyProvider = StateNotifierProvider<MirrorLatencyNotifier, MirrorLatencyState>(
    (ref) => getIt<MirrorLatencyNotifier>());
```

`selected*State` 写点必须改走 `appSettingsProvider`：results 页排序/重置、trending/categories 页的 `filtersEnabled`。

### MirrorLatency 控制器（`lib/data/services/mirror_latency_controller.dart`）

从 `state.dart` 原样搬出（逻辑零改动）：`MirrorLatencyState`、`MirrorLatencyResult`、`MirrorLatencyNotifier`、`hasFreshMirrorLatency`、`shouldShowMirrorLatencyHint`。`state.dart` 用 `export` 保持旧 import 可用；DI 注册 `lazySingleton<MirrorLatencyNotifier>`，provider 返回该单例。

### TrendingRepository（`lib/data/repositories/trending_repository.dart`）

```dart
class TrendingRepository {
  TrendingRepository({List<TrendingBooksImpl>? sources}); // 默认 GoodReads/PenguinRandomHouse/BookDigits
  Future<List<TrendingBookData>> trendingBooks();          // Future.wait 后展开
}
```

`getTrendingBooks` 改为 `ref.watch(trendingRepositoryProvider).trendingBooks()`，空列表仍抛 `Exception('Nothing Trending Today :(')`（视图行为不变）。

### SearchViewModel（`lib/ui/features/search/view_models/search_view_model.dart`）

```dart
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required SearchRepository search,
    required PreferencesRepository preferences,
    required AppSettings settings,
    required MirrorRepository mirrors,
    required MirrorLatencyNotifier mirrorLatency,
    required TrendingRepository trending,
    RecentSearchStore? recentStore,   // 默认 DbRecentSearchStore()
    GoogleSuggestApi? suggestionsApi, // 默认 GoogleSuggestApi()
    DateTime Function()? clock,
  });

  // 只读状态
  String get query;
  String get author;            // settings.searchAuthor
  String get publisher;
  SearchFilters get filters;    // settings.filters
  bool get filtersEnabled;
  SearchProviderId? get selectedSource;
  Set<SearchProviderId> get enabledProviders;   // 加载前为 all
  List<SearchProviderId> get sourceOrder;       // 加载前 defaultSearchSourceOrder
  bool get sourcesLoaded;
  List<TrendingBookData> get trending;
  List<String> get suggestions;
  bool get suggestionsLoading;
  List<String> get recentSearches;
  MirrorLatencyState get mirrorLatency;
  int get advancedFilterCount;

  // 命令
  Future<void> load();                       // recents + mirror.load() + sources + trending，各自到达即 notify
  void updateQuery(String value);            // 防抖 420ms、空值清建议
  void clearQuery();
  void selectSource(SearchProviderId? source);
  void setFilter(SearchFilterKind kind, String value); // settings.setFilter + 持久化
  void setAuthor(String value);
  void setPublisher(String value);
  void resetFilters();                       // settings.resetSearchFilters + resetSearchFilters()
  Future<String?> prepareSearch([String? value]); // null=空查询；否则写 query、记最近、filtersEnabled=true
  Future<MirrorLatencyResult> testMirrorLatency(); // 防重入 + 汇总实例 + notifier.test
  void removeRecent(String query);
  void clearRecents();
  @override void dispose();                  // 取消计时器、移除 settings/notifier 监听
}
```

监听：`settings.addListener(notifyListeners)`、`mirrorLatency.addListener(notifyListeners)`（构造函数里加、dispose 里移除）。建议源过滤/去重规则与现状一致（丢弃 `Suggestion Error` / `Network Error` / 空白）。`prepareSearch` 内的持久化与 `setFilter` 一致使用 `unawaited`。

### 页面（`lib/ui/features/search/views/search_page.dart`）

```dart
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.viewModel, this.onManageSources});
  final SearchViewModel? viewModel;      // 测试注入
  final VoidCallback? onManageSources;   // 打开“管理来源”→设置页
}
```

- `initState`：`_vm = widget.viewModel ?? getIt<SearchViewModel>()`，`_ownsVm` 标记；`_vm.load()`；`_vm.addListener(_syncController)`
- 页面主体包 `ListenableBuilder(listenable: _vm, ...)`；TextEditingController 只在 query 变化时同步
- 私有子组件（`_AdvancedSearchTab`、`_SuggestionsTab`、`_InlineSuggestions`、`_RecentSearchesSection`、`_TryTheseSection`、`_SearchSourceSelector`）全部改为普通 Widget，通过构造参数拿 `SearchViewModel` 与回调；不再有 `ConsumerWidget`/`WidgetRef`
- 空查询提交：提示 + 切回建议页 + 聚焦（不变）；`prepareSearch` 返回非空时 push `ResultPage`

### main.dart

`_widgetOptions` 从 `static const` 改为 `late final List<Widget> _pages`（`SearchPage(onManageSources: () => _selectTab(3))`）；移除 5 个筛选 StateProvider override。

## 任务拆分

### Task 1: 基础设施（owner A，串行先做）

- 新建 `mirror_latency_controller.dart`，从 `state.dart` 搬类（逻辑零改动），`state.dart` 改 import + `export`
- 新建 `trending_repository.dart`；`repository_providers.dart` 加 `trendingRepositoryProvider`
- `app_settings.dart` 加字段/方法；`search_filters.dart` 加 `copyWith`
- `state.dart`：`appSettingsProvider` + 8 个派生 provider；删 `searchQueryProvider`/`selectedSourceState`；`getTrendingBooks` 改走仓库；`mirrorLatencyProvider` 改单例
- `recent_searches.dart`：删 `RecentSearchesNotifier` 与 provider，去掉 `flutter_riverpod` import（保留 store 与纯函数）
- `di.dart`：注册 `TrendingRepository`、`MirrorLatencyNotifier`、`SearchViewModel` factory
- 改写写点：`results_page.dart`（排序 + 重置）、`trending_page.dart`、`categories_page.dart`、`main.dart`（overrides + pages 列表）
- 不跑 analyze（Task 2/3 未完成）

### Task 2: ViewModel + 单测（owner B，依赖 Task 1）

- 新建 `lib/ui/features/search/view_models/search_view_model.dart`（严格按契约）
- 新建 `test/search_view_model_test.dart`：筛选写 AppSettings + 持久化调用；重置；建议防抖/去重/丢弃错误项；最近搜索 record/remove/clear；资源加载；镜像测速防重入；dispose 后不再 notify
- 测试替身：`_FakeSearchRepository extends SearchRepository`、`_FakePreferences extends PreferencesRepository`、`_FakeMirror extends MirrorRepository`、`_FakeTrending extends TrendingRepository`、`_MemoryRecentStore`、`_FakeSuggestions`、`_FakeMirrorLatency extends MirrorLatencyNotifier`
- 不跑 analyze

### Task 3: 页面改写（owner C，依赖 Task 2 的契约，可与 Task 2 并行）

- 按契约重写 `search_page.dart` 的 State 与子组件；删除文件内 3 个 provider 定义与全部 `ref.*`
- 保持现有 Widget 树、Key（`advanced-search-card`）、文案、间距、动画不变
- 不跑 analyze

### Task 4: 测试适配（owner D，依赖 Task 2+3）

- `search_metrics_test.dart`、`search_suggestions_test.dart`：改为注入 `SearchViewModel`；保留 ResultPage/ActiveDownloadsWidget 需要的 ProviderScope override；结果页测试补 `appSettingsProvider` override
- `localization_ui_test.dart`：注入 VM
- `results_page_test.dart`：补 `appSettingsProvider.overrideWith((ref) => AppSettings(...))`
- `di_test.dart`：断言新增注册；`app_settings_test.dart`：新增 setter 用例
- `HANDOVER.md`：更新 search 状态归属（state.dart 桥接、VM、AppSettings 筛选）
- 不跑 analyze

### Task 5: 验收（主 agent）

- `grep -rn "ref\." lib/ui/features/search` → 无输出
- `grep -rn "searchQueryProvider\|selectedSourceState\|recentSearchesProvider" lib` → 无输出
- `dart analyze lib/ test/` 无问题；`flutter test` 全绿（期望 453 + 新增 VM 用例）
- 评审子 agent 复核：行为对齐（防抖、去重、镜像提示、排序/重置）、无残留 Riverpod、无越界改动
- 更新计划文档、提交

## Self-Review

- **Spec coverage：** W4 要求的 `SearchViewModel` + `ListenableBuilder`、68 处 `ref.*` 清除、两条搜索测试注入化，以及为保持跨页行为必须迁移的筛选/镜像/趋势状态。
- **Placeholder scan：** 每个任务列出文件与接口；VM 方法语义均有定义。
- **已知风险：** `ChangeNotifierProvider` 桥接是临时结构，W5/W6 删除；`mirrorLatencyProvider` 返回 get_it 单例，容器销毁时会 dispose 该单例（应用生命周期内只销毁一次）；结果页/趋势页在 W4 只改写点，不改渲染逻辑。
