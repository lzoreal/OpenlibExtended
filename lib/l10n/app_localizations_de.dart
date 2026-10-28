// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OpenlibExtended';

  @override
  String get navHome => 'Start';

  @override
  String get navSearch => 'Suche';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get add => 'Hinzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get advancedSearch => 'Erweiterte Suche';

  @override
  String get author => 'Autor';

  @override
  String get publisher => 'Verlag';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String resultsFor(String query) {
    return 'Ergebnisse für \'$query\'';
  }

  @override
  String get followSystem => 'Dem System folgen';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get languageSetting => 'Sprache';

  @override
  String get systemLanguage => 'Systemstandard';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get notificationsExplanation =>
      'OpenlibExtended benötigt die Berechtigung für Benachrichtigungen, um den Download-Fortschritt im Hintergrund anzuzeigen. So behalten Sie Ihre Buch-Downloads auch im minimierten Zustand im Blick.';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get enable => 'Aktivieren';

  @override
  String get statusCompleted => 'Fertig';

  @override
  String get results => 'Ergebnisse';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get about => 'Über';

  @override
  String get aboutDescription =>
      'Eine Open-Source-App, die Bücher aus Schattenbibliotheken (Anna\'s Archive, LibGen, Z-Library) herunterlädt und in deinem bevorzugten Reader öffnet.';

  @override
  String get aboutForkNote =>
      'Dieser Fork wird von lzoreal für den persönlichen Gebrauch und Community-Updates gepflegt.';

  @override
  String get aboutOriginalNote =>
      'Original-App von dstark5; erweiterter Fork von warreth (https://github.com/warreth/OpenlibExtended).';

  @override
  String get version => 'Version';

  @override
  String get github => 'Github';

  @override
  String get thisForkByMaintainer => 'Dieser Fork (von lzoreal)';

  @override
  String get reportAnIssue => 'Problem melden';

  @override
  String get originalProject => 'Original-Projekt (von dstark5)';

  @override
  String get licence => 'Lizenz';

  @override
  String get gplLicense => 'GPL v3.0 Lizenz';

  @override
  String couldNotLaunch(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get searchProvidersSection => 'Suchanbieter';

  @override
  String get searchOrderHint =>
      'Alle vier Quellen werden gleichzeitig durchsucht. Diese Reihenfolge bestimmt die Zusammenführung und die zuerst angezeigte Quelle. Karte gedrückt halten und ziehen, um sie zu verschieben.';

  @override
  String get searchOrderReset => 'Reihenfolge zurücksetzen';

  @override
  String get libraryInstancesSection => 'Mirror';

  @override
  String get appearanceSection => 'Erscheinungsbild';

  @override
  String get generalSection => 'Allgemein';

  @override
  String get advancedSection => 'Erweitert';

  @override
  String get backupSection => 'Sicherung';

  @override
  String get updatesSection => 'Updates';

  @override
  String get aboutSection => 'Über';

  @override
  String get archiveInstance => 'Archiv-Instanz';

  @override
  String get mirrorsAndProviders => 'Spiegel & Anbieter';

  @override
  String get fontSizeTitle => 'Schriftgröße';

  @override
  String scaleValue(String value) {
    return 'Skalierung: ${value}x';
  }

  @override
  String get preview => 'Vorschau';

  @override
  String get storageLocation => 'Speicherort';

  @override
  String get manualDownloadButton => 'Manuelle Download-Schaltfläche';

  @override
  String get backgroundVerification => 'Verifizierung im Hintergrund';

  @override
  String get backgroundVerificationHint =>
      'Löst DDoS-Prüfungen unsichtbar. Auf manchen Geräten schlägt das fehl - ausschalten, um sofort das sichtbare Fenster zu öffnen';

  @override
  String get backgroundVerificationFix =>
      'Falls die Verifizierung immer wieder fehlschlägt, deaktiviere \"Verifizierung im Hintergrund\" in den Einstellungen - manche Geräte können Prüfungen nicht unsichtbar lösen.';

  @override
  String get showManualDownloadHint =>
      'Schaltfläche zum manuellen Starten von Downloads anzeigen';

  @override
  String get donationKeyTitle => 'Anna\'s Archive Spende-Schlüssel';

  @override
  String get enterKeyForFasterDownloads =>
      'Schlüssel für schnellere Downloads eingeben';

  @override
  String get aboutOpenlib => 'Über OpenlibExtended';

  @override
  String get redoOnboarding => 'Onboarding wiederholen';

  @override
  String get resetAppSetup => 'App-Setup zurücksetzen und neu starten';

  @override
  String get exportLogs => 'Protokolle exportieren';

  @override
  String get shareDiagnosticLogs => 'Diagnoseprotokolle teilen (letzte 5 Min.)';

  @override
  String failedExportLogs(String error) {
    return 'Protokolle konnten nicht exportiert werden: $error';
  }

  @override
  String get donationKeyDialog => 'Spende-Schlüssel';

  @override
  String get enterYourKey => 'Schlüssel eingeben';

  @override
  String get instanceChanged => 'Instanz erfolgreich geändert';

  @override
  String rankingFailed(String error) {
    return 'Rangfolge fehlgeschlagen: $error';
  }

  @override
  String get autoRankInstances => 'Instanzen automatisch sortieren';

  @override
  String get sortBySpeedOnStartup =>
      'Beim Start automatisch nach Geschwindigkeit sortieren';

  @override
  String get rankInstancesNow => 'Instanzen jetzt sortieren';

  @override
  String onLatestVersion(String version) {
    return 'Sie nutzen die neueste Version ($version)';
  }

  @override
  String failedCheckUpdates(String error) {
    return 'Update-Prüfung fehlgeschlagen: $error';
  }

  @override
  String get includeBetaUpdates => 'Beta-Updates einbeziehen';

  @override
  String get getPreReleaseVersions => 'Vorabversionen erhalten';

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get backupSaved => 'Sicherung gespeichert';

  @override
  String failedExportBackup(String error) {
    return 'Sicherung konnte nicht exportiert werden: $error';
  }

  @override
  String get backupRestored => 'Sicherung wiederhergestellt';

  @override
  String failedImportBackup(String error) {
    return 'Sicherung konnte nicht importiert werden: $error';
  }

  @override
  String get atLeastOneSource => 'Mindestens eine Suchquelle ist erforderlich';

  @override
  String rankedFastest(String name, String time) {
    return 'Sortiert! Schnellste: $name (${time}ms)';
  }

  @override
  String get rankingComplete => 'Sortierung abgeschlossen';

  @override
  String get providerSourceOriginal =>
      'Wird zuletzt durchsucht - durch DDoS-Guard geschützt';

  @override
  String get providerLibgenCatalog =>
      'Schnelle, direkte Downloads - wird zuerst durchsucht';

  @override
  String get providerZlibMirrors =>
      'Spiegel wechseln; Anmeldung kann nötig sein';

  @override
  String get themeTitle => 'Design';

  @override
  String get saveBackupTitle => 'Sicherung speichern';

  @override
  String get pickBackupFile => 'Sicherungsdatei auswählen';

  @override
  String get notABackup => 'Diese Datei ist keine OpenlibExtended-Sicherung';

  @override
  String get donationKeyHelper =>
      'Wird für schnellere Downloads auf Anna\'s Archive verwendet';

  @override
  String get mirrorsTestedRanked =>
      'Spiegel getestet und nach Geschwindigkeit sortiert';

  @override
  String testingFailed(String error) {
    return 'Test fehlgeschlagen: $error';
  }

  @override
  String get addCustomMirror => 'Benutzerdefinierten Spiegel hinzufügen';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'z. B. Mein LibGen-Spiegel';

  @override
  String get serviceLabel => 'Dienst';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get pleaseFillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get enterValidUrl =>
      'Bitte eine gültige URL mit http:// oder https:// eingeben';

  @override
  String get mirrorAdded => 'Spiegel erfolgreich hinzugefügt';

  @override
  String get deleteMirror => 'Spiegel löschen';

  @override
  String deleteMirrorConfirm(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String get mirrorDeleted => 'Spiegel gelöscht';

  @override
  String get cannotDeleteDefaultMirrors =>
      'Standard-Spiegel können nicht gelöscht werden';

  @override
  String get manageMirrors => 'Spiegel verwalten';

  @override
  String get noMirrorsAvailable => 'Keine Spiegel verfügbar';

  @override
  String errorLabel(String error) {
    return 'Fehler: $error';
  }

  @override
  String get addMirror => 'Spiegel hinzufügen';

  @override
  String get testRankMirrors =>
      'Spiegel testen und nach Geschwindigkeit sortieren';

  @override
  String get unreachable => 'nicht erreichbar';

  @override
  String get open => 'Öffnen';

  @override
  String get unableToOpenFile => 'Datei konnte nicht geöffnet werden!';

  @override
  String get openInSite => 'Auf der Seite öffnen';

  @override
  String get bookDeleted => 'Buch wurde gelöscht!';

  @override
  String get deleteBook => 'Buch löschen';

  @override
  String get deletePermanentWarning =>
      'Dies ist dauerhaft und kann nicht rückgängig gemacht werden';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get showBlockedContent => 'Gesperrten Seiteninhalt anzeigen';

  @override
  String get verifyInBrowser => 'Im Browser verifizieren';

  @override
  String get manualVerificationRequired =>
      'Manuelle Verifizierung erforderlich';

  @override
  String get systemBrowser => 'Systembrowser';

  @override
  String get embeddedBrowser => 'Eingebetteter Browser';

  @override
  String get unableToOpenVerification =>
      'Verifizierungsseite konnte nicht geöffnet werden – keine URL verfügbar';

  @override
  String get blockedPageContent => 'Gesperrter Seiteninhalt';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get copy => 'Kopieren';

  @override
  String get tryUsingVpn => 'Versuchen Sie ein VPN';

  @override
  String get trending => 'Beliebt';

  @override
  String get genres => 'Genres';

  @override
  String get copiedBookPath => 'Buchpfad in die Zwischenablage kopiert';

  @override
  String get pauseDownload => 'Download anhalten';

  @override
  String get resumeDownload => 'Download fortsetzen';

  @override
  String get cancelDownload => 'Download abbrechen';

  @override
  String get copiedBookLink => 'Buchlink in die Zwischenablage kopiert';

  @override
  String get noMirrors => 'Keine Spiegel verfügbar!';

  @override
  String get downloadStartedBackground => 'Download im Hintergrund gestartet';

  @override
  String get bookDownloaded => 'Buch wurde heruntergeladen!';

  @override
  String get selectStorageToContinue =>
      'Bitte wählen Sie einen Speicherordner aus, um fortzufahren';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get next => 'Weiter';

  @override
  String get welcomeTitle => 'Willkommen bei OpenlibExtended';

  @override
  String get welcomeSubtitle =>
      'Ihr persönliches Tor zu einer Welt voller Wissen. Lassen Sie uns alles einrichten.';

  @override
  String get whereToStoreBooks => 'Wo sollen Ihre Bücher gespeichert werden?';

  @override
  String get noPathSelected => 'Kein Pfad ausgewählt';

  @override
  String get selectFolder => 'Ordner auswählen';

  @override
  String get storageScanNote =>
      'Wir durchsuchen diesen Ordner nur nach unterstützten E-Book-Dateien. Unterordner werden nicht eingescannt.';

  @override
  String get automaticUpdates => 'Automatische Updates';

  @override
  String get enableAutoUpdates => 'Auto-Updates aktivieren';

  @override
  String get autoUpdatesFdroidNote =>
      'Nicht empfohlen bei Installation über F-Droid (F-Droid verwaltet die Updates).';

  @override
  String get enableBetaUpdatesOnboarding => 'Beta-Updates aktivieren';

  @override
  String get betaUpdatesNote =>
      'Vorabversionen (Beta-Updates) erhalten, wenn verfügbar.';

  @override
  String get supportAnnasArchive => 'Anna\'s Archive unterstützen';

  @override
  String get donationPitch =>
      'Eine Spende an Anna\'s Archive ermöglicht schnellere Downloads und hilft, den Dienst für alle am Laufen zu halten. Sie können Ihren geheimen Schlüssel unten eingeben.';

  @override
  String get annasSecretKey => 'Geheimer Schlüssel von Anna\'s Archive';

  @override
  String get supportThisApp => 'Diese App unterstützen';

  @override
  String get sponsorPitch =>
      'Wenn Ihnen diese App gefällt, ziehen Sie in Betracht, die Entwicklung zu unterstützen. So kann ich mehr Zeit in die Verbesserung stecken!';

  @override
  String get sponsorOnGithub => 'Auf GitHub sponsern';

  @override
  String get stayUpdated => 'Auf dem Laufenden bleiben';

  @override
  String get notifyOnComplete =>
      'Benachrichtigung erhalten, wenn Downloads abgeschlossen sind.';

  @override
  String get chooseTheme => 'Design wählen';

  @override
  String get lightThemeShort => 'Hell';

  @override
  String get darkThemeShort => 'Dunkel';

  @override
  String get verifyingAccess => 'Zugriff wird verifiziert';

  @override
  String get done => 'Fertig';

  @override
  String get noVoiceAvailable => 'Keine Stimme für das Vorlesen verfügbar';

  @override
  String get close => 'Schließen';

  @override
  String get reloadHealthData => 'Gesundheitsdaten neu laden';

  @override
  String addServiceMirror(String title) {
    return '$title-Spiegel hinzufügen';
  }

  @override
  String get deleteMirrorTooltip => 'Spiegel löschen';

  @override
  String searchingOn(String source) {
    return 'Ergebnisse von $source';
  }

  @override
  String get sourceLibgen => 'LibGen';

  @override
  String get sourceZlib => 'Z-Library';

  @override
  String get sourceAnnas => 'Anna\'s Archive';

  @override
  String downloadFrom(String source) {
    return 'Download von $source';
  }

  @override
  String get tryingNextSource =>
      'Keine Ergebnisse, nächste Quelle wird versucht…';

  @override
  String get slowMirrorsSkipped => 'Schnellere Spiegel werden verwendet';

  @override
  String whatsNewTitle(String version) {
    return 'Neu in $version';
  }

  @override
  String get whatsNewIntro =>
      'OpenlibExtended wurde aktualisiert. Das hat sich geändert.';

  @override
  String get whatsNewTabFeatures => 'Neue Funktionen';

  @override
  String get whatsNewTabSources => 'Quellen & Mirror';

  @override
  String get whatsNewProvidersHint =>
      'Dieses Release fügt neue Suchanbieter und Mirror hinzu. Aktualisiere deine Liste, um tote Mirror zu entfernen und die neuen hinzuzufügen; alle drei Suchanbieter werden aktiviert.';

  @override
  String get whatsNewUpdateInstances => 'Mirror-Liste aktualisieren';

  @override
  String get whatsNewInstancesUpdated => 'Mirror-Liste aktualisiert';

  @override
  String get whatsNewContinue => 'Weiter';

  @override
  String get whatsNewFeatureSpeed =>
      'Downloads starten schneller: keine Mirror-Prüfung mehr, schnelle Hosts zuerst, langsame IPFS-Gateways zuletzt.';

  @override
  String get whatsNewFeatureSourceLabels =>
      'Jedes Suchergebnis und jeder Download zeigt jetzt, aus welchem Katalog er stammt.';

  @override
  String get whatsNewFeatureCovers =>
      'Fehlende LibGen-Cover werden von der Detailseite des Buchs geladen.';

  @override
  String get categoryClassicsTitle => 'Klassiker';

  @override
  String get categoryClassicsInfo =>
      'Zeitlose literarische Werke, die für ihren künstlerischen Wert und ihre kulturelle Bedeutung geschätzt werden.';

  @override
  String get categoryRomanceTitle => 'Liebesromane';

  @override
  String get categoryRomanceInfo =>
      'Geschichten über romantische Beziehungen, die Liebe, Leidenschaft und emotionale Verbindungen erkunden.';

  @override
  String get categoryFictionTitle => 'Belletristik';

  @override
  String get categoryFictionInfo =>
      'Erzählliteratur aus der Fantasie, nicht auf realen Ereignissen basierend.';

  @override
  String get categoryYoungAdultTitle => 'Junge Erwachsene';

  @override
  String get categoryYoungAdultInfo =>
      'Bücher für jugendliche Leserinnen und Leser, die Themen der Adoleszenz behandeln.';

  @override
  String get categoryFantasyTitle => 'Fantasy';

  @override
  String get categoryFantasyInfo =>
      'Ein Genre mit magischen Elementen, mythischen Wesen und fantastischen Welten.';

  @override
  String get categoryScienceFictionTitle => 'Science-Fiction';

  @override
  String get categoryScienceFictionInfo =>
      'Literatur über futuristische Konzepte, fortschrittliche Technik und Weltraumforschung.';

  @override
  String get categoryNonfictionTitle => 'Sachbücher';

  @override
  String get categoryNonfictionInfo =>
      'Werke auf Basis faktischer Informationen, darunter Essays, Biografien und Dokumentationen.';

  @override
  String get categoryChildrenTitle => 'Kinder';

  @override
  String get categoryChildrenInfo =>
      'Bücher für junge Leserinnen und Leser, oft mit Illustrationen und einfachen Erzählungen.';

  @override
  String get categoryHistoryTitle => 'Geschichte';

  @override
  String get categoryHistoryInfo =>
      'Literatur über vergangene Ereignisse, Kulturen und bedeutende historische Persönlichkeiten.';

  @override
  String get categoryMysteryTitle => 'Krimi';

  @override
  String get categoryMysteryInfo =>
      'Geschichten mit spannungsgeladenen Handlungen, oft mit Verbrechen oder Rätseln.';

  @override
  String get categoryCoversTitle => 'Cover';

  @override
  String get categoryCoversInfo =>
      'Die Gestaltung und das Artwork, das ein Buch visuell repräsentiert und Interesse weckt.';

  @override
  String get categoryHorrorTitle => 'Horror';

  @override
  String get categoryHorrorInfo =>
      'Ein Genre, das durch spannungsvolle Erzählweise Angst, Unbehagen oder Schrecken auslöst.';

  @override
  String get categoryHistoricalFictionTitle => 'Historische Romane';

  @override
  String get categoryHistoricalFictionInfo =>
      'Romane in einer bestimmten historischen Epoche, die reale Ereignisse mit fiktiven Figuren verbinden.';

  @override
  String get categoryBestTitle => 'Beste';

  @override
  String get categoryBestInfo =>
      'Häufig hochgelobte oder beliebte Bücher, meist nach Ranglisten oder Auszeichnungen sortiert.';

  @override
  String get categoryTitlesTitle => 'Titel';

  @override
  String get categoryTitlesInfo =>
      'Die Namen von Büchern, die oft ihre Themen oder Inhalte widerspiegeln.';

  @override
  String get categoryMiddleGradeTitle => 'Mittlere Lesestufe';

  @override
  String get categoryMiddleGradeInfo =>
      'Bücher für Leserinnen und Leser von 8 bis 12 Jahren mit altersgerechten Themen und Figuren.';

  @override
  String get categoryParanormalTitle => 'Paranormal';

  @override
  String get categoryParanormalInfo =>
      'Geschichten mit übernatürlichen Elementen wie Geistern, Vampiren und jenseitigen Wesen.';

  @override
  String get categoryLoveTitle => 'Liebe';

  @override
  String get categoryLoveInfo =>
      'Ein Thema, das die Facetten und Nuancen der Liebe in verschiedenen Formen und Beziehungen erkundet.';

  @override
  String get categoryQueerTitle => 'Queer';

  @override
  String get categoryQueerInfo =>
      'Literatur, die vielfältige sexuelle Orientierungen und Geschlechtsidentitäten im LGBTQ+-Spektrum darstellt.';

  @override
  String get categoryHistoricalRomanceTitle => 'Historische Liebesromane';

  @override
  String get categoryHistoricalRomanceInfo =>
      'Romane, die Liebesgeschichten vor historischer Kulisse verbinden.';

  @override
  String get categoryContemporaryTitle => 'Zeitgenössisch';

  @override
  String get categoryContemporaryInfo =>
      'Werke in der Gegenwart, oft zu aktuellen gesellschaftlichen Themen und nahbaren Figuren.';

  @override
  String get categoryThrillerTitle => 'Thriller';

  @override
  String get categoryThrillerInfo =>
      'Ein spannungsgeladenes Genre mit Nervenkitzel, Anspannung und unerwarteten Wendungen.';

  @override
  String get categoryWomenTitle => 'Frauen';

  @override
  String get categoryWomenInfo =>
      'Literatur über die Erfahrungen, Perspektiven und Selbstbestimmung von Frauen.';

  @override
  String get categoryBiographyTitle => 'Biografie';

  @override
  String get categoryBiographyInfo =>
      'Sachbücher über die Lebensgeschichte einer Person, ihre Leistungen und Herausforderungen.';

  @override
  String get categoryLgbtqTitle => 'LGBTQ';

  @override
  String get categoryLgbtqInfo =>
      'Inklusive Literatur, die Erfahrungen der lesbischen, schwulen, bisexuellen, trans und queeren Community darstellt.';

  @override
  String get categorySeriesTitle => 'Serien';

  @override
  String get categorySeriesInfo =>
      'Eine Sammlung zusammenhängender Bücher mit gemeinsamer Handlung oder Figuren.';

  @override
  String get categoryTitleChallengeTitle => 'Titel-Challenge';

  @override
  String get categoryTitleChallengeInfo =>
      'Aufgaben oder Wettbewerbe, die kreatives Denken über Buchtitel anregen.';

  @override
  String get mirrorsTitle => 'Spiegel';

  @override
  String get automaticMirrorOrder => 'Automatische Spiegelreihenfolge';

  @override
  String get mirrorOrderAutoHint =>
      'Einfachster Schutz zuerst, dann der schnellste. Empfohlen.';

  @override
  String get mirrorSortPriorityTitle =>
      'Priorität der automatischen Sortierung';

  @override
  String get mirrorSortPriorityHint =>
      '„Schnellste“ sortiert zuerst nach deiner gemessenen Latenz; „Einfachster Schutz“ stellt Spiegel ohne Browser-Prüfung voran.';

  @override
  String get mirrorSortPrioritySpeed => 'Schnellste';

  @override
  String get mirrorSortPriorityProtection => 'Einfachster Schutz';

  @override
  String get mirrorOrderManualHint =>
      'Manuell: Mit den Pfeilen die eigene Reihenfolge festlegen.';

  @override
  String get mirrorListUpToDate => 'Spiegelliste ist aktuell';

  @override
  String mirrorListUpdated(int count) {
    return 'Spiegelliste aktualisiert: $count Änderung(en)';
  }

  @override
  String mirrorRefreshFailed(String error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get mirrorCatalogueUnreachable =>
      'open-slum.org nicht erreichbar – keine Spiegelliste verfügbar';

  @override
  String get mirrorFooterNote =>
      'Spiegeladressen und ihr Status stammen von open-slum.org und werden automatisch aktualisiert. Ein als DOWN gemeldeter Spiegel wird nie kontaktiert. Die lokale Latenz misst dieses Gerät, wenn du auf die Geschwindigkeitstaste tippst.';

  @override
  String get mirrorLatencyTestTooltip => 'Lokale Latenz testen';

  @override
  String get mirrorLatencyHint =>
      'Lokale Spiegel wurden noch nicht getestet; die Suche kann langsamer sein. Nach dem Test werden sie nach deiner eigenen Latenz sortiert.';

  @override
  String get mirrorLatencyNeedsVerification => 'Prüfung nötig';

  @override
  String get mirrorLatencyGoTest => 'Testen';

  @override
  String get mirrorLatencyNotTested => 'Lokale Latenz nicht getestet';

  @override
  String get mirrorLatencyTesting => 'Lokale Latenz wird getestet…';

  @override
  String get mirrorLatencyTimeout => 'Lokale Zeitüberschreitung';

  @override
  String mirrorLatencyLocal(String latency) {
    return 'Lokal $latency';
  }

  @override
  String get mirrorLatencyJustNow => 'gerade eben';

  @override
  String get mirrorLatencyExpired => 'abgelaufen';

  @override
  String mirrorLatencyDone(int reachable, int total, String fastest) {
    return 'Lokaler Test: $reachable/$total erreichbar, schnellster $fastest';
  }

  @override
  String get mirrorLatencyAllTimedOut =>
      'Lokaler Test beendet · kein Spiegel hat geantwortet';

  @override
  String get mirrorLatencyNoTargets => 'Keine aktivierten Spiegel zum Testen';

  @override
  String mirrorLatencyFailed(String error) {
    return 'Lokaler Test fehlgeschlagen: $error';
  }

  @override
  String get noMirrorsReported => 'Keine Spiegel gemeldet';

  @override
  String get noMirrorsReportedHint =>
      'open-slum.org hat (noch) keinen Eintrag oder war nicht erreichbar.';

  @override
  String get couldNotLoadMirrors => 'Spiegel konnten nicht geladen werden';

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get reportedDownNeverContacted =>
      'als DOWN gemeldet – wird nie kontaktiert';

  @override
  String get mirrorServiceLibgenHint =>
      'Schnelle Downloads ohne Challenges, wenn ein Spiegel online ist';

  @override
  String get mirrorServiceZlibHint =>
      'DiamWall-Spiegel werden im Hintergrund gelöst';

  @override
  String get mirrorServiceWelibHint =>
      'Cloudflare-geschützte Suche, offene Buchseiten';

  @override
  String get mirrorServiceAnnasHint => 'Lesen, Details und Downloads';

  @override
  String get mirrorStatusUp => 'Online';

  @override
  String get mirrorStatusDegraded => 'Beeinträchtigt';

  @override
  String get mirrorStatusProtected => 'Geschützt';

  @override
  String get mirrorStatusDown => 'Offline';

  @override
  String get searchEmptyQuery => 'Das Suchfeld ist leer';

  @override
  String get filterTypeLabel => 'Typ';

  @override
  String get filterSortLabel => 'Sortieren nach';

  @override
  String get filterFileTypeLabel => 'Dateityp';

  @override
  String get filterYearLabel => 'Jahr';

  @override
  String get filterAll => 'Alle';

  @override
  String get typeAnyBooks => 'Alle Bücher';

  @override
  String get typeUnknownBooks => 'Unbekannte Bücher';

  @override
  String get typeFictionBooks => 'Belletristik';

  @override
  String get typeNonfictionBooks => 'Sachbücher';

  @override
  String get typeComicBooks => 'Comics';

  @override
  String get typeMagazine => 'Zeitschrift';

  @override
  String get typeStandardsDocument => 'Normdokument';

  @override
  String get typeJournalArticle => 'Zeitschriftenartikel';

  @override
  String get sortMostRelevant => 'Relevanteste';

  @override
  String get sortNewest => 'Neueste';

  @override
  String get sortOldest => 'Älteste';

  @override
  String get sortLargest => 'Größte';

  @override
  String get sortSmallest => 'Kleinste';

  @override
  String get yearBefore1980 => 'Vor 1980';

  @override
  String get langEnglish => 'Englisch';

  @override
  String get langSpanish => 'Spanisch';

  @override
  String get langFrench => 'Französisch';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langItalian => 'Italienisch';

  @override
  String get langPortuguese => 'Portugiesisch';

  @override
  String get langRussian => 'Russisch';

  @override
  String get langChinese => 'Chinesisch';

  @override
  String get langJapanese => 'Japanisch';

  @override
  String get langKorean => 'Koreanisch';

  @override
  String get langArabic => 'Arabisch';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langDutch => 'Niederländisch';

  @override
  String get langPolish => 'Polnisch';

  @override
  String get langTurkish => 'Türkisch';

  @override
  String get langSwedish => 'Schwedisch';

  @override
  String get langIndonesian => 'Indonesisch';

  @override
  String get langVietnamese => 'Vietnamesisch';

  @override
  String get langCzech => 'Tschechisch';

  @override
  String get langGreek => 'Griechisch';

  @override
  String get langRomanian => 'Rumänisch';

  @override
  String get langHungarian => 'Ungarisch';

  @override
  String get langUkrainian => 'Ukrainisch';

  @override
  String get langHebrew => 'Hebräisch';

  @override
  String get langThai => 'Thailändisch';

  @override
  String get langPersian => 'Persisch';

  @override
  String get langBengali => 'Bengalisch';

  @override
  String get langFinnish => 'Finnisch';

  @override
  String get langNorwegian => 'Norwegisch';

  @override
  String get langDanish => 'Dänisch';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadQueued => 'In Warteschlange';

  @override
  String get downloadGettingMirrors => 'Spiegel werden abgerufen…';

  @override
  String get downloadFindingMirror => 'Spiegel wird gesucht…';

  @override
  String get downloadDownloading => 'Wird heruntergeladen';

  @override
  String get downloadPaused => 'Pausiert';

  @override
  String get downloadVerifying => 'Datei wird geprüft…';

  @override
  String get downloadCancelled => 'Abgebrochen';

  @override
  String get downloadFailedGeneric => 'Download fehlgeschlagen';

  @override
  String get verifyAction => 'Überprüfen';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get noDescriptionAvailable => 'Keine Beschreibung verfügbar';

  @override
  String get couldNotOpenLink => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get manualDownloadAction => 'Manueller Download';

  @override
  String get fastDownloadStarted =>
      'Schneller Download im Hintergrund gestartet 🚀';

  @override
  String get welibNoDownloadLink =>
      'WeLib hat keinen Download-Link für dieses Buch angeboten.';

  @override
  String get zlibDailyLimit =>
      'Z-Library hat das tägliche Download-Limit für dein Netzwerk erreicht. Versuche es morgen erneut oder melde dich im App-Browser bei Z-Library an.';

  @override
  String get zlibSignIn =>
      'Z-Library verlangt eine Anmeldung, bevor dieses Buch heruntergeladen wird.';

  @override
  String get zlibNoDownloadLink =>
      'Diese Z-Library-Seite bot keinen Download-Link. Das Buch ist möglicherweise gesperrt oder entfernt.';

  @override
  String get welibRateLimit =>
      'WeLib begrenzt Downloads gerade. Warte einige Minuten und versuche es erneut.';

  @override
  String get welibBotCheck =>
      'WeLib hat die App nicht durch die Bot-Prüfung gelassen. Versuche es erneut oder öffne das Buch im App-Browser.';

  @override
  String get welibPageUnreadable =>
      'Die WeLib-Downloadseite konnte nicht gelesen werden.';

  @override
  String get fileNotFoundDownloadFailed =>
      'Datei nicht gefunden. Der Download ist möglicherweise fehlgeschlagen.';

  @override
  String shareBookMessage(String title, String link) {
    return 'Entdecke dieses großartige Buch: \"$title\"\nMehr erfahren: $link';
  }

  @override
  String get webviewWindowTitle => 'Zugriff prüfen – OpenLibExtended';

  @override
  String get webviewBrowserOpen => 'Browserfenster ist geöffnet';

  @override
  String get webviewBrowserOpening => 'Browserfenster wird geöffnet…';

  @override
  String get webviewInstructions =>
      '1. Löse das CAPTCHA im Browserfenster\n2. Warte, bis die Seite vollständig geladen ist\n3. Klicke oben auf „Fertig“, um fortzufahren';

  @override
  String get webviewPreparingDownload => 'Download wird vorbereitet…';

  @override
  String get webviewPreparingHint =>
      'Bitte warten, während der Zugriff geprüft und Download-Links abgerufen werden';

  @override
  String get changeStorageHint => 'Speicherort der Bücher ändern';

  @override
  String versionWithBuild(String version, String build) {
    return 'Version $version+$build';
  }

  @override
  String get backupShareText => 'OpenlibExtended-Sicherung';

  @override
  String get exportBackupTitle => 'Sicherung exportieren';

  @override
  String get exportBackupSubtitle =>
      'Einstellungen, Bücher und Instanzen in einer JSON-Datei speichern';

  @override
  String get importBackupTitle => 'Sicherung importieren';

  @override
  String get importBackupSubtitle =>
      'Aus einer Sicherungsdatei wiederherstellen (ersetzt aktuelle Daten)';

  @override
  String get providerWelibCatalog =>
      'Cloudflare-geschützte Suche und offene Buchseiten';

  @override
  String get errorWhatToDo => 'Was tun';

  @override
  String get errorVpnDescription =>
      'Ein VPN kann regionale Sperren umgehen und den Zugriff ermöglichen.';

  @override
  String get errorVerificationPrompt =>
      'Die Website verlangt eine Bestätigung, dass du ein Mensch bist. Wir öffnen ein Browserfenster, in dem du die Prüfung abschließen kannst.';

  @override
  String get errorVerificationReturn =>
      'Kehre nach der Prüfung zur App zurück und tippe auf „Erneut versuchen“.';

  @override
  String get errorNoContent => 'Kein Inhalt verfügbar';

  @override
  String get networkErrorNoInternetTitle => 'Keine Internetverbindung';

  @override
  String get networkErrorNoInternetSolution =>
      'Prüfe deine Internetverbindung. Stelle sicher, dass WLAN oder mobile Daten aktiviert sind.';

  @override
  String get networkErrorCloudflareTitle =>
      'Zugriff durch DDoS-Schutz blockiert';

  @override
  String get networkErrorCloudflareSolution =>
      'Diese Website ist geschützt und blockiert die App. Versuche ein VPN, ändere den DNS auf 1.1.1.1 oder 8.8.8.8 oder verifiziere im Browser.';

  @override
  String get networkErrorServerUnavailableTitle =>
      'Server vorübergehend nicht verfügbar';

  @override
  String get networkErrorServerUnavailableSolution =>
      'Der Server hat Probleme. Versuche es in einigen Minuten erneut oder wähle in den Einstellungen einen anderen Spiegel.';

  @override
  String get networkErrorTimeoutTitle => 'Zeitüberschreitung der Anfrage';

  @override
  String get networkErrorTimeoutSolution =>
      'Der Server antwortet zu langsam. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get networkErrorForbiddenTitle => 'Zugriff verweigert';

  @override
  String get networkErrorForbiddenSolution =>
      'Du hast keine Berechtigung für diese Ressource. Versuche ein VPN, ändere den DNS oder wähle in den Einstellungen einen anderen Spiegel.';

  @override
  String get networkErrorRateLimitedTitle => 'Zu viele Anfragen';

  @override
  String get networkErrorRateLimitedSolution =>
      'Es wurden zu viele Anfragen gesendet. Warte einige Minuten und versuche es erneut.';

  @override
  String get networkErrorSslTitle => 'Sichere Verbindung fehlgeschlagen';

  @override
  String get networkErrorSslSolution =>
      'Dein Netzwerk blockiert möglicherweise sichere Verbindungen. Versuche ein VPN oder ein anderes Netzwerk.';

  @override
  String get networkErrorDnsTitle => 'Server nicht gefunden';

  @override
  String get networkErrorDnsSolution =>
      'Die Website ist nicht erreichbar. Möglicherweise blockiert dein Anbieter sie. Versuche ein VPN oder ändere den DNS auf 1.1.1.1 / 8.8.8.8.';

  @override
  String get networkErrorParseTitle =>
      'Buchquellendaten konnten nicht gelesen werden';

  @override
  String get networkErrorParseSolution =>
      'Die Quelle hat eine Seite zurückgegeben, die die App nicht lesen konnte. Wechsle die Quelle oder den Mirror und versuche es erneut. Wenn das Problem bleibt, öffne die Diagnose und teile die Protokolle.';

  @override
  String get networkErrorStorageTitle =>
      'Lokaler Speicherzugriff fehlgeschlagen';

  @override
  String get networkErrorStorageSolution =>
      'Prüfe freien Speicher und Speicherberechtigungen und versuche es erneut. Wenn das Problem bleibt, öffne die Diagnose und teile die Protokolle.';

  @override
  String get networkErrorUnknownTitle => 'Etwas ist schiefgelaufen';

  @override
  String get networkErrorUnknownSolution =>
      'Bitte versuche es erneut. Wenn das Problem bleibt, öffne die Diagnose und teile die Protokolle.';

  @override
  String get errorDiagnostics => 'Diagnose';

  @override
  String get errorCopyDiagnostics => 'Diagnose kopieren';

  @override
  String errorLocation(String location) {
    return 'Ort: $location';
  }

  @override
  String get errorStackTrace => 'Stack-Trace';

  @override
  String get errorEnvironment => 'Umgebung';

  @override
  String get updatePermissionTitle => 'Berechtigung erforderlich';

  @override
  String get updatePermissionBody =>
      'Zum Installieren von App-Updates benötigt OpenlibExtended die Berechtigung zum Installieren von Paketen.\n\nDamit kann die App neue Versionen mit Fehlerbehebungen und neuen Funktionen automatisch installieren.\n\nDu wirst zu den Einstellungen weitergeleitet, um diese Berechtigung zu aktivieren.';

  @override
  String get updateOpenSettings => 'Einstellungen öffnen';

  @override
  String get updateDebugBuildWarning =>
      'Debug-Build erkannt: Das Update kann wegen unterschiedlicher Signaturen mit „App nicht installiert“ fehlschlagen. Deinstalliere diese App zuerst.';

  @override
  String get updateOpeningInstaller =>
      'Installer wird geöffnet… Wenn nichts passiert, ist die Installation fehlgeschlagen.';

  @override
  String get updateManualInstall => 'Manuelle Installation';

  @override
  String get updateInstallationIssueTitle => 'Installationsproblem';

  @override
  String get updateInstallationIssueBody =>
      'Der automatische Installer konnte die APK nicht öffnen. Das kann bei manchen Android-Versionen vorkommen.\n\nDu kannst sie manuell mit einer dieser Optionen installieren:';

  @override
  String updateFileLabel(String file) {
    return 'Datei: $file';
  }

  @override
  String get updateInstallationFailed => 'Installation fehlgeschlagen';

  @override
  String get updateMethodsTried => 'Versuche Methoden:';

  @override
  String get updateErrorsEncountered => 'Aufgetretene Fehler:';

  @override
  String updateMethodNumber(int number) {
    return 'Methode $number';
  }

  @override
  String get updateDownloadViaBrowser => 'Über Browser herunterladen';

  @override
  String get updateInstallationErrorTitle => 'Installationsfehler';

  @override
  String get updateOk => 'OK';

  @override
  String get updateTryManualInstall => 'Manuelle Installation versuchen';

  @override
  String updateInstallFailed(String error) {
    return 'Update konnte nicht installiert werden: $error';
  }

  @override
  String get updateAvailableTitle => 'Update verfügbar';

  @override
  String updateVersionAvailable(String version) {
    return 'Version $version ist verfügbar!';
  }

  @override
  String get updatePreRelease => 'Vorabversion';

  @override
  String get updateWhatsNew => 'Neuigkeiten:';

  @override
  String get updateLater => 'Später';

  @override
  String get updateDownloadAndInstall => 'Herunterladen & installieren';

  @override
  String get updateDownloadFromGithub => 'Von GitHub herunterladen';

  @override
  String get updateViewOnGithub => 'Auf GitHub ansehen';

  @override
  String get updateDownloading => 'Update wird heruntergeladen';

  @override
  String get updateDownloadComplete => 'Download abgeschlossen';

  @override
  String updateVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get updateOpeningInstallerShort => 'Installer wird geöffnet…';

  @override
  String get updateConnecting => 'Verbinden…';

  @override
  String get updateFileNotFound => 'Heruntergeladene Datei nicht gefunden';

  @override
  String updateFileCorrupted(String size) {
    return 'Die heruntergeladene Datei scheint beschädigt zu sein (nur $size)';
  }

  @override
  String get updatePermissionDenied =>
      'Die Berechtigung zum Installieren von Apps wurde verweigert. Du kannst weiterhin manuell installieren.';

  @override
  String get updateMayHaveFailedSilently =>
      'Möglicherweise still fehlgeschlagen';

  @override
  String get updateMethodOpenFile => 'Datei öffnen';

  @override
  String get updateMethodApkSideload => 'APK-Sideload';

  @override
  String get updateMethodPackageInstaller => 'Paketinstaller';

  @override
  String get networkErrorBookNotFoundTitle => 'Buch nicht gefunden';

  @override
  String get networkErrorBookNotFoundSolution =>
      'Die Seite wurde geladen, enthielt aber keine Buchdetails. Der Link ist möglicherweise veraltet – suche stattdessen nach dem Titel.';

  @override
  String get networkErrorBookDetailsUnavailableTitle =>
      'Buchdetails konnten nicht geladen werden';

  @override
  String get networkErrorBookDetailsUnavailableSolution =>
      'Die Buchinformationen konnten nicht abgerufen werden. Versuche es erneut oder wähle in den Einstellungen einen anderen Spiegel.';

  @override
  String get downloadNoWorkingMirrors =>
      'Keine funktionierenden Spiegel verfügbar!';

  @override
  String get downloadAllMirrorsFailed => 'Alle Spiegel sind fehlgeschlagen!';

  @override
  String get downloadErrorGettingMirrors => 'Fehler beim Abrufen der Spiegel';

  @override
  String downloadCouldNotSave(String error) {
    return 'Konnte nicht in der Bibliothek gespeichert werden: $error';
  }

  @override
  String get appLogsShareSubject => 'OpenlibExtended-App-Protokolle';

  @override
  String appLogsShareText(int minutes) {
    return 'OpenlibExtended-App-Protokolle der letzten $minutes Minuten';
  }

  @override
  String notificationAlreadyDownloading(String title) {
    return 'Wird bereits heruntergeladen: $title';
  }

  @override
  String notificationQueued(String title) {
    return 'In Warteschlange: $title';
  }

  @override
  String get notificationStartingFastDownload =>
      'Schneller Download wird gestartet…';

  @override
  String get notificationVerifyingFile => 'Datei wird überprüft…';

  @override
  String get notificationDownloadComplete => 'Download abgeschlossen!';

  @override
  String get notificationDownloadCompleteChecksumFailed =>
      'Download abgeschlossen (Prüfsumme fehlgeschlagen)';

  @override
  String get notificationChannelDescription =>
      'Benachrichtigungen zum Fortschritt von Buchdownloads';

  @override
  String notificationDownloadingPercent(int percent) {
    return 'Wird heruntergeladen… $percent %';
  }

  @override
  String notificationFailed(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get notificationDownloadTitle => 'Download';

  @override
  String get searchHintTitle => 'Finde dein nächstes Buch';

  @override
  String get searchHintBody =>
      'Suche nach Titel, Autor oder ISBN oder nutze die Filter oben.';

  @override
  String get homeSearchHint => 'Nach Titel, Autor oder ISBN suchen';

  @override
  String get trendingThisWeek => 'Diese Woche im Trend';

  @override
  String get keepExploring => 'Weiter entdecken';

  @override
  String get browseGenres => 'Nach Genre stöbern';

  @override
  String get settingsManage => 'Verwalten';

  @override
  String get searchSourcesTitle => 'Suchquellen';

  @override
  String get searchSourceAuto => 'Alle';

  @override
  String get searchSourceAutoHint =>
      'Alle vier Quellen werden gleichzeitig durchsucht und zusammengeführt';

  @override
  String get searchSourceOnlyHint => 'Nur Ergebnisse dieser Quelle anzeigen';

  @override
  String get bookDetailsTitle => 'Buchdetails';

  @override
  String get fileInfoTitle => 'Dateiinfos';

  @override
  String get formatLabel => 'Format';

  @override
  String get publishedYearLabel => 'Erschienen';

  @override
  String get fileSizeLabel => 'Dateigröße';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get sourceLabel => 'Quelle';

  @override
  String get sourceAndDownload => 'Quelle & Download';

  @override
  String get openAtSource => 'Bei Quelle öffnen';

  @override
  String get sourceWelib => 'WeLib';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get sourceStatusUntried => 'Nicht versucht';

  @override
  String get sourceStatusLocallyUnreachable => 'Lokal nicht erreichbar';

  @override
  String sourcesSkippedLocally(String sources) {
    return '$sources übersprungen: von diesem Gerät nicht erreichbar.';
  }

  @override
  String get retryAnyway => 'Trotzdem versuchen';

  @override
  String get sourceStatusFailed => 'Fehlgeschlagen';

  @override
  String sourceResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher',
      one: '1 Buch',
    );
    return '$_temp0';
  }

  @override
  String get searchingTitle => 'Suche läuft';

  @override
  String get searchingSourcesBody =>
      'Alle vier Quellen werden gleichzeitig abgefragt, dann werden die Ergebnisse zusammengeführt und entdoppelt.';

  @override
  String get loadMoreResults => 'Weitere Ergebnisse laden';

  @override
  String noResultsFor(String query) {
    return 'Keine Treffer für „$query“';
  }

  @override
  String get noResultsSourcesBody =>
      'Keine Quelle hat Treffer geliefert. Kürze den Suchbegriff oder lösche die Filter und suche erneut.';

  @override
  String get modifySearch => 'Suche bearbeiten';

  @override
  String get clearFiltersRetry => 'Filter löschen & erneut suchen';

  @override
  String get sourceSheetTitle => 'Suchquelle wechseln';

  @override
  String sourceSheetSubtitle(String query) {
    return 'Ergebnisse für „$query“ aus einer gewählten Quelle anzeigen.';
  }

  @override
  String get sourceAutoRecommended => 'Alle Quellen (zusammengeführt)';

  @override
  String get sourceSheetNote =>
      'Gilt nur für diese Suche. Deine Standardquelle bleibt unverändert.';

  @override
  String get recentSearchesTitle => 'Letzte Suchen';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get searchSuggestionsTitle => 'Suchvorschläge';

  @override
  String get searchSuggestionsLive => 'Live';

  @override
  String get searchRecentHint =>
      'Setze eine letzte Suche fort oder starte eine neue.';

  @override
  String searchInAllSources(String query) {
    return '„$query“ in allen Quellen suchen';
  }

  @override
  String searchInSource(String query, String source) {
    return '„$query“ in $source suchen';
  }

  @override
  String searchAutoScope(int count) {
    return '$count Quellen werden gleichzeitig durchsucht';
  }

  @override
  String searchSourceOnlyScope(String source) {
    return 'Nur $source';
  }

  @override
  String removeRecentSearch(String query) {
    return '„$query“ entfernen';
  }

  @override
  String get clearSearch => 'Suche leeren';

  @override
  String get searchSupportHint =>
      'Nach Titel, Autor, ISBN oder MD5 suchen. Alle vier Quellen werden parallel abgefragt.';

  @override
  String get tryThese => 'Diese ausprobieren';

  @override
  String get filtersAndAdvanced => 'Filter und erweiterte Suche';

  @override
  String get resultsAutoMerged =>
      'Ergebnisse werden automatisch zusammengeführt';

  @override
  String get searchAdvancedHint =>
      'Nach Autor, Verlag, Jahr, Sprache oder Format eingrenzen? Zu „Erweiterte Suche“ wechseln.';

  @override
  String get searchApply => 'Anwenden und suchen';

  @override
  String get resetFilters => 'Zurücksetzen';

  @override
  String get anyValue => 'Beliebig';

  @override
  String get advancedFilterNote =>
      'Erweiterte Filter gelten nur für diese Suche; die Standardquelle bleibt unverändert.';

  @override
  String get filterRelevance => 'Relevanz';

  @override
  String get searchAllSourcesLabel => 'Alle Quellen';

  @override
  String get sourceMarkAll => 'ALLE';

  @override
  String get sourceAnnasShort => 'Anna\'s';

  @override
  String get sourceZlibShort => 'Z-Lib';

  @override
  String sourceCount(int count) {
    return '$count Quellen';
  }

  @override
  String sourceStillSearching(String source) {
    return '$source sucht noch; Ergebnisse werden automatisch ergänzt.';
  }

  @override
  String otherSources(String summary) {
    return 'Andere Quellen: $summary';
  }

  @override
  String sourcesResponded(int count) {
    return '$count Quellen haben geantwortet';
  }

  @override
  String get sourceStatusTitle => 'Quellenstatus';

  @override
  String sourceStatusSummary(int ok, int failed) {
    return '$ok geantwortet, $failed fehlgeschlagen';
  }

  @override
  String sourceResponded(int count) {
    return 'Geantwortet · $count';
  }

  @override
  String get sourceTimedOut => 'Zeitüberschreitung';

  @override
  String get searchAgain => 'Erneut suchen';

  @override
  String sourceMirrorHint(String source) {
    return 'Vom $source-Spiegel; die MD5-Prüfung erfolgt nach dem Download.';
  }

  @override
  String downloadInProgressPercent(int percent) {
    return 'Wird heruntergeladen: $percent% · zum Pausieren tippen';
  }

  @override
  String downloadPausedPercent(int percent) {
    return 'Pausiert bei $percent% · zum Fortsetzen tippen';
  }

  @override
  String get downloadPreparing => 'Download wird vorbereitet…';

  @override
  String downloadWaitingSeconds(int seconds) {
    return 'Warte ${seconds}s';
  }

  @override
  String get downloadFailedRetry =>
      'Download fehlgeschlagen · zum Wiederholen tippen';

  @override
  String get downloadCompletedShort => 'Heruntergeladen';

  @override
  String get downloadThisBook => 'Buch herunterladen';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get downloadCenterTitle => 'Download-Center';

  @override
  String downloadCenterSummary(int active, int paused, int queued) {
    return '$active aktiv · $paused pausiert · $queued wartend';
  }

  @override
  String get downloadCenterNoTasks => 'Noch keine Download-Aufträge';

  @override
  String get downloadCenterAllPause => 'Alle pausieren';

  @override
  String get downloadCenterAllResume => 'Alle fortsetzen';

  @override
  String get downloadCenterAll => 'Alle';

  @override
  String get downloadCenterActive => 'Aktiv';

  @override
  String get downloadCenterCompleted => 'Abgeschlossen';

  @override
  String get downloadCenterFailed => 'Fehlgeschlagen';

  @override
  String get downloadCenterInProgress => 'Läuft';

  @override
  String get downloadCenterNeedsAttention => 'Aktion erforderlich';

  @override
  String get downloadCenterOrderHint => 'In Warteschlangenreihenfolge';

  @override
  String get downloadCenterQueueMemory => 'Warteschlange nur im Speicher';

  @override
  String get downloadCenterRemoveNote =>
      'Beim Entfernen kann die lokale Datei mitgelöscht werden; die Warteschlange liegt nur im Speicher und wird nach dem Beenden nicht fortgesetzt.';

  @override
  String get rangeResume => 'Range-Fortsetzung';

  @override
  String storagePathMessage(String path) {
    return 'Dateien werden gespeichert in: $path';
  }

  @override
  String get downloadCenterRetryHint => 'Wiederholen behält den geladenen Teil';

  @override
  String get downloadCenterOpenHint => 'Titel antippen für Details';

  @override
  String get downloadCenterCurrentProgress => 'Gesamtfortschritt';

  @override
  String get downloadCenterSpeed => 'Aktuelle Geschwindigkeit';

  @override
  String get downloadCenterRemaining => 'Verbleibend';

  @override
  String downloadCenterTodayCount(int count) {
    return 'Heute abgeschlossen: $count';
  }

  @override
  String downloadCenterEtaSeconds(int seconds) {
    return 'Noch $seconds s';
  }

  @override
  String downloadCenterEtaMinutes(int minutes) {
    return 'Noch $minutes min';
  }

  @override
  String downloadCenterStorageSummary(int count, String size) {
    return 'Diesen Monat: $count Bücher · $size';
  }

  @override
  String downloadCenterStorageLegend(String epub, String pdf) {
    return 'EPUB $epub · PDF $pdf';
  }

  @override
  String get downloadCenterRemoveRecord => 'Eintrag entfernen';

  @override
  String get downloadCenterRemoveRecordBody =>
      'Standardmäßig wird nur der Eintrag entfernt; die lokale Datei bleibt im Download-Ordner.';

  @override
  String get downloadCenterRemoveFile => 'Datei ebenfalls entfernen';

  @override
  String get downloadCenterSelect => 'Auswählen';

  @override
  String get downloadCenterSelectAll => 'Alle auswählen';

  @override
  String get downloadCenterDeselectAll => 'Auswahl aufheben';

  @override
  String downloadCenterSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String downloadCenterDeleteSelected(int count) {
    return '$count löschen';
  }

  @override
  String get downloadCenterShowInFolder => 'Im Ordner anzeigen';

  @override
  String get downloadCenterBookDetails => 'Buchdetails';

  @override
  String get share => 'Teilen';

  @override
  String get downloadCenterEmptyTitle => 'Noch keine Downloads';

  @override
  String get downloadCenterEmptyBody =>
      'Tippe auf einer Buchseite auf „Download“, um hier einen Auftrag zu starten. Fertige Bücher kannst du direkt öffnen.';

  @override
  String get downloadCenterGoSearch => 'Bücher suchen';

  @override
  String get downloadCenterTip =>
      'EPUB und PDF werden unterstützt. Pausierte Downloads werden vom letzten Byte fortgesetzt.';

  @override
  String get downloadBook => 'Herunterladen';

  @override
  String get homeTitle => 'Entdecken';

  @override
  String get homeEyebrow => 'Bücher entdecken';

  @override
  String get browseEyebrow => 'Stöbern';

  @override
  String get searchEyebrow => 'Suchquellen';

  @override
  String get downloadEyebrow => 'Lokaler Speicher';

  @override
  String get settingsEyebrow => 'Einstellungen';

  @override
  String get trendingSource => 'Goodreads-Liste';

  @override
  String categoryCount(int count) {
    return '$count Kategorien';
  }

  @override
  String get categorySearchHint => 'In Kategorien suchen';

  @override
  String get categoryInfoHint =>
      'Kategorien stammen aus dem SLUM-Katalog und bleiben 24 Stunden offline verfügbar.';

  @override
  String get searchSourcesIntro =>
      'Alle vier Quellen werden parallel durchsucht. Deaktivierte Quellen werden übersprungen; Spiegeladressen stammen aus dem SLUM-Katalog.';

  @override
  String get sourceOn => 'Aktiviert';

  @override
  String get sourceOff => 'Deaktiviert';

  @override
  String get mirrorsShort => 'Spiegel';

  @override
  String mirrorNodeCount(int count) {
    return '$count Knoten';
  }

  @override
  String get refreshMirrors => 'Spiegel aktualisieren';

  @override
  String get sourceBehaviorSection => 'Quellenverhalten';

  @override
  String get displaySection => 'Anzeige';

  @override
  String get currentLanguage => 'Aktuelle Sprache';

  @override
  String get behaviorSection => 'Verhalten';

  @override
  String get infoSection => 'Informationen';

  @override
  String get thanksSection => 'Danksagungen';

  @override
  String get changelogTitle => 'Änderungsprotokoll';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get projectHome => 'Projektseite';

  @override
  String get slumCatalogue => 'SLUM-Spiegelkatalog';

  @override
  String get slumCatalogueSubtitle => 'open-slum.org';

  @override
  String get challengeSolverTitle => 'Challenge-Löser';

  @override
  String get challengeSolverSubtitle =>
      'Manuelle WebView-Verifizierung als Fallback';

  @override
  String get aboutDisclaimer =>
      'Hier werden keine Buchinhalte gehostet; nur Spiegelsuche und Downloads. Bitte unterstütze die Autor:innen.';

  @override
  String get maintenanceSection => 'Wartung';

  @override
  String get languageCardHint => 'Sprache der Oberfläche, sofort wirksam';

  @override
  String get themeCardHint => 'System folgen oder immer hell bzw. dunkel';

  @override
  String get fontSizeCardHint => 'Gilt für Text in der gesamten App';

  @override
  String get fontPreviewSample =>
      'Ein Raum ohne Bücher ist ein Körper ohne Seele.';

  @override
  String get themeFollowSystemShort => 'System';

  @override
  String get themeLightShort => 'Hell';

  @override
  String get themeDarkShort => 'Dunkel';

  @override
  String get sourceAllSearchedHint =>
      'Alle vier Quellen werden gleichzeitig durchsucht. Tippe auf eine Quelle, um die Ergebnisse zu wechseln.';

  @override
  String get tapToExpandLanguage => 'Tippen, um die Sprache zu wählen';

  @override
  String get tapToCollapseLanguage => 'Tippen zum Einklappen';

  @override
  String get sourceStatusSearching => 'Wird gesucht…';

  @override
  String get verificationPageLoading =>
      'Die Verifizierungsseite wird geladen. Die App fährt automatisch fort.';

  @override
  String get verificationPageInstructions =>
      'Schließe die Prüfung unten ab; die App fährt automatisch fort.';

  @override
  String get challengeNeedsVerification =>
      'Manuelle Prüfung nötig - die Suche läuft danach automatisch weiter';

  @override
  String get challengeNeedsVerificationRetry =>
      'Manuelle Bestätigung nötig – die nächste Suche nutzt die bestätigte Seite.';

  @override
  String get challengeVerifyNow => 'Jetzt prüfen';

  @override
  String get languageNameEn => 'Englisch';

  @override
  String get languageNameEs => 'Spanisch';

  @override
  String get languageNameFr => 'Französisch';

  @override
  String get languageNameDe => 'Deutsch';

  @override
  String get languageNameIt => 'Italienisch';

  @override
  String get languageNamePt => 'Portugiesisch';

  @override
  String get languageNameRu => 'Russisch';

  @override
  String get languageNameZh => 'Chinesisch';

  @override
  String get languageNameJa => 'Japanisch';

  @override
  String get languageNameKo => 'Koreanisch';

  @override
  String get languageNameAr => 'Arabisch';

  @override
  String get languageNameHi => 'Hindi';

  @override
  String get languageNameMl => 'Malayalam';

  @override
  String get languageNameNl => 'Niederländisch';

  @override
  String get languageNamePl => 'Polnisch';

  @override
  String get languageNameTr => 'Türkisch';

  @override
  String get languageNameSv => 'Schwedisch';

  @override
  String get languageNameId => 'Indonesisch';

  @override
  String get languageNameVi => 'Vietnamesisch';

  @override
  String get languageNameCs => 'Tschechisch';

  @override
  String get languageNameEl => 'Griechisch';

  @override
  String get languageNameRo => 'Rumänisch';

  @override
  String get languageNameHu => 'Ungarisch';

  @override
  String get languageNameUk => 'Ukrainisch';

  @override
  String get languageNameHe => 'Hebräisch';

  @override
  String get languageNameTh => 'Thailändisch';

  @override
  String get languageNameFa => 'Persisch';

  @override
  String get languageNameBn => 'Bengalisch';

  @override
  String get languageNameFi => 'Finnisch';

  @override
  String get languageNameNo => 'Norwegisch';

  @override
  String get languageNameDa => 'Dänisch';
}
