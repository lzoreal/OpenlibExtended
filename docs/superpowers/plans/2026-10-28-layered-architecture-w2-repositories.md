# 分层架构迁移 · 第 2 阶段（W2 Repository 层）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `lib/data/repositories/` 建五个仓库，让 Riverpod provider 与现有 UI 的底层数据访问统一经过仓库，并清掉 W0–W1 遗留的装配问题。

**Architecture:** 仓库是服务之上的薄封装，构造函数注入服务（默认取现有单例），由 `lib/app/di.dart` 注册为 lazySingleton，`lib/state/repository_providers.dart` 把它们暴露成 Riverpod provider。页面在这一阶段仍用 Riverpod，只换底层调用点。

**Tech Stack:** Flutter 3.47.2、Dart >=3.3.0 <4.0.0、get_it、Riverpod（本阶段保留）、sqflite

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md`

## Global Constraints

- Flutter 固定 3.47.2；Dart SDK `>=3.3.0 <4.0.0`
- 不改变任何 UI 外观、交互与文案；不改下载/镜像/书源协议行为
- 不引入新依赖（get_it 已在 W0 加入）；不用 freezed/built_value
- 每任务结束 `dart analyze lib/ test/` 无问题且 `flutter test` 全绿再提交
- 真实网络用例保持 skip；不为跑绿而 skip 普通单测
- 提交信息英文 conventional commits；一次任务一次提交
- 不提交密钥；不改 `pubspec.yaml` 的 `version`
- 工作目录：`D:/OpenlibExtended/.worktrees/refactor-layered-architecture`（分支 `refactor/layered-architecture`）

## 当前基线

- `flutter test` = 445 passed / 18 skipped；`dart analyze lib/ test/` 无问题
- `lib/services/` 已不存在；服务在 `lib/data/services/`，模型在 `lib/data/models/`
- `AppSettings`（ChangeNotifier）在 `lib/app/app_settings.dart`，`initDi` 在 `lib/app/di.dart`
- 现有 `PreferencesService` 位于 `lib/data/services/preferences.dart`（本阶段升级为仓库）

---

### Task 1: 收尾 W0–W1 的装配问题

**Files:**
- Modify: `lib/app/app_settings.dart`、`lib/app/di.dart`、`lib/main.dart`
- Modify: `HANDOVER.md`（两处表述）
- Test: `test/app_settings_test.dart`、`test/di_test.dart`

**Interfaces:**
- Consumes: `PreferencesService`（即将在 Task 2 改名，本任务先按现名注入）
- Produces:
  - `AppSettings.load({required ThemeMode initialThemeMode, required PreferencesService preferences})`（新增必填 `preferences`）
  - `initDi({required AppSettings settings, required MyLibraryDb database, required PreferencesService preferences})`
  - `initDi` 第二次调用抛 `StateError('initDi called twice')`
  - 移除 `InstanceManager` 注册（W2 由 `MirrorRepository` 承担，见 Task 6）

- [ ] **Step 1: 改测试，先红**

在 `test/app_settings_test.dart` 中，把三处 `AppSettings.load(...)` 改成传入仓库实例：

```dart
final preferences = PreferencesService(database: MyLibraryDb.instance);
final settings = await AppSettings.load(
  initialThemeMode: ThemeMode.system,
  preferences: preferences,
);
```

在 `test/di_test.dart` 的两处 `initDi(...)` 改为：

```dart
final preferences = PreferencesService(database: MyLibraryDb.instance);
await initDi(
  settings: s,
  database: MyLibraryDb.instance,
  preferences: preferences,
);
```

并新增一个测试：

```dart
test('a second initDi throws instead of silently keeping stale state', () async {
  final preferences = PreferencesService(database: MyLibraryDb.instance);
  await initDi(
    settings: await settings(),
    database: MyLibraryDb.instance,
    preferences: preferences,
  );

  expect(
    () => initDi(
      settings: AppSettings(
        themeMode: ThemeMode.light,
        fontSizeScale: 1,
        locale: null,
        showManualDownloadButton: true,
        backgroundVerification: true,
        donationKey: '',
        userAgent: '',
        cookie: '',
        filters: const SearchFilters(),
      ),
      database: MyLibraryDb.instance,
      preferences: preferences,
    ),
    throwsA(isA<StateError>()),
  );
});
```

- [ ] **Step 2: 跑测试确认失败**

```bash
flutter test test/app_settings_test.dart test/di_test.dart
```

预期：编译错误 `required named parameter 'preferences' is not defined`。

- [ ] **Step 3: 实现**

`lib/app/app_settings.dart`：`load` 改为

```dart
  static Future<AppSettings> load({
    required ThemeMode initialThemeMode,
    required PreferencesService preferences,
  }) async {
    final db = preferences.database;
    final filters = await preferences.loadSearchFilters();
    // ...其余读取保持不变，只是 filters 复用同一仓库...
  }
