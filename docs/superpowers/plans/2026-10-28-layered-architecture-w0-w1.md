# 分层架构迁移 · 第 1 阶段（W0–W1）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不动 UI 与状态管理的前提下，建立 get_it 容器与启动期设置对象，并把数据层迁到 `lib/data/`、拆出模型类。

**Architecture:** 先建立 DI 容器与 `AppSettings`（ChangeNotifier），`main.dart` 双轨启动（get_it 与 Riverpod 并存）；然后把 `lib/services/` 整体搬到 `lib/data/services/`，再把模型类从服务文件中拆到 `lib/data/models/`。全程不改界面、不改行为。

**Tech Stack:** Flutter 3.47.2、Dart >=3.3.0 <4.0.0、get_it、sqflite、Riverpod（本阶段保留）

**Spec:** `docs/superpowers/specs/2026-10-28-flutter-layered-architecture-design.md`

## Global Constraints

- Flutter 固定 3.47.2；Dart SDK `>=3.3.0 <4.0.0`（来自 `pubspec.yaml`）
- 不改变任何 UI 外观、交互与文案
- 不改变下载、镜像、书源协议的既有行为与并发策略
- 不引入 `freezed` / `built_value`
- 每个任务结束必须 `dart analyze lib/ test/` 无问题且 `flutter test` 全绿才提交
- 真实网络用例继续保持 skip，不得为了跑绿把普通单测也 skip
- 提交信息用英文 conventional commits，一次任务一次提交
- 不提交 `android/key.properties`、`*.jks`、keystore、token、cookie
- 不修改 `pubspec.yaml` 的 `version`

## 阶段范围与后续计划

本计划只覆盖 spec 的 W0、W1。原因：W2 的仓库接口依赖 `state.dart` 内部结构，W3 的文件位置决定 W4–W6 的 ViewModel 拆分点；在 W1 落地前写出来只能是猜测。

| 计划文件 | 覆盖 | 前置 |
|---|---|---|
| 本文件 | W0 基础设施、W1 数据层搬家与模型拆分 | 无 |
| `2026-10-28-layered-architecture-w2-repositories.md` | W2 Repository 层 | 本文件完成 |
| `2026-10-28-layered-architecture-w3-ui-layout.md` | W3 UI 目录重排 | W2 完成 |
| `2026-10-28-layered-architecture-w4-search.md` | W4 search ViewModel | W3 完成 |
| `2026-10-28-layered-architecture-w5-results-library.md` | W5 results / library / book_detail | W4 完成 |
| `2026-10-28-layered-architecture-w6-w7-remaining.md` | W6 其余特性、W7 移除 Riverpod | W5 完成 |

---

### Task 1: 引入 get_it，建立 AppSettings

**Files:**
- Modify: `pubspec.yaml`（新增 `get_it`）
- Create: `lib/app/app_settings.dart`
- Test: `test/app_settings_test.dart`
- Modify: `AGENTS.md`（§4 状态管理条款、§1/§7 目录说明）

**Interfaces:**
- Consumes: `PreferencesService.loadSearchFilters()`、`SearchFilters`（已存在）、`MyLibraryDb`
- Produces: `AppSettings`，字段 `themeMode`、`fontSizeScale`、`locale`、`showManualDownloadButton`、`backgroundVerification`、`donationKey`、`userAgent`、`cookie`、`filters`；静态方法 `AppSettings.load({required ThemeMode initialThemeMode, MyLibraryDb? database})`；更新方法 `setThemeMode`、`setFontSizeScale`、`setLocale`、`setShowManualDownloadButton`、`setBackgroundVerification`、`setDonationKey`、`setUserAgent`、`setCookie`、`setFilters`

- [ ] **Step 1: 添加依赖**

```bash
cd /d/OpenlibExtended
flutter pub add get_it
```

预期：`pubspec.yaml` 的 `dependencies` 出现 `get_it: ^x.y.z`，`flutter pub get` 成功。

- [ ] **Step 2: 写失败测试**

创建 `test/app_settings_test.dart`：

