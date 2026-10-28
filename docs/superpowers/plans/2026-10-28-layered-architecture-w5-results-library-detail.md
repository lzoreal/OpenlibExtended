# 分层架构迁移 · 第 5 阶段（W5 results / library / book_detail）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 把 results、library（下载中心 + mybook）、book_detail 三个页面迁到 ViewModel + `ListenableBuilder`，并让共享卡片/详情组件改为构造注入；这三个 feature 的 `ref.*` 清零，流式结果、分页、下载队列、详情下载流程行为不变。

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md` §5、§6 W5

## Global Constraints

- 不引入新依赖；不改 UI 外观/文案/动画；保留下载协议、分页、去重与并发行为
- `dart analyze lib/ test/` 无问题；`flutter test` 全绿（基线 468 passed / 18 skipped）
- 真实网络用例保持 skip；提交信息英文 conventional commits
- 工作目录：`D:/OpenlibExtended/.worktrees/refactor-layered-architecture`

## 基础层（先做）

1. **`lib/data/repositories/cover_repository.dart`**
   ```dart
   class CoverRepository {
     CoverRepository({LibgenService? libgen, DateTime Function()? clock});
     Future<String?> coverFor(String url); // 仅 ads.php?md5=；TTL 10 分钟；同 URL 去重
   }
   ```
   迁移 `resultCoverProvider` 的 `LibgenService().fetchCover` + 10 分钟 keepAlive 语义。
2. **`lib/data/repositories/book_info_repository.dart`**：把 `state.dart` 的 `_fetchBookInfo` 与 `BookInfoCache` 读写搬进来：
   ```dart
   class BookInfoRepository {
     Future<BookInfoData> fetch(String url, {String donationKey = ''});
   }
   ```
   路由（`routeBookDetail`）、缓存读写、错误文案行为保持不变。
3. **`LibraryRepository.deleteWithFile(MyBook book)`**：调用 `deleteFileWithDbData`（`data/services/files.dart`），供 library / book_detail 删除记录 + 文件。
4. **`DownloadCenterPage` / `ResultPage` / `BookInfoPage` 增加可选 VM 构造参数**（测试注入）与 `fromDi`/getIt 默认构造；`main.dart` 给 `DownloadCenterPage(onBrowseSearch: () => _selectTab(1))`。
5. **DI**：注册 `CoverRepository`、`BookInfoRepository`、三个 ViewModel 的 factory（带 query/source 参数时用 `registerFactoryParam` 或页面内 `fromDi` 构造）。

## 共享组件契约（构造注入，去掉 Riverpod）

| 组件 | 新签名要点 |
|---|---|
| `BookInfoCard`（book_card_widget.dart） | 改 `StatefulWidget`；新增 `bool downloaded = false`、`Future<String?> Function(String link)? resolveCover`；缩略图为空且有 resolver 时懒加载封面并 setState |
| `SearchResultCard` | 新增 `bool downloaded = false`、`Future<String?> Function(String)? resolveCover`；去掉 `downloadedBookIdsProvider` |
| `BookInfoWidget` | 新增 `String? annaArchiveBaseUrl`；去掉 `annaArchiveBaseUrlProvider` |
| `ShowDeleteDialog` | 改 `StatelessWidget`；新增 `Future<void> Function(FileName) onDeleteFile` |
| `FileOpenAndDeleteButtons` | 新增 `Future<void> Function(FileName) onDeleteFile` 透传 |

`ActiveDownloadsWidget` 保持 Riverpod（W6 shell 迁移）。

## ViewModel 契约

### ResultsViewModel（`ui/features/results/view_models/results_view_model.dart`）

```dart
ResultsViewModel({required String query, SearchProviderId? source,
  required SearchRepository search, required AppSettings settings,
  required PreferencesRepository preferences, required LibraryRepository library,
  required CoverRepository covers});

// 状态
SearchManagerResult? firstResult; SearchProviderId? selectedSource;
List<BookData> books;                 // 当前视图（全部/单源），含分页
List<BookData> visibleBooks;          // 再套格式/语言本地筛选
List<BookData> allBooks;              // 全部视图，用于 allCount
List<SearchSourceRun> sources;        // result.sources
Set<String> downloadedIds;
Set<String> formatFilters; Set<String> languageFilters;
List<String> availableFormats; List<String> availableLanguages;
String sortValue; bool fetchingNextPage; bool currentViewEnded;
bool forceLocalTimeouts; bool retrying; bool loading; Object? error;
List<SearchProviderId> get enabledSources; List<SearchProviderId> get sourceOrder;

// 命令
Future<void> start();                 // 订阅 search.watch(SearchQuery(...))
Future<void> loadNextPage();          // 分页跟随当前视图，appendPage
void selectSource(SearchProviderId?);
Future<void> retryPageOne();
Future<void> retryIgnoringLocalTimeouts();
Future<void> clearFiltersAndRetry();  // AppSettings.resetSearchFilters + 持久化 + 重订阅
Future<void> setSort(String value);   // AppSettings + 持久化 + 重订阅
void setFormatFilters(Set<String>); void setLanguageFilters(Set<String>);
void clearLocalFilters();
Future<String?> coverFor(String link); bool isDownloaded(String? md5);
@override void dispose();             // 取消订阅
```

`SearchQuery` 仍由 `AppSettings.filters` + author/publisher + filtersEnabled 构造；错误处理与 `initialSearchProvider` 一致（全部源失败才抛错）。

### LibraryViewModel（`ui/features/library/view_models/library_view_model.dart`）

```dart
LibraryViewModel({required LibraryRepository library, required DownloadRepository downloads,
  required PreferencesRepository preferences, required CoverRepository covers});