```

需要在 `PreferencesService` 上加 getter：

```dart
  MyLibraryDb get database => _database;
```

`lib/main.dart`：

```dart
  final preferences = PreferencesService(database: dataBase);
  final settings = await AppSettings.load(
    initialThemeMode: startThemeMode,
    preferences: preferences,
  );
  await initDi(
    settings: settings,
    database: dataBase,
    preferences: preferences,
  );
```

`lib/app/di.dart`：

```dart
Future<void> initDi({
  required AppSettings settings,
  required MyLibraryDb database,
  required PreferencesService preferences,
}) async {
  if (getIt.isRegistered<AppSettings>()) {
    throw StateError('initDi called twice');
  }
  getIt.registerSingleton<MyLibraryDb>(database);
  getIt.registerSingleton<AppSettings>(settings);
  getIt.registerLazySingleton<PreferencesService>(() => preferences);
  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
}
```

删除 `instance_manager.dart` import 与 `InstanceManager` 注册。`di.dart` 顶部注释改为一句 why：`// Called once from main(); a second call is a startup bug, not a reuse path.`

- [ ] **Step 4: 更新 HANDOVER 两处**

- §4.2 第 4 步：改为「`ThemeModeNotifier.getInitialTheme()` 读主题，`AppSettings.load` 读其余偏好（经 `PreferencesRepository`）」
- §11「新增一个设置项」：在现有步骤后补一句「迁移期仍需在 `lib/state/state.dart` 定义 `StateProvider`，并在 `main.dart` 的 `ProviderScope` overrides 中接线；W6 后改由 SettingsViewModel 回写 `AppSettings`」

- [ ] **Step 5: 验证并提交**

```bash
dart analyze lib/ test/ && flutter test
git add lib/app lib/main.dart test/app_settings_test.dart test/di_test.dart HANDOVER.md
git commit -m "refactor(app): inject the preference store into AppSettings"
```

预期：446 passed / 18 skipped（原 445 + 新增 1）。

---

### Task 2: PreferencesRepository + 模型外移

**Files:**
- Move: `lib/data/services/preferences.dart` → `lib/data/repositories/preferences_repository.dart`
- Create: `lib/data/models/search_filters.dart`（`SearchFilterKind`、`SearchFilters` 原样搬入）
- Test: `test/preferences_service_test.dart` → `test/preferences_repository_test.dart`
- Modify: 所有引用 `PreferencesService`/`SearchFilters` 的文件（`lib/app/*`、`lib/ui/*`、`lib/main.dart`、测试）

**Interfaces:**
- Consumes: `MyLibraryDb`
- Produces: `PreferencesRepository({MyLibraryDb? database})`，方法 `loadSearchFilters()`、`saveSearchFilter(SearchFilterKind, String)`、`resetSearchFilters()`、`bookStorageDirectory()`、`MyLibraryDb get database`；模型从 `package:openlib/data/models/search_filters.dart` 导入

- [ ] **Step 1: 移动并改名**

```bash
git mv lib/data/services/preferences.dart lib/data/repositories/preferences_repository.dart
git mv test/preferences_service_test.dart test/preferences_repository_test.dart
grep -rl "PreferencesService" lib test | xargs sed -i 's/PreferencesService/PreferencesRepository/g'
grep -rl "services/preferences.dart" lib test | xargs sed -i 's|services/preferences.dart|repositories/preferences_repository.dart|g'
```