```dart
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/services/database.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('app_settings');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  test('load falls back to documented defaults when rows are missing',
      () async {
    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.system);

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.fontSizeScale, 1.0);
    expect(settings.locale, isNull);
    expect(settings.showManualDownloadButton, isTrue);
    expect(settings.backgroundVerification, isTrue);
    expect(settings.donationKey, '');
    expect(settings.userAgent, '');
    expect(settings.cookie, '');
    expect(settings.filters.type, 'All');
    expect(settings.filters.sort, 'Most Relevant');
  });

  test('load reads stored preferences', () async {
    final db = MyLibraryDb.instance;
    await db.savePreference('fontSizeScale', '1.5');
    await db.savePreference('showManualDownloadButton', 0);
    await db.savePreference('backgroundVerification', 0);
    await db.savePreference('donationKey', 'abc');
    await db.savePreference('locale', 'de');
    await db.savePreference('filterType', 'Comic Books');

    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.dark, database: db);

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.fontSizeScale, 1.5);
    expect(settings.showManualDownloadButton, isFalse);
    expect(settings.backgroundVerification, isFalse);
    expect(settings.donationKey, 'abc');
    expect(settings.locale?.languageCode, 'de');
    expect(settings.filters.type, 'Comic Books');
  });

  test('setters update state and notify listeners', () async {
    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.system);
    var notified = 0;
    settings.addListener(() => notified++);

    settings.setThemeMode(ThemeMode.light);
    settings.setThemeMode(ThemeMode.light);

    expect(settings.themeMode, ThemeMode.light);
    expect(notified, 1, reason: 'a no-op update must not notify');
  });
}
```

- [ ] **Step 3: 运行测试确认失败**

```bash
flutter test test/app_settings_test.dart
```

预期：编译失败，`Error: Method not found: 'AppSettings'` / `Target of URI doesn't exist`。

- [ ] **Step 4: 实现 AppSettings**

创建 `lib/app/app_settings.dart`：

```dart
// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/preferences.dart';

/// Startup values that used to be passed as ProviderScope overrides.
/// Pages listen to this instead of receiving a fresh override list.
class AppSettings extends ChangeNotifier {
  AppSettings({
    required this.themeMode,
    required this.fontSizeScale,
    required this.locale,
    required this.showManualDownloadButton,
    required this.backgroundVerification,
    required this.donationKey,
    required this.userAgent,
    required this.cookie,
    required this.filters,
  });

  ThemeMode themeMode;
  double fontSizeScale;
  Locale? locale;
  bool showManualDownloadButton;
  bool backgroundVerification;
  String donationKey;
  String userAgent;
  String cookie;
  SearchFilters filters;

  static Future<AppSettings> load({
    required ThemeMode initialThemeMode,
    MyLibraryDb? database,
  }) async {
    final db = database ?? MyLibraryDb.instance;

    double fontSizeScale = 1.0;
    final fontSize = await _read(db, 'fontSizeScale');
    if (fontSize is num) {
      fontSizeScale = fontSize.toDouble();
    } else if (fontSize is String) {
      fontSizeScale = double.tryParse(fontSize) ?? 1.0;
    }

    final donationKey = await _read(db, 'donationKey');
    final localeCode = await _read(db, 'locale');

    Locale? locale;
    for (final candidate in AppLocalizations.supportedLocales) {
      if (candidate.languageCode == localeCode) locale = candidate;
    }

    return AppSettings(
      themeMode: initialThemeMode,
      fontSizeScale: fontSizeScale,
      locale: locale,
      showManualDownloadButton: await _read(db, 'showManualDownloadButton') != 0,
      backgroundVerification: await _read(db, 'backgroundVerification') != 0,
      donationKey: donationKey is String ? donationKey : '',
      userAgent: await _readBrowserOption(db, 'userAgent'),
      cookie: await _readBrowserOption(db, 'cookie'),
      filters: await PreferencesService(database: db).loadSearchFilters(),
    );
  }

  static Future<dynamic> _read(MyLibraryDb db, String key) async {
    try {
      return await db.getPreference(key);
    } catch (_) {
      return null;
    }
  }

  static Future<String> _readBrowserOption(MyLibraryDb db, String key) async {
    try {
      return await db.getBrowserOptions(key);
    } catch (_) {
      return '';
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void setFontSizeScale(double scale) {
    if (fontSizeScale == scale) return;
    fontSizeScale = scale;
    notifyListeners();
  }

  void setLocale(Locale? value) {
    if (locale == value) return;
    locale = value;
    notifyListeners();
  }

  void setShowManualDownloadButton(bool value) {
    if (showManualDownloadButton == value) return;
    showManualDownloadButton = value;
    notifyListeners();
  }

  void setBackgroundVerification(bool value) {
    if (backgroundVerification == value) return;
    backgroundVerification = value;
    notifyListeners();
  }

  void setDonationKey(String value) {
    if (donationKey == value) return;
    donationKey = value;
    notifyListeners();
  }

  void setUserAgent(String value) {
    if (userAgent == value) return;
    userAgent = value;
    notifyListeners();
  }

  void setCookie(String value) {
    if (cookie == value) return;
    cookie = value;
    notifyListeners();
  }

  void setFilters(SearchFilters value) {
    filters = value;
    notifyListeners();
  }
}
```

