# OpenlibExtended 交接文档

> 适用代码：当前工作树（`main` HEAD `c5ae926` + 未提交改动），更新于 2026-10-26。
> 本文基于源码阅读整理，关键结论均附 `文件:行号`，便于核对。
> AI 编码代理请优先阅读 [AGENTS.md](AGENTS.md)；本文面向接手的人类开发者。

---

## 1. 项目概览

OpenlibExtended 是一个 Flutter 跨平台电子书客户端，从 Anna's Archive、Library Genesis、Z-Library、WeLib 搜索、下载并阅读电子书。它 fork 自 [dstark5/Openlib](https://github.com/dstark5/Openlib)，扩展了桌面端、多源搜索、镜像容灾、下载中心等功能。

| 项 | 值 |
|---|---|
| Dart 包名 | `openlib`（`pubspec.yaml:1`） |
| Android applicationId | `dev.wath.openlibextended`（`android/app/build.gradle:18,34`） |
| 许可证 | AGPL-3.0 |
| 状态管理 | Riverpod 2（`flutter_riverpod`） |
| 网络 | Dio + `package:html` 解析 HTML |
| 本地存储 | SQLite（`sqflite` / 桌面 `sqflite_common_ffi`） |
| 阅读 | 仅外部阅读器（系统/第三方应用）；不包含内置阅读器与 TTS 依赖 |
| 反爬 | `flutter_inappwebview`（移动 headless）+ `desktop_webview_window`（桌面可见窗）+ DiamWall PoW |
| 发布版本 | 最新已发布 v1.7.2；仓库内 `pubspec.yaml` 版本号是 1.0.11+14，由 CI 在构建时覆盖（见 §9） |

### 1.1 功能清单

- **搜索**：四个书源并行搜索；结果页可按“全部/单个来源”切换结果；语言/格式/年份/类型/排序筛选；作者/出版社高级检索；搜索建议；分页。
- **发现**：Trending（Goodreads + Penguin Random House + BookDigits 合并打乱）、28 个硬编码分类。
- **详情与下载**：按 URL 路由到正确书源；LibGen 直链、Z-Library DiamWall 解挑战后取签名 CDN、WeLib slow_download 解析、Anna's Archive donation key 快速下载；多镜像回退。
- **下载管理**：队列、暂停/继续/重试/取消、HTTP Range 断点续传、镜像间回退、瞬时错误退避、过期链接自动刷新、MD5 校验、系统通知、回到前台自动续传。
- **下载中心**：进行中任务的聚合进度/速度/剩余时间、全部/进行中/已完成三个可滑动标签（失败归入已完成）、批量暂停/继续；已完成记录点行进入书籍详情，点“打开”才交给外部阅读器；也可分享、在文件夹中显示（桌面）或删除记录（不删文件）。书库的标签、阅读状态、排序/筛选和磁盘同步入口已移除。
- **阅读**：仅通过外部阅读器打开 EPUB/PDF/CBR/CBZ；应用不再提供内置阅读入口。
- **镜像管理**：唯一数据源 open-slum.org；自动排序/手动排序、逐镜像启停、DOWN 镜像永不尝试；支持手动本机测速（只测已启用非 DOWN 节点），结果保留 24 小时并参与自动排序。
- **反爬处理**：DDoS-Guard/Cloudflare 用 WebView 过盾并缓存 HTML；Z-Library DiamWall 用 SHA1 工作量证明在本地求解。
- **其他**：JSON 备份/恢复、诊断日志导出、GitHub 更新检查与安装、首次引导、升级后 What's New、主题/字号/语言（en/de/es/fr/zh）。

### 1.2 平台支持现状

| 平台 | 状态 | 说明 |
|---|---|---|
| Android | ✅ 主发布平台 | 通知、headless WebView、APK 内更新 |
| iOS | ⚠️ 未签名 IPA | 只能侧载；通知服务未初始化；更新实际装不上 |
| Windows | ✅ 发布 | Inno Setup 安装包；桌面 WebView 过盾；Scoop 清单自动更新 |
| Linux | ✅ 发布 | 需 WebKitGTK 4.1；后台 headless 抓镜像不可用，走可见 WebView 手动流程 |
| macOS | ⚠️ 有工程，未构建/发布 | README Roadmap 仍列为待办 |
| Web | ❌ 不可用 | 代码直接依赖 `dart:io` / `Platform`，无 CI Web job |

---

## 2. 快速开始

### 2.1 环境

- Flutter stable；CI 固定 **3.47.2**（`.github/workflows/build.yml:49`），本地建议对齐。
- Dart SDK `>=3.3.0 <4.0.0`（`pubspec.yaml:21-22`）。
- Android 构建建议 JDK 17、Android SDK 34（`SETUP.md:48-58`）。
- Linux 需 `libwebkit2gtk-4.1-dev`（验证码窗口和桌面 WebView），见 `SETUP.md:73-91`。

### 2.2 常用命令

```bash
flutter pub get
flutter gen-l10n          # 生成 lib/l10n/app_localizations*.dart
flutter run               # 默认设备
flutter analyze           # 或 dart analyze lib/ test/
flutter test              # 默认跳过联网用例
flutter test --run-skipped  # 跑真实网络 live 用例（不稳定，慎用）
```

平台构建：