`mkdir -p lib/data/repositories` 若不存在先建。把 `SearchFilterKind` 与 `SearchFilters` 从仓库文件剪到 `lib/data/models/search_filters.dart`，仓库文件与所有使用者加 import：

```bash
grep -rl "SearchFilters\|SearchFilterKind" lib test | xargs -I{} sh -c "grep -q 'data/models/search_filters.dart' {} || sed -i \"/^\/\/ Project imports:/a import 'package:openlib/data/models/search_filters.dart';\" {}"
# 上一条会给模型文件自身插入自引用 import，删掉它
sed -i "/data\/models\/search_filters.dart/d" lib/data/models/search_filters.dart
```

- [ ] **Step 2: 跑测试确认仍绿**

```bash
dart analyze lib/ test/ && flutter test
```

预期：446 passed / 18 skipped。若出现 unused import 按提示删除。

- [ ] **Step 3: 提交**

```bash
git add -A lib test
git commit -m "refactor(data): promote preferences to a repository and move its models"
```

---

### Task 3: LibraryRepository

**Files:**
- Create: `lib/data/repositories/library_repository.dart`
- Create: `lib/state/repository_providers.dart`
- Modify: `lib/app/di.dart`、`lib/state/state.dart`（`myLibraryProvider`、`checkIdExists`、`getBookByIdProvider`）
- Test: `test/library_repository_test.dart`

**Interfaces:**
- Consumes: `MyLibraryDb`
- Produces:
  - `LibraryRepository({MyLibraryDb? database})`
  - `Future<List<MyBook>> allBooks()`
  - `Future<MyBook?> bookById(String id)`
  - `Future<bool> contains(String id)`
  - `Future<void> insert(MyBook book)`
  - `Future<void> deleteBook(String id)`
  - `final libraryRepositoryProvider = Provider<LibraryRepository>((ref) => getIt<LibraryRepository>());`

- [ ] **Step 1: 写失败测试**

```dart
// test/library_repository_test.dart
// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/services/database.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('library_repository');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  MyBook book(String id) => MyBook(
        id: id,
        title: 'Title $id',
        author: 'Author',
        thumbnail: '',
        link: '',
        publisher: '',
        info: '',
        format: 'epub',
        description: '',
      );

  test('insert, contains, bookById and deleteBook round-trip', () async {
    final repository = LibraryRepository();
    await repository.deleteBook('lib-repo-1');

    expect(await repository.contains('lib-repo-1'), isFalse);

    await repository.insert(book('lib-repo-1'));

    expect(await repository.contains('lib-repo-1'), isTrue);
    expect((await repository.bookById('lib-repo-1'))?.title, 'Title lib-repo-1');
    expect(
      (await repository.allBooks()).map((b) => b.id),
      contains('lib-repo-1'),
    );

    await repository.deleteBook('lib-repo-1');
    expect(await repository.contains('lib-repo-1'), isFalse);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

```bash
flutter test test/library_repository_test.dart
```

预期：`Target of URI doesn't exist: 'package:openlib/data/repositories/library_repository.dart'`。

- [ ] **Step 3: 实现**

```dart
// lib/data/repositories/library_repository.dart
// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/database.dart';

class LibraryRepository {
  LibraryRepository({MyLibraryDb? database})
      : _database = database ?? MyLibraryDb.instance;

  final MyLibraryDb _database;

  Future<List<MyBook>> allBooks() => _database.getAll();

  Future<MyBook?> bookById(String id) => _database.getId(id);

  Future<bool> contains(String id) => _database.checkIdExists(id);

  Future<void> insert(MyBook book) => _database.insert(book);

  Future<void> deleteBook(String id) => _database.delete(id);
}
```

`lib/state/repository_providers.dart`：

```dart
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/library_repository.dart';

final libraryRepositoryProvider =
    Provider<LibraryRepository>((ref) => getIt<LibraryRepository>());
```

`lib/app/di.dart` 增加注册：

```dart
  getIt.registerLazySingleton<LibraryRepository>(
      () => LibraryRepository(database: getIt<MyLibraryDb>()));
```

