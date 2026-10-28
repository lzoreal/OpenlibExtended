import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('zh')
  ];

  /// Application name shown in the app bar and about page
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended'**
  String get appTitle;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Common dismiss button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Common confirm button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Confirm a creation dialog
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Remove item action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Expandable metadata filter toggle on the search page
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearch;

  /// Text field label for the author metadata filter
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// Text field label for the publisher metadata filter
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// Shown when a search or filter returns nothing
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Title of the results page
  ///
  /// In en, this message translates to:
  /// **'Results for \'{query}\''**
  String resultsFor(String query);

  /// Theme mode choice that follows the OS
  ///
  /// In en, this message translates to:
  /// **'Follow the System'**
  String get followSystem;

  /// Theme mode choice
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// Theme mode choice
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// Settings row label for the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// Language picker entry that follows the system locale
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemLanguage;

  /// Onboarding notifications switch title
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Dialog body explaining why notifications are needed
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended needs notification permission to show download progress in the background. This helps you track your book downloads even when the app is minimized.'**
  String get notificationsExplanation;

  /// Deferred consent button in the notification dialog
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// Confirm button granting a permission
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Reading status filter chip
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Page header above search results
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Placeholder while content loads
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Fallback when a value cannot be read
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// About page title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Short app description on the About page
  ///
  /// In en, this message translates to:
  /// **'An open source app that downloads books from shadow libraries (Anna\'s Archive, LibGen, Z-Library) and opens them in your preferred reader.'**
  String get aboutDescription;

  /// Explains who maintains this fork
  ///
  /// In en, this message translates to:
  /// **'This fork is maintained by lzoreal for personal use and community updates.'**
  String get aboutForkNote;

  /// Credits the original app and the upstream fork
  ///
  /// In en, this message translates to:
  /// **'Original app by dstark5; extended fork by warreth (https://github.com/warreth/OpenlibExtended).'**
  String get aboutOriginalNote;

  /// Version section header
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Github section header
  ///
  /// In en, this message translates to:
  /// **'Github'**
  String get github;

  /// Link label to this fork's repository
  ///
  /// In en, this message translates to:
  /// **'This Fork (by lzoreal)'**
  String get thisForkByMaintainer;

  /// Link label to the issue tracker
  ///
  /// In en, this message translates to:
  /// **'Report An Issue'**
  String get reportAnIssue;

  /// Link label to the upstream project
  ///
  /// In en, this message translates to:
  /// **'Original Project (by dstark5)'**
  String get originalProject;

  /// Licence section header
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get licence;

  /// Link label to the licence text
  ///
  /// In en, this message translates to:
  /// **'GPL v3.0 license'**
  String get gplLicense;

  /// Snackbar when opening an external link fails
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunch(String url);

  /// Settings page header
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Search Providers'**
  String get searchProvidersSection;

  /// Settings hint explaining the drag-to-reorder search source list
  ///
  /// In en, this message translates to:
  /// **'All four sources are searched at once. This order controls how results are merged and which source opens first. Press and hold a card, then drag to reorder.'**
  String get searchOrderHint;

  /// Settings button that restores the default search source order
  ///
  /// In en, this message translates to:
  /// **'Reset order'**
  String get searchOrderReset;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Mirrors'**
  String get libraryInstancesSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesSection;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// Settings card title
  ///
  /// In en, this message translates to:
  /// **'Archive Instance'**
  String get archiveInstance;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Mirrors & Providers'**
  String get mirrorsAndProviders;

  /// Settings card title
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeTitle;

  /// Font scale slider readout
  ///
  /// In en, this message translates to:
  /// **'Scale: {value}x'**
  String scaleValue(String value);

  /// Font scale preview label
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// Settings switch tile title
  ///
  /// In en, this message translates to:
  /// **'Manual Download Button'**
  String get manualDownloadButton;

  /// Background challenge verification toggle
  ///
  /// In en, this message translates to:
  /// **'Verify challenges in background'**
  String get backgroundVerification;

  /// Background challenge verification toggle
  ///
  /// In en, this message translates to:
  /// **'Solve DDoS checks invisibly. Some devices fail this - turn it off to open the visible verification page straight away'**
  String get backgroundVerificationHint;

  /// Background challenge verification toggle
  ///
  /// In en, this message translates to:
  /// **'If verification keeps failing, try turning off \"Verify challenges in background\" in Settings - some devices cannot solve checks invisibly.'**
  String get backgroundVerificationFix;

  /// Settings switch tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Show button to manually trigger downloads'**
  String get showManualDownloadHint;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Anna\'s Archive Donation Key'**
  String get donationKeyTitle;

  /// Settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter key for faster downloads'**
  String get enterKeyForFasterDownloads;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'About OpenlibExtended'**
  String get aboutOpenlib;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Redo Onboarding'**
  String get redoOnboarding;

  /// Settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Reset app setup and start over'**
  String get resetAppSetup;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get exportLogs;

  /// Settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Share diagnostic logs (last 5 min)'**
  String get shareDiagnosticLogs;

  /// Snackbar when log export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export logs: {error}'**
  String failedExportLogs(String error);

  /// Dialog title for the donation key
  ///
  /// In en, this message translates to:
  /// **'Donation Key'**
  String get donationKeyDialog;

  /// Donation key field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your key'**
  String get enterYourKey;

  /// Snackbar after switching instance
  ///
  /// In en, this message translates to:
  /// **'Instance changed successfully'**
  String get instanceChanged;

  /// Snackbar when instance ranking fails
  ///
  /// In en, this message translates to:
  /// **'Ranking failed: {error}'**
  String rankingFailed(String error);

  /// Settings switch tile title
  ///
  /// In en, this message translates to:
  /// **'Auto-Rank Instances'**
  String get autoRankInstances;

  /// Settings switch tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Automatically sort by speed on startup'**
  String get sortBySpeedOnStartup;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Rank Instances Now'**
  String get rankInstancesNow;

  /// Snackbar when no update is available
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version ({version})'**
  String onLatestVersion(String version);

  /// Snackbar when the update check fails
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates: {error}'**
  String failedCheckUpdates(String error);

  /// Settings switch tile title
  ///
  /// In en, this message translates to:
  /// **'Include Beta Updates'**
  String get includeBetaUpdates;

  /// Settings switch tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Get pre-release versions'**
  String get getPreReleaseVersions;

  /// Settings tile title
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// Snackbar after successful backup export
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// Snackbar when backup export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export backup: {error}'**
  String failedExportBackup(String error);

  /// Snackbar after successful backup import
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// Snackbar when backup import fails
  ///
  /// In en, this message translates to:
  /// **'Failed to import backup: {error}'**
  String failedImportBackup(String error);

  /// Snackbar refusing to disable the last provider
  ///
  /// In en, this message translates to:
  /// **'At least one search source is needed'**
  String get atLeastOneSource;

  /// Snackbar summarizing instance ranking
  ///
  /// In en, this message translates to:
  /// **'Ranked! Fastest: {name} ({time}ms)'**
  String rankedFastest(String name, String time);

  /// Snackbar when ranking finds no reachable instance
  ///
  /// In en, this message translates to:
  /// **'Ranking complete'**
  String get rankingComplete;

  /// Anna's Archive provider subtitle
  ///
  /// In en, this message translates to:
  /// **'Searched last - protected by DDoS-Guard'**
  String get providerSourceOriginal;

  /// Libgen provider subtitle
  ///
  /// In en, this message translates to:
  /// **'Fast, direct downloads - searched first'**
  String get providerLibgenCatalog;

  /// Z-Library provider subtitle
  ///
  /// In en, this message translates to:
  /// **'Mirrors rotate; may need a login'**
  String get providerZlibMirrors;

  /// Settings card title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// Native save dialog title for backups
  ///
  /// In en, this message translates to:
  /// **'Save Backup'**
  String get saveBackupTitle;

  /// Native file picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Pick a backup file'**
  String get pickBackupFile;

  /// Snackbar when an imported file is invalid
  ///
  /// In en, this message translates to:
  /// **'That file is not an OpenlibExtended backup'**
  String get notABackup;

  /// Helper text under the donation key field
  ///
  /// In en, this message translates to:
  /// **'Used for faster downloads on Anna\'s Archive'**
  String get donationKeyHelper;

  /// Snackbar after ranking mirrors
  ///
  /// In en, this message translates to:
  /// **'Mirrors tested and ranked by speed'**
  String get mirrorsTestedRanked;

  /// Snackbar when mirror testing fails
  ///
  /// In en, this message translates to:
  /// **'Testing failed: {error}'**
  String testingFailed(String error);

  /// Dialog title for adding a mirror
  ///
  /// In en, this message translates to:
  /// **'Add Custom Mirror'**
  String get addCustomMirror;

  /// Mirror form field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Mirror name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., My LibGen mirror'**
  String get nameHint;

  /// Mirror service dropdown label
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// Mirror URL field label
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// Mirror URL field hint
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get urlHint;

  /// Validation snackbar for the mirror form
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// URL validation snackbar
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL with http:// or https://'**
  String get enterValidUrl;

  /// Snackbar after adding a mirror
  ///
  /// In en, this message translates to:
  /// **'Mirror added successfully'**
  String get mirrorAdded;

  /// Dialog title for deleting a mirror
  ///
  /// In en, this message translates to:
  /// **'Delete Mirror'**
  String get deleteMirror;

  /// Mirror deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteMirrorConfirm(String name);

  /// Snackbar after deleting a mirror
  ///
  /// In en, this message translates to:
  /// **'Mirror deleted'**
  String get mirrorDeleted;

  /// Snackbar refusing to delete a default mirror
  ///
  /// In en, this message translates to:
  /// **'Cannot delete default mirrors'**
  String get cannotDeleteDefaultMirrors;

  /// Screen title for mirror management
  ///
  /// In en, this message translates to:
  /// **'Manage Mirrors'**
  String get manageMirrors;

  /// Empty state when no mirrors exist
  ///
  /// In en, this message translates to:
  /// **'No mirrors available'**
  String get noMirrorsAvailable;

  /// Generic error display
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// Floating action button label
  ///
  /// In en, this message translates to:
  /// **'Add mirror'**
  String get addMirror;

  /// Tooltip for the rank button
  ///
  /// In en, this message translates to:
  /// **'Test & rank mirrors by speed'**
  String get testRankMirrors;

  /// Mirror status when ping fails
  ///
  /// In en, this message translates to:
  /// **'unreachable'**
  String get unreachable;

  /// Open the downloaded file button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Snackbar when opening a file fails
  ///
  /// In en, this message translates to:
  /// **'Unable to open file!'**
  String get unableToOpenFile;

  /// Button opening the book page on the source site
  ///
  /// In en, this message translates to:
  /// **'Open in site'**
  String get openInSite;

  /// Snackbar after deleting a book
  ///
  /// In en, this message translates to:
  /// **'Book has been Deleted!'**
  String get bookDeleted;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Book'**
  String get deleteBook;

  /// Delete confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'This is permanent and cannot be undone'**
  String get deletePermanentWarning;

  /// Retry button on the error screen
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error screen action revealing page HTML
  ///
  /// In en, this message translates to:
  /// **'Show blocked page content'**
  String get showBlockedContent;

  /// Error screen action for manual captcha solving
  ///
  /// In en, this message translates to:
  /// **'Verify in Browser'**
  String get verifyInBrowser;

  /// Dialog title for the verification chooser
  ///
  /// In en, this message translates to:
  /// **'Manual Verification Required'**
  String get manualVerificationRequired;

  /// Verification option label
  ///
  /// In en, this message translates to:
  /// **'System Browser'**
  String get systemBrowser;

  /// Verification option label
  ///
  /// In en, this message translates to:
  /// **'Embedded Browser'**
  String get embeddedBrowser;

  /// Snackbar when the verification URL is missing
  ///
  /// In en, this message translates to:
  /// **'Unable to open verification page - no URL available'**
  String get unableToOpenVerification;

  /// Dialog title showing the blocked page HTML
  ///
  /// In en, this message translates to:
  /// **'Blocked Page Content'**
  String get blockedPageContent;

  /// Snackbar after copying text
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Copy-to-clipboard button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Error screen hint heading
  ///
  /// In en, this message translates to:
  /// **'Try using a VPN'**
  String get tryUsingVpn;

  /// Home page header for the trending tab
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// Home page header for the genres tab
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// Snackbar after copying a book's file path
  ///
  /// In en, this message translates to:
  /// **'Copied the book path to your clipboard'**
  String get copiedBookPath;

  /// Tooltip on the pause button
  ///
  /// In en, this message translates to:
  /// **'Pause download'**
  String get pauseDownload;

  /// Tooltip on the resume button
  ///
  /// In en, this message translates to:
  /// **'Resume download'**
  String get resumeDownload;

  /// Tooltip on the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get cancelDownload;

  /// Snackbar after copying a book link
  ///
  /// In en, this message translates to:
  /// **'Copied the book link to your clipboard'**
  String get copiedBookLink;

  /// Snackbar when no mirror can serve the book
  ///
  /// In en, this message translates to:
  /// **'No mirrors available!'**
  String get noMirrors;

  /// Snackbar when a download begins
  ///
  /// In en, this message translates to:
  /// **'Download started in background'**
  String get downloadStartedBackground;

  /// Snackbar when a download completes
  ///
  /// In en, this message translates to:
  /// **'Book has been downloaded!'**
  String get bookDownloaded;

  /// Snackbar when advancing without a folder
  ///
  /// In en, this message translates to:
  /// **'Please select a storage folder to continue'**
  String get selectStorageToContinue;

  /// Final onboarding button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Onboarding advance button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Onboarding welcome heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenlibExtended'**
  String get welcomeTitle;

  /// Onboarding welcome body
  ///
  /// In en, this message translates to:
  /// **'Your personal gateway to a world of knowledge. Let\'s get you set up.'**
  String get welcomeSubtitle;

  /// Onboarding storage page heading
  ///
  /// In en, this message translates to:
  /// **'Where should we store your books?'**
  String get whereToStoreBooks;

  /// Storage path placeholder
  ///
  /// In en, this message translates to:
  /// **'No path selected'**
  String get noPathSelected;

  /// Storage folder picker button
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// Storage folder explanation
  ///
  /// In en, this message translates to:
  /// **'We\'ll only look for supported ebook files in this folder. No recursive scanning of subfolders.'**
  String get storageScanNote;

  /// Onboarding updates page heading
  ///
  /// In en, this message translates to:
  /// **'Automatic Updates'**
  String get automaticUpdates;

  /// Onboarding switch title
  ///
  /// In en, this message translates to:
  /// **'Enable Auto-Updates'**
  String get enableAutoUpdates;

  /// Onboarding switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Not recommended if you installed via F-Droid (F-Droid handles updates).'**
  String get autoUpdatesFdroidNote;

  /// Onboarding switch title
  ///
  /// In en, this message translates to:
  /// **'Enable Beta Updates'**
  String get enableBetaUpdatesOnboarding;

  /// Onboarding switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Get pre-release versions (beta updates) when available.'**
  String get betaUpdatesNote;

  /// Onboarding donation page heading
  ///
  /// In en, this message translates to:
  /// **'Support Anna\'s Archive'**
  String get supportAnnasArchive;

  /// Onboarding donation page body
  ///
  /// In en, this message translates to:
  /// **'Donating to Anna\'s Archive provides faster downloads and helps them keep the service running for everyone. You can enter your secret key below.'**
  String get donationPitch;

  /// Donation key field label on onboarding
  ///
  /// In en, this message translates to:
  /// **'Anna\'s Archive Secret Key'**
  String get annasSecretKey;

  /// Onboarding sponsor page heading
  ///
  /// In en, this message translates to:
  /// **'Support This App'**
  String get supportThisApp;

  /// Onboarding sponsor page body
  ///
  /// In en, this message translates to:
  /// **'If you enjoy this app, consider supporting its development. It helps me dedicate more time to making it better!'**
  String get sponsorPitch;

  /// Sponsor link button
  ///
  /// In en, this message translates to:
  /// **'Sponsor on GitHub'**
  String get sponsorOnGithub;

  /// Onboarding notifications page heading
  ///
  /// In en, this message translates to:
  /// **'Stay Updated'**
  String get stayUpdated;

  /// Onboarding notifications switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Get notified when downloads complete.'**
  String get notifyOnComplete;

  /// Onboarding theme page heading
  ///
  /// In en, this message translates to:
  /// **'Choose a Theme'**
  String get chooseTheme;

  /// Theme card label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightThemeShort;

  /// Theme card label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkThemeShort;

  /// AppBar title on the challenge solver screen
  ///
  /// In en, this message translates to:
  /// **'Verifying Access'**
  String get verifyingAccess;

  /// Webview verification finish button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Snackbar when TTS finds no voice
  ///
  /// In en, this message translates to:
  /// **'No voice available for reading aloud'**
  String get noVoiceAvailable;

  /// Dialog dismiss button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Mirror health refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Reload health data'**
  String get reloadHealthData;

  /// Tooltip for adding a mirror of a given service
  ///
  /// In en, this message translates to:
  /// **'Add a {title} mirror'**
  String addServiceMirror(String title);

  /// Mirror delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete mirror'**
  String get deleteMirrorTooltip;

  /// Header on the search results page naming the catalog that produced the results
  ///
  /// In en, this message translates to:
  /// **'Results from {source}'**
  String searchingOn(String source);

  /// Short source label for Library Genesis results
  ///
  /// In en, this message translates to:
  /// **'LibGen'**
  String get sourceLibgen;

  /// Short source label for Z-Library results
  ///
  /// In en, this message translates to:
  /// **'Z-Library'**
  String get sourceZlib;

  /// Short source label for Anna's Archive results
  ///
  /// In en, this message translates to:
  /// **'Anna\'s Archive'**
  String get sourceAnnas;

  /// Notification/UI text naming the mirror serving the download
  ///
  /// In en, this message translates to:
  /// **'Downloading from {source}'**
  String downloadFrom(String source);

  /// Shown while a search redirects to the next catalog after an empty page
  ///
  /// In en, this message translates to:
  /// **'No results here, trying next source…'**
  String get tryingNextSource;

  /// Tiny hint that slow IPFS mirrors were deprioritized
  ///
  /// In en, this message translates to:
  /// **'Using faster mirrors'**
  String get slowMirrorsSkipped;

  /// Upgrade screen title naming the new version
  ///
  /// In en, this message translates to:
  /// **'What\'s new in {version}'**
  String whatsNewTitle(String version);

  /// One-line intro on the upgrade screen
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended was updated. Here is what changed.'**
  String get whatsNewIntro;

  /// Tab label listing this release's features
  ///
  /// In en, this message translates to:
  /// **'New features'**
  String get whatsNewTabFeatures;

  /// Tab label offering the instance-list update
  ///
  /// In en, this message translates to:
  /// **'Sources & mirrors'**
  String get whatsNewTabSources;

  /// Explains what the instance-list update on upgrade does
  ///
  /// In en, this message translates to:
  /// **'This release adds new search providers and mirrors. Update your list to drop dead mirrors and add the new ones; all three search providers get enabled.'**
  String get whatsNewProvidersHint;

  /// Button that re-syncs the stored mirror list with the shipped defaults
  ///
  /// In en, this message translates to:
  /// **'Update mirror list'**
  String get whatsNewUpdateInstances;

  /// Confirmation after the mirror list was re-synced
  ///
  /// In en, this message translates to:
  /// **'Mirror list updated'**
  String get whatsNewInstancesUpdated;

  /// Button closing the upgrade screen and entering the app
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get whatsNewContinue;

  /// Release note about the download speed fix
  ///
  /// In en, this message translates to:
  /// **'Downloads start faster: no mirror probing, fast hosts first, slow IPFS gateways last.'**
  String get whatsNewFeatureSpeed;

  /// Release note about the source badges
  ///
  /// In en, this message translates to:
  /// **'Every search result and download now shows which catalog it came from.'**
  String get whatsNewFeatureSourceLabels;

  /// Release note about the lazy cover fix
  ///
  /// In en, this message translates to:
  /// **'Missing LibGen covers are fetched from the book\'s detail page.'**
  String get whatsNewFeatureCovers;

  /// Category title shown on the Genres page (Classics)
  ///
  /// In en, this message translates to:
  /// **'Classics'**
  String get categoryClassicsTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Timeless literary works often revered for their artistic merit and cultural significance.'**
  String get categoryClassicsInfo;

  /// Category title shown on the Genres page (Romance)
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get categoryRomanceTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Stories focused on romantic relationships, exploring love, passion, and emotional connections.'**
  String get categoryRomanceInfo;

  /// Category title shown on the Genres page (Fiction)
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get categoryFictionTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Narrative literature created from the imagination, not based on real events.'**
  String get categoryFictionInfo;

  /// Category title shown on the Genres page (Young Adult)
  ///
  /// In en, this message translates to:
  /// **'Young Adult'**
  String get categoryYoungAdultTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Books targeted at teenage readers, addressing themes relevant to adolescence.'**
  String get categoryYoungAdultInfo;

  /// Category title shown on the Genres page (Fantasy)
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get categoryFantasyTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'A genre featuring magical elements, mythical creatures, and fantastical worlds.'**
  String get categoryFantasyInfo;

  /// Category title shown on the Genres page (Science Fiction)
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get categoryScienceFictionTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Literature that explores futuristic concepts, advanced technology, and space exploration.'**
  String get categoryScienceFictionInfo;

  /// Category title shown on the Genres page (Nonfiction)
  ///
  /// In en, this message translates to:
  /// **'Nonfiction'**
  String get categoryNonfictionTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Works based on factual information, including essays, biographies, and documentaries.'**
  String get categoryNonfictionInfo;

  /// Category title shown on the Genres page (Children)
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get categoryChildrenTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Books aimed at young readers, often with illustrations and simple narratives.'**
  String get categoryChildrenInfo;

  /// Category title shown on the Genres page (History)
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get categoryHistoryTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Literature that examines past events, cultures, and significant historical figures.'**
  String get categoryHistoryInfo;

  /// Category title shown on the Genres page (Mystery)
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get categoryMysteryTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Stories centered around suspenseful plots, often involving crime or puzzles to solve.'**
  String get categoryMysteryInfo;

  /// Category title shown on the Genres page (Covers)
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get categoryCoversTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Refers to the artwork and design that visually represents a book, influencing reader interest.'**
  String get categoryCoversInfo;

  /// Category title shown on the Genres page (Horror)
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get categoryHorrorTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'A genre designed to evoke fear, dread, or terror in the reader through suspenseful storytelling.'**
  String get categoryHorrorInfo;

  /// Category title shown on the Genres page (Historical Fiction)
  ///
  /// In en, this message translates to:
  /// **'Historical Fiction'**
  String get categoryHistoricalFictionTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Novels set in a specific historical period, blending factual events with fictional characters.'**
  String get categoryHistoricalFictionInfo;

  /// Category title shown on the Genres page (Best)
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get categoryBestTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Often refers to critically acclaimed or popular books, usually categorized by rankings or awards.'**
  String get categoryBestInfo;

  /// Category title shown on the Genres page (Titles)
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get categoryTitlesTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Refers to the names of books, which often reflect their themes or subject matter.'**
  String get categoryTitlesInfo;

  /// Category title shown on the Genres page (Middle Grade)
  ///
  /// In en, this message translates to:
  /// **'Middle Grade'**
  String get categoryMiddleGradeTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Books intended for readers aged 8-12, featuring age-appropriate themes and characters.'**
  String get categoryMiddleGradeInfo;

  /// Category title shown on the Genres page (Paranormal)
  ///
  /// In en, this message translates to:
  /// **'Paranormal'**
  String get categoryParanormalTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Stories that incorporate supernatural elements, including ghosts, vampires, and otherworldly beings.'**
  String get categoryParanormalInfo;

  /// Category title shown on the Genres page (Love)
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get categoryLoveTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'A theme exploring the complexities and nuances of love in various forms and relationships.'**
  String get categoryLoveInfo;

  /// Category title shown on the Genres page (Queer)
  ///
  /// In en, this message translates to:
  /// **'Queer'**
  String get categoryQueerTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Literature that represents diverse sexual orientations and gender identities within the LGBTQ+ spectrum.'**
  String get categoryQueerInfo;

  /// Category title shown on the Genres page (Historical Romance)
  ///
  /// In en, this message translates to:
  /// **'Historical Romance'**
  String get categoryHistoricalRomanceTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Novels combining romantic plots set against a historical backdrop.'**
  String get categoryHistoricalRomanceInfo;

  /// Category title shown on the Genres page (Contemporary)
  ///
  /// In en, this message translates to:
  /// **'Contemporary'**
  String get categoryContemporaryTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Works set in modern times, often addressing current social issues and relatable characters.'**
  String get categoryContemporaryInfo;

  /// Category title shown on the Genres page (Thriller)
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get categoryThrillerTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'A suspenseful genre focused on excitement, tension, and unexpected twists.'**
  String get categoryThrillerInfo;

  /// Category title shown on the Genres page (Women)
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get categoryWomenTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Literature that explores women’s experiences, perspectives, and empowerment.'**
  String get categoryWomenInfo;

  /// Category title shown on the Genres page (Biography)
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get categoryBiographyTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Nonfiction works detailing the life story of an individual, highlighting their achievements and challenges.'**
  String get categoryBiographyInfo;

  /// Category title shown on the Genres page (LGBTQ)
  ///
  /// In en, this message translates to:
  /// **'LGBTQ'**
  String get categoryLgbtqTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Inclusive literature representing the experiences of the lesbian, gay, bisexual, transgender, and queer community.'**
  String get categoryLgbtqInfo;

  /// Category title shown on the Genres page (Series)
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get categorySeriesTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'A collection of related books that follow a common storyline or set of characters.'**
  String get categorySeriesInfo;

  /// Category title shown on the Genres page (Title Challenge)
  ///
  /// In en, this message translates to:
  /// **'Title Challenge'**
  String get categoryTitleChallengeTitle;

  /// Category description shown on the Genres page
  ///
  /// In en, this message translates to:
  /// **'Refers to prompts or contests encouraging creative thinking about book titles.'**
  String get categoryTitleChallengeInfo;

  /// Mirrors settings page text: Mirrors
  ///
  /// In en, this message translates to:
  /// **'Mirrors'**
  String get mirrorsTitle;

  /// Mirrors settings page text: Automatic mirror order
  ///
  /// In en, this message translates to:
  /// **'Automatic mirror order'**
  String get automaticMirrorOrder;

  /// Mirrors settings page text: Easiest protection first, then fastest. Recommended.
  ///
  /// In en, this message translates to:
  /// **'Easiest protection first, then fastest. Recommended.'**
  String get mirrorOrderAutoHint;

  /// Mirrors settings page text: Manual: use the arrows to set your own order.
  ///
  /// In en, this message translates to:
  /// **'Manual: use the arrows to set your own order.'**
  String get mirrorOrderManualHint;

  /// Mirrors settings page text: Mirror list is up to date
  ///
  /// In en, this message translates to:
  /// **'Mirror list is up to date'**
  String get mirrorListUpToDate;

  /// Mirrors settings page text: Mirror list updated: {count} change(s)
  ///
  /// In en, this message translates to:
  /// **'Mirror list updated: {count} change(s)'**
  String mirrorListUpdated(int count);

  /// Mirrors settings page text: Refresh failed: {error}
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String mirrorRefreshFailed(String error);

  /// Mirrors settings page text: Could not reach open-slum.org - no mirror list available
  ///
  /// In en, this message translates to:
  /// **'Could not reach open-slum.org - no mirror list available'**
  String get mirrorCatalogueUnreachable;

  /// Mirrors settings page text: Mirror addresses and their status come from open-slum.org and refresh automatically. A mirror reported DOWN is never contacted. Local latency is measured by this device when you tap the speed button.
  ///
  /// In en, this message translates to:
  /// **'Mirror addresses and their status come from open-slum.org and refresh automatically. A mirror reported DOWN is never contacted. Local latency is measured by this device when you tap the speed button.'**
  String get mirrorFooterNote;

  /// Mirrors settings page: AppBar button that measures this device's latency to enabled mirrors.
  ///
  /// In en, this message translates to:
  /// **'Test local latency'**
  String get mirrorLatencyTestTooltip;

  /// Search page hint shown when local mirror latency readings are missing or older than 24 hours
  ///
  /// In en, this message translates to:
  /// **'Local mirrors have not been tested; search may be slower. Testing sorts them by your own latency.'**
  String get mirrorLatencyHint;

  /// Local latency suffix for protected mirrors: reachable as a host, but a challenge may still block a search
  ///
  /// In en, this message translates to:
  /// **'needs verification'**
  String get mirrorLatencyNeedsVerification;

  /// Search page hint action that opens the mirrors page to run a local latency test
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get mirrorLatencyGoTest;

  /// Mirrors settings page: this device has no reading for the mirror yet.
  ///
  /// In en, this message translates to:
  /// **'Local latency not tested'**
  String get mirrorLatencyNotTested;

  /// Mirrors settings page: a local latency test is running for this mirror.
  ///
  /// In en, this message translates to:
  /// **'Testing local latency…'**
  String get mirrorLatencyTesting;

  /// Mirrors settings page: the mirror did not return response headers before the local test timed out.
  ///
  /// In en, this message translates to:
  /// **'Local timeout'**
  String get mirrorLatencyTimeout;

  /// Mirrors settings page: local latency value, e.g. Local 85 ms.
  ///
  /// In en, this message translates to:
  /// **'Local {latency}'**
  String mirrorLatencyLocal(String latency);

  /// Mirrors settings page: the local latency was measured less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get mirrorLatencyJustNow;

  /// Mirrors settings page: the local reading is older than 24 hours and no longer affects ordering.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get mirrorLatencyExpired;

  /// Snackbar after a local latency test.
  ///
  /// In en, this message translates to:
  /// **'Local test: {reachable}/{total} reachable, fastest {fastest}'**
  String mirrorLatencyDone(int reachable, int total, String fastest);

  /// Snackbar when every mirror in the local latency test timed out.
  ///
  /// In en, this message translates to:
  /// **'Local test finished · no mirror responded'**
  String get mirrorLatencyAllTimedOut;

  /// Snackbar when the local latency test has no enabled, non-DOWN mirrors.
  ///
  /// In en, this message translates to:
  /// **'No enabled mirrors to test'**
  String get mirrorLatencyNoTargets;

  /// Snackbar when the local latency test throws.
  ///
  /// In en, this message translates to:
  /// **'Local test failed: {error}'**
  String mirrorLatencyFailed(String error);

  /// Mirrors settings page text: No mirrors reported
  ///
  /// In en, this message translates to:
  /// **'No mirrors reported'**
  String get noMirrorsReported;

  /// Mirrors settings page text: open-slum.org has no entry (yet) or could not be reached.
  ///
  /// In en, this message translates to:
  /// **'open-slum.org has no entry (yet) or could not be reached.'**
  String get noMirrorsReportedHint;

  /// Mirrors settings page text: Could not load mirrors
  ///
  /// In en, this message translates to:
  /// **'Could not load mirrors'**
  String get couldNotLoadMirrors;

  /// Mirrors settings page text: Move up
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// Mirrors settings page text: Move down
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// Mirrors settings page text: reported down - never contacted
  ///
  /// In en, this message translates to:
  /// **'reported down - never contacted'**
  String get reportedDownNeverContacted;

  /// Mirrors settings page text: Fast, challenge-free downloads when a mirror is up
  ///
  /// In en, this message translates to:
  /// **'Fast, challenge-free downloads when a mirror is up'**
  String get mirrorServiceLibgenHint;

  /// Mirrors settings page text: DiamWall mirrors solve headlessly
  ///
  /// In en, this message translates to:
  /// **'DiamWall mirrors solve headlessly'**
  String get mirrorServiceZlibHint;

  /// Mirrors settings page text: Cloudflare-gated search, open book pages
  ///
  /// In en, this message translates to:
  /// **'Cloudflare-gated search, open book pages'**
  String get mirrorServiceWelibHint;

  /// Mirrors settings page text: Reading, details and downloads
  ///
  /// In en, this message translates to:
  /// **'Reading, details and downloads'**
  String get mirrorServiceAnnasHint;

  /// Mirrors settings page text: Up
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get mirrorStatusUp;

  /// Mirrors settings page text: Degraded
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get mirrorStatusDegraded;

  /// Mirrors settings page text: Protected
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get mirrorStatusProtected;

  /// Mirrors settings page text: Down
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get mirrorStatusDown;

  /// UI text: Search field is empty
  ///
  /// In en, this message translates to:
  /// **'Search field is empty'**
  String get searchEmptyQuery;

  /// UI text: Type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeLabel;

  /// UI text: Sort by
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortLabel;

  /// UI text: File type
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get filterFileTypeLabel;

  /// UI text: Year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYearLabel;

  /// UI text: All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// UI text: Any Books
  ///
  /// In en, this message translates to:
  /// **'Any Books'**
  String get typeAnyBooks;

  /// UI text: Unknown Books
  ///
  /// In en, this message translates to:
  /// **'Unknown Books'**
  String get typeUnknownBooks;

  /// UI text: Fiction Books
  ///
  /// In en, this message translates to:
  /// **'Fiction Books'**
  String get typeFictionBooks;

  /// UI text: Non-fiction Books
  ///
  /// In en, this message translates to:
  /// **'Non-fiction Books'**
  String get typeNonfictionBooks;

  /// UI text: Comic Books
  ///
  /// In en, this message translates to:
  /// **'Comic Books'**
  String get typeComicBooks;

  /// UI text: Magazine
  ///
  /// In en, this message translates to:
  /// **'Magazine'**
  String get typeMagazine;

  /// UI text: Standards Document
  ///
  /// In en, this message translates to:
  /// **'Standards Document'**
  String get typeStandardsDocument;

  /// UI text: Journal Article
  ///
  /// In en, this message translates to:
  /// **'Journal Article'**
  String get typeJournalArticle;

  /// UI text: Most Relevant
  ///
  /// In en, this message translates to:
  /// **'Most Relevant'**
  String get sortMostRelevant;

  /// UI text: Newest
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// UI text: Oldest
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// UI text: Largest
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get sortLargest;

  /// UI text: Smallest
  ///
  /// In en, this message translates to:
  /// **'Smallest'**
  String get sortSmallest;

  /// UI text: Before 1980
  ///
  /// In en, this message translates to:
  /// **'Before 1980'**
  String get yearBefore1980;

  /// Language filter label (English)
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// Language filter label (Spanish)
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// Language filter label (French)
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// Language filter label (German)
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// Language filter label (Italian)
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get langItalian;

  /// Language filter label (Portuguese)
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get langPortuguese;

  /// Language filter label (Russian)
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langRussian;

  /// Language filter label (Chinese)
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get langChinese;

  /// Language filter label (Japanese)
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJapanese;

  /// Language filter label (Korean)
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get langKorean;

  /// Language filter label (Arabic)
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// Language filter label (Hindi)
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHindi;

  /// Language filter label (Malayalam)
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get langMalayalam;

  /// Language filter label (Dutch)
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get langDutch;

  /// Language filter label (Polish)
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get langPolish;

  /// Language filter label (Turkish)
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// Language filter label (Swedish)
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get langSwedish;

  /// Language filter label (Indonesian)
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get langIndonesian;

  /// Language filter label (Vietnamese)
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get langVietnamese;

  /// Language filter label (Czech)
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get langCzech;

  /// Language filter label (Greek)
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get langGreek;

  /// Language filter label (Romanian)
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get langRomanian;

  /// Language filter label (Hungarian)
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get langHungarian;

  /// Language filter label (Ukrainian)
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get langUkrainian;

  /// Language filter label (Hebrew)
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get langHebrew;

  /// Language filter label (Thai)
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get langThai;

  /// Language filter label (Persian)
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get langPersian;

  /// Language filter label (Bengali)
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get langBengali;

  /// Language filter label (Finnish)
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get langFinnish;

  /// Language filter label (Norwegian)
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get langNorwegian;

  /// Language filter label (Danish)
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get langDanish;

  /// UI text: Downloads
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// UI text: Queued
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get downloadQueued;

  /// UI text: Getting mirrors...
  ///
  /// In en, this message translates to:
  /// **'Getting mirrors...'**
  String get downloadGettingMirrors;

  /// UI text: Finding mirror...
  ///
  /// In en, this message translates to:
  /// **'Finding mirror...'**
  String get downloadFindingMirror;

  /// UI text: Downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadDownloading;

  /// UI text: Paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadPaused;

  /// UI text: downloadVerifying
  ///
  /// In en, this message translates to:
  /// **'Verifying file…'**
  String get downloadVerifying;

  /// UI text: Cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get downloadCancelled;

  /// UI text: Download failed
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailedGeneric;

  /// UI text: Verify
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// UI text: Description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// UI text: No description available
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// UI text: Could not open the link.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// UI text: Manual Download
  ///
  /// In en, this message translates to:
  /// **'Manual Download'**
  String get manualDownloadAction;

  /// UI text: Fast download started in background 🚀
  ///
  /// In en, this message translates to:
  /// **'Fast download started in background 🚀'**
  String get fastDownloadStarted;

  /// UI text: WeLib did not offer a download link for this book.
  ///
  /// In en, this message translates to:
  /// **'WeLib did not offer a download link for this book.'**
  String get welibNoDownloadLink;

  /// UI text: zlibDailyLimit
  ///
  /// In en, this message translates to:
  /// **'Z-Library has reached its daily download limit for your network. Try again tomorrow, or sign in to Z-Library in the app browser.'**
  String get zlibDailyLimit;

  /// UI text: zlibSignIn
  ///
  /// In en, this message translates to:
  /// **'Z-Library asks you to sign in before downloading this book.'**
  String get zlibSignIn;

  /// UI text: zlibNoDownloadLink
  ///
  /// In en, this message translates to:
  /// **'This Z-Library page did not offer a download link. The book may be restricted or removed.'**
  String get zlibNoDownloadLink;

  /// UI text: welibRateLimit
  ///
  /// In en, this message translates to:
  /// **'WeLib is limiting downloads right now. Wait a few minutes and try again.'**
  String get welibRateLimit;

  /// UI text: welibBotCheck
  ///
  /// In en, this message translates to:
  /// **'WeLib did not let the app through its bot check. Try again, or open the book in the app browser.'**
  String get welibBotCheck;

  /// UI text: Could not read the WeLib download page.
  ///
  /// In en, this message translates to:
  /// **'Could not read the WeLib download page.'**
  String get welibPageUnreadable;

  /// UI text: File not found. The download may have failed.
  ///
  /// In en, this message translates to:
  /// **'File not found. The download may have failed.'**
  String get fileNotFoundDownloadFailed;

  /// UI text: Discover this amazing book: "{title}"
  /// Read more: {link}
  ///
  /// In en, this message translates to:
  /// **'Discover this amazing book: \"{title}\"\nRead more: {link}'**
  String shareBookMessage(String title, String link);

  /// UI text: Verify Access - OpenLibExtended
  ///
  /// In en, this message translates to:
  /// **'Verify Access - OpenLibExtended'**
  String get webviewWindowTitle;

  /// UI text: Browser window is open
  ///
  /// In en, this message translates to:
  /// **'Browser window is open'**
  String get webviewBrowserOpen;

  /// UI text: Opening browser window...
  ///
  /// In en, this message translates to:
  /// **'Opening browser window...'**
  String get webviewBrowserOpening;

  /// UI text: 1. Solve the CAPTCHA in the browser window
  /// 2. Wait for the page to fully load
  /// 3. Click 'Done' button above to continue
  ///
  /// In en, this message translates to:
  /// **'1. Solve the CAPTCHA in the browser window\n2. Wait for the page to fully load\n3. Click \'Done\' button above to continue'**
  String get webviewInstructions;

  /// UI text: Preparing download...
  ///
  /// In en, this message translates to:
  /// **'Preparing download...'**
  String get webviewPreparingDownload;

  /// UI text: Please wait while we verify access and fetch download links
  ///
  /// In en, this message translates to:
  /// **'Please wait while we verify access and fetch download links'**
  String get webviewPreparingHint;

  /// UI text: Change where books are saved
  ///
  /// In en, this message translates to:
  /// **'Change where books are saved'**
  String get changeStorageHint;

  /// UI text: Version {version}+{build}
  ///
  /// In en, this message translates to:
  /// **'Version {version}+{build}'**
  String versionWithBuild(String version, String build);

  /// UI text: OpenlibExtended backup
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended backup'**
  String get backupShareText;

  /// UI text: Export Backup
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackupTitle;

  /// UI text: Save settings, books and instances to a JSON file
  ///
  /// In en, this message translates to:
  /// **'Save settings, books and instances to a JSON file'**
  String get exportBackupSubtitle;

  /// UI text: Import Backup
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackupTitle;

  /// UI text: Restore from a backup file (replaces current data)
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file (replaces current data)'**
  String get importBackupSubtitle;

  /// UI text: Cloudflare-gated search and open book pages
  ///
  /// In en, this message translates to:
  /// **'Cloudflare-gated search and open book pages'**
  String get providerWelibCatalog;

  /// UI text: What to do
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get errorWhatToDo;

  /// UI text: A VPN can help bypass regional blocks and access the content.
  ///
  /// In en, this message translates to:
  /// **'A VPN can help bypass regional blocks and access the content.'**
  String get errorVpnDescription;

  /// UI text: The site is asking you to verify that you're human. We'll open a browser window where you can complete the verification.
  ///
  /// In en, this message translates to:
  /// **'The site is asking you to verify that you\'re human. We\'ll open a browser window where you can complete the verification.'**
  String get errorVerificationPrompt;

  /// UI text: Once you complete the verification, return to the app and tap 'Try Again'.
  ///
  /// In en, this message translates to:
  /// **'Once you complete the verification, return to the app and tap \'Try Again\'.'**
  String get errorVerificationReturn;

  /// UI text: No content available
  ///
  /// In en, this message translates to:
  /// **'No content available'**
  String get errorNoContent;

  /// Localized network error title or solution: No internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkErrorNoInternetTitle;

  /// Localized network error title or solution: Check your internet connection. Make sure Wi-Fi or mobile data is enabled.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection. Make sure Wi-Fi or mobile data is enabled.'**
  String get networkErrorNoInternetSolution;

  /// Localized network error title or solution: Access blocked by DDoS protection
  ///
  /// In en, this message translates to:
  /// **'Access blocked by DDoS protection'**
  String get networkErrorCloudflareTitle;

  /// Localized network error title or solution: This site is protected and blocking the app. Try a VPN, change DNS to 1.1.1.1 or 8.8.8.8, or verify
  ///
  /// In en, this message translates to:
  /// **'This site is protected and blocking the app. Try a VPN, change DNS to 1.1.1.1 or 8.8.8.8, or verify in the browser.'**
  String get networkErrorCloudflareSolution;

  /// Localized network error title or solution: Server temporarily unavailable
  ///
  /// In en, this message translates to:
  /// **'Server temporarily unavailable'**
  String get networkErrorServerUnavailableTitle;

  /// Localized network error title or solution: The server is having problems. Try again in a few minutes or choose another mirror in Settings.
  ///
  /// In en, this message translates to:
  /// **'The server is having problems. Try again in a few minutes or choose another mirror in Settings.'**
  String get networkErrorServerUnavailableSolution;

  /// Localized network error title or solution: Request timed out
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get networkErrorTimeoutTitle;

  /// Localized network error title or solution: The server is taking too long to respond. Check your connection and try again.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. Check your connection and try again.'**
  String get networkErrorTimeoutSolution;

  /// Localized network error title or solution: Access denied
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get networkErrorForbiddenTitle;

  /// Localized network error title or solution: You don't have permission to access this resource. Try a VPN, change DNS, or use another mirror in S
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this resource. Try a VPN, change DNS, or use another mirror in Settings.'**
  String get networkErrorForbiddenSolution;

  /// Localized network error title or solution: Too many requests
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get networkErrorRateLimitedTitle;

  /// Localized network error title or solution: Too many requests were sent. Wait a few minutes and try again.
  ///
  /// In en, this message translates to:
  /// **'Too many requests were sent. Wait a few minutes and try again.'**
  String get networkErrorRateLimitedSolution;

  /// Localized network error title or solution: Secure connection failed
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed'**
  String get networkErrorSslTitle;

  /// Localized network error title or solution: Your network may be blocking secure connections. Try a VPN or a different network.
  ///
  /// In en, this message translates to:
  /// **'Your network may be blocking secure connections. Try a VPN or a different network.'**
  String get networkErrorSslSolution;

  /// Localized network error title or solution: Server not found
  ///
  /// In en, this message translates to:
  /// **'Server not found'**
  String get networkErrorDnsTitle;

  /// Localized network error title or solution: The site could not be reached. Your ISP may be blocking it. Try a VPN or change DNS to 1.1.1.1 / 8.8
  ///
  /// In en, this message translates to:
  /// **'The site could not be reached. Your ISP may be blocking it. Try a VPN or change DNS to 1.1.1.1 / 8.8.8.8.'**
  String get networkErrorDnsSolution;

  /// Error title when the catalog returned HTML the app could not parse
  ///
  /// In en, this message translates to:
  /// **'Could not read the book source data'**
  String get networkErrorParseTitle;

  /// Suggested action for an unreadable catalog response
  ///
  /// In en, this message translates to:
  /// **'The source returned a page the app could not read. Switch to another source or mirror and try again. If it keeps happening, open Diagnostics and share the logs.'**
  String get networkErrorParseSolution;

  /// Error title for database or file system failures
  ///
  /// In en, this message translates to:
  /// **'Local storage operation failed'**
  String get networkErrorStorageTitle;

  /// Suggested action for local database or file failures
  ///
  /// In en, this message translates to:
  /// **'Check free space and storage permissions, then try again. If it keeps happening, open Diagnostics and share the logs.'**
  String get networkErrorStorageSolution;

  /// Localized network error title or solution: Something went wrong
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get networkErrorUnknownTitle;

  /// Generic error solution; points at diagnostics instead of restarting
  ///
  /// In en, this message translates to:
  /// **'Please try again. If it persists, open Diagnostics and share the logs.'**
  String get networkErrorUnknownSolution;

  /// Button and dialog title for error diagnostics
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get errorDiagnostics;

  /// Button that copies the current error diagnostics
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get errorCopyDiagnostics;

  /// Where the error happened, e.g. search results or book details
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String errorLocation(String location);

  /// Label for the captured stack trace
  ///
  /// In en, this message translates to:
  /// **'Stack trace'**
  String get errorStackTrace;

  /// Label for app version, platform and time in diagnostics
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get errorEnvironment;

  /// Localized update/install dialog text: Permission Required
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get updatePermissionTitle;

  /// Localized update/install dialog text: To install app updates, OpenlibExtended needs permission to install packages.
  ///
  /// This allows the app t
  ///
  /// In en, this message translates to:
  /// **'To install app updates, OpenlibExtended needs permission to install packages.\n\nThis allows the app to automatically install new versions with bug fixes and new features.\n\nYou will be taken to Settings to enable this permission.'**
  String get updatePermissionBody;

  /// Localized update/install dialog text: Open Settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get updateOpenSettings;

  /// Localized update/install dialog text: Debug Build Detected: Update may fail with 'App not installed' due to signature mismatch. Uninstall
  ///
  /// In en, this message translates to:
  /// **'Debug Build Detected: Update may fail with \'App not installed\' due to signature mismatch. Uninstall this app first.'**
  String get updateDebugBuildWarning;

  /// Localized update/install dialog text: Opening installer... If nothing happens, the install failed.
  ///
  /// In en, this message translates to:
  /// **'Opening installer... If nothing happens, the install failed.'**
  String get updateOpeningInstaller;

  /// Localized update/install dialog text: Manual Install
  ///
  /// In en, this message translates to:
  /// **'Manual Install'**
  String get updateManualInstall;

  /// Localized update/install dialog text: Installation Issue
  ///
  /// In en, this message translates to:
  /// **'Installation Issue'**
  String get updateInstallationIssueTitle;

  /// Localized update/install dialog text: The automatic installer couldn't open the APK. This can happen on some Android versions.
  ///
  /// You can in
  ///
  /// In en, this message translates to:
  /// **'The automatic installer couldn\'t open the APK. This can happen on some Android versions.\n\nYou can install manually using one of these options:'**
  String get updateInstallationIssueBody;

  /// Localized update/install dialog text: File: {file}
  ///
  /// In en, this message translates to:
  /// **'File: {file}'**
  String updateFileLabel(String file);

  /// Localized update/install dialog text: Installation Failed
  ///
  /// In en, this message translates to:
  /// **'Installation Failed'**
  String get updateInstallationFailed;

  /// Localized update/install dialog text: Methods tried:
  ///
  /// In en, this message translates to:
  /// **'Methods tried:'**
  String get updateMethodsTried;

  /// Localized update/install dialog text: Errors encountered:
  ///
  /// In en, this message translates to:
  /// **'Errors encountered:'**
  String get updateErrorsEncountered;

  /// Localized update/install dialog text: Method {number}
  ///
  /// In en, this message translates to:
  /// **'Method {number}'**
  String updateMethodNumber(int number);

  /// Localized update/install dialog text: Download via Browser
  ///
  /// In en, this message translates to:
  /// **'Download via Browser'**
  String get updateDownloadViaBrowser;

  /// Localized update/install dialog text: Installation Error
  ///
  /// In en, this message translates to:
  /// **'Installation Error'**
  String get updateInstallationErrorTitle;

  /// Localized update/install dialog text: OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get updateOk;

  /// Localized update/install dialog text: Try Manual Install
  ///
  /// In en, this message translates to:
  /// **'Try Manual Install'**
  String get updateTryManualInstall;

  /// Localized update/install dialog text: Failed to install update: {error}
  ///
  /// In en, this message translates to:
  /// **'Failed to install update: {error}'**
  String updateInstallFailed(String error);

  /// Localized update/install dialog text: Update Available
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// Localized update/install dialog text: Version {version} is available!
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available!'**
  String updateVersionAvailable(String version);

  /// Localized update/install dialog text: Pre-release
  ///
  /// In en, this message translates to:
  /// **'Pre-release'**
  String get updatePreRelease;

  /// Localized update/install dialog text: What's new:
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get updateWhatsNew;

  /// Localized update/install dialog text: Later
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// Localized update/install dialog text: Download & Install
  ///
  /// In en, this message translates to:
  /// **'Download & Install'**
  String get updateDownloadAndInstall;

  /// Localized update/install dialog text: Download from GitHub
  ///
  /// In en, this message translates to:
  /// **'Download from GitHub'**
  String get updateDownloadFromGithub;

  /// Localized update/install dialog text: View on GitHub
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get updateViewOnGithub;

  /// Localized update/install dialog text: Downloading Update
  ///
  /// In en, this message translates to:
  /// **'Downloading Update'**
  String get updateDownloading;

  /// Localized update/install dialog text: Download Complete
  ///
  /// In en, this message translates to:
  /// **'Download Complete'**
  String get updateDownloadComplete;

  /// Localized update/install dialog text: Version {version}
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateVersionLabel(String version);

  /// Localized update/install dialog text: Opening installer...
  ///
  /// In en, this message translates to:
  /// **'Opening installer...'**
  String get updateOpeningInstallerShort;

  /// Localized update/install dialog text: Connecting...
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get updateConnecting;

  /// Localized update/install dialog text: Downloaded file not found
  ///
  /// In en, this message translates to:
  /// **'Downloaded file not found'**
  String get updateFileNotFound;

  /// Localized update/install dialog text: Downloaded file appears to be corrupted (only {size})
  ///
  /// In en, this message translates to:
  /// **'Downloaded file appears to be corrupted (only {size})'**
  String updateFileCorrupted(String size);

  /// Localized update/install dialog text: Permission to install apps was denied. You can still install manually.
  ///
  /// In en, this message translates to:
  /// **'Permission to install apps was denied. You can still install manually.'**
  String get updatePermissionDenied;

  /// Localized update/install dialog text: May have failed silently
  ///
  /// In en, this message translates to:
  /// **'May have failed silently'**
  String get updateMayHaveFailedSilently;

  /// Localized update/install dialog text: Open File
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get updateMethodOpenFile;

  /// Localized update/install dialog text: APK Sideload
  ///
  /// In en, this message translates to:
  /// **'APK Sideload'**
  String get updateMethodApkSideload;

  /// Localized update/install dialog text: Package Installer
  ///
  /// In en, this message translates to:
  /// **'Package Installer'**
  String get updateMethodPackageInstaller;

  /// Localized network error title or solution: Book not found
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get networkErrorBookNotFoundTitle;

  /// Localized network error title or solution: The page loaded but no book details were on it. The link may be outdated - try searching for the tit
  ///
  /// In en, this message translates to:
  /// **'The page loaded but no book details were on it. The link may be outdated - try searching for the title instead.'**
  String get networkErrorBookNotFoundSolution;

  /// Localized network error title or solution: Unable to load book details
  ///
  /// In en, this message translates to:
  /// **'Unable to load book details'**
  String get networkErrorBookDetailsUnavailableTitle;

  /// Localized network error title or solution: The book information could not be retrieved. Try again or use another mirror in Settings.
  ///
  /// In en, this message translates to:
  /// **'The book information could not be retrieved. Try again or use another mirror in Settings.'**
  String get networkErrorBookDetailsUnavailableSolution;

  /// Download failure message: No working mirrors available!
  ///
  /// In en, this message translates to:
  /// **'No working mirrors available!'**
  String get downloadNoWorkingMirrors;

  /// Download failure message: All mirrors failed!
  ///
  /// In en, this message translates to:
  /// **'All mirrors failed!'**
  String get downloadAllMirrorsFailed;

  /// Download failure message: Error getting mirrors
  ///
  /// In en, this message translates to:
  /// **'Error getting mirrors'**
  String get downloadErrorGettingMirrors;

  /// Download failure message: Could not save to library: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not save to library: {error}'**
  String downloadCouldNotSave(String error);

  /// Log export dialog text: OpenlibExtended App Logs
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended App Logs'**
  String get appLogsShareSubject;

  /// Log export dialog text: OpenlibExtended app logs for the past {minutes} minutes
  ///
  /// In en, this message translates to:
  /// **'OpenlibExtended app logs for the past {minutes} minutes'**
  String appLogsShareText(int minutes);

  /// Android download notification text: Already downloading: {title}
  ///
  /// In en, this message translates to:
  /// **'Already downloading: {title}'**
  String notificationAlreadyDownloading(String title);

  /// Android download notification text: Queued: {title}
  ///
  /// In en, this message translates to:
  /// **'Queued: {title}'**
  String notificationQueued(String title);

  /// Android download notification text: Starting fast download...
  ///
  /// In en, this message translates to:
  /// **'Starting fast download...'**
  String get notificationStartingFastDownload;

  /// Android download notification text: Verifying file...
  ///
  /// In en, this message translates to:
  /// **'Verifying file...'**
  String get notificationVerifyingFile;

  /// Android download notification text: Download completed!
  ///
  /// In en, this message translates to:
  /// **'Download completed!'**
  String get notificationDownloadComplete;

  /// Android download notification text: Download completed (checksum failed)
  ///
  /// In en, this message translates to:
  /// **'Download completed (checksum failed)'**
  String get notificationDownloadCompleteChecksumFailed;

  /// Android download notification text: Book download progress notifications
  ///
  /// In en, this message translates to:
  /// **'Book download progress notifications'**
  String get notificationChannelDescription;

  /// Android download notification text: Downloading... {percent}%
  ///
  /// In en, this message translates to:
  /// **'Downloading... {percent}%'**
  String notificationDownloadingPercent(int percent);

  /// Android download notification text: Failed: {error}
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String notificationFailed(String error);

  /// Android download notification text: Download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get notificationDownloadTitle;

  /// Search page empty-state hint: Find your next read
  ///
  /// In en, this message translates to:
  /// **'Find your next read'**
  String get searchHintTitle;

  /// Search page empty-state hint: Search by title, author, or ISBN, or use the filters below.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, or ISBN, or use the filters above.'**
  String get searchHintBody;

  /// UI label: Search by title, author, or ISBN
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, or ISBN'**
  String get homeSearchHint;

  /// UI label: Trending this week
  ///
  /// In en, this message translates to:
  /// **'Trending this week'**
  String get trendingThisWeek;

  /// UI label: Keep exploring
  ///
  /// In en, this message translates to:
  /// **'Keep exploring'**
  String get keepExploring;

  /// UI label: Browse by genre
  ///
  /// In en, this message translates to:
  /// **'Browse by genre'**
  String get browseGenres;

  /// UI label: Manage
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManage;

  /// Search source selector: Search sources
  ///
  /// In en, this message translates to:
  /// **'Search sources'**
  String get searchSourcesTitle;

  /// Search source selector: Auto
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchSourceAuto;

  /// Search source selector: Tries enabled sources in order
  ///
  /// In en, this message translates to:
  /// **'All four sources are searched at once; results are merged'**
  String get searchSourceAutoHint;

  /// Search source selector hint when a single source is selected
  ///
  /// In en, this message translates to:
  /// **'Only this source’s results are shown'**
  String get searchSourceOnlyHint;

  /// Book detail page text: Book details
  ///
  /// In en, this message translates to:
  /// **'Book details'**
  String get bookDetailsTitle;

  /// Book detail page text: File info
  ///
  /// In en, this message translates to:
  /// **'File info'**
  String get fileInfoTitle;

  /// Book detail page text: Format
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatLabel;

  /// Book detail page text: Published
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedYearLabel;

  /// Book detail page text: File size
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSizeLabel;

  /// Book detail file info row label for the ISBN
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbnLabel;

  /// Book detail page text: Source
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// Book detail page text: Source & download
  ///
  /// In en, this message translates to:
  /// **'Source & download'**
  String get sourceAndDownload;

  /// Book detail page text: Open at source
  ///
  /// In en, this message translates to:
  /// **'Open at source'**
  String get openAtSource;

  /// Short source label for WeLib results
  ///
  /// In en, this message translates to:
  /// **'WeLib'**
  String get sourceWelib;

  /// Results page heading with the number of loaded results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// A source after the winning source that the automatic chain never queried
  ///
  /// In en, this message translates to:
  /// **'Untried'**
  String get sourceStatusUntried;

  /// A source skipped because every enabled mirror has a fresh local speed-test timeout
  ///
  /// In en, this message translates to:
  /// **'Locally unreachable'**
  String get sourceStatusLocallyUnreachable;

  /// Results-page hint naming sources skipped by fresh local timeouts
  ///
  /// In en, this message translates to:
  /// **'{sources} skipped: unreachable from this device.'**
  String sourcesSkippedLocally(String sources);

  /// Button that re-runs the search ignoring the local-timeout source skip
  ///
  /// In en, this message translates to:
  /// **'Try anyway'**
  String get retryAnyway;

  /// A source that could not be reached during the search
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sourceStatusFailed;

  /// Number of books found in one search source
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book} other{{count} books}}'**
  String sourceResultCount(int count);

  /// Results page heading while the source chain is running
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searchingTitle;

  /// Explanation shown while the automatic source chain is searching
  ///
  /// In en, this message translates to:
  /// **'Queries all four sources at once, then merges and de-duplicates the results.'**
  String get searchingSourcesBody;

  /// Footer hint while more result pages can be loaded
  ///
  /// In en, this message translates to:
  /// **'Scroll for more results'**
  String get loadMoreResults;

  /// Empty results title including the submitted query
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResultsFor(String query);

  /// Empty results explanation below the no-results title
  ///
  /// In en, this message translates to:
  /// **'All sources returned no matches. Try a shorter query, or clear the filters and search again.'**
  String get noResultsSourcesBody;

  /// Empty results action that returns to the search page
  ///
  /// In en, this message translates to:
  /// **'Edit search'**
  String get modifySearch;

  /// Empty results action that resets filters and repeats the search
  ///
  /// In en, this message translates to:
  /// **'Clear filters & retry'**
  String get clearFiltersRetry;

  /// Title of the bottom sheet that reruns a search in another source
  ///
  /// In en, this message translates to:
  /// **'Switch search source'**
  String get sourceSheetTitle;

  /// Subtitle of the source picker naming the current query
  ///
  /// In en, this message translates to:
  /// **'View results for “{query}” from a chosen source.'**
  String sourceSheetSubtitle(String query);

  /// Automatic option in the search source picker
  ///
  /// In en, this message translates to:
  /// **'All sources (combined)'**
  String get sourceAutoRecommended;

  /// Footer note in the search source picker
  ///
  /// In en, this message translates to:
  /// **'Applies to this search only. Your default source stays the same.'**
  String get sourceSheetNote;

  /// Search suggestion panel section header for persisted recent searches
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearchesTitle;

  /// Action that deletes every recent search
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Search suggestion panel section header for live suggestions
  ///
  /// In en, this message translates to:
  /// **'Search suggestions'**
  String get searchSuggestionsTitle;

  /// Small label marking live network suggestions
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get searchSuggestionsLive;

  /// Hint shown in the focused search suggestion panel with an empty query
  ///
  /// In en, this message translates to:
  /// **'Continue from a recent search, or start a new one.'**
  String get searchRecentHint;

  /// Primary action in the suggestion panel when the automatic chain is selected
  ///
  /// In en, this message translates to:
  /// **'Search “{query}” in all sources'**
  String searchInAllSources(String query);

  /// Primary action in the suggestion panel when one source is selected
  ///
  /// In en, this message translates to:
  /// **'Search “{query}” in {source}'**
  String searchInSource(String query, String source);

  /// Scope pill in the suggestion panel when the automatic chain is selected
  ///
  /// In en, this message translates to:
  /// **'Searching {count} sources at once'**
  String searchAutoScope(int count);

  /// Scope pill in the suggestion panel when a single source is selected
  ///
  /// In en, this message translates to:
  /// **'{source} only'**
  String searchSourceOnlyScope(String source);

  /// Tooltip for deleting one recent search
  ///
  /// In en, this message translates to:
  /// **'Remove “{query}”'**
  String removeRecentSearch(String query);

  /// Tooltip for clearing the search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Hint at the bottom of the empty search page.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, ISBN or MD5. All four sources are queried in parallel.'**
  String get searchSupportHint;

  /// Suggested searches section on the empty search page.
  ///
  /// In en, this message translates to:
  /// **'Try these'**
  String get tryThese;

  /// Section label for the search filters and advanced fields.
  ///
  /// In en, this message translates to:
  /// **'Filters and advanced search'**
  String get filtersAndAdvanced;

  /// Hint beside the search scope pill while typing
  ///
  /// In en, this message translates to:
  /// **'Results merged automatically'**
  String get resultsAutoMerged;

  /// Hint under the inline suggestions pointing at the advanced tab
  ///
  /// In en, this message translates to:
  /// **'Need to narrow by author, publisher, year, language or format? Switch to Advanced search.'**
  String get searchAdvancedHint;

  /// Primary action on the advanced search tab
  ///
  /// In en, this message translates to:
  /// **'Apply and search'**
  String get searchApply;

  /// Resets every advanced search filter
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// Placeholder for an unset advanced filter value
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyValue;

  /// Note under the advanced search actions
  ///
  /// In en, this message translates to:
  /// **'Advanced filters apply to this search only; your default source stays unchanged.'**
  String get advancedFilterNote;

  /// Default sort chip on the results page.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get filterRelevance;

  /// Subtitle for a recent search that ran across every source.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get searchAllSourcesLabel;

  /// Compact mark shown on the all-sources search chip.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get sourceMarkAll;

  /// Compact source label for Anna's Archive in the results journey
  ///
  /// In en, this message translates to:
  /// **'Anna\'s'**
  String get sourceAnnasShort;

  /// Compact source label for Z-Library in the results source pills
  ///
  /// In en, this message translates to:
  /// **'Z-Lib'**
  String get sourceZlibShort;

  /// Number of sources that answered a search
  ///
  /// In en, this message translates to:
  /// **'{count} sources'**
  String sourceCount(int count);

  /// Streaming hint when a source has not answered yet
  ///
  /// In en, this message translates to:
  /// **'{source} is still searching; results will be added automatically.'**
  String sourceStillSearching(String source);

  /// Summary of the sources other than the selected one
  ///
  /// In en, this message translates to:
  /// **'Other sources: {summary}'**
  String otherSources(String summary);

  /// Right label on the empty results heading
  ///
  /// In en, this message translates to:
  /// **'{count} sources responded'**
  String sourcesResponded(int count);

  /// Title of the source diagnosis card on the empty results page
  ///
  /// In en, this message translates to:
  /// **'Source status'**
  String get sourceStatusTitle;

  /// Subtitle of the source diagnosis card
  ///
  /// In en, this message translates to:
  /// **'{ok} responded, {failed} failed'**
  String sourceStatusSummary(int ok, int failed);

  /// Status row for a source that answered
  ///
  /// In en, this message translates to:
  /// **'Responded · {count}'**
  String sourceResponded(int count);

  /// Status row for a source that failed or timed out
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get sourceTimedOut;

  /// Empty-results action that returns to the search page
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// Hint card at the bottom of the book detail page
  ///
  /// In en, this message translates to:
  /// **'From the {source} mirror; MD5 is verified after download.'**
  String sourceMirrorHint(String source);

  /// UI text: downloadInProgressPercent
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}% · tap to pause'**
  String downloadInProgressPercent(int percent);

  /// UI text: downloadPausedPercent
  ///
  /// In en, this message translates to:
  /// **'Paused at {percent}% · tap to resume'**
  String downloadPausedPercent(int percent);

  /// UI text: downloadPreparing
  ///
  /// In en, this message translates to:
  /// **'Preparing download…'**
  String get downloadPreparing;

  /// UI text: downloadFailedRetry
  ///
  /// In en, this message translates to:
  /// **'Download failed · tap to retry'**
  String get downloadFailedRetry;

  /// UI text: downloadCompletedShort
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadCompletedShort;

  /// Primary action on the book detail page
  ///
  /// In en, this message translates to:
  /// **'Download book'**
  String get downloadThisBook;

  /// Bottom navigation label for the download center.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get navDownloads;

  /// Page title for the download center.
  ///
  /// In en, this message translates to:
  /// **'Download Center'**
  String get downloadCenterTitle;

  /// Counts of active, paused and queued download tasks.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {paused} paused · {queued} queued'**
  String downloadCenterSummary(int active, int paused, int queued);

  /// Subtitle when the download center has no tasks.
  ///
  /// In en, this message translates to:
  /// **'No download tasks yet'**
  String get downloadCenterNoTasks;

  /// Pause every active download.
  ///
  /// In en, this message translates to:
  /// **'Pause all'**
  String get downloadCenterAllPause;

  /// Resume every paused download.
  ///
  /// In en, this message translates to:
  /// **'Resume all'**
  String get downloadCenterAllResume;

  /// Filter label for all download tasks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get downloadCenterAll;

  /// Filter label for active download tasks.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get downloadCenterActive;

  /// Filter and section label for completed downloads.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get downloadCenterCompleted;

  /// Filter label for failed downloads.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get downloadCenterFailed;

  /// Section header for active downloads.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get downloadCenterInProgress;

  /// Section header for failed downloads.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get downloadCenterNeedsAttention;

  /// Hint for the active downloads section.
  ///
  /// In en, this message translates to:
  /// **'In queue order'**
  String get downloadCenterOrderHint;

  /// Hint for the active downloads section.
  ///
  /// In en, this message translates to:
  /// **'Queue lives in memory'**
  String get downloadCenterQueueMemory;

  /// Note under the completed download records.
  ///
  /// In en, this message translates to:
  /// **'When removing a record you can also remove the local file; the queue lives in memory only and does not resume after exit.'**
  String get downloadCenterRemoveNote;

  /// Shown next to the downloaded/total bytes in the download hero.
  ///
  /// In en, this message translates to:
  /// **'Range resume'**
  String get rangeResume;

  /// Shown on mobile when the user taps the storage folder action
  ///
  /// In en, this message translates to:
  /// **'Files are saved in {path}'**
  String storagePathMessage(String path);

  /// Micro copy for the failed downloads section.
  ///
  /// In en, this message translates to:
  /// **'Retry keeps the downloaded part'**
  String get downloadCenterRetryHint;

  /// Download center completed section hint
  ///
  /// In en, this message translates to:
  /// **'Tap a title to view details'**
  String get downloadCenterOpenHint;

  /// Hero label for total download progress.
  ///
  /// In en, this message translates to:
  /// **'Current progress'**
  String get downloadCenterCurrentProgress;

  /// Hero label for the current download speed.
  ///
  /// In en, this message translates to:
  /// **'Current speed'**
  String get downloadCenterSpeed;

  /// Hero label for the estimated remaining time.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get downloadCenterRemaining;

  /// Hero footer showing how many books finished today.
  ///
  /// In en, this message translates to:
  /// **'Completed today: {count}'**
  String downloadCenterTodayCount(int count);

  /// Estimated remaining time in seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String downloadCenterEtaSeconds(int seconds);

  /// Estimated remaining time in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String downloadCenterEtaMinutes(int minutes);

  /// Monthly download storage summary.
  ///
  /// In en, this message translates to:
  /// **'This month: {count} books · {size}'**
  String downloadCenterStorageSummary(int count, String size);

  /// Storage split between EPUB and PDF files.
  ///
  /// In en, this message translates to:
  /// **'EPUB {epub} · PDF {pdf}'**
  String downloadCenterStorageLegend(String epub, String pdf);

  /// Menu action to remove a completed download record.
  ///
  /// In en, this message translates to:
  /// **'Remove record'**
  String get downloadCenterRemoveRecord;

  /// Confirmation body for removing a download record.
  ///
  /// In en, this message translates to:
  /// **'Only the record is removed; the local file stays in your download folder.'**
  String get downloadCenterRemoveRecordBody;

  /// Checkbox in the remove-record dialog that also deletes the downloaded file.
  ///
  /// In en, this message translates to:
  /// **'Also remove file'**
  String get downloadCenterRemoveFile;

  /// UI text: downloadCenterSelect
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get downloadCenterSelect;

  /// UI text: downloadCenterSelectAll
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get downloadCenterSelectAll;

  /// UI text: downloadCenterDeselectAll
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get downloadCenterDeselectAll;

  /// UI text: downloadCenterSelectedCount
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String downloadCenterSelectedCount(int count);

  /// UI text: downloadCenterDeleteSelected
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String downloadCenterDeleteSelected(int count);

  /// Menu action to reveal a downloaded file in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get downloadCenterShowInFolder;

  /// Menu action to open the book detail page.
  ///
  /// In en, this message translates to:
  /// **'Book details'**
  String get downloadCenterBookDetails;

  /// Generic share action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Empty state title in the download center.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get downloadCenterEmptyTitle;

  /// Empty state body in the download center.
  ///
  /// In en, this message translates to:
  /// **'Tap Download on a book page and the task will appear here. Once it finishes, you can open it directly.'**
  String get downloadCenterEmptyBody;

  /// Empty state action that switches to the search tab.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get downloadCenterGoSearch;

  /// Tip card shown in the download center empty state.
  ///
  /// In en, this message translates to:
  /// **'EPUB and PDF are supported. Pausing and resuming continues from the last byte.'**
  String get downloadCenterTip;

  /// Download the book into the download center.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadBook;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get homeTitle;

  /// Small label above the home page title
  ///
  /// In en, this message translates to:
  /// **'Discover books'**
  String get homeEyebrow;

  /// Small label above the categories title
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseEyebrow;

  /// Small label above the search page title
  ///
  /// In en, this message translates to:
  /// **'Search sources'**
  String get searchEyebrow;

  /// Small label above the download center title
  ///
  /// In en, this message translates to:
  /// **'Local storage'**
  String get downloadEyebrow;

  /// Small label above the settings title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsEyebrow;

  /// Hint on the weekly trending section
  ///
  /// In en, this message translates to:
  /// **'Goodreads list'**
  String get trendingSource;

  /// Number of categories in the browse shortcut section
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String categoryCount(int count);

  /// Search field hint when the categories tab is selected
  ///
  /// In en, this message translates to:
  /// **'Search within categories'**
  String get categorySearchHint;

  /// Hint at the bottom of the categories tab
  ///
  /// In en, this message translates to:
  /// **'Categories come from the SLUM catalog and stay available offline for 24 hours.'**
  String get categoryInfoHint;

  /// Intro paragraph on the search sources settings tab
  ///
  /// In en, this message translates to:
  /// **'All four sources are queried in parallel. Disabled sources are skipped; mirror addresses come from the SLUM catalog.'**
  String get searchSourcesIntro;

  /// Footer label for an enabled search source
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get sourceOn;

  /// Footer label for a disabled search source
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get sourceOff;

  /// Link on a source card that opens the mirrors page
  ///
  /// In en, this message translates to:
  /// **'Mirrors'**
  String get mirrorsShort;

  /// Number of mirror nodes for one service
  ///
  /// In en, this message translates to:
  /// **'{count} nodes'**
  String mirrorNodeCount(int count);

  /// Toolbar action that re-syncs the mirror list
  ///
  /// In en, this message translates to:
  /// **'Refresh mirrors'**
  String get refreshMirrors;

  /// Settings group for mirror and source behavior
  ///
  /// In en, this message translates to:
  /// **'Source behavior'**
  String get sourceBehaviorSection;

  /// Appearance settings group for typography
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// Subtitle on the selected language row
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// Advanced settings group for downloads and verification
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behaviorSection;

  /// About tab group for changelog, licenses and links
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoSection;

  /// About tab group for third-party credits
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get thanksSection;

  /// About tab row that opens the release notes
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelogTitle;

  /// About tab row that opens the license list
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// About tab row that opens the GitHub project
  ///
  /// In en, this message translates to:
  /// **'Project home'**
  String get projectHome;

  /// Acknowledgement row for the mirror catalog
  ///
  /// In en, this message translates to:
  /// **'SLUM mirror catalog'**
  String get slumCatalogue;

  /// Subtitle for the SLUM acknowledgement row
  ///
  /// In en, this message translates to:
  /// **'open-slum.org'**
  String get slumCatalogueSubtitle;

  /// Acknowledgement row for the verification solver
  ///
  /// In en, this message translates to:
  /// **'Challenge solver'**
  String get challengeSolverTitle;

  /// Subtitle for the verification solver acknowledgement
  ///
  /// In en, this message translates to:
  /// **'WebView manual verification fallback'**
  String get challengeSolverSubtitle;

  /// Footer disclaimer on the about tab
  ///
  /// In en, this message translates to:
  /// **'No book content is hosted here; only mirror search and downloads. Please support the authors.'**
  String get aboutDisclaimer;

  /// About tab group for onboarding reset and logs
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceSection;

  /// Appearance card: language description
  ///
  /// In en, this message translates to:
  /// **'Interface language, applied immediately'**
  String get languageCardHint;

  /// Appearance card: theme description
  ///
  /// In en, this message translates to:
  /// **'Follow the system, or always light or dark'**
  String get themeCardHint;

  /// Appearance card: font size description
  ///
  /// In en, this message translates to:
  /// **'Applies to text across the app'**
  String get fontSizeCardHint;

  /// Sample sentence in the font size preview
  ///
  /// In en, this message translates to:
  /// **'A room without books is a body without a soul.'**
  String get fontPreviewSample;

  /// Theme option label: follow the system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeFollowSystemShort;

  /// Theme option label: light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLightShort;

  /// Theme option label: dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDarkShort;

  /// Results source card: explains all sources are searched in parallel and tapping switches results
  ///
  /// In en, this message translates to:
  /// **'All four sources are searched at once. Tap a source to switch results.'**
  String get sourceAllSearchedHint;

  /// Language card row affordance
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a language'**
  String get tapToExpandLanguage;

  /// Language card row affordance
  ///
  /// In en, this message translates to:
  /// **'Tap to collapse'**
  String get tapToCollapseLanguage;

  /// Source tile status while a parallel search is still running
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get sourceStatusSearching;

  /// Visible verification page copy
  ///
  /// In en, this message translates to:
  /// **'Loading the verification page. The app will continue automatically.'**
  String get verificationPageLoading;

  /// Visible verification page copy
  ///
  /// In en, this message translates to:
  /// **'Complete the check below; the app will continue automatically.'**
  String get verificationPageInstructions;

  /// Shown while a source waits on a manual challenge; the button opens the verification page.
  ///
  /// In en, this message translates to:
  /// **'Manual verification needed - the search continues as soon as it passes'**
  String get challengeNeedsVerification;

  /// Shown after automatic challenge solving failed; the next search skips the automatic solve and uses a manual verification.
  ///
  /// In en, this message translates to:
  /// **'Manual verification needed - the next search reuses the verified page'**
  String get challengeNeedsVerificationRetry;

  /// Button that opens the manual verification page for a blocked source.
  ///
  /// In en, this message translates to:
  /// **'Verify now'**
  String get challengeVerifyNow;

  /// Name of the language with code "en", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// Name of the language with code "es", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageNameEs;

  /// Name of the language with code "fr", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageNameFr;

  /// Name of the language with code "de", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageNameDe;

  /// Name of the language with code "it", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageNameIt;

  /// Name of the language with code "pt", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languageNamePt;

  /// Name of the language with code "ru", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageNameRu;

  /// Name of the language with code "zh", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageNameZh;

  /// Name of the language with code "ja", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageNameJa;

  /// Name of the language with code "ko", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageNameKo;

  /// Name of the language with code "ar", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageNameAr;

  /// Name of the language with code "hi", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageNameHi;

  /// Name of the language with code "ml", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get languageNameMl;

  /// Name of the language with code "nl", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageNameNl;

  /// Name of the language with code "pl", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languageNamePl;

  /// Name of the language with code "tr", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageNameTr;

  /// Name of the language with code "sv", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get languageNameSv;

  /// Name of the language with code "id", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageNameId;

  /// Name of the language with code "vi", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageNameVi;

  /// Name of the language with code "cs", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get languageNameCs;

  /// Name of the language with code "el", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get languageNameEl;

  /// Name of the language with code "ro", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get languageNameRo;

  /// Name of the language with code "hu", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get languageNameHu;

  /// Name of the language with code "uk", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageNameUk;

  /// Name of the language with code "he", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get languageNameHe;

  /// Name of the language with code "th", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get languageNameTh;

  /// Name of the language with code "fa", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get languageNameFa;

  /// Name of the language with code "bn", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get languageNameBn;

  /// Name of the language with code "fi", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get languageNameFi;

  /// Name of the language with code "no", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get languageNameNo;

  /// Name of the language with code "da", shown in result chips and the language filter.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get languageNameDa;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