```bash
flutter build apk --release
flutter build apk --split-per-abi --release
flutter build ios --release --no-codesign
flutter build windows --release
flutter build linux --release
```

### 2.3 首次运行注意

- 桌面端启动时会初始化 sqflite FFI（`lib/main.dart:66-69`）。
- 启动会做四件事：加载偏好、检查升级、后台刷新镜像、2 秒后检查更新（`lib/main.dart:162-194,312-368`）。
- 首次安装进入 Onboarding；升级后进入 What's New；否则进入四 Tab 主界面（`lib/main.dart:282-289`）。
- 当前 `pubspec.yaml` 版本号不是发布版本；本地构建显示 1.0.11，CI 构建才注入 tag 版本。

---

## 3. 目录地图

```text
lib/
├─ main.dart                  # 启动、偏好注入、主题/本地化、主壳与底部导航
├─ l10n/                      # ARB 源文件 + 生成代码（5 语言，557 个 key）
├─ state/state.dart           # 全局 Riverpod provider、派生数据、阅读进度写入
├─ services/
│  ├─ search_manager.dart     # 4 个 SearchProvider + 并行搜索 + 去重
│  ├─ annas_archieve.dart     # Anna's Archive 抓取/解析/过盾/快速下载
│  ├─ libgen_service.dart     # LibGen 详情/下载/封面
│  ├─ slum_catalogue.dart     # open-slum.org 镜像目录抓取、排序、缓存
│  ├─ instance_manager.dart   # 用户启停/手动排序 + 实际可用镜像列表
│  ├─ book_detail_routing.dart# URL → 书源路由
│  ├─ download_manager.dart   # 下载状态机、多镜像、续传、校验
│  ├─ mirror_fetcher.dart     # 从详情页 headless 抓镜像（Linux 不可用）
│  ├─ download_target.dart    # 下载目标选择（链接 vs 拒绝原因）
│  ├─ webview_challenge_solver.dart # DDoS/Cloudflare 过盾
│  ├─ diamwall_solver.dart    # Z-Library SHA1 PoW
│  ├─ challenge_html_cache.dart# 过盾后 HTML 的 10 分钟缓存
│  ├─ database.dart           # SQLite schema v7 + MyBook 模型
│  ├─ files.dart              # 文件名、目录、迁移、磁盘同步
│  ├─ backup_service.dart     # JSON 备份/恢复
│  ├─ update_checker.dart     # GitHub Release 检查/下载/安装
│  ├─ upgrade_detector.dart   # 版本升级检测（驱动 What's New）
│  ├─ download_notification.dart # Android 通知
│  ├─ logger.dart             # 内存日志 + 导出
│  ├─ network_error.dart      # Dio/Socket/Cloudflare 错误分类
│  ├─ platform_utils.dart     # 平台能力判断
│  └─ ...                     # 元数据源、分享、偏好存储等
├─ ui/
│  ├─ home_page / trending_page / categories_page
│  ├─ search_page / results_page / book_info_page
│  ├─ download_center_page / mybook_page / instances_page / settings_page
│  ├─ webview_page / challenge_solver_page
│  ├─ onboarding/、whats_new_page、about_page
│  └─ components/             # 书卡、下载面板、错误页、文件按钮等
test/                         # 37 个测试文件 + HTML fixtures
tool/update_scoop_manifest.py # 发布后重写 scoop 清单
.github/workflows/build.yml   # 唯一 CI：测试 + 全平台构建 + 发布 + scoop
bucket/openlibextended.json   # Scoop 清单
```

---

## 4. 架构

### 4.1 分层

```text
Widget / Page (ConsumerWidget, ConsumerStatefulWidget)
        │ ref.watch / ref.read
        ▼
Riverpod providers（lib/state/state.dart + 页面内 provider）
        │
        ▼
Service 层（单例：MyLibraryDb / DownloadManager / InstanceManager / AppLogger）
        │
        ├─ Dio + package:html      网络与解析
        ├─ WebView（移动/桌面）     过盾、抓镜像
        ├─ SQLite                  下载记录、偏好、阅读进度、浏览器 cookie
        └─ 文件系统                 书籍文件、备份、日志
```

约定：

- **UI 不直接发网络请求或写文件**；下载统一走 `DownloadManager`，下载记录/偏好读写统一走 `MyLibraryDb`。
- 全局偏好由 `main()` 读库后通过 `ProviderScope.overrides` 注入（`lib/main.dart:196-219`），页面再 `watch` 对应 provider。
- 重要服务都是单例：`MyLibraryDb.instance`、`DownloadManager()`、`InstanceManager()`、`AppLogger()`。
- 书源、镜像、下载目标都有明确的“服务 + 数据模型 + 纯函数”拆分，便于测试注入（如 `SearchManager(providers: ...)`、`InstanceManager.forTest`）。

### 4.2 启动时序

1. Linux/Windows 先处理桌面 WebView 标题栏插件参数（`lib/main.dart:59-63`）。
2. 桌面端初始化 sqflite FFI（`lib/main.dart:66-69`）。
3. 打开 SQLite（首次建表 v7），初始化 `DownloadManager` 并清空旧通知（`lib/main.dart:71-73`）。
4. 从 `preferences` / `browserOptions` 读取：主题、字号、语言、手动下载按钮、后台验证、donation key、UA/cookie、5 个搜索筛选、onboarding 状态（`lib/main.dart:75-166`）。
5. 检测版本升级（`UpgradeDetector`，写 `lastRunVersion`，`lib/main.dart:168-176`）。
6. Android 额外迁移旧内部存储文件（`lib/main.dart:178-182`）。
7. 注册“headless 过盾失败 → 可见验证页”的 UI 回调（`lib/main.dart:187-194`）。
8. `runApp`；主壳在首帧后请求通知权限、2 秒后检查更新、1 秒后预热镜像目录（`lib/main.dart:312-368`）；回前台时恢复中断下载（`lib/main.dart:334-342`）。