注意：`showManualDownloadButton` 与 `backgroundVerification` 的原语义是「缺失或非 0 即为 true」，`null != 0` 在 Dart 中返回 `true`，与现状一致，不要改成 `== 1`。

- [ ] **Step 5: 运行测试确认通过**

```bash
flutter test test/app_settings_test.dart
```

预期：3 个用例全部 PASS。

- [ ] **Step 6: 同步 AGENTS.md**

修改 `AGENTS.md`：

1. §1 目录说明中 `lib/services/`、`lib/state/` 的表述改为：`lib/data/services/`、`lib/app/`（本轮先加 `lib/app/` 与 `lib/data/`，`lib/state/` 在 W7 前仍存在）
2. §4 第一条约束

```markdown
- 不要新增抽象层、状态管理库、网络库或文件存储库；沿用 Riverpod + Dio + sqflite。
```

改为：

```markdown
- 状态管理用 ChangeNotifier + get_it，网络用 Dio，本地存储用 sqflite；不要新增其他状态管理库。
```

3. §7「加设置项」路径里的 `lib/state/state.dart` 改为 `lib/app/app_settings.dart`（迁移完成前的过渡说明可直接替换）

- [ ] **Step 7: 提交**

```bash
git add pubspec.yaml pubspec.lock lib/app/app_settings.dart test/app_settings_test.dart AGENTS.md
git commit -m "feat(app): add get_it and a startup settings object"
```

---

### Task 2: DI 容器

**Files:**
- Create: `lib/app/di.dart`
- Test: `test/di_test.dart`

**Interfaces:**
- Consumes: `AppSettings`（Task 1）、`MyLibraryDb`、`PreferencesService`、`DownloadManager`、`InstanceManager`
- Produces: `Future<void> initDi({required AppSettings settings, MyLibraryDb? database})`、`Future<void> resetDi()`、`final GetIt getIt`

- [ ] **Step 1: 写失败测试**

创建 `test/di_test.dart`：

```dart
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/preferences.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('di');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  tearDown(() async {
    await resetDi();
  });

  Future<AppSettings> settings() =>
      AppSettings.load(initialThemeMode: ThemeMode.system);

  test('registers services as resolvable singletons', () async {
    await initDi(settings: await settings());

    expect(getIt<MyLibraryDb>(), same(MyLibraryDb.instance));
    expect(getIt<PreferencesService>(), same(getIt<PreferencesService>()));
    expect(getIt<DownloadManager>(), same(getIt<DownloadManager>()));
    expect(getIt<AppSettings>(), isA<AppSettings>());
  });

  test('resetDi forgets registrations', () async {
    await initDi(settings: await settings());
    await resetDi();

    expect(() => getIt<AppSettings>(), throwsA(anything));
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
flutter test test/di_test.dart
```

预期：`Target of URI doesn't exist: 'package:openlib/app/di.dart'`。

- [ ] **Step 3: 实现容器**

创建 `lib/app/di.dart`：

```dart
// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/preferences.dart';

final GetIt getIt = GetIt.instance;

/// Single assembly point. Pages resolve view models from here; nothing
/// registers itself on first use.
Future<void> initDi({
  required AppSettings settings,
  MyLibraryDb? database,
}) async {
  final db = database ?? MyLibraryDb.instance;

  if (!getIt.isRegistered<MyLibraryDb>()) {
    getIt.registerSingleton<MyLibraryDb>(db);
  }
  getIt.registerSingleton<AppSettings>(settings);
  getIt.registerLazySingleton<PreferencesService>(
      () => PreferencesService(database: db));
  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
  getIt.registerLazySingleton<InstanceManager>(() => InstanceManager());
}

Future<void> resetDi() => getIt.reset();
```

- [ ] **Step 4: 运行测试确认通过**

```bash
flutter test test/di_test.dart
```

预期：2 个用例 PASS。

- [ ] **Step 5: 提交**

```bash
git add lib/app/di.dart test/di_test.dart
git commit -m "feat(app): add the get_it container"
```

---

### Task 3: main.dart 接入 initDi（双轨启动）

**Files:**
- Modify: `lib/main.dart:61-196`

**Interfaces:**
- Consumes: `AppSettings.load(...)`、`initDi(...)`
- Produces: 无新 API；`ProviderScope` 的启动值改为读 `settings` 字段

