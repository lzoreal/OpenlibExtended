# AGENTS.md

给在本仓库工作的 AI 编码代理的说明。**先读 [HANDOVER.md](HANDOVER.md)** 了解产品、架构与已知坑；本文件只保留可执行的约束、命令和检查清单。

技术术语、代码标识符、命令保持英文；解释用中文。

---

## 1. 项目速览

- Flutter 跨平台电子书客户端：Anna's Archive / LibGen / Z-Library / WeLib 搜索 → 下载中心 → 外部阅读器打开 EPUB/PDF。
- 入口 `lib/main.dart`；全局状态 `lib/state/state.dart`；服务 `lib/services/`；页面 `lib/ui/`；数据库 `lib/services/database.dart`。
- 发布平台：Android、iOS（未签名侧载）、Windows、Linux。**Web 不可用**；macOS 有工程但未发布。
- “我的书库”已重构为“下载中心”：标签、阅读状态筛选、排序/筛选、磁盘同步入口均已删除，不要恢复。
- CI 固定 Flutter **3.47.2**；Dart SDK `>=3.3.0 <4.0.0`。

---

## 2. 命令

```bash
flutter pub get
flutter gen-l10n                 # 修改 lib/l10n/*.arb 后必须执行
dart analyze lib/ test/          # CI 使用的静态检查
flutter test                     # 默认跳过 live 网络用例
flutter test --run-skipped       # 真实网络用例，容易不稳定
flutter run

flutter build apk --release
flutter build apk --split-per-abi --release
flutter build windows --release
flutter build linux --release
flutter build ios --release --no-codesign
```

没有 Makefile / 自定义脚本别名。不要引入新的构建系统。

---

## 3. 硬性架构约束

修改代码时优先遵守现有分层；不要为了“更优雅”重写核心链路。

1. **镜像地址只能来自 SLUM**
   - 唯一允许硬编码的镜像相关 URL 是 `https://open-slum.org`（`lib/services/slum_catalogue.dart`）。
   - 取镜像用 `InstanceManager().enabledUrls(...)`；不要在 provider/UI 里写 `z-lib.*`、`libgen.*`、AA host 常量。
   - DOWN 镜像永不请求；用户禁用和 `headlessOnly` 过滤必须保留。

2. **书源协议**
   - 实现 `SearchProvider`：搜索成功但无结果返回 `[]`；不可达/解析失败抛异常。
   - `SearchManager` **并行查询所有启用书源**；书源顺序只决定合并顺序和默认显示，不再“首个非空即停”。
   - 首屏用 `initialSearchProvider` 流式返回：快源先展示，慢源显示“搜索中…”并回填；结果页的“搜索来源”卡片点击可在“全部/单个来源”之间切换；分页只作用于当前视图。
   - 新增书源要同时处理详情路由与下载解析，并覆盖 `SearchSourceStatus.pending/hit/empty/failed`。

3. **详情路由**
   - 用 `routeBookDetail()` 按 SLUM host + URL 形状路由；不要新增硬编码 host 白名单。
   - `ads.php?md5=` → LibGen；`/book/` → Z-Library；其余 → Anna's Archive（WeLib 详情在目录可用时由 host 命中，下载侧用 `isWelibUrl` 识别）。

4. **下载只能走 DownloadManager**
   - UI 不要直接写文件或发下载请求；构造 `DownloadTask` 后调用 `addDownload` / `addDownloadWithMirrorUrl`。
   - 保留以下行为：同 md5 单任务、HTTPS 优先/IPFS 最后、Range 续传、瞬时错误退避、`linkRefresher`、完成前 MD5 校验、完成后写库。
   - Z-Library/WeLib 的签名链接会过期，必须保留 `linkRefresher`。
   - 下载队列是内存态；不要假装重启后可恢复。

5. **持久化只走 MyLibraryDb**
   - 不引入 `shared_preferences` 或其他偏好存储。
   - 偏好键是字符串常量；`getPreference` 缺失会抛异常，调用方要兜底。
   - 改 schema 必须同时改 `onCreate` + `onUpgrade` 并提升 version；评估 `BackupService` 兼容性。

6. **本地化**
   - 用户可见文案必须走 `AppLocalizations`。
   - 新 key 要同时加入 `app_en.arb`、`app_de.arb`、`app_es.arb`、`app_fr.arb`、`app_zh.arb`，并在英文 ARB 写 `@key` 描述。
   - 运行 `flutter gen-l10n`；**不要手改** `app_localizations*.dart`。
   - `test/localization_test.dart` 会强制五份 ARB key 完全一致。