### 4.3 MD3 设计系统

- **主题源**：`lib/ui/themes.dart` 以暖纸背景 + 翡翠绿 `#0F6B5C` 为种子生成 light/dark 两套语义色；不再使用旧的紫色 `#6750A4`、红色 `#FB0101` 或纯白/纯黑硬编码。
- **语义色**：正文/标题用 `onSurface`，次要信息用 `onSurfaceVariant`，卡片用 `surface`/`surfaceContainerLow`，输入框用 `surfaceContainerHigh`，强调色用 `primary` / `primaryContainer`；禁止在新代码里写 `Colors.red`、`Colors.white` 等（深色遮罩上的白字除外）。
- **排版**：保留 Nunito，但映射到 MD3 角色：页面标题 `headlineMedium`，卡片标题 `titleSmall`，正文 `bodyMedium`，辅助信息 `bodySmall`，按钮/标签 `labelLarge`。
- **形状**：卡片 20dp 圆角 + 极浅描边，输入/选项 16dp，对话框 28dp，按钮与选项卡胶囊形；页面横向内边距统一 16dp。
- **页头**：一级页统一用 `PageHeader`（小标签 + 26dp 标题 + 可选右侧操作，**不显示副标题**）；列表内节标题用 `SectionHeader`（标题 + 可选说明/右侧提示）。
- **选项卡**：设置页、What's New、发现、搜索、下载中心统一用 `PillTabs + TabBarView`（tonal 轨道 + 白色滑动胶囊），页面和子标签都支持左右滑动；搜索/下载/设置的页头与标签固定，内容区独立滚动。根页面滑动只在页头/空白 chrome 区生效，内容区的横向手势属于内层子标签。
- **底栏**：四个标签为“发现 / 搜索 / 下载中心 / 设置”；四页装在横向 `PageView` 中，滑动与底栏选中态同步；首页标签使用 `l10n.homeTitle`，不要再改回“首页”。
- **设置分组**：搜索来源 / 外观 / 高级 / 关于四个 Tab；存储位置在“高级 → 通用”，不要放回外观。语言默认收起，点击后展开两/三列选项卡（原生语言名 + 选中勾），选择后自动收起；主题用带缩略预览的三张选项卡，字号用「Aa 预览 + A−/A+ + 滑杆」；不要再改回下拉框。
- **全站原型**：`design/ui_prototype.html` 覆盖首页、搜索、结果、详情、下载中心、设置四个 Tab、镜像、分类、关于、What's New、引导与验证页；改版时先改原型再落代码。
- **共享视觉组件**：`PageHeader`、`PillTabs`、`SectionHeader`、`EdgeFade`、`BookInfoWidget`、`ActiveDownloadsWidget`、`CustomErrorWidget`、`ShowDeleteDialog`。新增页面应复用它们，而不是另写一套卡片/按钮。


---

## 5. 核心业务流程

### 5.1 搜索

入口：首屏 `initialSearchProvider`（`lib/state/state.dart`）→ `SearchManager.watch()` 流式返回；分页走 `searchProvider` → `SearchManager.search()`（`lib/data/services/search_manager.dart`）。

实际行为（重要）：

1. 读取用户启用的书源（偏好键 `searchProviders`，默认四个全开）。
2. 对全部启用书源 **并行** 发起搜索；首屏用 `watch()` 在每个源完成时推送快照，未完成的源状态为 `pending`（UI 显示“搜索中…”）；书源顺序只决定结果合并顺序与默认显示来源，不是“第一个命中即停”。
3. 单个源失败不会影响其他源；只有“所有启用的源都抛错”时 UI 才显示错误。空结果 `[]` 是合法的“没搜到”。
4. 每个来源的结果先在源内按 `md5` 去重，再按书源顺序合并成“全部”视图并跨源去重；`booksBySource` 保留每个来源自己的列表。
5. 结果页第一页在第一个来源命中后立即显示，后续来源完成时自动回填；“搜索来源”卡片点击即可在“全部 / 单个来源”之间切换，不需重新搜索。
6. 分页跟随当前视图：全部视图的下一页仍查询所有来源；单源视图的下一页只请求该来源。分页使用 `searchProvider`，等待该页所有来源完成后合并。

筛选能力矩阵：

| 维度 | Anna's Archive | LibGen | Z-Library | WeLib |
|---|---|---|---|---|
| 关键词 | ✅ | ✅ | ✅ | ✅ |
| 类型 content | ✅ | ❌ | ❌ | ❌ |
| 排序 sort | ✅ | ❌ | ❌ | ❌ |
| 格式 | ✅ `ext` | ✅ `extension` | ❌ | ❌ |
| 语言 | ✅ `lang` | ✅ | ❌ | ❌ |
| 年份 | ✅（含区间） | ✅ | ❌ | ❌ |
| 作者/出版社 | ✅ `author:"…"` | ✅ `columns[]` | ❌ | ❌ |
| 分页 | ✅ | ✅ | ✅ | ✅ |

