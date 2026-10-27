// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OpenlibExtended';

  @override
  String get navHome => '首页';

  @override
  String get navSearch => '搜索';

  @override
  String get navSettings => '设置';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get add => '添加';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get advancedSearch => '高级搜索';

  @override
  String get author => '作者';

  @override
  String get publisher => '出版社';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String resultsFor(String query) {
    return '“$query”的搜索结果';
  }

  @override
  String get followSystem => '跟随系统';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get languageSetting => '语言';

  @override
  String get systemLanguage => '系统默认';

  @override
  String get enableNotifications => '启用通知';

  @override
  String get notificationsExplanation =>
      '为了在后台显示下载进度，OpenlibExtended 需要通知权限。这样即使应用最小化，也能跟踪书籍下载进度。';

  @override
  String get maybeLater => '以后再说';

  @override
  String get enable => '启用';

  @override
  String get statusCompleted => '已完成';

  @override
  String get results => '结果';

  @override
  String get loading => '加载中…';

  @override
  String get unknown => '未知';

  @override
  String get about => '关于';

  @override
  String get aboutDescription =>
      '一个从影子图书馆（Anna\'s Archive、LibGen、Z-Library）下载电子书，并用你喜欢的阅读器打开的开源应用。';

  @override
  String get aboutForkNote => '此分支由 lzoreal 维护，用于个人使用和社区更新。';

  @override
  String get aboutOriginalNote =>
      '原应用由 dstark5 开发；扩展分支由 warreth 维护（https://github.com/warreth/OpenlibExtended）。';

  @override
  String get version => '版本';

  @override
  String get github => 'GitHub';

  @override
  String get thisForkByMaintainer => '此分支（由 lzoreal 维护）';

  @override
  String get reportAnIssue => '报告问题';

  @override
  String get originalProject => '原项目（由 dstark5 开发）';

  @override
  String get licence => '许可证';

  @override
  String get gplLicense => 'GPL v3.0 许可证';

  @override
  String couldNotLaunch(String url) {
    return '无法打开 $url';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get searchProvidersSection => '搜索来源';

  @override
  String get searchOrderHint => '四个来源同时搜索；此顺序决定结果合并与默认显示哪个来源。长按方块并拖动可调整顺序。';

  @override
  String get searchOrderReset => '恢复默认顺序';

  @override
  String get libraryInstancesSection => '镜像';

  @override
  String get appearanceSection => '外观';

  @override
  String get generalSection => '通用';

  @override
  String get advancedSection => '高级';

  @override
  String get backupSection => '备份';

  @override
  String get updatesSection => '更新';

  @override
  String get aboutSection => '关于';

  @override
  String get archiveInstance => '档案实例';

  @override
  String get mirrorsAndProviders => '镜像与来源';

  @override
  String get fontSizeTitle => '字体大小';

  @override
  String scaleValue(String value) {
    return '缩放：${value}x';
  }

  @override
  String get preview => '预览';

  @override
  String get storageLocation => '存储位置';

  @override
  String get manualDownloadButton => '手动下载按钮';

  @override
  String get backgroundVerification => '后台完成验证';

  @override
  String get backgroundVerificationHint => '无感完成 DDoS 验证。部分设备可能失败，可关闭后在可见窗口中验证';

  @override
  String get backgroundVerificationFix =>
      '如果验证持续失败，请尝试在设置中关闭“后台完成验证”——部分设备无法在无感状态下通过验证。';

  @override
  String get showManualDownloadHint => '显示手动触发下载的按钮';

  @override
  String get donationKeyTitle => 'Anna\'s Archive 捐赠密钥';

  @override
  String get enterKeyForFasterDownloads => '输入密钥以加快下载';

  @override
  String get aboutOpenlib => '关于 OpenlibExtended';

  @override
  String get redoOnboarding => '重新运行引导';

  @override
  String get resetAppSetup => '重置应用设置并重新开始';

  @override
  String get exportLogs => '导出日志';

  @override
  String get shareDiagnosticLogs => '分享诊断日志（最近 5 分钟）';

  @override
  String failedExportLogs(String error) {
    return '导出日志失败：$error';
  }

  @override
  String get donationKeyDialog => '捐赠密钥';

  @override
  String get enterYourKey => '输入你的密钥';

  @override
  String get instanceChanged => '镜像已更新';

  @override
  String rankingFailed(String error) {
    return '排序失败：$error';
  }

  @override
  String get autoRankInstances => '自动排序镜像';

  @override
  String get sortBySpeedOnStartup => '启动时自动按速度排序';

  @override
  String get rankInstancesNow => '立即排序镜像';

  @override
  String onLatestVersion(String version) {
    return '你已是最新版本（$version）';
  }

  @override
  String failedCheckUpdates(String error) {
    return '检查更新失败：$error';
  }

  @override
  String get includeBetaUpdates => '包含测试版更新';

  @override
  String get getPreReleaseVersions => '获取预发布版本';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get backupSaved => '备份已保存';

  @override
  String failedExportBackup(String error) {
    return '导出备份失败：$error';
  }

  @override
  String get backupRestored => '备份已恢复';

  @override
  String failedImportBackup(String error) {
    return '导入备份失败：$error';
  }

  @override
  String get atLeastOneSource => '至少需要一个搜索来源';

  @override
  String rankedFastest(String name, String time) {
    return '排序完成！最快：$name（${time}ms）';
  }

  @override
  String get rankingComplete => '排序完成';

  @override
  String get providerSourceOriginal => '最后搜索——受 DDoS-Guard 保护';

  @override
  String get providerLibgenCatalog => '快速直链下载——优先搜索';

  @override
  String get providerZlibMirrors => '镜像轮换，可能需要登录';

  @override
  String get themeTitle => '主题';

  @override
  String get saveBackupTitle => '保存备份';

  @override
  String get pickBackupFile => '选择备份文件';

  @override
  String get notABackup => '该文件不是 OpenlibExtended 备份';

  @override
  String get donationKeyHelper => '用于加快 Anna\'s Archive 下载';

  @override
  String get mirrorsTestedRanked => '镜像已按速度测试并排序';

  @override
  String testingFailed(String error) {
    return '测试失败：$error';
  }

  @override
  String get addCustomMirror => '添加自定义镜像';

  @override
  String get nameLabel => '名称';

  @override
  String get nameHint => '例如：我的 LibGen 镜像';

  @override
  String get serviceLabel => '服务';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get pleaseFillAllFields => '请填写所有字段';

  @override
  String get enterValidUrl => '请输入以 http:// 或 https:// 开头的有效 URL';

  @override
  String get mirrorAdded => '镜像添加成功';

  @override
  String get deleteMirror => '删除镜像';

  @override
  String deleteMirrorConfirm(String name) {
    return '确定要删除“$name”吗？';
  }

  @override
  String get mirrorDeleted => '镜像已删除';

  @override
  String get cannotDeleteDefaultMirrors => '无法删除默认镜像';

  @override
  String get manageMirrors => '管理镜像';

  @override
  String get noMirrorsAvailable => '没有可用镜像';

  @override
  String errorLabel(String error) {
    return '错误：$error';
  }

  @override
  String get addMirror => '添加镜像';

  @override
  String get testRankMirrors => '测试并按速度排序镜像';

  @override
  String get unreachable => '无法访问';

  @override
  String get open => '打开';

  @override
  String get unableToOpenFile => '无法打开文件！';

  @override
  String get openInSite => '在网站中打开';

  @override
  String get bookDeleted => '书籍已删除！';

  @override
  String get deleteBook => '删除书籍';

  @override
  String get deletePermanentWarning => '此操作永久生效，无法撤销';

  @override
  String get tryAgain => '重试';

  @override
  String get showBlockedContent => '显示被拦截页面内容';

  @override
  String get verifyInBrowser => '在浏览器中验证';

  @override
  String get manualVerificationRequired => '需要手动验证';

  @override
  String get systemBrowser => '系统浏览器';

  @override
  String get embeddedBrowser => '内置浏览器';

  @override
  String get unableToOpenVerification => '无法打开验证页面——没有可用 URL';

  @override
  String get blockedPageContent => '被拦截页面内容';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get tryUsingVpn => '尝试使用 VPN';

  @override
  String get trending => '热门';

  @override
  String get genres => '分类';

  @override
  String get copiedBookPath => '已将书籍路径复制到剪贴板';

  @override
  String get pauseDownload => '暂停下载';

  @override
  String get resumeDownload => '继续下载';

  @override
  String get cancelDownload => '取消下载';

  @override
  String get copiedBookLink => '已将书籍链接复制到剪贴板';

  @override
  String get noMirrors => '没有可用镜像！';

  @override
  String get downloadStartedBackground => '下载已在后台开始';

  @override
  String get bookDownloaded => '书籍已下载！';

  @override
  String get selectStorageToContinue => '请选择存储文件夹以继续';

  @override
  String get getStarted => '开始使用';

  @override
  String get next => '下一步';

  @override
  String get welcomeTitle => '欢迎使用 OpenlibExtended';

  @override
  String get welcomeSubtitle => '通往知识世界的个人入口。让我们完成初始设置。';

  @override
  String get whereToStoreBooks => '书籍保存在哪里？';

  @override
  String get noPathSelected => '未选择路径';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String get storageScanNote => '我们只会在此文件夹中查找 PDF/EPUB 文件，不会递归扫描子文件夹。';

  @override
  String get automaticUpdates => '自动更新';

  @override
  String get enableAutoUpdates => '启用自动更新';

  @override
  String get autoUpdatesFdroidNote => '如果你通过 F-Droid 安装，不建议启用（F-Droid 会处理更新）。';

  @override
  String get enableBetaUpdatesOnboarding => '启用测试版更新';

  @override
  String get betaUpdatesNote => '有可用预发布版本（测试版更新）时获取。';

  @override
  String get supportAnnasArchive => '支持 Anna\'s Archive';

  @override
  String get donationPitch =>
      '向 Anna\'s Archive 捐赠可获得更快的下载，并帮助他们为所有人维持服务。你可以在下方输入你的密钥。';

  @override
  String get annasSecretKey => 'Anna\'s Archive 密钥';

  @override
  String get supportThisApp => '支持本应用';

  @override
  String get sponsorPitch => '如果你喜欢这个应用，欢迎支持它的开发。这能让我投入更多时间把它做得更好！';

  @override
  String get sponsorOnGithub => '在 GitHub 上赞助';

  @override
  String get stayUpdated => '保持更新';

  @override
  String get notifyOnComplete => '下载完成时通知你。';

  @override
  String get chooseTheme => '选择主题';

  @override
  String get lightThemeShort => '浅色';

  @override
  String get darkThemeShort => '深色';

  @override
  String get verifyingAccess => '正在验证访问权限';

  @override
  String get done => '完成';

  @override
  String get noVoiceAvailable => '没有可用于朗读的语音';

  @override
  String get close => '关闭';

  @override
  String get reloadHealthData => '重新加载镜像状态';

  @override
  String addServiceMirror(String title) {
    return '添加 $title 镜像';
  }

  @override
  String get deleteMirrorTooltip => '删除镜像';

  @override
  String searchingOn(String source) {
    return '结果来自 $source';
  }

  @override
  String get sourceLibgen => 'LibGen';

  @override
  String get sourceZlib => 'Z-Library';

  @override
  String get sourceAnnas => 'Anna\'s Archive';

  @override
  String downloadFrom(String source) {
    return '正在从 $source 下载';
  }

  @override
  String get tryingNextSource => '这里没有结果，正在尝试下一个来源…';

  @override
  String get slowMirrorsSkipped => '正在使用更快的镜像';

  @override
  String whatsNewTitle(String version) {
    return '$version 的新功能';
  }

  @override
  String get whatsNewIntro => 'OpenlibExtended 已更新。以下是本次变更。';

  @override
  String get whatsNewTabFeatures => '新功能';

  @override
  String get whatsNewTabSources => '来源与镜像';

  @override
  String get whatsNewProvidersHint =>
      '此版本新增了搜索来源和镜像。更新列表可移除失效镜像并添加新镜像；所有搜索来源都会重新启用。';

  @override
  String get whatsNewUpdateInstances => '更新镜像列表';

  @override
  String get whatsNewInstancesUpdated => '镜像列表已更新';

  @override
  String get whatsNewContinue => '继续';

  @override
  String get whatsNewFeatureSpeed => '下载启动更快：不再探测镜像，快速主机优先，较慢的 IPFS 网关最后。';

  @override
  String get whatsNewFeatureSourceLabels => '每条搜索结果和每个下载现在都会显示来源目录。';

  @override
  String get whatsNewFeatureCovers => '缺失的 LibGen 封面会从书籍详情页获取。';

  @override
  String get categoryClassicsTitle => '经典';

  @override
  String get categoryClassicsInfo => '历久弥新的文学作品，常因其艺术价值与文化意义而备受推崇。';

  @override
  String get categoryRomanceTitle => '爱情';

  @override
  String get categoryRomanceInfo => '聚焦恋爱关系的故事，探索爱情、激情与情感联结。';

  @override
  String get categoryFictionTitle => '小说';

  @override
  String get categoryFictionInfo => '出自想象而非真实事件的叙事文学。';

  @override
  String get categoryYoungAdultTitle => '青少年';

  @override
  String get categoryYoungAdultInfo => '面向青少年读者的书籍，探讨与青春期相关的主题。';

  @override
  String get categoryFantasyTitle => '奇幻';

  @override
  String get categoryFantasyInfo => '包含魔法元素、神话生物与奇幻世界的类型。';

  @override
  String get categoryScienceFictionTitle => '科幻';

  @override
  String get categoryScienceFictionInfo => '探索未来构想、先进科技与太空探索的文学。';

  @override
  String get categoryNonfictionTitle => '非虚构';

  @override
  String get categoryNonfictionInfo => '基于事实信息的作品，包括随笔、传记与纪实。';

  @override
  String get categoryChildrenTitle => '儿童';

  @override
  String get categoryChildrenInfo => '面向小读者的书籍，通常配有插图、叙事简单。';

  @override
  String get categoryHistoryTitle => '历史';

  @override
  String get categoryHistoryInfo => '考察历史事件、文化与重要历史人物的文学。';

  @override
  String get categoryMysteryTitle => '悬疑';

  @override
  String get categoryMysteryInfo => '以悬念情节为核心的故事，常涉及犯罪或待解谜题。';

  @override
  String get categoryCoversTitle => '封面';

  @override
  String get categoryCoversInfo => '以视觉形式呈现书籍的艺术与设计，影响读者的兴趣。';

  @override
  String get categoryHorrorTitle => '恐怖';

  @override
  String get categoryHorrorInfo => '通过悬念叙事唤起读者恐惧、不安或惊骇的类型。';

  @override
  String get categoryHistoricalFictionTitle => '历史小说';

  @override
  String get categoryHistoricalFictionInfo => '设定于特定历史时期的小说，将真实事件与虚构人物交织在一起。';

  @override
  String get categoryBestTitle => '精选';

  @override
  String get categoryBestInfo => '常指广受好评或受欢迎的书籍，通常按榜单或奖项分类。';

  @override
  String get categoryTitlesTitle => '书名';

  @override
  String get categoryTitlesInfo => '书籍的名称，往往反映其主题或题材。';

  @override
  String get categoryMiddleGradeTitle => '中年级';

  @override
  String get categoryMiddleGradeInfo => '面向 8–12 岁读者的书籍，主题与人物均适合其年龄。';

  @override
  String get categoryParanormalTitle => '超自然';

  @override
  String get categoryParanormalInfo => '融入超自然元素的故事，包括鬼魂、吸血鬼与异界生物。';

  @override
  String get categoryLoveTitle => '恋爱';

  @override
  String get categoryLoveInfo => '探讨各种形式与关系中的爱情复杂性与细微差别的主题。';

  @override
  String get categoryQueerTitle => '酷儿';

  @override
  String get categoryQueerInfo => '呈现 LGBTQ+ 光谱内多元性取向与性别认同的文学。';

  @override
  String get categoryHistoricalRomanceTitle => '历史爱情';

  @override
  String get categoryHistoricalRomanceInfo => '以历史为背景、融合爱情情节的小说。';

  @override
  String get categoryContemporaryTitle => '当代';

  @override
  String get categoryContemporaryInfo => '以现代为背景的作品，常涉及当下社会议题与贴近生活的人物。';

  @override
  String get categoryThrillerTitle => '惊悚';

  @override
  String get categoryThrillerInfo => '以紧张刺激、悬念与意外转折为核心的惊悚类型。';

  @override
  String get categoryWomenTitle => '女性';

  @override
  String get categoryWomenInfo => '探讨女性经验、视角与赋权的文学。';

  @override
  String get categoryBiographyTitle => '传记';

  @override
  String get categoryBiographyInfo => '讲述个人生平、突出其成就与挑战的非虚构作品。';

  @override
  String get categoryLgbtqTitle => 'LGBTQ';

  @override
  String get categoryLgbtqInfo => '呈现女同、男同、双性恋、跨性别与酷儿群体经验的包容性文学。';

  @override
  String get categorySeriesTitle => '系列';

  @override
  String get categorySeriesInfo => '围绕共同故事线或人物的一组相关书籍。';

  @override
  String get categoryTitleChallengeTitle => '书名挑战';

  @override
  String get categoryTitleChallengeInfo => '鼓励围绕书名进行创意构思的挑战或竞赛。';

  @override
  String get mirrorsTitle => '镜像';

  @override
  String get automaticMirrorOrder => '自动排序镜像';

  @override
  String get mirrorOrderAutoHint => '优先最简单的防护，其次最快。推荐。';

  @override
  String get mirrorOrderManualHint => '手动：使用箭头自定义顺序。';

  @override
  String get mirrorListUpToDate => '镜像列表已是最新';

  @override
  String mirrorListUpdated(int count) {
    return '镜像列表已更新：$count 项变更';
  }

  @override
  String mirrorRefreshFailed(String error) {
    return '刷新失败：$error';
  }

  @override
  String get mirrorCatalogueUnreachable => '无法访问 open-slum.org，暂无镜像列表';

  @override
  String get mirrorFooterNote =>
      '镜像地址与状态来自 open-slum.org 并自动刷新。标记为 DOWN 的镜像永远不会被访问。点右上角测速按钮可测本机到已启用节点的延迟。';

  @override
  String get mirrorLatencyTestTooltip => '测试本机延迟';

  @override
  String get mirrorLatencyNotTested => '本机未测速';

  @override
  String get mirrorLatencyTesting => '本机测速中…';

  @override
  String get mirrorLatencyTimeout => '本机超时';

  @override
  String mirrorLatencyLocal(String latency) {
    return '本机 $latency';
  }

  @override
  String get mirrorLatencyJustNow => '刚刚';

  @override
  String get mirrorLatencyExpired => '已过期';

  @override
  String mirrorLatencyDone(int reachable, int total, String fastest) {
    return '测速完成：$reachable/$total 个节点可达，最快 $fastest';
  }

  @override
  String get mirrorLatencyAllTimedOut => '测速完成 · 没有节点响应';

  @override
  String get mirrorLatencyNoTargets => '没有已启用的节点可测速';

  @override
  String mirrorLatencyFailed(String error) {
    return '测速失败：$error';
  }

  @override
  String get noMirrorsReported => '暂无镜像报告';

  @override
  String get noMirrorsReportedHint => 'open-slum.org 尚无记录，或无法访问。';

  @override
  String get couldNotLoadMirrors => '无法加载镜像';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get reportedDownNeverContacted => '报告为 DOWN，不会被访问';

  @override
  String get mirrorServiceLibgenHint => '镜像可用时可快速下载，无需验证';

  @override
  String get mirrorServiceZlibHint => 'DiamWall 镜像可在后台自动完成验证';

  @override
  String get mirrorServiceWelibHint => 'Cloudflare 防护的搜索，书籍页面可直接访问';

  @override
  String get mirrorServiceAnnasHint => '阅读、详情与下载';

  @override
  String get mirrorStatusUp => '在线';

  @override
  String get mirrorStatusDegraded => '降级';

  @override
  String get mirrorStatusProtected => '受保护';

  @override
  String get mirrorStatusDown => '离线';

  @override
  String get searchEmptyQuery => '搜索框为空';

  @override
  String get filterTypeLabel => '类型';

  @override
  String get filterSortLabel => '排序方式';

  @override
  String get filterFileTypeLabel => '文件类型';

  @override
  String get filterYearLabel => '年份';

  @override
  String get filterAll => '全部';

  @override
  String get typeAnyBooks => '任意书籍';

  @override
  String get typeUnknownBooks => '未知书籍';

  @override
  String get typeFictionBooks => '小说类书籍';

  @override
  String get typeNonfictionBooks => '非虚构类书籍';

  @override
  String get typeComicBooks => '漫画书';

  @override
  String get typeMagazine => '杂志';

  @override
  String get typeStandardsDocument => '标准文档';

  @override
  String get typeJournalArticle => '期刊文章';

  @override
  String get sortMostRelevant => '最相关';

  @override
  String get sortNewest => '最新';

  @override
  String get sortOldest => '最旧';

  @override
  String get sortLargest => '最大';

  @override
  String get sortSmallest => '最小';

  @override
  String get yearBefore1980 => '1980 年以前';

  @override
  String get langEnglish => '英语';

  @override
  String get langSpanish => '西班牙语';

  @override
  String get langFrench => '法语';

  @override
  String get langGerman => '德语';

  @override
  String get langItalian => '意大利语';

  @override
  String get langPortuguese => '葡萄牙语';

  @override
  String get langRussian => '俄语';

  @override
  String get langChinese => '中文';

  @override
  String get langJapanese => '日语';

  @override
  String get langKorean => '韩语';

  @override
  String get langArabic => '阿拉伯语';

  @override
  String get langHindi => '印地语';

  @override
  String get langMalayalam => '马拉雅拉姆语';

  @override
  String get langDutch => '荷兰语';

  @override
  String get langPolish => '波兰语';

  @override
  String get langTurkish => '土耳其语';

  @override
  String get langSwedish => '瑞典语';

  @override
  String get langIndonesian => '印度尼西亚语';

  @override
  String get langVietnamese => '越南语';

  @override
  String get langCzech => '捷克语';

  @override
  String get langGreek => '希腊语';

  @override
  String get langRomanian => '罗马尼亚语';

  @override
  String get langHungarian => '匈牙利语';

  @override
  String get langUkrainian => '乌克兰语';

  @override
  String get langHebrew => '希伯来语';

  @override
  String get langThai => '泰语';

  @override
  String get langPersian => '波斯语';

  @override
  String get langBengali => '孟加拉语';

  @override
  String get langFinnish => '芬兰语';

  @override
  String get langNorwegian => '挪威语';

  @override
  String get langDanish => '丹麦语';

  @override
  String get downloadsTitle => '下载';

  @override
  String get downloadQueued => '排队中';

  @override
  String get downloadGettingMirrors => '正在获取镜像…';

  @override
  String get downloadFindingMirror => '正在查找镜像…';

  @override
  String get downloadDownloading => '下载中';

  @override
  String get downloadPaused => '已暂停';

  @override
  String get downloadVerifying => '校验中';

  @override
  String get downloadCancelled => '已取消';

  @override
  String get downloadFailedGeneric => '下载失败';

  @override
  String get verifyAction => '验证';

  @override
  String get descriptionLabel => '简介';

  @override
  String get noDescriptionAvailable => '暂无简介';

  @override
  String get couldNotOpenLink => '无法打开链接。';

  @override
  String get manualDownloadAction => '手动下载';

  @override
  String get fastDownloadStarted => '后台已开始快速下载 🚀';

  @override
  String get welibNoDownloadLink => 'WeLib 未提供此书的下载链接。';

  @override
  String get welibPageUnreadable => '无法读取 WeLib 下载页面。';

  @override
  String get fileNotFoundDownloadFailed => '文件不存在，下载可能已失败。';

  @override
  String shareBookMessage(String title, String link) {
    return '发现这本精彩的书：“$title”\n了解更多：$link';
  }

  @override
  String get webviewWindowTitle => '验证访问 - OpenlibExtended';

  @override
  String get webviewBrowserOpen => '浏览器窗口已打开';

  @override
  String get webviewBrowserOpening => '正在打开浏览器窗口…';

  @override
  String get webviewInstructions =>
      '1. 在浏览器窗口中完成 CAPTCHA\n2. 等待页面完全加载\n3. 点击上方的“完成”继续';

  @override
  String get webviewPreparingDownload => '正在准备下载…';

  @override
  String get webviewPreparingHint => '正在验证访问并获取下载链接，请稍候';

  @override
  String get changeStorageHint => '更改书籍保存位置';

  @override
  String versionWithBuild(String version, String build) {
    return '版本 $version+$build';
  }

  @override
  String get backupShareText => 'OpenlibExtended 备份';

  @override
  String get exportBackupTitle => '导出备份';

  @override
  String get exportBackupSubtitle => '将设置、书籍与镜像实例保存为 JSON 文件';

  @override
  String get importBackupTitle => '导入备份';

  @override
  String get importBackupSubtitle => '从备份文件恢复（会替换当前数据）';

  @override
  String get providerWelibCatalog => 'Cloudflare 防护的搜索，书籍页面可直接访问';

  @override
  String get errorWhatToDo => '如何处理';

  @override
  String get errorVpnDescription => 'VPN 可帮助绕过地区限制并访问内容。';

  @override
  String get errorVerificationPrompt => '该网站要求验证你是真人。我们会打开浏览器窗口，供你完成验证。';

  @override
  String get errorVerificationReturn => '完成验证后，返回应用并点击“重试”。';

  @override
  String get errorNoContent => '暂无内容';

  @override
  String get networkErrorNoInternetTitle => '无网络连接';

  @override
  String get networkErrorNoInternetSolution => '请检查网络连接，确保 Wi-Fi 或移动数据已开启。';

  @override
  String get networkErrorCloudflareTitle => '访问被 DDoS 防护拦截';

  @override
  String get networkErrorCloudflareSolution =>
      '该网站受防护并拦截了应用。请尝试 VPN、将 DNS 改为 1.1.1.1 或 8.8.8.8，或在浏览器中验证。';

  @override
  String get networkErrorServerUnavailableTitle => '服务器暂时不可用';

  @override
  String get networkErrorServerUnavailableSolution =>
      '服务器出现问题。请稍后重试，或在设置中选择其他镜像。';

  @override
  String get networkErrorTimeoutTitle => '请求超时';

  @override
  String get networkErrorTimeoutSolution => '服务器响应时间过长。请检查网络后重试。';

  @override
  String get networkErrorForbiddenTitle => '访问被拒绝';

  @override
  String get networkErrorForbiddenSolution =>
      '你没有访问此资源的权限。请尝试 VPN、更改 DNS，或在设置中使用其他镜像。';

  @override
  String get networkErrorRateLimitedTitle => '请求过于频繁';

  @override
  String get networkErrorRateLimitedSolution => '请求次数过多。请等待几分钟后重试。';

  @override
  String get networkErrorSslTitle => '安全连接失败';

  @override
  String get networkErrorSslSolution => '你的网络可能阻止了安全连接。请尝试 VPN 或更换网络。';

  @override
  String get networkErrorDnsTitle => '找不到服务器';

  @override
  String get networkErrorDnsSolution =>
      '无法访问该网站，可能被网络运营商屏蔽。请尝试 VPN，或将 DNS 改为 1.1.1.1 / 8.8.8.8。';

  @override
  String get networkErrorUnknownTitle => '出现问题';

  @override
  String get networkErrorUnknownSolution => '请重试。如果问题仍然存在，请重启应用。';

  @override
  String get updatePermissionTitle => '需要权限';

  @override
  String get updatePermissionBody =>
      '安装应用更新需要授予 OpenlibExtended 安装软件包的权限。\n\n这样应用才能自动安装包含修复与新功能的新版本。\n\n系统将跳转到设置页面以开启此权限。';

  @override
  String get updateOpenSettings => '打开设置';

  @override
  String get updateDebugBuildWarning =>
      '检测到调试版本：由于签名不一致，更新可能失败并提示“应用未安装”。请先卸载此应用。';

  @override
  String get updateOpeningInstaller => '正在打开安装程序…如果没有反应，说明安装失败。';

  @override
  String get updateManualInstall => '手动安装';

  @override
  String get updateInstallationIssueTitle => '安装问题';

  @override
  String get updateInstallationIssueBody =>
      '自动安装程序无法打开 APK，这在某些 Android 版本上可能发生。\n\n你可以使用以下方式之一手动安装：';

  @override
  String updateFileLabel(String file) {
    return '文件：$file';
  }

  @override
  String get updateInstallationFailed => '安装失败';

  @override
  String get updateMethodsTried => '已尝试的方法：';

  @override
  String get updateErrorsEncountered => '遇到的错误：';

  @override
  String updateMethodNumber(int number) {
    return '方法 $number';
  }

  @override
  String get updateDownloadViaBrowser => '通过浏览器下载';

  @override
  String get updateInstallationErrorTitle => '安装错误';

  @override
  String get updateOk => '确定';

  @override
  String get updateTryManualInstall => '尝试手动安装';

  @override
  String updateInstallFailed(String error) {
    return '安装更新失败：$error';
  }

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String updateVersionAvailable(String version) {
    return '版本 $version 已发布！';
  }

  @override
  String get updatePreRelease => '预发布版';

  @override
  String get updateWhatsNew => '更新内容：';

  @override
  String get updateLater => '稍后';

  @override
  String get updateDownloadAndInstall => '下载并安装';

  @override
  String get updateDownloadFromGithub => '从 GitHub 下载';

  @override
  String get updateViewOnGithub => '在 GitHub 查看';

  @override
  String get updateDownloading => '正在下载更新';

  @override
  String get updateDownloadComplete => '下载完成';

  @override
  String updateVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get updateOpeningInstallerShort => '正在打开安装程序…';

  @override
  String get updateConnecting => '正在连接…';

  @override
  String get updateFileNotFound => '找不到已下载的文件';

  @override
  String updateFileCorrupted(String size) {
    return '下载的文件似乎已损坏（仅 $size）';
  }

  @override
  String get updatePermissionDenied => '安装应用的权限被拒绝，你仍然可以手动安装。';

  @override
  String get updateMayHaveFailedSilently => '可能已静默失败';

  @override
  String get updateMethodOpenFile => '打开文件';

  @override
  String get updateMethodApkSideload => 'APK 侧载';

  @override
  String get updateMethodPackageInstaller => '软件包安装程序';

  @override
  String get networkErrorBookNotFoundTitle => '未找到书籍';

  @override
  String get networkErrorBookNotFoundSolution =>
      '页面已加载，但没有书籍信息。链接可能已失效，请尝试按书名搜索。';

  @override
  String get networkErrorBookDetailsUnavailableTitle => '无法加载书籍详情';

  @override
  String get networkErrorBookDetailsUnavailableSolution =>
      '无法获取书籍信息。请重试，或在设置中使用其他镜像。';

  @override
  String get downloadNoWorkingMirrors => '没有可用的镜像！';

  @override
  String get downloadAllMirrorsFailed => '所有镜像均失败！';

  @override
  String get downloadErrorGettingMirrors => '获取镜像时出错';

  @override
  String downloadCouldNotSave(String error) {
    return '无法保存到书库：$error';
  }

  @override
  String get appLogsShareSubject => 'OpenlibExtended 应用日志';

  @override
  String appLogsShareText(int minutes) {
    return 'OpenlibExtended 最近 $minutes 分钟的应用日志';
  }

  @override
  String notificationAlreadyDownloading(String title) {
    return '已在下载：$title';
  }

  @override
  String notificationQueued(String title) {
    return '已排队：$title';
  }

  @override
  String get notificationStartingFastDownload => '正在开始快速下载…';

  @override
  String get notificationVerifyingFile => '正在校验文件…';

  @override
  String get notificationDownloadComplete => '下载完成！';

  @override
  String get notificationDownloadCompleteChecksumFailed => '下载完成（校验和失败）';

  @override
  String get notificationChannelDescription => '书籍下载进度通知';

  @override
  String notificationDownloadingPercent(int percent) {
    return '下载中… $percent%';
  }

  @override
  String notificationFailed(String error) {
    return '失败：$error';
  }

  @override
  String get notificationDownloadTitle => '下载';

  @override
  String get searchHintTitle => '找到下一本书';

  @override
  String get searchHintBody => '按书名、作者或 ISBN 搜索，或使用上方筛选。';

  @override
  String get homeSearchHint => '搜索书名、作者或 ISBN';

  @override
  String get trendingThisWeek => '本周热门';

  @override
  String get keepExploring => '继续探索';

  @override
  String get browseGenres => '按类型浏览';

  @override
  String get settingsManage => '管理';

  @override
  String get searchSourcesTitle => '搜索来源';

  @override
  String get searchSourceAuto => '全部';

  @override
  String get searchSourceAutoHint => '四个来源同时搜索，结果自动合并';

  @override
  String get searchSourceOnlyHint => '只显示这个来源的结果';

  @override
  String get bookDetailsTitle => '书籍详情';

  @override
  String get fileInfoTitle => '文件信息';

  @override
  String get formatLabel => '格式';

  @override
  String get publishedYearLabel => '出版年份';

  @override
  String get fileSizeLabel => '文件大小';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get sourceLabel => '来源';

  @override
  String get sourceAndDownload => '来源与下载';

  @override
  String get openAtSource => '在来源打开';

  @override
  String get sourceWelib => 'WeLib';

  @override
  String resultsCount(int count) {
    return '$count 个结果';
  }

  @override
  String get sourceStatusUntried => '未尝试';

  @override
  String get sourceStatusFailed => '失败';

  @override
  String sourceResultCount(int count) {
    return '$count 本';
  }

  @override
  String get searchingTitle => '正在搜索';

  @override
  String get searchingSourcesBody => '四个来源同时查询，返回后按顺序合并并去重。';

  @override
  String get loadMoreResults => '下滑加载更多';

  @override
  String noResultsFor(String query) {
    return '没有找到「$query」';
  }

  @override
  String get noResultsSourcesBody => '所有来源都没有匹配结果。试试缩短关键词，或清除筛选条件后重新搜索。';

  @override
  String get modifySearch => '修改搜索';

  @override
  String get clearFiltersRetry => '清除筛选重试';

  @override
  String get sourceSheetTitle => '切换搜索来源';

  @override
  String sourceSheetSubtitle(String query) {
    return '查看「$query」在不同来源中的结果。';
  }

  @override
  String get sourceAutoRecommended => '全部来源（合并）';

  @override
  String get sourceSheetNote => '仅本次搜索生效，不会更改默认来源设置。';

  @override
  String get recentSearchesTitle => '最近搜索';

  @override
  String get clearAll => '清除';

  @override
  String get searchSuggestionsTitle => '搜索建议';

  @override
  String get searchSuggestionsLive => '实时联想';

  @override
  String get searchRecentHint => '从最近搜索继续，或换一个关键词开始';

  @override
  String searchInAllSources(String query) {
    return '在全部来源中搜索「$query」';
  }

  @override
  String searchInSource(String query, String source) {
    return '在 $source 中搜索「$query」';
  }

  @override
  String searchAutoScope(int count) {
    return '$count 个来源同时搜索';
  }

  @override
  String searchSourceOnlyScope(String source) {
    return '仅 $source';
  }

  @override
  String removeRecentSearch(String query) {
    return '删除「$query」';
  }

  @override
  String get clearSearch => '清空搜索';

  @override
  String get searchSupportHint => '支持书名、作者、ISBN 与 MD5，四个书源会并行检索。';

  @override
  String get tryThese => '试试这些';

  @override
  String get filtersAndAdvanced => '筛选与高级搜索';

  @override
  String get resultsAutoMerged => '结果自动合并';

  @override
  String get searchAdvancedHint => '需要限定作者、出版社、年份、语言或格式？切换到「高级搜索」。';

  @override
  String get searchApply => '应用并搜索';

  @override
  String get resetFilters => '重置';

  @override
  String get anyValue => '不限';

  @override
  String get advancedFilterNote => '高级筛选只影响本次搜索，不会更改默认来源。';

  @override
  String get filterRelevance => '相关度';

  @override
  String get searchAllSourcesLabel => '全部来源';

  @override
  String get sourceMarkAll => '全';

  @override
  String get sourceAnnasShort => 'Anna\'s';

  @override
  String get sourceZlibShort => 'Z-Lib';

  @override
  String sourceCount(int count) {
    return '$count 个来源';
  }

  @override
  String sourceStillSearching(String source) {
    return '$source 仍在检索，结果将自动补充。';
  }

  @override
  String otherSources(String summary) {
    return '其他来源：$summary';
  }

  @override
  String sourcesResponded(int count) {
    return '$count 个来源已响应';
  }

  @override
  String get sourceStatusTitle => '来源状态';

  @override
  String sourceStatusSummary(int ok, int failed) {
    return '$ok 个已响应，$failed 个失败';
  }

  @override
  String sourceResponded(int count) {
    return '已响应 · $count';
  }

  @override
  String get sourceTimedOut => '超时';

  @override
  String get searchAgain => '重新搜索';

  @override
  String sourceMirrorHint(String source) {
    return '来自 $source 镜像，下载后自动校验 MD5。';
  }

  @override
  String get downloadThisBook => '下载本书';

  @override
  String get navDownloads => '下载中心';

  @override
  String get downloadCenterTitle => '下载中心';

  @override
  String downloadCenterSummary(int active, int paused, int queued) {
    return '$active 个进行中 · $paused 个已暂停 · $queued 个等待';
  }

  @override
  String get downloadCenterNoTasks => '还没有下载任务';

  @override
  String get downloadCenterAllPause => '全部暂停';

  @override
  String get downloadCenterAllResume => '全部继续';

  @override
  String get downloadCenterAll => '全部';

  @override
  String get downloadCenterActive => '进行中';

  @override
  String get downloadCenterCompleted => '已完成';

  @override
  String get downloadCenterFailed => '失败';

  @override
  String get downloadCenterInProgress => '进行中';

  @override
  String get downloadCenterNeedsAttention => '需要处理';

  @override
  String get downloadCenterOrderHint => '按加入顺序';

  @override
  String get downloadCenterQueueMemory => '队列为内存态';

  @override
  String get downloadCenterCompletedHint => '点书名看详情 · 点打开用外部阅读器';

  @override
  String get downloadCenterRemoveNote => '移除记录时可勾选同时移除本地文件；队列仅存在内存中，进程退出后不续传。';

  @override
  String get rangeResume => 'Range 续传';

  @override
  String storagePathMessage(String path) {
    return '文件保存在：$path';
  }

  @override
  String get downloadCenterRetryHint => '重试会保留已下载部分';

  @override
  String get downloadCenterOpenHint => '点书名查看详情';

  @override
  String get downloadCenterCurrentProgress => '当前任务总进度';

  @override
  String get downloadCenterSpeed => '当前速度';

  @override
  String get downloadCenterRemaining => '预计剩余';

  @override
  String downloadCenterTodayCount(int count) {
    return '今日已完成 $count 本';
  }

  @override
  String downloadCenterEtaSeconds(int seconds) {
    return '还剩 $seconds 秒';
  }

  @override
  String downloadCenterEtaMinutes(int minutes) {
    return '还剩 $minutes 分钟';
  }

  @override
  String downloadCenterStorageSummary(int count, String size) {
    return '本月已下载 $count 本 · $size';
  }

  @override
  String downloadCenterStorageLegend(String epub, String pdf) {
    return 'EPUB $epub · PDF $pdf';
  }

  @override
  String get downloadCenterRemoveRecord => '删除记录';

  @override
  String get downloadCenterRemoveRecordBody => '默认只移除记录；本地文件会保留在下载目录。';

  @override
  String get downloadCenterRemoveFile => '同时移除文件';

  @override
  String get downloadCenterShowInFolder => '在文件夹中显示';

  @override
  String get downloadCenterBookDetails => '书籍详情';

  @override
  String get share => '分享';

  @override
  String get downloadCenterEmptyTitle => '还没有下载任务';

  @override
  String get downloadCenterEmptyBody => '在书籍详情页点「下载」，任务会出现在这里。完成之后可以直接打开阅读。';

  @override
  String get downloadCenterGoSearch => '去搜索';

  @override
  String get downloadCenterTip => 'EPUB 与 PDF 都支持。暂停后继续会从断点续传，不用重新下载。';

  @override
  String get downloadBook => '下载';

  @override
  String get homeTitle => '发现';

  @override
  String get homeEyebrow => '发现好书';

  @override
  String get browseEyebrow => '浏览';

  @override
  String get searchEyebrow => '搜索书源';

  @override
  String get downloadEyebrow => '本地存储';

  @override
  String get settingsEyebrow => '偏好';

  @override
  String get trendingSource => 'Goodreads 榜单';

  @override
  String categoryCount(int count) {
    return '$count 个分类';
  }

  @override
  String get categorySearchHint => '在分类中查找';

  @override
  String get categoryInfoHint => '分类由 SLUM 镜像目录提供，可离线缓存 24 小时。';

  @override
  String get searchSourcesIntro => '四个书源并行检索。关闭的来源不会发起请求，镜像地址由 SLUM 目录下发。';

  @override
  String get sourceOn => '已启用';

  @override
  String get sourceOff => '已关闭';

  @override
  String get mirrorsShort => '镜像';

  @override
  String mirrorNodeCount(int count) {
    return '$count 个节点';
  }

  @override
  String get refreshMirrors => '刷新镜像';

  @override
  String get sourceBehaviorSection => '来源行为';

  @override
  String get displaySection => '显示';

  @override
  String get currentLanguage => '当前语言';

  @override
  String get behaviorSection => '行为';

  @override
  String get infoSection => '信息';

  @override
  String get thanksSection => '致谢';

  @override
  String get changelogTitle => '更新日志';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get projectHome => '项目主页';

  @override
  String get slumCatalogue => 'SLUM 镜像目录';

  @override
  String get slumCatalogueSubtitle => 'open-slum.org';

  @override
  String get challengeSolverTitle => '过盾求解器';

  @override
  String get challengeSolverSubtitle => 'WebView 手动验证兜底';

  @override
  String get aboutDisclaimer => '不提供书籍内容，仅做镜像检索与下载。请支持正版。';

  @override
  String get maintenanceSection => '维护';

  @override
  String get languageCardHint => '界面文字，立即生效';

  @override
  String get themeCardHint => '跟随系统，或固定浅色 / 深色';

  @override
  String get fontSizeCardHint => '影响全站文字大小';

  @override
  String get fontPreviewSample => '书是随身携带的避难所。';

  @override
  String get themeFollowSystemShort => '系统';

  @override
  String get themeLightShort => '浅色';

  @override
  String get themeDarkShort => '深色';

  @override
  String get sourceAllSearchedHint => '四个来源同时搜索，点击切换结果。';

  @override
  String get tapToExpandLanguage => '点击展开多语言设置';

  @override
  String get tapToCollapseLanguage => '点击收起';

  @override
  String get sourceStatusSearching => '搜索中…';

  @override
  String get verificationPageLoading => '正在加载验证页面，完成后会自动继续。';

  @override
  String get verificationPageInstructions => '请在下方完成验证，应用会自动继续。';
}