7. **平台判断**
   - 用 `PlatformUtils` 或 `dart:io` 的 `Platform`，保持现有分支。
   - 不要声称支持 Web；`main.dart` 依赖 `dart:io`。
   - Linux 后台 headless 抓镜像不可用，必须保留可见 WebView 手动流程。
   - 过盾求解器：移动 headless + 可见回退；桌面可见窗口。不要缩短/移除超时与缓存逻辑。

8. **不要随意升级钉死的依赖**
   - `html: 0.15.6`、`permission_handler_android: 13.0.1`、`sqlite3_flutter_libs: 0.5.42` 都有兼容性原因。
   - 升级前先读 `pubspec.yaml` 里的注释，并跑全平台构建（至少 analyze + test + 目标平台 build）。

9. **不要改发布版本号**
   - `pubspec.yaml` 的 `version` 是本地默认值；CI 会用 Release tag 覆盖。
   - 不要把 1.0.11 改成 1.7.x 来“对齐”；发布由 GitHub Release 驱动。

10. **不要提交密钥**
    - 禁止提交 `android/key.properties`、`*.jks`、keystore、token、cookie。
    - CI 通过 secrets 注入签名材料。

11. **UI 必须遵循 MD3 设计系统**
    - 颜色/形状/文字样式只从 `Theme.of(context)` 取；主题源是 `lib/ui/themes.dart`（暖纸 + 翡翠绿 `#0F6B5C`，light/dark）。
    - 使用语义角色：`primary`/`primaryContainer`、`onSurface`/`onSurfaceVariant`、`surfaceContainerLow/High/Highest`、`error`/`errorContainer`；不要新增硬编码 `Colors.*` 或十六进制色值（深色遮罩上的白字除外）。
    - 使用 MD3 组件：`NavigationBar`、`Card`、`FilledButton`/`OutlinedButton`/`TextButton`、`FilterChip`、`SegmentedButton`、`SearchBar`、`AlertDialog`、`BottomSheet`。
    - 一级页统一 `PageHeader`（小标签 + 标题 + 可选操作，**不带副标题**），列表节标题统一 `SectionHeader`，设置/What's New 选项卡统一 `PillTabs`。
    - 设置分组固定为搜索来源 / 外观 / 高级 / 关于；存储位置在“高级 → 通用”，不要放回外观。
    - 语言默认收起、点击展开；主题用带预览的选项卡，不用下拉框。
    - 页面横向内边距 16dp、卡片圆角 20dp、输入框/选项 16dp、对话框 28dp；底部导航首页标签用 `homeTitle`（发现）。新页面复用 `BookInfoWidget`、`ActiveDownloadsWidget`、`CustomErrorWidget` 等共享组件。
    - 不要恢复已移除的 `google_nav_bar`、旧的红色/紫色主题或内置阅读器。

---

## 4. 代码风格与边界

- 遵循 `flutter_lints`（`analysis_options.yaml`）；没有自定义 lint。
- Import 分组沿用现有风格：Dart → Flutter → Package → Project（`main.dart` 等文件开头）。
- 文件内注释只写“为什么”，不写“做了什么”；不要写多段 docstring。
- 不为不可能发生的场景加防御性错误处理；但网络/解析边界要保留现有容错。
- 不要新增抽象层、状态管理库、网络库或文件存储库；沿用 Riverpod + Dio + sqflite。
- 不要顺手重构无关代码；一个变更只解决一个明确问题。
- 新增依赖前先确认现有依赖能否完成，并在 PR 中说明 APK 体积影响（CONTRIBUTING 明确要求）。

---

## 5. 测试要求

改动后至少运行：

```bash
dart analyze lib/ test/
flutter test
```

按改动类型补测试：

| 改动 | 必测 |
|---|---|
| HTML 解析器 | 用 `test/fixtures/` 的抓取页做纯解析测试 |
| 书源/镜像 | provider 测试 + `instance_manager_test` / `slum_catalogue_test` |
| 下载 | `download_manager_test`（本地 HTTP 服务模拟 Range/失败/重试） |
| 数据库/迁移 | 备份恢复、升级路径 |
| 设置/UI | widget 测试（参考 `settings_page_test`、`download_center_page_test`） |
| 结果页/来源切换 | `results_page_test`（首屏流式、全部/单源切换、分页跟随视图） |
| 本地化 | `localization_test` |
| 构建/发布配置 | `android_build_size_test`、`scoop_manifest_test` |

- 真实网络用例默认 `skip`；不要为了“跑绿”把普通单测也 skip。
- 不要修改测试来迁就有缺陷的实现；先确认需求。
- UI 改动尽量在目标平台实际运行验证（至少桌面 + 一个移动端）；无法验证时要在交付说明中明确写出。