实现位置：AA `lib/data/services/annas_archieve.dart:612-687`；LibGen `lib/data/services/search_manager.dart:256-335`；Z-Library `lib/data/services/search_manager.dart:399-470`；WeLib `lib/data/services/search_manager.dart:900-983`。

每页搜索结果用 `SearchPageKey(query, page)` 作为 provider family key 缓存（`lib/state/state.dart:385-433`）；结果页滚动到距底部 200px 加载下一页（`lib/ui/results_page.dart:82-110`）。

### 5.2 详情路由

`routeBookDetail()`（`lib/data/services/book_detail_routing.dart:34-54`）按以下优先级决定由谁处理详情页：

1. URL 含 `ads.php?md5=` → LibGen。
2. URL 的 host 命中 open-slum.org 目录中的某个书源 → 对应书源。
3. 路径以 `/book/` 开头 → Z-Library（URL 形状兜底）。
4. 其余 → Anna's Archive（catch-all；WeLib 的 `/md5/` 在目录可用时会先被 host 命中 `welib`，只有冷目录/未知 host 才落到这里）。

`bookInfoProvider` 根据路由调用对应服务（`lib/state/state.dart:449-476`）。**不要新增硬编码 host 白名单**：镜像会变，目录是唯一事实来源。

### 5.3 下载

入口在详情页“Download”（`lib/ui/book_info_page.dart:151-360`），流程：

1. **LibGen**：`get.php` 直链，直接 `fast=true`。
2. **Z-Library**：先 `resolveBookDownload()` 重新解析 `/dl/<id>`，处理 DiamWall、302 签名 CDN、204 死链；拿不到时保留镜像给出的拒绝原因（每日限额/需登录）。
3. **WeLib**：`resolveDownload()` 解析 `a.js-partner-download-link` 或 `/fast_download`、`/auto_download`；保留 slow_download 页面用于过期后重新解析。
4. **Anna's Archive**：若配置了 donation key，调用 `getFastDownloadUrl()` 获取直接下载地址。
5. `chooseDownloadTarget()` 决定最终目标：只要拿到可用 URL 就用 URL；镜像明确拒绝且无 URL 时才显示拒绝原因（`lib/data/services/download_target.dart:38-47`）。
6. Linux 且非快速链接：打开可见 WebView 页抓镜像后入队（`lib/ui/book_info_page.dart:249-294`）；其他平台交给 `DownloadManager` 后台抓镜像。

下载状态机（`lib/data/services/download_manager.dart:16-26`）：

```text
queued → fetchingMirrors → downloadingMirrors → downloading → verifying → completed
   ↘ paused ↗        ↘ failed ↗ retry        ↘ cancelled
```

关键机制：

- **镜像排序**：HTTPS/CDN 优先，IPFS 最后；丢弃已知死域名（`lib/data/services/download_manager.dart:190-204`）。
- **同书去重**：同一 `md5` 只允许一个进行中的任务，避免写同一文件互相破坏（`:241-264`）。
- **断点续传**：文件已存在则发 `Range: bytes=N-`；服务端忽略 Range 返回 200 时截断重下；416 视为已完成（`:781-899`）。
- **重试**：429/500/502/503/504/超时/连接错误在同一镜像上退避重试，最多 3 次；403 等永久错误直接换镜像（`:227-236,654-732`）。
- **链接刷新**：Z-Library/WeLib 的签名链接过期后，通过 `linkRefresher` 重新解析，最多 2 轮（`:739-769`）。
- **完成**：校验 MD5（`:206-221`）→ 写入 `mybooks` → 状态 completed → 30 秒后从活动列表移除（`:926-986`）。
- **中断恢复**：回到前台时恢复 paused/failed 任务；failed 任务保留部分文件以 Range 续传（`:436-482`）。

> 任务队列**只在内存**（`lib/data/services/download_manager.dart:144`），进程被杀后任务列表丢失，不会自动续传；只有进程存活期间的暂停/失败可恢复。

### 5.4 镜像与反爬

**镜像目录**：唯一硬编码 URL 是 `https://open-slum.org`（`lib/data/services/slum_catalogue.dart:166`）。四个页面分别提供 AA/LibGen/Z-Library/WeLib 镜像列表（`:171-177`），内存缓存 10 分钟并持久化到偏好 `slum_catalogue_cache`（`:188-190,434-475`）。SLUM 不可达且无缓存时返回空列表，应用报告“无镜像”，不会猜地址。

**排序**（`InstanceManager` + `SlumCatalogue.sortAuto`）：

- 自动模式：DOWN 永远最后且永不尝试；有新鲜本机测速结果的节点优先，按本机延迟升序；未测节点按保护难度 `none → diamwall → ddosGuard → cloudflare → unknown`，再按 SLUM 状态、延迟排序（`lib/data/services/slum_catalogue.dart`）。
- 本机测速：`lib/data/services/mirror_latency.dart` 只测启用且非 DOWN 节点，HEAD → GET 回退、TTFB、6s 超时、4 并发；`InstanceManager.localLatencies()` / `saveLocalLatencies()` 持久化 24 小时。过期结果继续显示“已过期”，但排序回退 SLUM（`lib/data/services/instance_manager.dart`）。
- 手动模式：用户排序优先，未排序的接在自动顺序后面（`lib/data/services/instance_manager.dart:183-214`）。
- 用户可单独禁用镜像；`enabledUrls()` 同时过滤 DOWN、用户禁用、以及 `headlessOnly` 时不可无头解决的镜像（`lib/data/services/instance_manager.dart:223-233`）。