List<MyBook> books; List<CompletedDownload> completed; List<DownloadTask> active;
int activeCount; int failedCount; bool loading; bool busy;
Future<void> load(); void refresh();
Future<void> pause(String id); Future<void> resume(String id);
void cancel(String id); Future<void> retry(String id);
Future<void> deleteBook(MyBook book);      // 记录 + 文件，然后刷新
Future<String?> coverFor(String? thumbnail, String link);
@override void dispose();                  // 取消 active 流订阅
```

`CompletedDownload`（book + size + modified）从页面移入 VM 文件；完成列表大小/修改时间逻辑原样保留。active 流用 `throttleLatest(..., 100ms)`；有任务从活动转为完成时自动刷新 books/completed。

### BookDetailViewModel（`ui/features/book_detail/view_models/book_detail_view_model.dart`）

```dart
BookDetailViewModel({required String url, String? source, BookData? preview,
  required LibraryRepository library, required DownloadRepository downloads,
  required AppSettings settings, required BookInfoRepository bookInfo,
  required MirrorRepository mirrors});

BookData? book; bool loading; Object? error; bool hasError;
bool? inLibrary; MyBook? libraryBook; String? annaArchiveBaseUrl;
bool showManualButton; String donationKey;

Future<void> load(); void retry();
Future<void> refreshMembership();
sealed DownloadPlan { class DownloadNeedsMirrors(String url); class DownloadStarted(bool fast);
                      class DownloadRefused(String? refusal); }
Future<DownloadPlan> startDownload();               // 完整解析：direct/zlib/welib/donation → target
Future<DownloadPlan> manualDownload();              // mirror 为空 → refused(null)
Future<bool> startWithMirrors(String url, List<String> mirrors);
Future<void> deleteFile(FileName fileName);         // 删除文件+记录并刷新 inLibrary
@override void dispose();
```

解析细节（direct link、Z-Library `resolveBookDownload`、WeLib `resolveDownload`、donation fast link、`chooseDownloadTarget`、`linkRefresher`、Linux 可见 WebView 分支）原样保留在 VM 内。页面只负责 push `Webview`、snackbar 文案与刷新按钮。

## 页面契约

- `ResultPage({..., this.viewModel})`、`DownloadCenterPage({this.viewModel, this.onBrowseSearch})`、`BookInfoPage({..., this.viewModel})`；`initState` 取 `widget.viewModel ?? <Vm>.fromDi(...)`，`dispose` 只释放自建 VM。
- 主体包 `ListenableBuilder`；页面保留滚动控制器、底部弹窗、路由跳转与 l10n。
- 三个 feature 文件内 `ref.` / `ConsumerWidget` / `ConsumerState` 必须为 0。

## 任务拆分（文件所有权互斥，可并行）

- **Task A（results）**：`CoverRepository`、`results_view_model.dart`、`results_page.dart`、`search_result_card.dart`、`book_card_widget.dart`、`results_page_test.dart`、`cover_visibility_test.dart`、`result_row_metrics_test.dart`、`scroll_behavior_test.dart` 中的结果页部分、`test/helpers/results_test_support.dart`（新建）。
- **Task B（library）**：`LibraryRepository.deleteWithFile`、`library_view_model.dart`、`download_center_page.dart`、`mybook_page.dart`、`download_center_page_test.dart`、`test/helpers/library_test_support.dart`。
- **Task C（book_detail）**：`BookInfoRepository`、`book_detail_view_model.dart`、`book_info_page.dart`、`book_info_widget.dart`、`delete_dialog_widget.dart`、`file_buttons_widget.dart`、`book_info_metrics_test.dart`、`book_info_preview_test.dart`、`book_info_selection_test.dart`、`open_in_site_test.dart`、`test/helpers/book_detail_test_support.dart`。
- **Task D（收尾，主 agent）**：`state.dart` 删除已迁移 provider（`searchProvider`、`initialSearchProvider`、`bookInfoProvider`、`myLibraryProvider`、`downloadedBookIdsProvider`、`checkIdExists`、`resultCoverProvider`、`getBookByIdProvider`、`deleteFileFromMyLib`、`completedDownloadsProvider` 等确认无引用后），`main.dart` 接线，`di.dart` 注册，全量 analyze/test，评审，提交。

## 验收

- `grep -rn "ref\." lib/ui/features/{results,library,book_detail} lib/ui/core/components/{book_card_widget,book_info_widget,delete_dialog_widget,file_buttons_widget}.dart` → 0
- `dart analyze lib/ test/` 无问题；`flutter test` 全绿（468 + 新 VM 用例）
- 评审子 agent 复核：流式首屏/回填、分页跟随视图、下载队列与完成刷新、详情下载分支、删除确认流程无行为变化

## Self-Review

- **Spec coverage：** W5 三页 + 其共享组件；结果页收编 `ResultsPager`；`DownloadTask` 构造移出 UI。
- **已知风险：** 详情页下载流程分支多（Linux WebView、zlib/WeLib 刷新），迁移必须逐分支对照；共享组件签名变化会波及 library 页面，三个任务按上表契约对齐。