- [ ] **Step 1: 改造启动流程**

在 `lib/main.dart` 中：

1. 新增 import：

```dart
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
```

2. 把现有的 `fontSizeScale`、`showManualDownloadButton`、`backgroundVerification`、`browserUserAgent`、`browserCookie`、`savedFilters`、`savedDonationKey`、`startLocale` 计算块替换为：

```dart
  final settings = await AppSettings.load(
    initialThemeMode: startThemeMode,
  );
  await initDi(settings: settings);
```

3. 保留 `WebviewChallengeSolver.headlessEnabled = settings.backgroundVerification;` 这一行，位置移到 `initDi` 之后（原位置在 `backgroundVerification` 计算之后）。

4. `DownloadManager().setLocale(...)` 改为：

```dart
  DownloadManager()
      .setLocale(settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale);
```

5. `ProviderScope` 的 overrides 改为读 `settings`：

```dart
        fontSizeScaleProvider.overrideWith((ref) => settings.fontSizeScale),
        localeOverrideProvider.overrideWith((ref) => settings.locale),
        showManualDownloadButtonProvider
            .overrideWith((ref) => settings.showManualDownloadButton),
        backgroundVerificationProvider
            .overrideWith((ref) => settings.backgroundVerification),
        donationKeyProvider.overrideWith((ref) => settings.donationKey),
        userAgentProvider.overrideWith((ref) => settings.userAgent),
        cookieProvider.overrideWith((ref) => settings.cookie),
        selectedTypeState.overrideWith((ref) => settings.filters.type),
        selectedSortState.overrideWith((ref) => settings.filters.sort),
        selectedFileTypeState.overrideWith((ref) => settings.filters.fileType),
        selectedLanguageState.overrideWith((ref) => settings.filters.language),
        selectedYearState.overrideWith((ref) => settings.filters.year),
```

`themeModeProvider` 保持 `ThemeModeNotifier(settings.themeMode)`。

删除因此不再使用的 import（`preferences.dart` 若仍被其他代码使用则保留；以 `dart analyze` 结果为准）。

- [ ] **Step 2: 静态检查与全量测试**

```bash
dart analyze lib/ test/
flutter test
```

预期：analyze 无问题；测试 439 passed / 18 skipped（数量允许因新增测试而增加，不允许减少或出现失败）。

- [ ] **Step 3: 提交**

```bash
git add lib/main.dart
git commit -m "refactor(app): read startup values from AppSettings"
```

---

### Task 4: 数据层搬家（lib/services → lib/data/services）

**Files:**
- Move: `lib/services/*.dart`（37 个文件）→ `lib/data/services/`
- Modify: 所有 import `package:openlib/services/...` 的文件（lib 与 test）

**Interfaces:**
- Consumes: 无
- Produces: 新的导入前缀 `package:openlib/data/services/`；本任务不改类名与方法签名

- [ ] **Step 1: 移动文件**

```bash
mkdir -p lib/data/services lib/data/models
git mv lib/services/*.dart lib/data/services/
rmdir lib/services
```

预期：`lib/services/` 不再存在；`ls lib/data/services | wc -l` 输出 37。

- [ ] **Step 2: 重写导入前缀**

```bash
grep -rl "package:openlib/services/" lib test | xargs sed -i 's|package:openlib/services/|package:openlib/data/services/|g'
```

预期：`grep -rn "package:openlib/services/" lib test` 无输出。

- [ ] **Step 3: 验证**

```bash
dart analyze lib/ test/
flutter test
```

预期：analyze 无问题；测试全绿。若出现 `Unused import`，按提示删除。

- [ ] **Step 4: 提交**

```bash
git add -A lib test
git status --short
git commit -m "refactor(data): move the service layer under lib/data"
```

注意：提交前用 `git status --short` 确认只包含移动结果与 import 改动，没有混入其他修改。

---

### Task 5: 拆出模型类到 lib/data/models

**Files:**
- Create: `lib/data/models/book_data.dart`
- Create: `lib/data/models/my_book.dart`
- Create: `lib/data/models/search_result.dart`
- Create: `lib/data/models/trending_book_data.dart`
- Modify: `lib/data/services/annas_archieve.dart`、`lib/data/services/database.dart`、`lib/data/services/search_manager.dart`、`lib/data/services/open_library.dart`
- Modify: 所有引用这些模型的 lib 与 test 文件