**过盾链**：

- AA / WeLib 的 Cloudflare / DDoS-Guard：Dio 先抓，识别到挑战 → `WebviewChallengeSolver.fetchHtmlAfterChallenge()`。
  - 移动：headless WebView 60 秒；失败回退到可见 `ChallengeSolverPage`（`lib/data/services/webview_challenge_solver.dart:102-128`）。
  - 可见回退页：先显示全屏“正在验证访问权限”加载态（盾牌 + 进度），加载完成后切换为顶部“需要手动验证”提示 + 可交互 WebView；右上角刷新可重试（`lib/ui/challenge_solver_page.dart`）。
  - 桌面：`desktop_webview_window` 可见窗口 3 分钟（`:244-314`）。
  - 成功后 HTML 存入 `ChallengeHtmlCache`，TTL 10 分钟（`lib/data/services/challenge_html_cache.dart:20-48`），后续解析直接命中缓存。
- Z-Library DiamWall：解析 503 页面里的 seed，本地暴力 `SHA1(seed+i)` 求目标前缀，拿到 cookie 后重试（`lib/data/services/diamwall_solver.dart:41-111`）。
- **cookie 不回灌 Dio**：DDoS 清除态绑定浏览器 TLS 指纹，存下来的 cookie 对纯 HTTP 客户端无效（`lib/data/services/ddos_protection_handler.dart:8-11`、`lib/data/services/annas_archieve.dart:286-288`）。

### 5.5 阅读

- 应用不内置阅读器：`epub_view` / `pdfrx` / `epubx` / `flutter_tts` 依赖、内置阅读器页面和 TTS 服务均已删除。
- 下载中心、书籍详情和文件按钮的“打开”统一走 `openBookExternally()`（`lib/ui/components/file_buttons_widget.dart`），把本地文件交给系统/第三方阅读器（`OpenFile.open`）；CBR/CBZ 也直接交给系统应用。
- 数据库仍保留 `bookposition` 表以兼容旧备份，但应用内不再写入阅读进度。

### 5.6 下载中心

- 第三个 Tab，替换旧的“我的书库”。页面实现：`lib/ui/download_center_page.dart`。
- **进行中/失败任务**来自 `DownloadManager` 的内存队列；**已完成记录**来自 `mybooks` 表，因此重启后仍在。
- 页首进度卡聚合总进度、当前速度与预计剩余时间（UI 每秒采样已下载字节并做滑动平均，没有样本时隐藏速度/剩余）。
- 筛选：全部 / 进行中 / 已完成 / 失败；顶部支持全部暂停 / 全部继续。
- 已完成行点击进入书籍详情，“打开”按钮才调用外部阅读器；也可分享、在文件夹中显示（桌面）或删除记录；删除记录不删除本地文件。
- 已移除书库专属功能：标签、阅读状态筛选、9 种排序、书库搜索、磁盘同步入口。数据库 schema 与书籍详情保持不变（`bookposition` 表保留用于备份兼容）。
- 存储位置在“设置 → 高级 → 通用”中；切换目录会移动 pdf/epub/cbr/cbz 文件（目标已存在则保留源文件），然后扫描导入（`lib/ui/settings_page.dart`、`lib/data/services/files.dart`）。

### 5.7 备份、更新、日志

- 备份：导出 `preferences`、`mybooks`、`bookposition`、`browserOptions`、`booktags` 全表的 JSON（`format: openlib-backup` v1），不含书籍文件；恢复时单事务逐表删除+插入（`lib/data/services/backup_service.dart`）。
- 更新：GitHub Releases API（`lzoreal/OpenlibExtended`）；比较版本、可选预发布；下载后 Android 三级安装回退（`open_file` → `apk_sideload` → `android_package_installer`），Windows/Linux 启动安装包（`lib/data/services/update_checker.dart:130-970`）。
- 日志：内存环形队列（10000 条 / 2 小时），自动脱敏 authorization/cookie/token，正文截断 500 字符；设置页可导出分享（`lib/data/services/logger.dart`）。

---

## 6. 数据与持久化

### 6.1 SQLite schema v7

定义在 `lib/data/services/database.dart:81-172`：

| 表 | 主键 | 用途 |
|---|---|---|
| `mybooks` | `id`（md5/书源 id） | 已完成下载记录、文件名、格式、封面、链接 |
| `preferences` | `name` | 应用偏好（K/V，值为字符串或整数） |
| `bookposition` | `fileName` | EPUB CFI / PDF 页码 / `completed` 标记 |
| `browserOptions` | `name` | `userAgent`、`cookie`、按域 cookie |
| `booktags` | `(bookId, tag)` | 旧书库标签（schema 保留兼容，UI 不再使用） |

数据库位置：桌面 `getApplicationSupportDirectory()`，移动 `getDatabasesPath()`（`lib/data/services/database.dart:81-93`）。桌面需先初始化 FFI（`lib/main.dart:66-69`）。

### 6.2 偏好键