---

## 6. 高频坑（改动前必看）

- **Z-Library 的 `md5` 不是文件 MD5**，而是 `/book/<id>` 的书籍 id；下载完成校验会显示失败，但文件仍入库。
- **文件名清洗会删除所有非 ASCII 字符**；纯中文标题退化为 md5 前 8 位，且没有唯一后缀，可能覆盖同名书。
- **下载任务只在内存**；进程死亡后不会自动续传。
- **`enableAutoUpdate` 是死偏好**；启动时总会检查更新，真正生效的是 `includePrereleaseUpdates`。
- **应用内更新没有签名/哈希校验**，且 Android 固定优先 arm64。不要在此基础上叠加更多“信任下载”的逻辑。
- **分类页解析器有笔误**（`img"]`、`herf`）；修它时先补 fixtures。
- **`setCompleted` 会用空 position 覆盖进度**；内置阅读器已删除，应用内不再写阅读位置，但旧数据/备份仍可能包含。
- **下载中心里进行中任务只在内存**，完成记录来自 `mybooks`；删除记录不删除本地文件。
- **已完成记录：点行进入书籍详情，只有“打开”按钮调用外部阅读器**；不要合并这两个动作，也不要把提示写回“点书名直接阅读”。
- **不内置阅读器**：`epub_view` / `pdfrx` / `epubx` / `flutter_tts` 已移除；打开书籍统一走 `openBookExternally()`（`OpenFile`）。不要重新引入内置阅读器、TTS 或相应设置开关。
- **macOS/iOS 通知不可用**；通知服务仅 Android 初始化。
- **Linux 需要 WebKitGTK 4.1**；否则过盾/桌面 WebView 失败。
- **可见过盾页必须可交互**：加载时显示设计的全屏加载态，加载完成后显示顶部“需要手动验证”提示并露出 WebView；不要用遮罩长期挡住验证页面。
- **`getPreference` 会抛异常**；不要假设返回 null。
- **桌面数据库需要 FFI 初始化**；新增入口/测试时要先初始化。
- **测试里的 `test/fixtures` 是真实页面快照**；改解析器前先看 fixture 结构。

---

## 7. 常见任务路径

- **加书源**：`SearchProviderId` → 实现 `SearchProvider` → 注册 `SearchManager` → SLUM 服务映射 → `routeBookDetail` → 详情下载分支 → ARB/设置开关 → 测试。
- **加设置项**：`lib/state/state.dart` provider → `lib/main.dart` 读偏好并 override → `lib/ui/settings_page.dart` UI + 写库 → 即时生效则同步服务静态开关。
- **加 l10n**：四个 ARB + `@description` → `flutter gen-l10n` → `AppLocalizations.of(context)`。
- **改下载**：`DownloadManager` → `lib/services/download_target.dart` → `lib/ui/book_info_page.dart` → `download_manager_test`。
- **改镜像**：`SlumCatalogue` / `InstanceManager` → `slum_catalogue_test` / `instance_manager_test` / `instances_page_test`。
- **改更新**：`update_checker.dart` → `upgrade_detector`/What's New → 相关 widget 测试；注意 CI 产物命名约定。
- **改发布**：`.github/workflows/build.yml` + `tool/update_scoop_manifest.py` + `bucket/openlibextended.json`；改产物名会破坏应用内更新识别。

---

## 8. 交付前检查清单

- [ ] `dart analyze lib/ test/` 无新增问题。
- [ ] `flutter test` 通过；联网用例仍保持 skip。
- [ ] 新增/修改的解析器有 fixture 测试。
- [ ] 用户可见文案已进入五份 ARB 并重新生成。
- [ ] 没有硬编码镜像 host、密钥、cookie。
- [ ] 没有改动 `pubspec.yaml` 的发布版本号（除非用户明确要求）。
- [ ] 没有随意升级钉死依赖。
- [ ] 平台差异分支保留（Android/iOS/Windows/Linux）。
- [ ] 如果改了下载/更新/镜像，已说明对现有用户的影响。
- [ ] 如果是 UI 改动，已在目标平台实际运行验证，或在交付说明中明确未验证。

---

## 9. 文档与协作

- 产品/架构/流程：`HANDOVER.md`。
- 全站 UI 原型：`design/ui_prototype.html`；页面改版先更新原型，再按原型实现。
- 贡献流程：`CONTRIBUTING.md`（不要修改 README 等信息文件，除非用户明确要求修错别字）。
- 用户常见问题：`FAQ.md`。
- 安装/平台依赖：`SETUP.md`。
- 许可证：AGPL-3.0；不得上架 Google Play（README 明确说明）。
