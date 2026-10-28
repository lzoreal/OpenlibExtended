# Task 7 Report: 阶段验收 + 三项测试强度修补

**Status:** DONE
**Branch:** `refactor/layered-architecture`
**Worktree:** `D:/OpenlibExtended/.worktrees/refactor-layered-architecture`（未触碰 `D:/OpenlibExtended`）
**Commit:** 本报告与代码同一提交（`test(data): assert repository DI, harden settings and mirror tests`，哈希见交付说明 / `git log -1`）

## Changes

| File | Change |
|---|---|
| `test/di_test.dart` | “registers services as resolvable singletons” 用例补 `LibraryRepository` / `SearchRepository` / `DownloadRepository` / `MirrorRepository` 的 `same(getIt<...>())` 恒等断言（`PreferencesRepository` 的原断言已存在，未重复）；补齐四个仓库 import。既有断言一条未删 |
| `test/settings_page_test.dart` | `setUp` 里调用 `initDi(settings: AppSettings(...), database: MyLibraryDb.instance, preferences: PreferencesRepository(database: MyLibraryDb.instance))`，新增 `tearDown` 调 `resetDi()`；`AppSettings` 直接构造（`AppSettings.load` 会 await sqlite，widget 测试的 fake async zone 里永不完成，且页面不读 `AppSettings`）；`pumpPage` 的首帧与 300 ms 真实异步窗口放进 `tester.runAsync`，否则搜索来源 provider 的 sqlite 查询永不完成、卡片永远停在空白 `SizedBox.shrink()`；mock `package_info` channel（About 页在真实异步窗口里会抛 `MissingPluginException`）；第一个用例新增 `expect(find.text('WeLib'), findsOneWidget)`，验证来源卡片真的渲染；主题/语言用例在写库后各补一次 `runAsync` 短窗口，让 sqlite 写入完成、不残留 10 s 锁告警定时器。所有既有用例与断言保留 |
| `test/mirror_repository_test.dart` | 新增用例：本地 HTTP 服务喂 `test/fixtures/slum_*.html`，`InstanceManager.forTest(catalogue: SlumCatalogue(...), store: MemoryPreferenceStore())` 装配 `MirrorRepository`。断言“非 headless 可解”节点在 `enabledUrls(...)` 里存在、`headlessOnly: true` 时消失；“被用户关掉的节点”在两种调用里都消失。节点从 `instances()` 动态选出，不硬编码 host |
| `test/download_repository_test.dart` | 头部注释改为指向 `test/download_manager_test.dart`（服务层）覆盖队列内容，并写明 `active` 转发断言 deferred；删除对 `download_center_page_test` 的错误声明 |
| `docs/superpowers/plans/2026-10-28-layered-architecture-w2-repositories.md` | 约 629 行注释由“Broadcast controllers hand out the same stream object twice”改为“equality 来自 `_ControllerStream.==` 比较所属 controller，而非返回同一对象” |
| `lib/state/state.dart` | `downloadManagerProvider` 上方加一行注释：故意没有 `onDispose`，`DownloadManager` 是进程级单例，关闭其 broadcast controller 不可逆（唯一生产代码改动，无行为变化） |

## Acceptance results（Task 7 验收命令，逐条）

| 命令 | 结果 |
|---|---|
| `ls lib/data/repositories lib/data/models lib/app lib/state` | repositories 5 个（download/library/mirror/preferences/search）；models 6 个（book_data/book_detail_source/my_book/search_filters/search_result/trending_book_data）；app 2 个（app_settings/di）；state 3 个（repository_providers/results_pager/state） |
| `grep -rn "data/services" lib/ui \| grep -v open_book` | 仍有 **16 个 UI 文件、46 处**直接 import 服务（book_info_page、challenge_solver_page、active_downloads_widget、book_card_widget、error_widget、search_source_meta、download_center_page、instances_page、mybook_page、onboarding_page、results_page、search_page、settings_page、themes、webview_page、whats_new_page）。属 W2 范围外，留给后续波次（book_info 的 `DownloadTask` 构造为 W5 已知欠账） |
| `grep -rnE "^import .*\.\./(ui\|app)/" lib/data` | **0 行**（data 不依赖 ui/app） |
| `grep -rn "SearchManager()" lib \| grep -v repositories` | **0 行**（只有 `SearchRepository` 构造它） |
| `grep -rn "DownloadManager()" lib \| grep -v repositories` | **4 行**：`lib/app/di.dart:32`（注册）、`lib/data/services/download_manager.dart:143`（单例 factory）、`lib/main.dart:80`、`lib/main.dart:315`（组合根初始化/恢复，brief 允许保留） |
| `dart analyze lib/ test/` | `No issues found!` |
| `flutter test` | **453 passed / 18 skipped**，`All tests passed!`（基线 452/18 + 本任务 1 个新用例） |
| `git status --short`（提交后） | 仅剩 7 个先前已存在的生成插件文件（`linux/flutter/generated_*`、`macos/Flutter/GeneratedPluginRegistrant.swift`、`windows/flutter/generated_*`），未提交 |

## Deviations / notes

1. **设置页测试必须跑在真实异步窗口里。** `testWidgets` 的 fake async zone 里 sqlite 的 Future 永不完成（已用一个临时探针用例验证：假 zone 内发起的 `getPreference` 在 `runAsync` 窗口里也不完成，只有在 `runAsync` 内发起的操作才完成）。所以 `pumpPage` 的 `pumpWidget` + 300 ms 等待必须整体放进 `tester.runAsync`，并 mock `package_info` channel；这不是放宽断言，新增的 `WeLib` 断言在去掉 `initDi` 后实测会失败（临时改 `if (false) await initDi(...)` 验证后已还原）。
2. **两个既有主题/语言用例各加了一次 `runAsync` 冲刷。** 数据库被打开后，点击主题/语言会真实写库；写入在假 zone 里完成不了，sqflite 的 10 s 锁告警定时器会活到用例结束并触发 `A Timer is still pending` 不变量。加 200 ms 真实窗口后写入完成、定时器取消。断言与步骤顺序未变。
3. **MirrorRepository 用例动态选节点。** brief 允许在 fixture 不适合时做委派等价测试；实测 fixture 完全可用，故按 brief 的第一种写法实现，但 host 由 `instances()` 选出（非 headless 可解 + 未被禁用），避免 fixture 更新时脆断。
4. **`download_repository_test` 仍只做“wiring + 空队列 smoke”。** `active` 转发断言明确 deferred；队列内容覆盖指向 `test/download_manager_test.dart`（服务层，用本地 HTTP 服务模拟 Range/失败/重试）。
5. **无行为变化、无新依赖、`pubspec.yaml` 未触碰**；唯一生产改动是 `lib/state/state.dart` 的一行注释。
6. **未实机验证**：本任务只改测试与注释，无 UI/下载/镜像/更新行为变化，按批次留到下次需要设备时统一验证。