| 分组 | 键 |
|---|---|
| 外观 | `themeMode`、`darkMode`（旧版兼容）、`fontSizeScale`、`locale`、`readerFontSize` |
| 搜索 | `filterType`、`filterSort`、`filterFileType`、`filterLanguage`、`filterYear`、`searchProviders` |
| 阅读（旧版遗留） | `openPdfwithExternalApp`、`openEpubwithExternalApp`、`hasSeenReaderTutorial`、`readerFontSize` |
| 存储 | `bookStorageDirectory` |
| 下载/验证 | `showManualDownloadButton`、`backgroundVerification`、`donationKey` |
| 更新/引导 | `onboardingCompleted`、`lastRunVersion`、`includePrereleaseUpdates`、`enableAutoUpdate`（写了但未读，见 §10） |
| 通知 | `hasAskedNotificationPermission` |
| 镜像 | `instance_auto_mode`、`instance_manual_order`、`instance_disabled_hosts`、`instance_local_latency`、`slum_catalogue_cache` |
| 浏览器 | `browserOptions.userAgent`、`browserOptions.cookie`、`browserOptions.cookies_<domain>` |

注意：`getPreference()` 会把能解析为整数的值返回为 `int`，否则返回 `String`；键不存在时**抛异常**，调用方普遍依赖 `.catchError` 兜底（`lib/data/services/database.dart:391-408`）。`savePreference()` 只接受 `bool/int/String`，bool 自动转 0/1（`:373-389`）。

---

## 7. 平台差异

| 能力 | Android | iOS | Windows | Linux | macOS |
|---|---|---|---|---|---|
| 内置 WebView | ✅ headless + 可见 | ✅ headless + 可见 | ✅ 桌面窗口 / headless 抓取 | ✅ 桌面窗口（需 WebKitGTK 4.1） | ✅ 桌面窗口 |
| 后台 headless 抓镜像 | ✅ | ✅ | ✅（代码未禁用，依赖 WebView2） | ❌ 返回空，走手动 WebView（`lib/data/services/mirror_fetcher.dart:25-28`） | ✅（代码未禁用） |
| 下载通知 | ✅ | ❌ 服务仅 Android 初始化 | ❌ | ❌ | ❌ |
| TTS | ✅ | ✅ | ❌ | ❌ | ❌ |
| 外部 PDF/EPUB 阅读 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 应用内更新安装 | ✅ APK | ❌（打开 IPA 也无法安装） | ✅ EXE | ✅ AppImage | ❌ 未构建 |
| 发布产物 | 通用/分 ABI APK | 未签名 IPA | Inno Setup EXE | AppImage + tar.gz | 无 |

平台判断集中在 `lib/data/services/platform_utils.dart`；但过盾求解器还额外用 `WebviewChallengeSolver.isSupported`（移动或桌面，`lib/data/services/webview_challenge_solver.dart:38-39`）。

---

## 8. 测试

`test/` 共 37 个测试文件 + HTML fixtures，覆盖：

- 解析器：AA、LibGen、Z-Library、WeLib、搜索管理、元数据、镜像目录。
- 下载：状态机、Range 续传、镜像回退、目标选择、通知节流。
- 持久化/迁移：备份恢复、库整理、文件迁移、存储选择。
- UI/交互：结果页、设置页、实例页、下载中心、滚动、分享、开屏/What's New。
- 基础设施：网络错误分类、DDOS 处理、过盾、升级检测、本地化、Scoop 清单、Android APK 体积约束。

运行：

```bash
dart analyze lib/ test/
flutter test
flutter test --run-skipped   # 真实网络用例，默认 skip
```

CI 只跑 `dart analyze lib/ test/` + `flutter test`（`.github/workflows/build.yml:96-118`），不跑 skipped 的 live 用例。

当前工作树验证（2026-10-26）：`dart analyze` 无问题；`flutter test` 282 passed / 18 skipped；debug APK 已在真机安装并验证搜索流式返回、来源切换、下载行/打开按钮、设置存储位置。

---

## 9. 构建、CI 与发布

唯一 workflow：`.github/workflows/build.yml`。

- **触发**：GitHub Release 创建，或手动 `workflow_dispatch`。
- **Flutter**：固定 3.47.2。
- **测试门禁**：Android/iOS/Windows/Linux 构建都 `needs: [prepare, test]`。
- **版本号**：Release tag 去掉 `v`；手动可传 `version`/`release_tag`；否则读 `pubspec.yaml`。build number 用 `github.run_number`。构建前用 `sed` 把 `version:` 覆写进 `pubspec.yaml`（`:68-93,170-172,219-221,281-283,347-351`）。
- **Android 签名**：读取 secrets `KEYSTORE_BASE64`、`KEY_ALIAS`、`STORE_PASSWORD`、`KEY_PASSWORD`，生成 `android/app/upload-keystore.jks` 和 `key.properties`；缺失则产出未签名包（`:151-166`）。
- **产物命名**（更新检查器依赖这些关键字）：
  - `openlib-android-{universal,arm64,armeabi-v7a,x86_64}-<ver>.apk`
  - `openlib-ios-<ver>.ipa`
  - `openlib-windows-x64-<ver>.exe`
  - `openlib-linux-x64-<ver>.AppImage` / `.tar.gz`