`lib/state/state.dart` 改三个 provider：

```dart
final myLibraryProvider = FutureProvider((ref) async {
  return ref.watch(libraryRepositoryProvider).allBooks();
});

final checkIdExists =
    FutureProvider.family.autoDispose<bool, String>((ref, id) async {
  return ref.watch(libraryRepositoryProvider).contains(id);
});

final getBookByIdProvider =
    FutureProvider.family.autoDispose<MyBook?, String>((ref, id) async {
  return ref.watch(libraryRepositoryProvider).bookById(id);
});
```

- [ ] **Step 4: 跑测试与静态检查**

```bash
dart analyze lib/ test/ && flutter test
```

预期：447 passed / 18 skipped。

- [ ] **Step 5: 提交**

```bash
git add lib/data/repositories/library_repository.dart lib/state/repository_providers.dart lib/state/state.dart lib/app/di.dart test/library_repository_test.dart
git commit -m "feat(data): add LibraryRepository behind the library providers"
```

---

### Task 4: SearchRepository

**Files:**
- Create: `lib/data/repositories/search_repository.dart`
- Modify: `lib/app/di.dart`、`lib/state/repository_providers.dart`、`lib/state/state.dart`（`searchProvider`、`initialSearchProvider`、`searchProviderToggles`、`searchSourceOrderProvider`）、`lib/ui/settings_page.dart`（源排序/开关）、`lib/ui/whats_new_page.dart`
- Test: `test/search_repository_test.dart`

**Interfaces:**
- Consumes: `SearchManager`, `SearchQuery`, `SearchManagerResult`, `SearchProviderId`
- Produces:
  - `SearchRepository({SearchManager? manager})`
  - `Future<SearchManagerResult> search(SearchQuery query, {bool forceLocalTimeouts = false})`
  - `Stream<SearchManagerResult> watch(SearchQuery query, {bool forceLocalTimeouts = false})`
  - `Future<Set<SearchProviderId>> enabledProviders()`
  - `Future<void> setProviderEnabled(SearchProviderId id, bool enabled)`
  - `Future<void> enableAllProviders()`
  - `Future<List<SearchProviderId>> sourceOrder()`
  - `Future<void> setSourceOrder(List<SearchProviderId> order)`
  - `final searchRepositoryProvider = Provider<SearchRepository>((ref) => getIt<SearchRepository>());`

- [ ] **Step 1: 写失败测试（用假 provider 走真实 SearchManager）**

```dart
// test/search_repository_test.dart
// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/search_manager.dart';

import 'helpers/fake_path_provider.dart';

class _FakeProvider implements SearchProvider {
  _FakeProvider(this.id, this.books, {this.failure});
  @override
  final SearchProviderId id;
  @override
  String get displayName => id.name;
  final List<BookData> books;
  final Object? failure;

  @override
  Future<List<BookData>> search(SearchQuery query) async {
    if (failure != null) throw failure!;
    return books;
  }
}

BookData _book(String md5) => BookData(
      title: md5,
      link: 'https://example.com/$md5',
      md5: md5,
    );

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('search_repository');
  });

  test('search merges sources and reports the failing one', () async {
    final repository = SearchRepository(
      manager: SearchManager(providers: [
        _FakeProvider(SearchProviderId.libgen, [_book('a')]),
        _FakeProvider(SearchProviderId.zlibrary, [_book('b')]),
        _FakeProvider(SearchProviderId.welib, const [],
            failure: Exception('boom')),
      ]),
    );

    final result = await repository.search(const SearchQuery(text: 'docker'));

    expect(result.books.map((b) => b.md5), containsAll(['a', 'b']));
    expect(result.failedProviders, contains('welib'));
  });

  test('watch emits the merged page', () async {
    final repository = SearchRepository(
      manager: SearchManager(providers: [
        _FakeProvider(SearchProviderId.libgen, [_book('a')]),
      ]),
    );

    final result =
        await repository.watch(const SearchQuery(text: 'docker')).first;

    expect(result.books.map((b) => b.md5), ['a']);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

```bash
flutter test test/search_repository_test.dart
```

预期：URI 不存在。

- [ ] **Step 3: 实现**

```dart
// lib/data/repositories/search_repository.dart
// Project imports:
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/services/search_manager.dart';