**Interfaces:**
- Consumes: 无
- Produces:
  - `BookData`、`BookInfoData` 从 `package:openlib/data/models/book_data.dart` 导入
  - `MyBook` 从 `package:openlib/data/models/my_book.dart` 导入
  - `SearchProviderId`、`SearchSourceStatus`、`SearchSourceRun`、`SearchManagerResult` 从 `package:openlib/data/models/search_result.dart` 导入
  - `TrendingBookData` 从 `package:openlib/data/models/trending_book_data.dart` 导入

- [ ] **Step 1: 移动 BookData / BookInfoData**

把 `lib/data/services/annas_archieve.dart` 第 21–96 行（`class BookData` 与 `class BookInfoData`）原样剪切到新文件 `lib/data/models/book_data.dart`，并在新文件顶部加：

```dart
// Project imports:
import 'package:openlib/data/services/book_detail_source.dart';
```

在 `annas_archieve.dart` 顶部加：

```dart
// Project imports:
import 'package:openlib/data/models/book_data.dart';
```

- [ ] **Step 2: 移动 MyBook**

把 `lib/data/services/database.dart` 第 13–76 行（`class MyBook`）剪切到 `lib/data/models/my_book.dart`，新文件顶部：

```dart
// Project imports:
import 'package:openlib/data/services/book_detail_source.dart';
```

在 `database.dart` 顶部加：

```dart
// Project imports:
import 'package:openlib/data/models/my_book.dart';
```

- [ ] **Step 3: 移动搜索结果类型**

把 `lib/data/services/search_manager.dart` 中以下类型剪切到 `lib/data/models/search_result.dart`：

- `enum SearchProviderId`（原第 25 行）
- `enum SearchSourceStatus`（原第 1476–1497 行）
- `class SearchSourceRun`（原第 1498–1514 行）
- `class SearchManagerResult`（原第 1518–1550 行）

新文件顶部：

```dart
// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
```

在 `search_manager.dart` 顶部加：

```dart
// Project imports:
import 'package:openlib/data/models/search_result.dart';
```

注意：行号是搬移前的基准，移动 `BookData`/`MyBook` 不会影响 `search_manager.dart`，但移动本文件内部的类型会改变后续行号，从后往前剪切（1518 → 1498 → 1476 → 25）。

- [ ] **Step 4: 移动 TrendingBookData**

把 `lib/data/services/open_library.dart` 第 8–35 行（`class TrendingBookData`）剪切到 `lib/data/models/trending_book_data.dart`，无额外依赖；在 `open_library.dart` 顶部加：

```dart
// Project imports:
import 'package:openlib/data/models/trending_book_data.dart';
```

- [ ] **Step 5: 运行分析，修复导入**

```bash
dart analyze lib/ test/
```

预期：出现一批 `Undefined class 'BookData'` 之类的错误。对每个报错文件，在项目 import 分组中加入对应模型的 import（`book_data.dart` / `my_book.dart` / `search_result.dart` / `trending_book_data.dart`）。重复直到 analyze 无问题。同时删除不再使用的服务 import（analyze 会报 `Unused import`）。

- [ ] **Step 6: 全量测试**

```bash
flutter test
```

预期：全绿，数量与 Task 4 结束时一致。

- [ ] **Step 7: 提交**

```bash
git add lib test
git commit -m "refactor(data): split models out of the service files"
```

---

### Task 6: 阶段验收

**Files:** 无（只读检查）

- [ ] **Step 1: 结构与依赖检查**

```bash
ls lib/data/services lib/data/models lib/app
grep -rn "package:openlib/services/" lib test    # 预期无输出
grep -rn "import.*\.\./ui/\|import.*\.\./app/" lib/data   # 预期无输出
```

- [ ] **Step 2: 全量验证**

```bash
dart analyze lib/ test/
flutter test
```

- [ ] **Step 3: 记录结果**

把「测试通过数 / 跳过数」和「是否有未实机验证的改动」写进交付说明。本阶段没有 UI 改动，不需要实机验证。

---

## Self-Review

- **Spec coverage：** W0（Task 1–3）、W1（Task 4–5）、AGENTS.md 同步（Task 1 Step 6）、验收（Task 6）。W2–W7 由后续计划覆盖，已在「阶段范围与后续计划」中列明。
- **Placeholder scan：** 无 TBD/TODO；所有代码步骤给出完整代码；移动类步骤给出文件与行号基准。
- **Type consistency：** `AppSettings.load` 的签名在 Task 1 定义、Task 2/3 使用一致；`initDi` 的签名在 Task 2 定义、Task 3 使用一致；模型导入路径在 Task 5 四个子步骤中一致。