- **发布**：`softprops/action-gh-release@v2` 把 artifacts 挂到 tag（`:462-489`）。
- **Scoop**：release 后 checkout `main`，运行 `tool/update_scoop_manifest.py`，下载 Windows 安装包算 SHA-256，改写 `bucket/openlibextended.json` 并由 bot 提交（`:493-524`）。因此 `bucket` 的 1.7.2 是最新发布版本，而 `pubspec.yaml` 仍是旧值。
- **Flatpak**：仅手动触发且依赖 Linux job；不在默认 release 资产中（`:398-459`）。

发布流程（人工）：改代码 → 合并 main → 创建 GitHub Release（tag `vX.Y.Z`）→ CI 测试/构建/挂资产 → bot 更新 Scoop 清单。版本号不需要手改 `pubspec.yaml`，CI 会覆盖。

---

## 10. 已知问题与技术债

按影响排序，均可在代码中复核：

1. **下载队列不持久化**：`_activeDownloads` 是内存 Map（`lib/data/services/download_manager.dart:144`），进程被杀后任务全丢；`resumeInterruptedDownloads()` 只能恢复仍在本进程内的 paused/failed 任务（`:436-459`）。Android 没有前台 Service，退后台可能被挂起。
2. **应用内更新无完整性校验**：只检查文件存在且 ≥10240 字节，没有 SHA-256/签名校验（`lib/data/services/update_checker.dart:566-585`）；Android 更新还固定优先 arm64，不检查设备 ABI（`:310-314`）。
3. **版本号双轨**：`pubspec.yaml:19` 是 1.0.11+14，发布版本由 CI 注入；本地构建、About 页、更新比较都可能受旧版本号影响。
4. **“自动更新”开关无效**：Onboarding 写入 `enableAutoUpdate`（`lib/ui/onboarding/onboarding_page.dart:106`），但没有任何代码读取它；启动时总会检查更新（`lib/main.dart:357-367`）。真正生效的是 `includePrereleaseUpdates`。
5. **搜索是并行聚合**：所有启用书源同时查询，按配置顺序合并并跨源去重；结果页用来源卡片切换单源视图。新增书源时不要把 UI 假设改回“顺序兜底、首个命中即停”。
6. **Z-Library 下载 MD5 校验必然失败**：Z-Library 的 `md5` 字段实际是 `/book/<id>` 的书籍 id（`lib/data/services/search_manager.dart:511-514`），`_verifyFileCheckSum` 拿它和文件 MD5 比较必然不等（`lib/data/services/download_manager.dart:206-221`），完成通知可能显示 “checksum failed”，但文件仍会入库。
7. **文件名清洗丢弃非 ASCII**：`removeSpecialChars` 删除所有非 ASCII（`lib/data/services/files.dart:24-31`），纯中文标题会退化为 md5 前 8 位；且文件名没有唯一后缀，同标题/同格式的书可能互相覆盖（`:17-108`）。
8. **分类页解析器有明显笔误**：`img"]` 选择器与 `attributes['herf']`（应为 `href`）导致分类内容解析为空或抛错（`lib/data/services/goodreads.dart:40-44`）；分类列表本身是 28 个硬编码分类和远程封面。
9. **Web 端不可用**：`lib/main.dart` 直接 `import 'dart:io'`、用 `Platform` 分支（`lib/main.dart:2,59,66`），README 仍把 Web 列为 roadmap。
10. **macOS 未进入发布流程**：有工程与 Podfile，但 CI 没有 macOS job，README Roadmap 仍列 “MacOs release”。
11. **iOS 最低版本配置不一致**：Xcode 工程 deployment target 12.0，Podfile 强制 15.0（`ios/Podfile:8`）；CI 用 `nm` 检查 iOS 17-only Swift 符号作为回归护栏（`.github/workflows/build.yml:225-246`）。修改依赖/Pod 时要保持 Podfile 与工程一致。
12. **Linux 后台抓镜像不可用**：`MirrorFetcherService` 在 Linux 直接返回空（`lib/data/services/mirror_fetcher.dart:25-28`），详情页因此走可见 WebView 手动流程（`lib/ui/book_info_page.dart:249-294`）；过盾仍可用桌面窗口（需 WebKitGTK 4.1）。
13. **通知能力仅 Android**：`DownloadNotificationService` 只在 Android 初始化；通知点击目前只 `debugPrint`，不会打开应用/任务（`lib/data/services/download_notification.dart:56-82`）。
14. **备份不含书籍文件**：仅备份数据库表，换机后需自行迁移书籍目录。
15. **本地化覆盖**：5 个语言、531 个 key，测试强制五份 ARB key 完全一致（`test/localization_test.dart:31-52`）；仍有少量硬编码英文（如设置页部分说明、实例页）。
16. **依赖锁有明确原因，不要随意升级**：`html` 0.15.6、`permission_handler_android` 13.0.1、`sqlite3_flutter_libs` 0.5.42 都是为兼容当前 Flutter/插件而钉死的（`pubspec.yaml:39-92`）。
17. **年份筛选硬编码到 2025**：`yearValues` 列表没有 2026（`lib/state/state.dart:128-147`），跨年后需要更新。
18. **`MirrorFetcherService` 错误路径不释放 WebView**：超时/异常返回时没有 `dispose()`（`lib/data/services/mirror_fetcher.dart:95-112`），长期运行可能泄漏。
19. **`setCompleted` 仍会清空阅读位置**：标记完成时以 `position: ''` 覆盖同一行（`lib/data/services/database.dart:314-320`）；内置阅读器已删除，应用内不再写入阅读位置，但旧数据/备份仍可能包含。