class SearchRepository {
  SearchRepository({SearchManager? manager})
      : _manager = manager ?? SearchManager();

  final SearchManager _manager;

  Future<SearchManagerResult> search(SearchQuery query,
          {bool forceLocalTimeouts = false}) =>
      _manager.search(query, forceLocalTimeouts: forceLocalTimeouts);

  Stream<SearchManagerResult> watch(SearchQuery query,
          {bool forceLocalTimeouts = false}) =>
      _manager.watch(query, forceLocalTimeouts: forceLocalTimeouts);

  Future<Set<SearchProviderId>> enabledProviders() =>
      _manager.enabledProviders();

  Future<void> setProviderEnabled(SearchProviderId id, bool enabled) =>
      _manager.setProviderEnabled(id, enabled);

  Future<void> enableAllProviders() => _manager.enableAllProviders();

  Future<List<SearchProviderId>> sourceOrder() => _manager.sourceOrder();

  Future<void> setSourceOrder(List<SearchProviderId> order) =>
      _manager.setSourceOrder(order);
}
```

注册与测试 provider（`repository_providers.dart`）：

```dart
final searchRepositoryProvider =
    Provider<SearchRepository>((ref) => getIt<SearchRepository>());
```

`di.dart`：

```dart
  getIt.registerLazySingleton<SearchRepository>(() => SearchRepository());
```

`lib/state/state.dart` 四处替换：
- `searchProvider`：`final manager = SearchManager();` 删掉；用 `final repository = ref.watch(searchRepositoryProvider);`，随后 `await repository.enabledProviders()` 与 `repository.search(...)`
- `initialSearchProvider`：`SearchManager().watch(...)` → `ref.watch(searchRepositoryProvider).watch(...)`
- `searchProviderToggles`：`SearchManager().enabledProviders()` → `ref.watch(searchRepositoryProvider).enabledProviders()`
- `searchSourceOrderProvider`：同上改 `sourceOrder()`

`lib/ui/settings_page.dart:756` 的 `SearchManager()` 与 `:790/:821` 改为从 `ref.read(searchRepositoryProvider)` 调用；`lib/ui/whats_new_page.dart:70` 的 `SearchManager().enableAllProviders()` 同样改。

- [ ] **Step 4: 验证**

```bash
dart analyze lib/ test/ && flutter test
```

预期：449 passed / 18 skipped。

- [ ] **Step 5: 提交**

```bash
git add lib/data/repositories/search_repository.dart lib/state lib/ui/settings_page.dart lib/ui/whats_new_page.dart lib/app/di.dart test/search_repository_test.dart
git commit -m "feat(data): add SearchRepository and route search providers through it"
```

---

### Task 5: DownloadRepository

**Files:**
- Create: `lib/data/repositories/download_repository.dart`
- Modify: `lib/app/di.dart`、`lib/state/repository_providers.dart`、`lib/state/state.dart`（`downloadManagerProvider`、`activeDownloadsProvider`）、`lib/ui/download_center_page.dart`、`lib/ui/book_info_page.dart`、`lib/ui/settings_page.dart`（`setLocale`）
- Test: `test/download_repository_test.dart`

**Interfaces:**
- Consumes: `DownloadManager`、`DownloadTask`、`DownloadStatus`
- Produces:
  - `DownloadRepository({DownloadManager? manager})`
  - `Stream<Map<String, DownloadTask>> get updates`
  - `Map<String, DownloadTask> get active`
  - `Future<void> add(DownloadTask task)`
  - `Future<void> addWithMirrorUrl(DownloadTask task, String mirrorUrl)`
  - `Future<void> pause(String taskId)` / `resume(String taskId)` / `pauseAll()` / `resumeAll()` / `retry(String taskId)` / `restartWithMirrors(String taskId, List<String> mirrors)` / `retryKeepingPartial(String taskId)`
  - `void cancel(String taskId)` / `void remove(String taskId)`
  - `void setLocale(Locale locale)`
  - `Future<void> initialize()`
  - `final downloadRepositoryProvider = Provider<DownloadRepository>((ref) => getIt<DownloadRepository>());`

- [ ] **Step 1: 写失败测试（真实单例、空队列）**

```dart
// test/download_repository_test.dart
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Project imports:
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/services/download_manager.dart';

