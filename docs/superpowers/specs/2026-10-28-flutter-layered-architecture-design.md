# OpenlibExtended 分层架构重构设计

- 日期：2026-10-28
- 状态：已确认，待实施
- 范围：`lib/` 全量结构重组 + 状态管理从 Riverpod 迁移到 ChangeNotifier + get_it

## 1. 背景

`lib/` 现有 90 个 Dart 文件（含 6 个 l10n 生成物）、约 2.9 万行（不含 l10n）。分层现状：

- `lib/services/` 37 个文件，是事实上的数据层，且**没有任何文件 import ui/ 或 state/**，依赖方向健康
- `lib/state/state.dart`（740 行、44 个 provider）承担全局状态与视图模型
- `lib/ui/` 30+ 文件，其中 4 个巨型页面承载业务逻辑（行数为本轮重构前）：
  `results_page.dart`（2140 行）、`settings_page.dart`（1864 行）、`download_center_page.dart`（1830 行）、`search_page.dart`（1817 行）

已完成的先行改进（本次重构的前置条件）：
`PreferencesService`、`ResultsPager`、`book_import`、`storage_permission`、`open_book` 已抽出并有单测。

Riverpod 使用面（迁移成本基线）：42 个文件 import、44 个 provider、226 处 `ref.*`、19 个测试文件使用 `ProviderScope`、76 处 `Consumer*`。

## 2. 目标与非目标

### 目标

1. 目录按 `data/`、`domain/`、`ui/features/` 组织
2. View 只负责渲染；业务状态与命令进入 ViewModel
3. 数据访问经 Repository 收口
4. 最终移除 `flutter_riverpod`，统一为 ChangeNotifier + get_it
5. 过程中每一波都可独立提交、独立回退

### 非目标（明确不做）

- 不改变任何 UI 外观、交互与文案
- 不引入 `freezed` / `built_value`：现有模型已是不变类，codegen 成本不值
- 不复制 domain 模型：`BookData`、`MyBook` 等直接作为 domain 模型使用
- 不建 `use_cases/`：当前没有跨 ViewModel 复用的复杂规则
- 不改下载、镜像、书源协议的既有行为与并发策略

## 3. 目标结构

```text
lib/
├── app/
│   ├── di.dart              # get_it 注册：services → repositories → view models
│   └── app_settings.dart    # 启动期偏好（主题/字号/语言/筛选默认值/开关）
├── data/
│   ├── models/              # BookData, MyBook, SearchManagerResult, SearchSourceRun,
│   │                        # SearchSourceStatus, SearchProviderId, TrendingBookData 等
│   ├── services/            # 现 lib/services/ 全部迁入
│   └── repositories/        # SearchRepository, LibraryRepository, DownloadRepository,
│                            # PreferencesRepository, MirrorRepository
├── domain/                  # 按需新增；本轮不建空目录占位
└── ui/
    ├── core/                # themes, motion, swiss_grid, filter_options, 共享 components
    └── features/
        ├── shell/           # home_page, bottom_nav_bar, content_width
        ├── search/          # view_models/, views/, widgets/
        ├── results/
        ├── library/         # download_center_page, mybook_page
        ├── book_detail/
        ├── settings/
        ├── instances/
        ├── onboarding/
        ├── trending/
        └── webview/
```

## 4. 分层职责与依赖规则

| 层 | 允许依赖 | 禁止 |
|---|---|---|
| `data/services` | dart/package、`data/models` | 任何 UI、Flutter Widget、BuildContext |
| `data/repositories` | `data/services`、`data/models` | UI、直接发网络/文件请求以外的事情 |
| `ui/core` | `data/models` | `data/services`、`data/repositories` |
| `ui/features/*/view_models` | repositories、models、`app/app_settings` | Widget、BuildContext |
| `ui/features/*/views` | 自身 ViewModel、`ui/core`、models | 直接调用 repository/service |

补充规则：

- Repository 返回值是模型或模型集合；失败用异常表达（沿用现有网络层语义），不引入 `Result` 包装
- `PreferencesService` 升级为 `PreferencesRepository`；调用点改依赖仓库
- 筛选选项目录（`typeValues`、`languageValues`、`yearValues`、`sortValues`、`fileType`）从 `state.dart` 移到 `ui/core/filter_options.dart`，因为它们是展示用标签集合，被 `book_card_widget` 等 core 组件共享

## 5. 状态管理与依赖注入

- ViewModel 继承 `ChangeNotifier`，暴露不可变状态快照与命令方法
- 页面级 ViewModel 注册为 **factory**：`initState` 取实例，`dispose` 中释放
- 跨页面单例（`DownloadManager`、镜像状态、`AppSettings`）注册为 **lazySingleton**
- 依赖全部走构造函数，`app/di.dart` 是唯一装配点，不使用隐式代理依赖
- 启动顺序：`WidgetsFlutterBinding.ensureInitialized()` → 读库与偏好 → `initDi()`
  → `runApp`。现有 `ProviderScope.overrides` 的 20 项启动值迁入 `AppSettings`
- Widget 通过构造参数接收 ViewModel，用 `ListenableBuilder` 订阅

### 页面级 ViewModel 清单

| 页面 | ViewModel | 主要依赖 |
|---|---|---|
| `search_page` | `SearchViewModel` | `SearchRepository`、`InstanceManager`、镜像测速 |
| `results_page` | `ResultsViewModel` | `SearchRepository`、`PreferencesRepository`、`ResultsPager` |
| `download_center_page` | `LibraryViewModel` | `LibraryRepository`、`DownloadRepository` |
| `book_info_page` | `BookDetailViewModel` | `SearchRepository`、`BookInfoCache` |
| `settings_page` | `SettingsViewModel` | `PreferencesRepository`、`BackupService`、`UpdateChecker` |
| `instances_page` | `InstancesViewModel` | `MirrorRepository`、`InstanceManager` |
| `onboarding_page` | `OnboardingViewModel` | `PreferencesRepository`、`book_import` |
| `home_page` | `ShellViewModel` | `AppSettings` |

## 6. 迁移波次

每一波都必须 `dart analyze lib/ test/` 无问题且 `flutter test` 全绿，单独提交后才能进入下一波。

### W0 基础设施（双轨启动）

- 新增 `get_it` 依赖（纯 Dart、无原生代码，体积影响可忽略）
- 新建 `app/di.dart`、`app/app_settings.dart`
- `main.dart` 先 `initDi()` 再 `runApp`；此时 Riverpod 的 `ProviderScope` 仍在
- 判据：行为零变化，全量测试绿

### W1 数据层搬家

- `lib/services/` → `lib/data/services/`
- 从 service 文件拆出模型类到 `lib/data/models/`：
  `annas_archieve.dart`→`BookData`、`database.dart`→`MyBook`、
  `search_manager.dart`→`SearchManagerResult`/`SearchSourceRun`/`SearchSourceStatus`/`SearchProviderId`
- 判据：纯移动，import 全改，全量测试绿

### W2 Repository 层

- 新建 `SearchRepository`、`LibraryRepository`、`DownloadRepository`、`PreferencesRepository`、`MirrorRepository`
- 每个仓库补单测（复用现有 ffi/本地 HTTP 测试设施）
- 页面此时仍走 Riverpod，只是底层改成仓库

### W3 UI 目录重排

- 共享组件与主题 → `ui/core/`
- 页面搬入 `ui/features/<feature>/views/`，页内私有组件搬入同 feature 的 `widgets/`
- 判据：纯移动，测试绿

### W4 search 特性迁移

- `SearchViewModel` + `ListenableBuilder`
- 68 处 `ref.*` 清除；流式结果、建议、镜像提示行为不变
- 判据：`search_metrics_test`、`search_suggestions_test` 改为注入后绿

### W5 results + library + book_detail 迁移

- `ResultsViewModel` 收编 `ResultsPager`
- `LibraryViewModel`、`BookDetailViewModel`
- 判据：`results_page_test`、`download_center_page_test`、`book_info_*_test` 改造后绿

### W6 其余特性迁移

- settings、instances、onboarding、shell、trending、webview、what's new
- 19 个 `ProviderScope` 测试全部改为 get_it 注入
- 判据：全量测试绿；此时 lib 中已无 `ref.*`

### W7 收尾

- 删除 `lib/state/state.dart`
- 从 `pubspec.yaml` 移除 `flutter_riverpod`
- 删除测试中的 `ProviderScope` 脚手架，补 `test/helpers/test_di.dart`
- 判据：全量测试绿；`grep -r flutter_riverpod lib test` 为空

## 7. 测试策略

- 每个 ViewModel / Repository 新增单测；沿用现有 `sqflite_common_ffi` + 本地 HTTP 服务设施
- Widget 测试改为：`setUp` 中 `GetIt.I.reset()`，注册 fake 依赖，再 pump 页面
- 新增 `test/helpers/test_di.dart` 统一注册与清理，避免 19 个文件各写一套
- 真实网络用例继续保持 skip
- 实机验证按批次进行；W6 结束后做一次覆盖主流程的实机验收（首页 → 搜索 → 结果 → 详情 → 下载 → 下载中心 → 设置）

## 8. 文档同步

需要在 `AGENTS.md` 同步的两处（实施 W0 时一并修改）：

1. §4「不要新增抽象层、状态管理库…沿用 Riverpod + Dio + sqflite」→ 改为 ChangeNotifier + get_it + Dio + sqflite
2. §1 与 §7 中的目录说明（`lib/state/`、`lib/services/`、`lib/ui/`）→ 更新为新结构

## 9. 风险与回退

| 风险 | 影响 | 应对 |
|---|---|---|
| 复用组件（`active_downloads_widget`、`book_card_widget`、`search_result_card`）现直接 `ref.watch` | 改构造注入会波及多页面与多个测试 | 放在 W5/W6，先补测试再改 |
| W1/W3 大规模移动产生大量 import 改动 | 遗漏会导致编译失败 | 纯移动、无逻辑改动，靠 analyze 全量兜底 |
| 迁移期间两套状态管理并存 | 新读者认知负担 | 仅在 W0–W6 期间存在，W7 移除依赖 |
| 实机行为回归 | 无法靠单测发现 | W6 后集中实机验收；按批次执行 |

回退：每波独立提交；W7 之前 Riverpod 始终可用，任意一波可单独 revert。

## 10. 验收标准

- [ ] `lib/` 目录符合第 3 节目标结构
- [ ] `grep -r "flutter_riverpod\|ConsumerWidget\|ref\.watch" lib test` 为空
- [ ] `pubspec.yaml` 不含 `flutter_riverpod`
- [ ] `dart analyze lib/ test/` 无问题
- [ ] `flutter test` 全绿（联网用例仍 skip）
- [ ] 新增 ViewModel / Repository 单测覆盖核心规则
- [ ] UI 与交互无可见变化（实机验收）