---

## 11. 常见改动指南

### 新增一个书源

1. 在 `SearchProviderId` 增加枚举，并实现 `SearchProvider`（`lib/data/services/search_manager.dart:22-36`）。
2. 在 `SearchManager` 默认 provider 列表注册；顺序决定合并优先级与默认视图。
3. 在 `MirrorService` / SLUM 页面映射中确认镜像归属（`lib/data/services/slum_catalogue.dart:22-30,171-177`）。
4. 在 `routeBookDetail` 中加入详情路由规则（优先用目录 host，其次 URL 形状）。
5. 在 `lib/ui/book_info_page.dart` 增加下载目标解析分支，必要时实现 `linkRefresher`。
6. 设置页书源开关、ARB 文案、解析器测试、下载测试。

### 新增一个设置项

1. 在 `lib/state/state.dart` 定义 provider。
2. 在 `main()` 读取偏好并通过 `ProviderScope.overrides` 注入（`lib/main.dart:196-219`）。
3. 在 `lib/ui/settings_page.dart` 加 `_SettingsTile` / `_SettingsSwitchTile`，切换时写库。
4. 若需要即时生效，同步更新对应服务的静态开关（参考 `backgroundVerification`）。

### 新增/修改数据库字段

1. 提升 `openDatabase(version:)`。
2. `onCreate` 与 `onUpgrade` 同时修改，使用 `ALTER TABLE` 并容忍“列已存在”。
3. 更新 `MyBook.toMap/listMapToMyBook`。
4. 评估 `BackupService` 的导出/恢复字段。
5. 增加迁移测试（参考现有 DB/备份测试）。

### 新增本地化文案

1. 在 `lib/l10n/app_en.arb` 添加 key + `@key` 描述。
2. 同步 `app_de.arb`、`app_es.arb`、`app_fr.arb`、`app_zh.arb`（测试会强制 key 一致）。
3. 运行 `flutter gen-l10n`，不要手改 `app_localizations*.dart`。
4. 在 UI 中用 `AppLocalizations.of(context).key`。

### 修改镜像/下载行为

- 镜像列表、顺序、启停：只改 `SlumCatalogue` / `InstanceManager`，不要在 provider 中硬编码 host。
- 下载重试/续传/链接刷新：只改 `DownloadManager`，并补充 `test/download_manager_test.dart`。
- 新增“拒绝原因”文案：走 `ZlibraryDownload.refusal` / `WelibDownload.refusal` / `chooseDownloadTarget`，不要用通用失败覆盖。

---

## 12. 关键文件索引

| 想了解 | 先看 |
|---|---|
| 启动、导航、主题 | `lib/main.dart` |
| 所有全局状态/数据源 | `lib/state/state.dart` |
| 搜索与书源 | `lib/data/services/search_manager.dart` |
| Anna's Archive | `lib/data/services/annas_archieve.dart` |
| 镜像目录 | `lib/data/services/slum_catalogue.dart`、`lib/data/services/instance_manager.dart` |
| 下载 | `lib/data/services/download_manager.dart`、`lib/data/services/download_target.dart` |
| 过盾 | `lib/data/services/webview_challenge_solver.dart`、`lib/data/services/diamwall_solver.dart` |
| 数据库 | `lib/data/services/database.dart` |
| 文件/目录/同步 | `lib/data/services/files.dart` |
| 详情页与下载按钮 | `lib/ui/book_info_page.dart` |
| 下载中心 | `lib/ui/download_center_page.dart`、`lib/data/services/download_manager.dart` |
| 搜索结果与来源切换 | `lib/ui/results_page.dart`、`lib/ui/components/source_journey_card.dart`、`lib/state/state.dart`（`initialSearchProvider`） |
| 外部阅读入口 | `lib/ui/components/file_buttons_widget.dart` |
| 设置 | `lib/ui/settings_page.dart` |
| 更新 | `lib/data/services/update_checker.dart` |
| CI/发布 | `.github/workflows/build.yml`、`tool/update_scoop_manifest.py` |
| 测试约定 | `test/*_test.dart`、`analysis_options.yaml` |

---

## 13. 交接清单

接手后建议逐项确认：

- [ ] 是否仍有 GitHub 仓库写权限、Release 权限、Actions secrets（Android keystore 四项）。
- [ ] 当前发布 tag 与 `bucket` 版本；下一版发布由谁创建 Release。
- [ ] 固定 Flutter 3.47.2 是否仍可安装；升级 Flutter 前先看 `pubspec.yaml` 的钉死依赖注释。
- [ ] 真机验证：四源搜索、AA/WeLib 过盾、Z-Library DiamWall、断网/切后台续传、通知、外部阅读器打开 EPUB/PDF、存储目录迁移、备份恢复、应用内更新。
- [ ] 检查 open-slum.org 页面结构是否变化（镜像解析全靠它）。
- [ ] 检查 GitHub API 匿名限流对更新检查的影响。
- [ ] 确认 AGPL 义务：修改分发需开源；不得上架 Google Play（README 明确说明）。
- [ ] 评估技术债优先级：下载持久化、更新完整性校验、文件名唯一性、分类页解析、自动更新开关。