void main() {
  test('an untouched queue is empty and unknown ids are ignored', () {
    final repository = DownloadRepository();

    expect(repository.active, isEmpty);
    repository.cancel('no-such-task');
    repository.remove('no-such-task');
    repository.setLocale(const Locale('en'));

    expect(repository.active, isEmpty);
  });

  test('updates forwards the manager stream', () {
    final repository = DownloadRepository();

    expect(repository.updates, isA<Stream<Map<String, DownloadTask>>>());
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

```bash
flutter test test/download_repository_test.dart
```

- [ ] **Step 3: 实现**

```dart
// lib/data/repositories/download_repository.dart
// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/data/services/download_manager.dart';

class DownloadRepository {
  DownloadRepository({DownloadManager? manager})
      : _manager = manager ?? DownloadManager();

  final DownloadManager _manager;

  Stream<Map<String, DownloadTask>> get updates => _manager.downloadsStream;

  Map<String, DownloadTask> get active => _manager.activeDownloads;

  Future<void> initialize() => _manager.initialize();

  void setLocale(Locale locale) => _manager.setLocale(locale);

  Future<void> add(DownloadTask task) => _manager.addDownload(task);

  Future<void> addWithMirrorUrl(DownloadTask task, String mirrorUrl) =>
      _manager.addDownloadWithMirrorUrl(task, mirrorUrl);

  Future<void> pause(String taskId) => _manager.pauseDownload(taskId);

  Future<void> resume(String taskId) => _manager.resumeDownload(taskId);

  Future<void> pauseAll() => _manager.pauseAll();

  Future<void> resumeAll() => _manager.resumeAll();

  Future<void> retry(String taskId) => _manager.retryDownload(taskId);

  Future<void> restartWithMirrors(String taskId, List<String> mirrors) =>
      _manager.restartDownloadWithMirrors(taskId, mirrors);

  Future<void> retryKeepingPartial(String taskId) =>
      _manager.retryDownloadKeepingPartial(taskId);

  void cancel(String taskId) => _manager.cancelDownload(taskId);

  void remove(String taskId) => _manager.removeDownload(taskId);
}
```

注册 + provider 同前两个任务。`state.dart`：

```dart
final downloadRepositoryProvider... // 在 repository_providers.dart

final downloadManagerProvider = Provider<DownloadRepository>((ref) {
  return ref.watch(downloadRepositoryProvider);
});

final activeDownloadsProvider =
    StreamProvider<Map<String, DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return throttleLatest(
    repository.updates,
    const Duration(milliseconds: 100),
  );
});
```

调用点替换（保持签名不变，只换对象）：
- `lib/ui/book_info_page.dart`：`DownloadManager()` → `ref.read(downloadRepositoryProvider)`，方法名 `addDownload`→`add`、`addDownloadWithMirrorUrl`→`addWithMirrorUrl`
- `lib/ui/download_center_page.dart`：`DownloadManager()` 的 `activeDownloads`→`active`，`pauseDownload`→`pause`、`resumeDownload`→`resume`、`cancelDownload`→`cancel`、`retryDownloadKeepingPartial`→`retryKeepingPartial`、`restartDownloadWithMirrors`→`restartWithMirrors`
- `lib/ui/settings_page.dart:1241` 的 `downloadManagerProvider.setLocale(...)` 保持不变（provider 类型变了，方法名相同）
- `lib/main.dart`：`DownloadManager().initialize()` 保持在原位（组合根允许直接用服务）；`DownloadManager().setLocale(...)` 改为 `getIt<DownloadRepository>().setLocale(...)`，调用点在 `initDi` 之后

- [ ] **Step 4: 验证**

```bash
dart analyze lib/ test/ && flutter test
```

预期：451 passed / 18 skipped。

- [ ] **Step 5: 提交**

```bash
git add lib/data/repositories/download_repository.dart lib/state lib/ui lib/main.dart lib/app/di.dart test/download_repository_test.dart
git commit -m "feat(data): add DownloadRepository and route the queue UI through it"
```

---

### Task 6: MirrorRepository

**Files:**
- Create: `lib/data/repositories/mirror_repository.dart`
- Modify: `lib/app/di.dart`、`lib/state/repository_providers.dart`、`lib/state/state.dart`（`instanceManagerProvider`、`serviceInstancesProvider`、`mirrorLatencyProvider`、`annaArchiveBaseUrlProvider`）、`lib/ui/instances_page.dart`、`lib/ui/search_page.dart`、`lib/ui/whats_new_page.dart`
- Test: `test/mirror_repository_test.dart`

**Interfaces:**
- Consumes: `InstanceManager`（含 `InstanceManager.forTest`）、`MirrorLatencyTester`、`MirrorService`、`InstanceView`、`MirrorLatencyReading`
- Produces:
  - `MirrorRepository({InstanceManager? manager, MirrorLatencyTester? tester})`
  - `Future<List<InstanceView>> instances(MirrorService service, {bool force = false})`
  - `Future<List<String>> enabledUrls(MirrorService service, {bool force = false, bool headlessOnly = false})`
  - `Future<bool> isAutoMode()` / `Future<void> setAutoMode(bool)`
  - `Future<void> setEnabled(MirrorService, String host, bool enabled)`
  - `Future<void> move(MirrorService, String host, int delta)`
  - `Future<MirrorRefreshResult> refresh()` / `Future<void> refreshOnStartup()`
  - `Future<Map<String, MirrorLatencyReading>> localLatencies()`
  - `Future<void> saveLocalLatencies(Map<String, int?> results, {DateTime? testedAt})`
  - `Future<Map<String, int?>> measureLatency(Iterable<String> urls)`
  - `final mirrorRepositoryProvider = Provider<MirrorRepository>((ref) => getIt<MirrorRepository>());`

- [ ] **Step 1: 写失败测试（用 forTest 注入假目录）**

```dart
// test/mirror_repository_test.dart
// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Project imports:
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('mirror_repository');
  });

  test('delegates latency persistence to the manager', () async {
    final repository = MirrorRepository(manager: InstanceManager.forTest());
    final testedAt = DateTime(2026, 10, 28, 12);

    await repository.saveLocalLatencies(
      {'https://example.com': 120, 'https://slow.example.com': null},
      testedAt: testedAt,
    );

    final readings = await repository.localLatencies();
    expect(readings['https://example.com']?.milliseconds, 120);
    expect(readings['https://example.com']?.testedAt, testedAt);
    expect(readings['https://slow.example.com']?.isReachable, isFalse);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

```bash
flutter test test/mirror_repository_test.dart
```

- [ ] **Step 3: 实现**

```dart
// lib/data/repositories/mirror_repository.dart
// Project imports:
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';

class MirrorRepository {
  MirrorRepository({InstanceManager? manager, MirrorLatencyTester? tester})
      : _manager = manager ?? InstanceManager(),
        _tester = tester ?? const MirrorLatencyTester();

  final InstanceManager _manager;
  final MirrorLatencyTester _tester;

  Future<List<InstanceView>> instances(MirrorService service,
          {bool force = false}) =>
      _manager.instances(service, force: force);

  Future<List<String>> enabledUrls(MirrorService service,
          {bool force = false, bool headlessOnly = false}) =>
      _manager.enabledUrls(service,
          force: force, headlessOnly: headlessOnly);

  Future<bool> isAutoMode() => _manager.isAutoMode();

  Future<void> setAutoMode(bool auto) => _manager.setAutoMode(auto);

  Future<void> setEnabled(MirrorService service, String host, bool enabled) =>
      _manager.setEnabled(service, host, enabled);

  Future<void> move(MirrorService service, String host, int delta) =>
      _manager.move(service, host, delta);

  Future<MirrorRefreshResult> refresh() => _manager.refresh();

  Future<void> refreshOnStartup() => _manager.refreshOnStartup();

  Future<Map<String, MirrorLatencyReading>> localLatencies() =>
      _manager.localLatencies();

  Future<void> saveLocalLatencies(Map<String, int?> results,
          {DateTime? testedAt}) =>
      _manager.saveLocalLatencies(results, testedAt: testedAt);

  Future<Map<String, int?>> measureLatency(Iterable<String> urls) =>
      _tester.measure(urls);
}
```

`state.dart`：
- `instanceManagerProvider` → 改名为 `mirrorRepositoryProvider`（从 `repository_providers.dart` 导入），类型 `MirrorRepository`
- `serviceInstancesProvider` → `ref.watch(mirrorRepositoryProvider).instances(service)`
- `annaArchiveBaseUrlProvider` → `enabledUrls(...)`
- `mirrorLatencyProvider` → `MirrorLatencyNotifier(ref.watch(mirrorRepositoryProvider), ...)`；`MirrorLatencyNotifier` 的构造参数 `InstanceManager` 改为 `MirrorRepository`，内部 `localLatencies/saveLocalLatencies/measureLatency` 改调仓库方法（`test(views)` 里用 `repository.measureLatency(urls)`）

UI 调用点：`instances_page.dart`（`isAutoMode/refresh/setAutoMode/setEnabled/move`）、`search_page.dart`（`instances`）、`whats_new_page.dart`（`refresh`）把 `instanceManagerProvider` 改为 `mirrorRepositoryProvider`；方法名已对齐，无需逐个改名。

`di.dart` 注册：

```dart
  getIt.registerLazySingleton<MirrorRepository>(() => MirrorRepository());
```

- [ ] **Step 4: 验证**

```bash
dart analyze lib/ test/ && flutter test
```

预期：452 passed / 18 skipped。

- [ ] **Step 5: 提交**

```bash
git add lib/data/repositories/mirror_repository.dart lib/state lib/ui lib/app/di.dart test/mirror_repository_test.dart
git commit -m "feat(data): add MirrorRepository behind the mirror providers"
```

---

### Task 7: 阶段验收

**Files:** 无（只读检查 + 文档补记）

- [ ] **Step 1: 依赖方向检查**

```bash
grep -rn "data/services" lib/ui | grep -v "open_book" || echo "no direct service use in ui"
grep -rnE "^import .*\.\./(ui|app)/" lib/data || echo "data does not import ui/app"
grep -rn "SearchManager()" lib | grep -v repositories || echo "only the repository builds SearchManager"
grep -rn "DownloadManager()" lib | grep -v repositories || echo "only the repository builds DownloadManager"
```

- [ ] **Step 2: 全量验证**

```bash
dart analyze lib/ test/ && flutter test
```

- [ ] **Step 3: 记录结果**

把测试总数、仍直接访问服务的 UI 文件、以及未实机验证的项目写进交付说明。

---

## Self-Review

- **Spec coverage：** W2 的五个仓库（Task 2 Preferences、Task 3 Library、Task 4 Search、Task 5 Download、Task 6 Mirror）、仓库单测、provider 改走仓库、文档同步（Task 1）。W0–W1 审查遗留的四项（AppSettings 注入、initDi 语义、InstanceManager 缝隙→由 MirrorRepository 替代、HANDOVER 表述）落在 Task 1。
- **Placeholder scan：** 每个代码步骤给出完整实现与测试；UI 替换点给到文件与旧方法名。
- **Type consistency：** 仓库方法名在「Produced 接口」与调用点替换表中一致（`add`/`pause`/`resume`/`restartWithMirrors`/`retryKeepingPartial`；`instances`/`enabledUrls`/`measureLatency`）；provider 名 `libraryRepositoryProvider`/`searchRepositoryProvider`/`downloadRepositoryProvider`/`mirrorRepositoryProvider` 在各任务中一致。
- **已知风险：** `book_info_page` 的 `DownloadTask` 构造仍留在 UI（W5 处理）；`completedDownloadsProvider` 仍在 `download_center_page`（W5 移入 LibraryRepository）。
