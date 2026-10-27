// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenlibExtended';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get advancedSearch => 'Advanced Search';

  @override
  String get author => 'Author';

  @override
  String get publisher => 'Publisher';

  @override
  String get noResultsFound => 'No results found';

  @override
  String resultsFor(String query) {
    return 'Results for \'$query\'';
  }

  @override
  String get followSystem => 'Follow the System';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get languageSetting => 'Language';

  @override
  String get systemLanguage => 'System default';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationsExplanation =>
      'OpenlibExtended needs notification permission to show download progress in the background. This helps you track your book downloads even when the app is minimized.';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get enable => 'Enable';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get results => 'Results';

  @override
  String get loading => 'Loading...';

  @override
  String get unknown => 'Unknown';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'An open source app that downloads books from shadow libraries (Anna\'s Archive, LibGen, Z-Library) and opens them in your preferred reader.';

  @override
  String get aboutForkNote =>
      'This fork is maintained by lzoreal for personal use and community updates.';

  @override
  String get aboutOriginalNote =>
      'Original app by dstark5; extended fork by warreth (https://github.com/warreth/OpenlibExtended).';

  @override
  String get version => 'Version';

  @override
  String get github => 'Github';

  @override
  String get thisForkByMaintainer => 'This Fork (by lzoreal)';

  @override
  String get reportAnIssue => 'Report An Issue';

  @override
  String get originalProject => 'Original Project (by dstark5)';

  @override
  String get licence => 'Licence';

  @override
  String get gplLicense => 'GPL v3.0 license';

  @override
  String couldNotLaunch(String url) {
    return 'Could not launch $url';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchProvidersSection => 'Search Providers';

  @override
  String get searchOrderHint =>
      'All four sources are searched at once. This order controls how results are merged and which source opens first. Press and hold a card, then drag to reorder.';

  @override
  String get searchOrderReset => 'Reset order';

  @override
  String get libraryInstancesSection => 'Mirrors';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get generalSection => 'General';

  @override
  String get advancedSection => 'Advanced';

  @override
  String get backupSection => 'Backup';

  @override
  String get updatesSection => 'Updates';

  @override
  String get aboutSection => 'About';

  @override
  String get archiveInstance => 'Archive Instance';

  @override
  String get mirrorsAndProviders => 'Mirrors & Providers';

  @override
  String get fontSizeTitle => 'Font Size';

  @override
  String scaleValue(String value) {
    return 'Scale: ${value}x';
  }

  @override
  String get preview => 'Preview';

  @override
  String get storageLocation => 'Storage Location';

  @override
  String get manualDownloadButton => 'Manual Download Button';

  @override
  String get backgroundVerification => 'Verify challenges in background';

  @override
  String get backgroundVerificationHint =>
      'Solve DDoS checks invisibly. Some devices fail this - turn it off to open the visible verification page straight away';

  @override
  String get backgroundVerificationFix =>
      'If verification keeps failing, try turning off \"Verify challenges in background\" in Settings - some devices cannot solve checks invisibly.';

  @override
  String get showManualDownloadHint =>
      'Show button to manually trigger downloads';

  @override
  String get donationKeyTitle => 'Anna\'s Archive Donation Key';

  @override
  String get enterKeyForFasterDownloads => 'Enter key for faster downloads';

  @override
  String get aboutOpenlib => 'About OpenlibExtended';

  @override
  String get redoOnboarding => 'Redo Onboarding';

  @override
  String get resetAppSetup => 'Reset app setup and start over';

  @override
  String get exportLogs => 'Export Logs';

  @override
  String get shareDiagnosticLogs => 'Share diagnostic logs (last 5 min)';

  @override
  String failedExportLogs(String error) {
    return 'Failed to export logs: $error';
  }

  @override
  String get donationKeyDialog => 'Donation Key';

  @override
  String get enterYourKey => 'Enter your key';

  @override
  String get instanceChanged => 'Instance changed successfully';

  @override
  String rankingFailed(String error) {
    return 'Ranking failed: $error';
  }

  @override
  String get autoRankInstances => 'Auto-Rank Instances';

  @override
  String get sortBySpeedOnStartup => 'Automatically sort by speed on startup';

  @override
  String get rankInstancesNow => 'Rank Instances Now';

  @override
  String onLatestVersion(String version) {
    return 'You\'re on the latest version ($version)';
  }

  @override
  String failedCheckUpdates(String error) {
    return 'Failed to check for updates: $error';
  }

  @override
  String get includeBetaUpdates => 'Include Beta Updates';

  @override
  String get getPreReleaseVersions => 'Get pre-release versions';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String failedExportBackup(String error) {
    return 'Failed to export backup: $error';
  }

  @override
  String get backupRestored => 'Backup restored';

  @override
  String failedImportBackup(String error) {
    return 'Failed to import backup: $error';
  }

  @override
  String get atLeastOneSource => 'At least one search source is needed';

  @override
  String rankedFastest(String name, String time) {
    return 'Ranked! Fastest: $name (${time}ms)';
  }

  @override
  String get rankingComplete => 'Ranking complete';

  @override
  String get providerSourceOriginal =>
      'Searched last - protected by DDoS-Guard';

  @override
  String get providerLibgenCatalog => 'Fast, direct downloads - searched first';

  @override
  String get providerZlibMirrors => 'Mirrors rotate; may need a login';

  @override
  String get themeTitle => 'Theme';

  @override
  String get saveBackupTitle => 'Save Backup';

  @override
  String get pickBackupFile => 'Pick a backup file';

  @override
  String get notABackup => 'That file is not an OpenlibExtended backup';

  @override
  String get donationKeyHelper =>
      'Used for faster downloads on Anna\'s Archive';

  @override
  String get mirrorsTestedRanked => 'Mirrors tested and ranked by speed';

  @override
  String testingFailed(String error) {
    return 'Testing failed: $error';
  }

  @override
  String get addCustomMirror => 'Add Custom Mirror';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'e.g., My LibGen mirror';

  @override
  String get serviceLabel => 'Service';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get enterValidUrl =>
      'Please enter a valid URL with http:// or https://';

  @override
  String get mirrorAdded => 'Mirror added successfully';

  @override
  String get deleteMirror => 'Delete Mirror';

  @override
  String deleteMirrorConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get mirrorDeleted => 'Mirror deleted';

  @override
  String get cannotDeleteDefaultMirrors => 'Cannot delete default mirrors';

  @override
  String get manageMirrors => 'Manage Mirrors';

  @override
  String get noMirrorsAvailable => 'No mirrors available';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get addMirror => 'Add mirror';

  @override
  String get testRankMirrors => 'Test & rank mirrors by speed';

  @override
  String get unreachable => 'unreachable';

  @override
  String get open => 'Open';

  @override
  String get unableToOpenFile => 'Unable to open file!';

  @override
  String get openInSite => 'Open in site';

  @override
  String get bookDeleted => 'Book has been Deleted!';

  @override
  String get deleteBook => 'Delete Book';

  @override
  String get deletePermanentWarning => 'This is permanent and cannot be undone';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get showBlockedContent => 'Show blocked page content';

  @override
  String get verifyInBrowser => 'Verify in Browser';

  @override
  String get manualVerificationRequired => 'Manual Verification Required';

  @override
  String get systemBrowser => 'System Browser';

  @override
  String get embeddedBrowser => 'Embedded Browser';

  @override
  String get unableToOpenVerification =>
      'Unable to open verification page - no URL available';

  @override
  String get blockedPageContent => 'Blocked Page Content';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get tryUsingVpn => 'Try using a VPN';

  @override
  String get trending => 'Trending';

  @override
  String get genres => 'Genres';

  @override
  String get copiedBookPath => 'Copied the book path to your clipboard';

  @override
  String get pauseDownload => 'Pause download';

  @override
  String get resumeDownload => 'Resume download';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get copiedBookLink => 'Copied the book link to your clipboard';

  @override
  String get noMirrors => 'No mirrors available!';

  @override
  String get downloadStartedBackground => 'Download started in background';

  @override
  String get bookDownloaded => 'Book has been downloaded!';

  @override
  String get selectStorageToContinue =>
      'Please select a storage folder to continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get welcomeTitle => 'Welcome to OpenlibExtended';

  @override
  String get welcomeSubtitle =>
      'Your personal gateway to a world of knowledge. Let\'s get you set up.';

  @override
  String get whereToStoreBooks => 'Where should we store your books?';

  @override
  String get noPathSelected => 'No path selected';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get storageScanNote =>
      'We\'ll only look for PDF/EPUB files in this folder. No recursive scanning of subfolders.';

  @override
  String get automaticUpdates => 'Automatic Updates';

  @override
  String get enableAutoUpdates => 'Enable Auto-Updates';

  @override
  String get autoUpdatesFdroidNote =>
      'Not recommended if you installed via F-Droid (F-Droid handles updates).';

  @override
  String get enableBetaUpdatesOnboarding => 'Enable Beta Updates';

  @override
  String get betaUpdatesNote =>
      'Get pre-release versions (beta updates) when available.';

  @override
  String get supportAnnasArchive => 'Support Anna\'s Archive';

  @override
  String get donationPitch =>
      'Donating to Anna\'s Archive provides faster downloads and helps them keep the service running for everyone. You can enter your secret key below.';

  @override
  String get annasSecretKey => 'Anna\'s Archive Secret Key';

  @override
  String get supportThisApp => 'Support This App';

  @override
  String get sponsorPitch =>
      'If you enjoy this app, consider supporting its development. It helps me dedicate more time to making it better!';

  @override
  String get sponsorOnGithub => 'Sponsor on GitHub';

  @override
  String get stayUpdated => 'Stay Updated';

  @override
  String get notifyOnComplete => 'Get notified when downloads complete.';

  @override
  String get chooseTheme => 'Choose a Theme';

  @override
  String get lightThemeShort => 'Light';

  @override
  String get darkThemeShort => 'Dark';

  @override
  String get verifyingAccess => 'Verifying Access';

  @override
  String get done => 'Done';

  @override
  String get noVoiceAvailable => 'No voice available for reading aloud';

  @override
  String get close => 'Close';

  @override
  String get reloadHealthData => 'Reload health data';

  @override
  String addServiceMirror(String title) {
    return 'Add a $title mirror';
  }

  @override
  String get deleteMirrorTooltip => 'Delete mirror';

  @override
  String searchingOn(String source) {
    return 'Results from $source';
  }

  @override
  String get sourceLibgen => 'LibGen';

  @override
  String get sourceZlib => 'Z-Library';

  @override
  String get sourceAnnas => 'Anna\'s Archive';

  @override
  String downloadFrom(String source) {
    return 'Downloading from $source';
  }

  @override
  String get tryingNextSource => 'No results here, trying next source…';

  @override
  String get slowMirrorsSkipped => 'Using faster mirrors';

  @override
  String whatsNewTitle(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get whatsNewIntro =>
      'OpenlibExtended was updated. Here is what changed.';

  @override
  String get whatsNewTabFeatures => 'New features';

  @override
  String get whatsNewTabSources => 'Sources & mirrors';

  @override
  String get whatsNewProvidersHint =>
      'This release adds new search providers and mirrors. Update your list to drop dead mirrors and add the new ones; all three search providers get enabled.';

  @override
  String get whatsNewUpdateInstances => 'Update mirror list';

  @override
  String get whatsNewInstancesUpdated => 'Mirror list updated';

  @override
  String get whatsNewContinue => 'Continue';

  @override
  String get whatsNewFeatureSpeed =>
      'Downloads start faster: no mirror probing, fast hosts first, slow IPFS gateways last.';

  @override
  String get whatsNewFeatureSourceLabels =>
      'Every search result and download now shows which catalog it came from.';

  @override
  String get whatsNewFeatureCovers =>
      'Missing LibGen covers are fetched from the book\'s detail page.';

  @override
  String get categoryClassicsTitle => 'Classics';

  @override
  String get categoryClassicsInfo =>
      'Timeless literary works often revered for their artistic merit and cultural significance.';

  @override
  String get categoryRomanceTitle => 'Romance';

  @override
  String get categoryRomanceInfo =>
      'Stories focused on romantic relationships, exploring love, passion, and emotional connections.';

  @override
  String get categoryFictionTitle => 'Fiction';

  @override
  String get categoryFictionInfo =>
      'Narrative literature created from the imagination, not based on real events.';

  @override
  String get categoryYoungAdultTitle => 'Young Adult';

  @override
  String get categoryYoungAdultInfo =>
      'Books targeted at teenage readers, addressing themes relevant to adolescence.';

  @override
  String get categoryFantasyTitle => 'Fantasy';

  @override
  String get categoryFantasyInfo =>
      'A genre featuring magical elements, mythical creatures, and fantastical worlds.';

  @override
  String get categoryScienceFictionTitle => 'Science Fiction';

  @override
  String get categoryScienceFictionInfo =>
      'Literature that explores futuristic concepts, advanced technology, and space exploration.';

  @override
  String get categoryNonfictionTitle => 'Nonfiction';

  @override
  String get categoryNonfictionInfo =>
      'Works based on factual information, including essays, biographies, and documentaries.';

  @override
  String get categoryChildrenTitle => 'Children';

  @override
  String get categoryChildrenInfo =>
      'Books aimed at young readers, often with illustrations and simple narratives.';

  @override
  String get categoryHistoryTitle => 'History';

  @override
  String get categoryHistoryInfo =>
      'Literature that examines past events, cultures, and significant historical figures.';

  @override
  String get categoryMysteryTitle => 'Mystery';

  @override
  String get categoryMysteryInfo =>
      'Stories centered around suspenseful plots, often involving crime or puzzles to solve.';

  @override
  String get categoryCoversTitle => 'Covers';

  @override
  String get categoryCoversInfo =>
      'Refers to the artwork and design that visually represents a book, influencing reader interest.';

  @override
  String get categoryHorrorTitle => 'Horror';

  @override
  String get categoryHorrorInfo =>
      'A genre designed to evoke fear, dread, or terror in the reader through suspenseful storytelling.';

  @override
  String get categoryHistoricalFictionTitle => 'Historical Fiction';

  @override
  String get categoryHistoricalFictionInfo =>
      'Novels set in a specific historical period, blending factual events with fictional characters.';

  @override
  String get categoryBestTitle => 'Best';

  @override
  String get categoryBestInfo =>
      'Often refers to critically acclaimed or popular books, usually categorized by rankings or awards.';

  @override
  String get categoryTitlesTitle => 'Titles';

  @override
  String get categoryTitlesInfo =>
      'Refers to the names of books, which often reflect their themes or subject matter.';

  @override
  String get categoryMiddleGradeTitle => 'Middle Grade';

  @override
  String get categoryMiddleGradeInfo =>
      'Books intended for readers aged 8-12, featuring age-appropriate themes and characters.';

  @override
  String get categoryParanormalTitle => 'Paranormal';

  @override
  String get categoryParanormalInfo =>
      'Stories that incorporate supernatural elements, including ghosts, vampires, and otherworldly beings.';

  @override
  String get categoryLoveTitle => 'Love';

  @override
  String get categoryLoveInfo =>
      'A theme exploring the complexities and nuances of love in various forms and relationships.';

  @override
  String get categoryQueerTitle => 'Queer';

  @override
  String get categoryQueerInfo =>
      'Literature that represents diverse sexual orientations and gender identities within the LGBTQ+ spectrum.';

  @override
  String get categoryHistoricalRomanceTitle => 'Historical Romance';

  @override
  String get categoryHistoricalRomanceInfo =>
      'Novels combining romantic plots set against a historical backdrop.';

  @override
  String get categoryContemporaryTitle => 'Contemporary';

  @override
  String get categoryContemporaryInfo =>
      'Works set in modern times, often addressing current social issues and relatable characters.';

  @override
  String get categoryThrillerTitle => 'Thriller';

  @override
  String get categoryThrillerInfo =>
      'A suspenseful genre focused on excitement, tension, and unexpected twists.';

  @override
  String get categoryWomenTitle => 'Women';

  @override
  String get categoryWomenInfo =>
      'Literature that explores women’s experiences, perspectives, and empowerment.';

  @override
  String get categoryBiographyTitle => 'Biography';

  @override
  String get categoryBiographyInfo =>
      'Nonfiction works detailing the life story of an individual, highlighting their achievements and challenges.';

  @override
  String get categoryLgbtqTitle => 'LGBTQ';

  @override
  String get categoryLgbtqInfo =>
      'Inclusive literature representing the experiences of the lesbian, gay, bisexual, transgender, and queer community.';

  @override
  String get categorySeriesTitle => 'Series';

  @override
  String get categorySeriesInfo =>
      'A collection of related books that follow a common storyline or set of characters.';

  @override
  String get categoryTitleChallengeTitle => 'Title Challenge';

  @override
  String get categoryTitleChallengeInfo =>
      'Refers to prompts or contests encouraging creative thinking about book titles.';

  @override
  String get mirrorsTitle => 'Mirrors';

  @override
  String get automaticMirrorOrder => 'Automatic mirror order';

  @override
  String get mirrorOrderAutoHint =>
      'Easiest protection first, then fastest. Recommended.';

  @override
  String get mirrorOrderManualHint =>
      'Manual: use the arrows to set your own order.';

  @override
  String get mirrorListUpToDate => 'Mirror list is up to date';

  @override
  String mirrorListUpdated(int count) {
    return 'Mirror list updated: $count change(s)';
  }

  @override
  String mirrorRefreshFailed(String error) {
    return 'Refresh failed: $error';
  }

  @override
  String get mirrorCatalogueUnreachable =>
      'Could not reach open-slum.org - no mirror list available';

  @override
  String get mirrorFooterNote =>
      'Mirror addresses and their status come from open-slum.org and refresh automatically. A mirror reported DOWN is never contacted. Local latency is measured by this device when you tap the speed button.';

  @override
  String get mirrorLatencyTestTooltip => 'Test local latency';

  @override
  String get mirrorLatencyNotTested => 'Local latency not tested';

  @override
  String get mirrorLatencyTesting => 'Testing local latency…';

  @override
  String get mirrorLatencyTimeout => 'Local timeout';

  @override
  String mirrorLatencyLocal(String latency) {
    return 'Local $latency';
  }

  @override
  String get mirrorLatencyJustNow => 'just now';

  @override
  String get mirrorLatencyExpired => 'expired';

  @override
  String mirrorLatencyDone(int reachable, int total, String fastest) {
    return 'Local test: $reachable/$total reachable, fastest $fastest';
  }

  @override
  String get mirrorLatencyAllTimedOut =>
      'Local test finished · no mirror responded';

  @override
  String get mirrorLatencyNoTargets => 'No enabled mirrors to test';

  @override
  String mirrorLatencyFailed(String error) {
    return 'Local test failed: $error';
  }

  @override
  String get noMirrorsReported => 'No mirrors reported';

  @override
  String get noMirrorsReportedHint =>
      'open-slum.org has no entry (yet) or could not be reached.';

  @override
  String get couldNotLoadMirrors => 'Could not load mirrors';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get reportedDownNeverContacted => 'reported down - never contacted';

  @override
  String get mirrorServiceLibgenHint =>
      'Fast, challenge-free downloads when a mirror is up';

  @override
  String get mirrorServiceZlibHint => 'DiamWall mirrors solve headlessly';

  @override
  String get mirrorServiceWelibHint =>
      'Cloudflare-gated search, open book pages';

  @override
  String get mirrorServiceAnnasHint => 'Reading, details and downloads';

  @override
  String get mirrorStatusUp => 'Up';

  @override
  String get mirrorStatusDegraded => 'Degraded';

  @override
  String get mirrorStatusProtected => 'Protected';

  @override
  String get mirrorStatusDown => 'Down';

  @override
  String get searchEmptyQuery => 'Search field is empty';

  @override
  String get filterTypeLabel => 'Type';

  @override
  String get filterSortLabel => 'Sort by';

  @override
  String get filterFileTypeLabel => 'File type';

  @override
  String get filterYearLabel => 'Year';

  @override
  String get filterAll => 'All';

  @override
  String get typeAnyBooks => 'Any Books';

  @override
  String get typeUnknownBooks => 'Unknown Books';

  @override
  String get typeFictionBooks => 'Fiction Books';

  @override
  String get typeNonfictionBooks => 'Non-fiction Books';

  @override
  String get typeComicBooks => 'Comic Books';

  @override
  String get typeMagazine => 'Magazine';

  @override
  String get typeStandardsDocument => 'Standards Document';

  @override
  String get typeJournalArticle => 'Journal Article';

  @override
  String get sortMostRelevant => 'Most Relevant';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortLargest => 'Largest';

  @override
  String get sortSmallest => 'Smallest';

  @override
  String get yearBefore1980 => 'Before 1980';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Spanish';

  @override
  String get langFrench => 'French';

  @override
  String get langGerman => 'German';

  @override
  String get langItalian => 'Italian';

  @override
  String get langPortuguese => 'Portuguese';

  @override
  String get langRussian => 'Russian';

  @override
  String get langChinese => 'Chinese';

  @override
  String get langJapanese => 'Japanese';

  @override
  String get langKorean => 'Korean';

  @override
  String get langArabic => 'Arabic';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langDutch => 'Dutch';

  @override
  String get langPolish => 'Polish';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get langSwedish => 'Swedish';

  @override
  String get langIndonesian => 'Indonesian';

  @override
  String get langVietnamese => 'Vietnamese';

  @override
  String get langCzech => 'Czech';

  @override
  String get langGreek => 'Greek';

  @override
  String get langRomanian => 'Romanian';

  @override
  String get langHungarian => 'Hungarian';

  @override
  String get langUkrainian => 'Ukrainian';

  @override
  String get langHebrew => 'Hebrew';

  @override
  String get langThai => 'Thai';

  @override
  String get langPersian => 'Persian';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langFinnish => 'Finnish';

  @override
  String get langNorwegian => 'Norwegian';

  @override
  String get langDanish => 'Danish';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadQueued => 'Queued';

  @override
  String get downloadGettingMirrors => 'Getting mirrors...';

  @override
  String get downloadFindingMirror => 'Finding mirror...';

  @override
  String get downloadDownloading => 'Downloading';

  @override
  String get downloadPaused => 'Paused';

  @override
  String get downloadVerifying => 'Verifying';

  @override
  String get downloadCancelled => 'Cancelled';

  @override
  String get downloadFailedGeneric => 'Download failed';

  @override
  String get verifyAction => 'Verify';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get manualDownloadAction => 'Manual Download';

  @override
  String get fastDownloadStarted => 'Fast download started in background 🚀';

  @override
  String get welibNoDownloadLink =>
      'WeLib did not offer a download link for this book.';

  @override
  String get welibPageUnreadable => 'Could not read the WeLib download page.';

  @override
  String get fileNotFoundDownloadFailed =>
      'File not found. The download may have failed.';

  @override
  String shareBookMessage(String title, String link) {
    return 'Discover this amazing book: \"$title\"\nRead more: $link';
  }

  @override
  String get webviewWindowTitle => 'Verify Access - OpenLibExtended';

  @override
  String get webviewBrowserOpen => 'Browser window is open';

  @override
  String get webviewBrowserOpening => 'Opening browser window...';

  @override
  String get webviewInstructions =>
      '1. Solve the CAPTCHA in the browser window\n2. Wait for the page to fully load\n3. Click \'Done\' button above to continue';

  @override
  String get webviewPreparingDownload => 'Preparing download...';

  @override
  String get webviewPreparingHint =>
      'Please wait while we verify access and fetch download links';

  @override
  String get changeStorageHint => 'Change where books are saved';

  @override
  String versionWithBuild(String version, String build) {
    return 'Version $version+$build';
  }

  @override
  String get backupShareText => 'OpenlibExtended backup';

  @override
  String get exportBackupTitle => 'Export Backup';

  @override
  String get exportBackupSubtitle =>
      'Save settings, books and instances to a JSON file';

  @override
  String get importBackupTitle => 'Import Backup';

  @override
  String get importBackupSubtitle =>
      'Restore from a backup file (replaces current data)';

  @override
  String get providerWelibCatalog =>
      'Cloudflare-gated search and open book pages';

  @override
  String get errorWhatToDo => 'What to do';

  @override
  String get errorVpnDescription =>
      'A VPN can help bypass regional blocks and access the content.';

  @override
  String get errorVerificationPrompt =>
      'The site is asking you to verify that you\'re human. We\'ll open a browser window where you can complete the verification.';

  @override
  String get errorVerificationReturn =>
      'Once you complete the verification, return to the app and tap \'Try Again\'.';

  @override
  String get errorNoContent => 'No content available';

  @override
  String get networkErrorNoInternetTitle => 'No internet connection';

  @override
  String get networkErrorNoInternetSolution =>
      'Check your internet connection. Make sure Wi-Fi or mobile data is enabled.';

  @override
  String get networkErrorCloudflareTitle => 'Access blocked by DDoS protection';

  @override
  String get networkErrorCloudflareSolution =>
      'This site is protected and blocking the app. Try a VPN, change DNS to 1.1.1.1 or 8.8.8.8, or verify in the browser.';

  @override
  String get networkErrorServerUnavailableTitle =>
      'Server temporarily unavailable';

  @override
  String get networkErrorServerUnavailableSolution =>
      'The server is having problems. Try again in a few minutes or choose another mirror in Settings.';

  @override
  String get networkErrorTimeoutTitle => 'Request timed out';

  @override
  String get networkErrorTimeoutSolution =>
      'The server is taking too long to respond. Check your connection and try again.';

  @override
  String get networkErrorForbiddenTitle => 'Access denied';

  @override
  String get networkErrorForbiddenSolution =>
      'You don\'t have permission to access this resource. Try a VPN, change DNS, or use another mirror in Settings.';

  @override
  String get networkErrorRateLimitedTitle => 'Too many requests';

  @override
  String get networkErrorRateLimitedSolution =>
      'Too many requests were sent. Wait a few minutes and try again.';

  @override
  String get networkErrorSslTitle => 'Secure connection failed';

  @override
  String get networkErrorSslSolution =>
      'Your network may be blocking secure connections. Try a VPN or a different network.';

  @override
  String get networkErrorDnsTitle => 'Server not found';

  @override
  String get networkErrorDnsSolution =>
      'The site could not be reached. Your ISP may be blocking it. Try a VPN or change DNS to 1.1.1.1 / 8.8.8.8.';

  @override
  String get networkErrorUnknownTitle => 'Something went wrong';

  @override
  String get networkErrorUnknownSolution =>
      'Please try again. If the problem persists, restart the app.';

  @override
  String get updatePermissionTitle => 'Permission Required';

  @override
  String get updatePermissionBody =>
      'To install app updates, OpenlibExtended needs permission to install packages.\n\nThis allows the app to automatically install new versions with bug fixes and new features.\n\nYou will be taken to Settings to enable this permission.';

  @override
  String get updateOpenSettings => 'Open Settings';

  @override
  String get updateDebugBuildWarning =>
      'Debug Build Detected: Update may fail with \'App not installed\' due to signature mismatch. Uninstall this app first.';

  @override
  String get updateOpeningInstaller =>
      'Opening installer... If nothing happens, the install failed.';

  @override
  String get updateManualInstall => 'Manual Install';

  @override
  String get updateInstallationIssueTitle => 'Installation Issue';

  @override
  String get updateInstallationIssueBody =>
      'The automatic installer couldn\'t open the APK. This can happen on some Android versions.\n\nYou can install manually using one of these options:';

  @override
  String updateFileLabel(String file) {
    return 'File: $file';
  }

  @override
  String get updateInstallationFailed => 'Installation Failed';

  @override
  String get updateMethodsTried => 'Methods tried:';

  @override
  String get updateErrorsEncountered => 'Errors encountered:';

  @override
  String updateMethodNumber(int number) {
    return 'Method $number';
  }

  @override
  String get updateDownloadViaBrowser => 'Download via Browser';

  @override
  String get updateInstallationErrorTitle => 'Installation Error';

  @override
  String get updateOk => 'OK';

  @override
  String get updateTryManualInstall => 'Try Manual Install';

  @override
  String updateInstallFailed(String error) {
    return 'Failed to install update: $error';
  }

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateVersionAvailable(String version) {
    return 'Version $version is available!';
  }

  @override
  String get updatePreRelease => 'Pre-release';

  @override
  String get updateWhatsNew => 'What\'s new:';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloadAndInstall => 'Download & Install';

  @override
  String get updateDownloadFromGithub => 'Download from GitHub';

  @override
  String get updateViewOnGithub => 'View on GitHub';

  @override
  String get updateDownloading => 'Downloading Update';

  @override
  String get updateDownloadComplete => 'Download Complete';

  @override
  String updateVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get updateOpeningInstallerShort => 'Opening installer...';

  @override
  String get updateConnecting => 'Connecting...';

  @override
  String get updateFileNotFound => 'Downloaded file not found';

  @override
  String updateFileCorrupted(String size) {
    return 'Downloaded file appears to be corrupted (only $size)';
  }

  @override
  String get updatePermissionDenied =>
      'Permission to install apps was denied. You can still install manually.';

  @override
  String get updateMayHaveFailedSilently => 'May have failed silently';

  @override
  String get updateMethodOpenFile => 'Open File';

  @override
  String get updateMethodApkSideload => 'APK Sideload';

  @override
  String get updateMethodPackageInstaller => 'Package Installer';

  @override
  String get networkErrorBookNotFoundTitle => 'Book not found';

  @override
  String get networkErrorBookNotFoundSolution =>
      'The page loaded but no book details were on it. The link may be outdated - try searching for the title instead.';

  @override
  String get networkErrorBookDetailsUnavailableTitle =>
      'Unable to load book details';

  @override
  String get networkErrorBookDetailsUnavailableSolution =>
      'The book information could not be retrieved. Try again or use another mirror in Settings.';

  @override
  String get downloadNoWorkingMirrors => 'No working mirrors available!';

  @override
  String get downloadAllMirrorsFailed => 'All mirrors failed!';

  @override
  String get downloadErrorGettingMirrors => 'Error getting mirrors';

  @override
  String downloadCouldNotSave(String error) {
    return 'Could not save to library: $error';
  }

  @override
  String get appLogsShareSubject => 'OpenlibExtended App Logs';

  @override
  String appLogsShareText(int minutes) {
    return 'OpenlibExtended app logs for the past $minutes minutes';
  }

  @override
  String notificationAlreadyDownloading(String title) {
    return 'Already downloading: $title';
  }

  @override
  String notificationQueued(String title) {
    return 'Queued: $title';
  }

  @override
  String get notificationStartingFastDownload => 'Starting fast download...';

  @override
  String get notificationVerifyingFile => 'Verifying file...';

  @override
  String get notificationDownloadComplete => 'Download completed!';

  @override
  String get notificationDownloadCompleteChecksumFailed =>
      'Download completed (checksum failed)';

  @override
  String get notificationChannelDescription =>
      'Book download progress notifications';

  @override
  String notificationDownloadingPercent(int percent) {
    return 'Downloading... $percent%';
  }

  @override
  String notificationFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get notificationDownloadTitle => 'Download';

  @override
  String get searchHintTitle => 'Find your next read';

  @override
  String get searchHintBody =>
      'Search by title, author, or ISBN, or use the filters above.';

  @override
  String get homeSearchHint => 'Search by title, author, or ISBN';

  @override
  String get trendingThisWeek => 'Trending this week';

  @override
  String get keepExploring => 'Keep exploring';

  @override
  String get browseGenres => 'Browse by genre';

  @override
  String get settingsManage => 'Manage';

  @override
  String get searchSourcesTitle => 'Search sources';

  @override
  String get searchSourceAuto => 'All';

  @override
  String get searchSourceAutoHint =>
      'All four sources are searched at once; results are merged';

  @override
  String get searchSourceOnlyHint => 'Only this source’s results are shown';

  @override
  String get bookDetailsTitle => 'Book details';

  @override
  String get fileInfoTitle => 'File info';

  @override
  String get formatLabel => 'Format';

  @override
  String get publishedYearLabel => 'Published';

  @override
  String get fileSizeLabel => 'File size';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceAndDownload => 'Source & download';

  @override
  String get openAtSource => 'Open at source';

  @override
  String get sourceWelib => 'WeLib';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get sourceStatusUntried => 'Untried';

  @override
  String get sourceStatusFailed => 'Failed';

  @override
  String sourceResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get searchingTitle => 'Searching';

  @override
  String get searchingSourcesBody =>
      'Queries all four sources at once, then merges and de-duplicates the results.';

  @override
  String get loadMoreResults => 'Scroll for more results';

  @override
  String noResultsFor(String query) {
    return 'No results for “$query”';
  }

  @override
  String get noResultsSourcesBody =>
      'All sources returned no matches. Try a shorter query, or clear the filters and search again.';

  @override
  String get modifySearch => 'Edit search';

  @override
  String get clearFiltersRetry => 'Clear filters & retry';

  @override
  String get sourceSheetTitle => 'Switch search source';

  @override
  String sourceSheetSubtitle(String query) {
    return 'View results for “$query” from a chosen source.';
  }

  @override
  String get sourceAutoRecommended => 'All sources (combined)';

  @override
  String get sourceSheetNote =>
      'Applies to this search only. Your default source stays the same.';

  @override
  String get recentSearchesTitle => 'Recent searches';

  @override
  String get clearAll => 'Clear all';

  @override
  String get searchSuggestionsTitle => 'Search suggestions';

  @override
  String get searchSuggestionsLive => 'Live';

  @override
  String get searchRecentHint =>
      'Continue from a recent search, or start a new one.';

  @override
  String searchInAllSources(String query) {
    return 'Search “$query” in all sources';
  }

  @override
  String searchInSource(String query, String source) {
    return 'Search “$query” in $source';
  }

  @override
  String searchAutoScope(int count) {
    return 'Searching $count sources at once';
  }

  @override
  String searchSourceOnlyScope(String source) {
    return '$source only';
  }

  @override
  String removeRecentSearch(String query) {
    return 'Remove “$query”';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchSupportHint =>
      'Search by title, author, ISBN or MD5. All four sources are queried in parallel.';

  @override
  String get tryThese => 'Try these';

  @override
  String get filtersAndAdvanced => 'Filters and advanced search';

  @override
  String get resultsAutoMerged => 'Results merged automatically';

  @override
  String get searchAdvancedHint =>
      'Need to narrow by author, publisher, year, language or format? Switch to Advanced search.';

  @override
  String get searchApply => 'Apply and search';

  @override
  String get resetFilters => 'Reset';

  @override
  String get anyValue => 'Any';

  @override
  String get advancedFilterNote =>
      'Advanced filters apply to this search only; your default source stays unchanged.';

  @override
  String get filterRelevance => 'Relevance';

  @override
  String get searchAllSourcesLabel => 'All sources';

  @override
  String get sourceMarkAll => 'ALL';

  @override
  String get sourceAnnasShort => 'Anna\'s';

  @override
  String get sourceZlibShort => 'Z-Lib';

  @override
  String sourceCount(int count) {
    return '$count sources';
  }

  @override
  String sourceStillSearching(String source) {
    return '$source is still searching; results will be added automatically.';
  }

  @override
  String otherSources(String summary) {
    return 'Other sources: $summary';
  }

  @override
  String sourcesResponded(int count) {
    return '$count sources responded';
  }

  @override
  String get sourceStatusTitle => 'Source status';

  @override
  String sourceStatusSummary(int ok, int failed) {
    return '$ok responded, $failed failed';
  }

  @override
  String sourceResponded(int count) {
    return 'Responded · $count';
  }

  @override
  String get sourceTimedOut => 'Timed out';

  @override
  String get searchAgain => 'Search again';

  @override
  String sourceMirrorHint(String source) {
    return 'From the $source mirror; MD5 is verified after download.';
  }

  @override
  String get downloadThisBook => 'Download book';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get downloadCenterTitle => 'Download Center';

  @override
  String downloadCenterSummary(int active, int paused, int queued) {
    return '$active active · $paused paused · $queued queued';
  }

  @override
  String get downloadCenterNoTasks => 'No download tasks yet';

  @override
  String get downloadCenterAllPause => 'Pause all';

  @override
  String get downloadCenterAllResume => 'Resume all';

  @override
  String get downloadCenterAll => 'All';

  @override
  String get downloadCenterActive => 'Active';

  @override
  String get downloadCenterCompleted => 'Completed';

  @override
  String get downloadCenterFailed => 'Failed';

  @override
  String get downloadCenterInProgress => 'In progress';

  @override
  String get downloadCenterNeedsAttention => 'Needs attention';

  @override
  String get downloadCenterOrderHint => 'In queue order';

  @override
  String get downloadCenterQueueMemory => 'Queue lives in memory';

  @override
  String get downloadCenterRemoveNote =>
      'When removing a record you can also remove the local file; the queue lives in memory only and does not resume after exit.';

  @override
  String get rangeResume => 'Range resume';

  @override
  String storagePathMessage(String path) {
    return 'Files are saved in $path';
  }

  @override
  String get downloadCenterRetryHint => 'Retry keeps the downloaded part';

  @override
  String get downloadCenterOpenHint => 'Tap a title to view details';

  @override
  String get downloadCenterCurrentProgress => 'Current progress';

  @override
  String get downloadCenterSpeed => 'Current speed';

  @override
  String get downloadCenterRemaining => 'Remaining';

  @override
  String downloadCenterTodayCount(int count) {
    return 'Completed today: $count';
  }

  @override
  String downloadCenterEtaSeconds(int seconds) {
    return '${seconds}s left';
  }

  @override
  String downloadCenterEtaMinutes(int minutes) {
    return '$minutes min left';
  }

  @override
  String downloadCenterStorageSummary(int count, String size) {
    return 'This month: $count books · $size';
  }

  @override
  String downloadCenterStorageLegend(String epub, String pdf) {
    return 'EPUB $epub · PDF $pdf';
  }

  @override
  String get downloadCenterRemoveRecord => 'Remove record';

  @override
  String get downloadCenterRemoveRecordBody =>
      'Only the record is removed; the local file stays in your download folder.';

  @override
  String get downloadCenterRemoveFile => 'Also remove file';

  @override
  String get downloadCenterShowInFolder => 'Show in folder';

  @override
  String get downloadCenterBookDetails => 'Book details';

  @override
  String get share => 'Share';

  @override
  String get downloadCenterEmptyTitle => 'No downloads yet';

  @override
  String get downloadCenterEmptyBody =>
      'Tap Download on a book page and the task will appear here. Once it finishes, you can open it directly.';

  @override
  String get downloadCenterGoSearch => 'Search books';

  @override
  String get downloadCenterTip =>
      'EPUB and PDF are supported. Pausing and resuming continues from the last byte.';

  @override
  String get downloadBook => 'Download';

  @override
  String get homeTitle => 'Discover';

  @override
  String get homeEyebrow => 'Discover books';

  @override
  String get browseEyebrow => 'Browse';

  @override
  String get searchEyebrow => 'Search sources';

  @override
  String get downloadEyebrow => 'Local storage';

  @override
  String get settingsEyebrow => 'Preferences';

  @override
  String get trendingSource => 'Goodreads list';

  @override
  String categoryCount(int count) {
    return '$count categories';
  }

  @override
  String get categorySearchHint => 'Search within categories';

  @override
  String get categoryInfoHint =>
      'Categories come from the SLUM catalog and stay available offline for 24 hours.';

  @override
  String get searchSourcesIntro =>
      'All four sources are queried in parallel. Disabled sources are skipped; mirror addresses come from the SLUM catalog.';

  @override
  String get sourceOn => 'Enabled';

  @override
  String get sourceOff => 'Disabled';

  @override
  String get mirrorsShort => 'Mirrors';

  @override
  String mirrorNodeCount(int count) {
    return '$count nodes';
  }

  @override
  String get refreshMirrors => 'Refresh mirrors';

  @override
  String get sourceBehaviorSection => 'Source behavior';

  @override
  String get displaySection => 'Display';

  @override
  String get currentLanguage => 'Current language';

  @override
  String get behaviorSection => 'Behavior';

  @override
  String get infoSection => 'Information';

  @override
  String get thanksSection => 'Acknowledgements';

  @override
  String get changelogTitle => 'Changelog';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get projectHome => 'Project home';

  @override
  String get slumCatalogue => 'SLUM mirror catalog';

  @override
  String get slumCatalogueSubtitle => 'open-slum.org';

  @override
  String get challengeSolverTitle => 'Challenge solver';

  @override
  String get challengeSolverSubtitle => 'WebView manual verification fallback';

  @override
  String get aboutDisclaimer =>
      'No book content is hosted here; only mirror search and downloads. Please support the authors.';

  @override
  String get maintenanceSection => 'Maintenance';

  @override
  String get languageCardHint => 'Interface language, applied immediately';

  @override
  String get themeCardHint => 'Follow the system, or always light or dark';

  @override
  String get fontSizeCardHint => 'Applies to text across the app';

  @override
  String get fontPreviewSample =>
      'A room without books is a body without a soul.';

  @override
  String get themeFollowSystemShort => 'System';

  @override
  String get themeLightShort => 'Light';

  @override
  String get themeDarkShort => 'Dark';

  @override
  String get sourceAllSearchedHint =>
      'All four sources are searched at once. Tap a source to switch results.';

  @override
  String get tapToExpandLanguage => 'Tap to choose a language';

  @override
  String get tapToCollapseLanguage => 'Tap to collapse';

  @override
  String get sourceStatusSearching => 'Searching…';

  @override
  String get verificationPageLoading =>
      'Loading the verification page. The app will continue automatically.';

  @override
  String get verificationPageInstructions =>
      'Complete the check below; the app will continue automatically.';

  @override
  String get challengeNeedsVerification =>
      'Manual verification needed - the search continues as soon as it passes';

  @override
  String get challengeVerifyNow => 'Verify now';

  @override
  String get languageNameEn => 'English';

  @override
  String get languageNameEs => 'Spanish';

  @override
  String get languageNameFr => 'French';

  @override
  String get languageNameDe => 'German';

  @override
  String get languageNameIt => 'Italian';

  @override
  String get languageNamePt => 'Portuguese';

  @override
  String get languageNameRu => 'Russian';

  @override
  String get languageNameZh => 'Chinese';

  @override
  String get languageNameJa => 'Japanese';

  @override
  String get languageNameKo => 'Korean';

  @override
  String get languageNameAr => 'Arabic';

  @override
  String get languageNameHi => 'Hindi';

  @override
  String get languageNameMl => 'Malayalam';

  @override
  String get languageNameNl => 'Dutch';

  @override
  String get languageNamePl => 'Polish';

  @override
  String get languageNameTr => 'Turkish';

  @override
  String get languageNameSv => 'Swedish';

  @override
  String get languageNameId => 'Indonesian';

  @override
  String get languageNameVi => 'Vietnamese';

  @override
  String get languageNameCs => 'Czech';

  @override
  String get languageNameEl => 'Greek';

  @override
  String get languageNameRo => 'Romanian';

  @override
  String get languageNameHu => 'Hungarian';

  @override
  String get languageNameUk => 'Ukrainian';

  @override
  String get languageNameHe => 'Hebrew';

  @override
  String get languageNameTh => 'Thai';

  @override
  String get languageNameFa => 'Persian';

  @override
  String get languageNameBn => 'Bengali';

  @override
  String get languageNameFi => 'Finnish';

  @override
  String get languageNameNo => 'Norwegian';

  @override
  String get languageNameDa => 'Danish';
}
