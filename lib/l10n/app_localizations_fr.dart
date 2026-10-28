// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OpenlibExtended';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get retry => 'Réessayer';

  @override
  String get advancedSearch => 'Recherche avancée';

  @override
  String get author => 'Auteur';

  @override
  String get publisher => 'Éditeur';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String resultsFor(String query) {
    return 'Résultats pour « $query »';
  }

  @override
  String get followSystem => 'Suivre le système';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get languageSetting => 'Langue';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get notificationsExplanation =>
      'OpenlibExtended a besoin de l\'autorisation de notification pour afficher la progression des téléchargements en arrière-plan. Vous pouvez ainsi suivre vos téléchargements de livres même lorsque l\'application est réduite.';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get enable => 'Activer';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get results => 'Résultats';

  @override
  String get loading => 'Chargement...';

  @override
  String get unknown => 'Inconnu';

  @override
  String get about => 'À propos';

  @override
  String get aboutDescription =>
      'Une application open source qui télécharge des livres depuis des bibliothèques clandestines (Anna\'s Archive, LibGen, Z-Library) et les ouvre dans votre lecteur préféré.';

  @override
  String get aboutForkNote =>
      'Ce fork est maintenu par lzoreal pour un usage personnel et des mises à jour communautaires.';

  @override
  String get aboutOriginalNote =>
      'Application originale par dstark5 ; fork étendu par warreth (https://github.com/warreth/OpenlibExtended).';

  @override
  String get version => 'Version';

  @override
  String get github => 'Github';

  @override
  String get thisForkByMaintainer => 'Ce fork (par lzoreal)';

  @override
  String get reportAnIssue => 'Signaler un problème';

  @override
  String get originalProject => 'Projet original (par dstark5)';

  @override
  String get licence => 'Licence';

  @override
  String get gplLicense => 'Licence GPL v3.0';

  @override
  String couldNotLaunch(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get searchProvidersSection => 'Sources de recherche';

  @override
  String get searchOrderHint =>
      'Les quatre sources sont interrogées en même temps. Cet ordre détermine la fusion des résultats et la source affichée en premier. Maintenez une carte et faites-la glisser pour réorganiser.';

  @override
  String get searchOrderReset => 'Rétablir l’ordre';

  @override
  String get libraryInstancesSection => 'Miroirs';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get generalSection => 'Général';

  @override
  String get advancedSection => 'Avancé';

  @override
  String get backupSection => 'Sauvegarde';

  @override
  String get updatesSection => 'Mises à jour';

  @override
  String get aboutSection => 'À propos';

  @override
  String get archiveInstance => 'Instance d\'archive';

  @override
  String get mirrorsAndProviders => 'Miroirs et sources';

  @override
  String get fontSizeTitle => 'Taille de police';

  @override
  String scaleValue(String value) {
    return 'Échelle : ${value}x';
  }

  @override
  String get preview => 'Aperçu';

  @override
  String get storageLocation => 'Emplacement de stockage';

  @override
  String get manualDownloadButton => 'Bouton de téléchargement manuel';

  @override
  String get backgroundVerification => 'Vérifier en arrière-plan';

  @override
  String get backgroundVerificationHint =>
      'Résout les vérifications DDoS de façon invisible. Échoue sur certains appareils : désactivez-le pour ouvrir aussitôt la fenêtre visible';

  @override
  String get backgroundVerificationFix =>
      'Si la vérification échoue sans arrêt, désactivez « Vérifier en arrière-plan » dans les paramètres - certains appareils ne peuvent pas résoudre les vérifications de façon invisible.';

  @override
  String get showManualDownloadHint =>
      'Afficher le bouton pour lancer les téléchargements manuellement';

  @override
  String get donationKeyTitle => 'Clé de don Anna\'s Archive';

  @override
  String get enterKeyForFasterDownloads =>
      'Saisissez la clé pour des téléchargements plus rapides';

  @override
  String get aboutOpenlib => 'À propos d\'OpenlibExtended';

  @override
  String get redoOnboarding => 'Refaire l\'introduction';

  @override
  String get resetAppSetup => 'Réinitialiser la configuration et recommencer';

  @override
  String get exportLogs => 'Exporter les journaux';

  @override
  String get shareDiagnosticLogs =>
      'Partager les journaux de diagnostic (5 dernières min.)';

  @override
  String failedExportLogs(String error) {
    return 'Échec de l\'export des journaux : $error';
  }

  @override
  String get donationKeyDialog => 'Clé de don';

  @override
  String get enterYourKey => 'Saisissez votre clé';

  @override
  String get instanceChanged => 'Instance modifiée avec succès';

  @override
  String rankingFailed(String error) {
    return 'Échec du classement : $error';
  }

  @override
  String get autoRankInstances => 'Classement automatique des instances';

  @override
  String get sortBySpeedOnStartup =>
      'Trier automatiquement par vitesse au démarrage';

  @override
  String get rankInstancesNow => 'Classer les instances maintenant';

  @override
  String onLatestVersion(String version) {
    return 'Vous utilisez la dernière version ($version)';
  }

  @override
  String failedCheckUpdates(String error) {
    return 'Échec de la vérification des mises à jour : $error';
  }

  @override
  String get includeBetaUpdates => 'Inclure les versions bêta';

  @override
  String get getPreReleaseVersions => 'Recevoir les préversions';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String failedExportBackup(String error) {
    return 'Échec de l\'export de la sauvegarde : $error';
  }

  @override
  String get backupRestored => 'Sauvegarde restaurée';

  @override
  String failedImportBackup(String error) {
    return 'Échec de l\'import de la sauvegarde : $error';
  }

  @override
  String get atLeastOneSource =>
      'Au moins une source de recherche est nécessaire';

  @override
  String rankedFastest(String name, String time) {
    return 'Classé ! Plus rapide : $name (${time}ms)';
  }

  @override
  String get rankingComplete => 'Classement terminé';

  @override
  String get providerSourceOriginal =>
      'Recherché en dernier - protégé par DDoS-Guard';

  @override
  String get providerLibgenCatalog =>
      'Téléchargements rapides et directs - recherché en premier';

  @override
  String get providerZlibMirrors =>
      'Les miroirs tournent ; connexion parfois requise';

  @override
  String get themeTitle => 'Thème';

  @override
  String get saveBackupTitle => 'Enregistrer la sauvegarde';

  @override
  String get pickBackupFile => 'Choisir un fichier de sauvegarde';

  @override
  String get notABackup =>
      'Ce fichier n\'est pas une sauvegarde OpenlibExtended';

  @override
  String get donationKeyHelper =>
      'Utilisée pour des téléchargements plus rapides sur Anna\'s Archive';

  @override
  String get mirrorsTestedRanked => 'Miroirs testés et classés par vitesse';

  @override
  String testingFailed(String error) {
    return 'Échec du test : $error';
  }

  @override
  String get addCustomMirror => 'Ajouter un miroir personnalisé';

  @override
  String get nameLabel => 'Nom';

  @override
  String get nameHint => 'ex. Mon miroir LibGen';

  @override
  String get serviceLabel => 'Service';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get pleaseFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get enterValidUrl =>
      'Veuillez saisir une URL valide avec http:// ou https://';

  @override
  String get mirrorAdded => 'Miroir ajouté avec succès';

  @override
  String get deleteMirror => 'Supprimer le miroir';

  @override
  String deleteMirrorConfirm(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ?';
  }

  @override
  String get mirrorDeleted => 'Miroir supprimé';

  @override
  String get cannotDeleteDefaultMirrors =>
      'Impossible de supprimer les miroirs par défaut';

  @override
  String get manageMirrors => 'Gérer les miroirs';

  @override
  String get noMirrorsAvailable => 'Aucun miroir disponible';

  @override
  String errorLabel(String error) {
    return 'Erreur : $error';
  }

  @override
  String get addMirror => 'Ajouter un miroir';

  @override
  String get testRankMirrors => 'Tester et classer les miroirs par vitesse';

  @override
  String get unreachable => 'inaccessible';

  @override
  String get open => 'Ouvrir';

  @override
  String get unableToOpenFile => 'Impossible d\'ouvrir le fichier !';

  @override
  String get openInSite => 'Ouvrir sur le site';

  @override
  String get bookDeleted => 'Livre supprimé !';

  @override
  String get deleteBook => 'Supprimer le livre';

  @override
  String get deletePermanentWarning =>
      'Cette action est définitive et ne peut pas être annulée';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get showBlockedContent => 'Afficher le contenu de la page bloquée';

  @override
  String get verifyInBrowser => 'Vérifier dans le navigateur';

  @override
  String get manualVerificationRequired => 'Vérification manuelle requise';

  @override
  String get systemBrowser => 'Navigateur système';

  @override
  String get embeddedBrowser => 'Navigateur intégré';

  @override
  String get unableToOpenVerification =>
      'Impossible d\'ouvrir la page de vérification - aucune URL disponible';

  @override
  String get blockedPageContent => 'Contenu de la page bloquée';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get copy => 'Copier';

  @override
  String get tryUsingVpn => 'Essayez d\'utiliser un VPN';

  @override
  String get trending => 'Tendances';

  @override
  String get genres => 'Genres';

  @override
  String get copiedBookPath => 'Chemin du livre copié dans le presse-papiers';

  @override
  String get pauseDownload => 'Mettre le téléchargement en pause';

  @override
  String get resumeDownload => 'Reprendre le téléchargement';

  @override
  String get cancelDownload => 'Annuler le téléchargement';

  @override
  String get copiedBookLink => 'Lien du livre copié dans le presse-papiers';

  @override
  String get noMirrors => 'Aucun miroir disponible !';

  @override
  String get downloadStartedBackground =>
      'Téléchargement lancé en arrière-plan';

  @override
  String get bookDownloaded => 'Livre téléchargé !';

  @override
  String get selectStorageToContinue =>
      'Veuillez sélectionner un dossier de stockage pour continuer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get welcomeTitle => 'Bienvenue sur OpenlibExtended';

  @override
  String get welcomeSubtitle =>
      'Votre porte d\'entrée personnelle vers un monde de connaissances. Préparons tout.';

  @override
  String get whereToStoreBooks => 'Où devons-nous stocker vos livres ?';

  @override
  String get noPathSelected => 'Aucun chemin sélectionné';

  @override
  String get selectFolder => 'Choisir un dossier';

  @override
  String get storageScanNote =>
      'Nous ne chercherons que des fichiers de livres compatibles dans ce dossier. Aucun scan récursif des sous-dossiers.';

  @override
  String get automaticUpdates => 'Mises à jour automatiques';

  @override
  String get enableAutoUpdates => 'Activer les mises à jour automatiques';

  @override
  String get autoUpdatesFdroidNote =>
      'Déconseillé si vous avez installé via F-Droid (F-Droid gère les mises à jour).';

  @override
  String get enableBetaUpdatesOnboarding => 'Activer les versions bêta';

  @override
  String get betaUpdatesNote =>
      'Recevoir les préversions (bêta) quand elles sont disponibles.';

  @override
  String get supportAnnasArchive => 'Soutenir Anna\'s Archive';

  @override
  String get donationPitch =>
      'Faire un don à Anna\'s Archive permet des téléchargements plus rapides et les aide à maintenir le service pour tous. Vous pouvez saisir votre clé secrète ci-dessous.';

  @override
  String get annasSecretKey => 'Clé secrète Anna\'s Archive';

  @override
  String get supportThisApp => 'Soutenir cette application';

  @override
  String get sponsorPitch =>
      'Si vous aimez cette application, pensez à soutenir son développement. Cela m\'aide à y consacrer plus de temps !';

  @override
  String get sponsorOnGithub => 'Sponsoriser sur GitHub';

  @override
  String get stayUpdated => 'Rester informé';

  @override
  String get notifyOnComplete =>
      'Être notifié lorsque les téléchargements se terminent.';

  @override
  String get chooseTheme => 'Choisir un thème';

  @override
  String get lightThemeShort => 'Clair';

  @override
  String get darkThemeShort => 'Sombre';

  @override
  String get verifyingAccess => 'Vérification de l\'accès';

  @override
  String get done => 'Terminé';

  @override
  String get noVoiceAvailable =>
      'Aucune voix disponible pour la lecture à voix haute';

  @override
  String get close => 'Fermer';

  @override
  String get reloadHealthData => 'Recharger les données de santé';

  @override
  String addServiceMirror(String title) {
    return 'Ajouter un miroir $title';
  }

  @override
  String get deleteMirrorTooltip => 'Supprimer le miroir';

  @override
  String searchingOn(String source) {
    return 'Résultats de $source';
  }

  @override
  String get sourceLibgen => 'LibGen';

  @override
  String get sourceZlib => 'Z-Library';

  @override
  String get sourceAnnas => 'Anna\'s Archive';

  @override
  String downloadFrom(String source) {
    return 'Téléchargement depuis $source';
  }

  @override
  String get tryingNextSource =>
      'Aucun résultat ici, essai de la source suivante…';

  @override
  String get slowMirrorsSkipped => 'Utilisation de miroirs plus rapides';

  @override
  String whatsNewTitle(String version) {
    return 'Nouveautés de $version';
  }

  @override
  String get whatsNewIntro =>
      'OpenlibExtended a été mis à jour. Voici ce qui a changé.';

  @override
  String get whatsNewTabFeatures => 'Nouvelles fonctionnalités';

  @override
  String get whatsNewTabSources => 'Sources et miroirs';

  @override
  String get whatsNewProvidersHint =>
      'Cette version ajoute de nouveaux fournisseurs de recherche et de nouveaux miroirs. Mettez à jour votre liste pour supprimer les miroirs morts et ajouter les nouveaux ; les trois fournisseurs seront activés.';

  @override
  String get whatsNewUpdateInstances => 'Mettre à jour la liste des miroirs';

  @override
  String get whatsNewInstancesUpdated => 'Liste des miroirs mise à jour';

  @override
  String get whatsNewContinue => 'Continuer';

  @override
  String get whatsNewFeatureSpeed =>
      'Les téléchargements démarrent plus vite : plus de sondage des miroirs, serveurs rapides d\'abord, passerelles IPFS lentes en dernier.';

  @override
  String get whatsNewFeatureSourceLabels =>
      'Chaque résultat de recherche et chaque téléchargement indique maintenant son catalogue d\'origine.';

  @override
  String get whatsNewFeatureCovers =>
      'Les couvertures LibGen manquantes sont récupérées depuis la page détaillée du livre.';

  @override
  String get categoryClassicsTitle => 'Classiques';

  @override
  String get categoryClassicsInfo =>
      'Des œuvres littéraires intemporelles, souvent saluées pour leur mérite artistique et leur importance culturelle.';

  @override
  String get categoryRomanceTitle => 'Romance';

  @override
  String get categoryRomanceInfo =>
      'Des histoires centrées sur les relations amoureuses, explorant l’amour, la passion et les liens émotionnels.';

  @override
  String get categoryFictionTitle => 'Fiction';

  @override
  String get categoryFictionInfo =>
      'Une littérature narrative issue de l’imagination, non fondée sur des événements réels.';

  @override
  String get categoryYoungAdultTitle => 'Young Adult';

  @override
  String get categoryYoungAdultInfo =>
      'Des livres destinés aux adolescents, abordant des thèmes liés à l’adolescence.';

  @override
  String get categoryFantasyTitle => 'Fantasy';

  @override
  String get categoryFantasyInfo =>
      'Un genre mêlant éléments magiques, créatures mythiques et mondes fantastiques.';

  @override
  String get categoryScienceFictionTitle => 'Science-fiction';

  @override
  String get categoryScienceFictionInfo =>
      'Une littérature explorant des concepts futuristes, les technologies avancées et l’exploration spatiale.';

  @override
  String get categoryNonfictionTitle => 'Non-fiction';

  @override
  String get categoryNonfictionInfo =>
      'Des œuvres fondées sur des faits, notamment des essais, des biographies et des documentaires.';

  @override
  String get categoryChildrenTitle => 'Jeunesse';

  @override
  String get categoryChildrenInfo =>
      'Des livres destinés aux jeunes lecteurs, souvent illustrés et à la narration simple.';

  @override
  String get categoryHistoryTitle => 'Histoire';

  @override
  String get categoryHistoryInfo =>
      'Une littérature qui examine les événements passés, les cultures et les grandes figures historiques.';

  @override
  String get categoryMysteryTitle => 'Polar';

  @override
  String get categoryMysteryInfo =>
      'Des histoires au suspense intense, souvent autour d’un crime ou d’une énigme à résoudre.';

  @override
  String get categoryCoversTitle => 'Couvertures';

  @override
  String get categoryCoversInfo =>
      'L’illustration et la conception visuelle d’un livre, qui attirent l’intérêt des lecteurs.';

  @override
  String get categoryHorrorTitle => 'Horreur';

  @override
  String get categoryHorrorInfo =>
      'Un genre conçu pour susciter la peur, l’effroi ou la terreur par un récit plein de suspense.';

  @override
  String get categoryHistoricalFictionTitle => 'Roman historique';

  @override
  String get categoryHistoricalFictionInfo =>
      'Des romans situés à une époque historique précise, mêlant faits réels et personnages fictifs.';

  @override
  String get categoryBestTitle => 'Meilleurs';

  @override
  String get categoryBestInfo =>
      'Des livres souvent salués par la critique ou populaires, classés par palmarès ou récompenses.';

  @override
  String get categoryTitlesTitle => 'Titres';

  @override
  String get categoryTitlesInfo =>
      'Les noms des livres, qui reflètent souvent leurs thèmes ou leur sujet.';

  @override
  String get categoryMiddleGradeTitle => 'Pré-adolescents';

  @override
  String get categoryMiddleGradeInfo =>
      'Des livres pour les 8-12 ans, avec des thèmes et des personnages adaptés à leur âge.';

  @override
  String get categoryParanormalTitle => 'Paranormal';

  @override
  String get categoryParanormalInfo =>
      'Des histoires intégrant des éléments surnaturels : fantômes, vampires et êtres d’un autre monde.';

  @override
  String get categoryLoveTitle => 'Amour';

  @override
  String get categoryLoveInfo =>
      'Un thème explorant les complexités et les nuances de l’amour sous diverses formes et relations.';

  @override
  String get categoryQueerTitle => 'Queer';

  @override
  String get categoryQueerInfo =>
      'Une littérature représentant la diversité des orientations sexuelles et des identités de genre du spectre LGBTQ+.';

  @override
  String get categoryHistoricalRomanceTitle => 'Romance historique';

  @override
  String get categoryHistoricalRomanceInfo =>
      'Des romans mêlant intrigues amoureuses et toile de fond historique.';

  @override
  String get categoryContemporaryTitle => 'Contemporain';

  @override
  String get categoryContemporaryInfo =>
      'Des œuvres contemporaines, souvent axées sur des enjeux de société actuels et des personnages proches de nous.';

  @override
  String get categoryThrillerTitle => 'Thriller';

  @override
  String get categoryThrillerInfo =>
      'Un genre haletant axé sur l’excitation, la tension et les rebondissements inattendus.';

  @override
  String get categoryWomenTitle => 'Femmes';

  @override
  String get categoryWomenInfo =>
      'Une littérature explorant les expériences, les perspectives et l’autonomisation des femmes.';

  @override
  String get categoryBiographyTitle => 'Biographie';

  @override
  String get categoryBiographyInfo =>
      'Des ouvrages non romanesques retraçant la vie d’une personne, ses réussites et ses défis.';

  @override
  String get categoryLgbtqTitle => 'LGBTQ';

  @override
  String get categoryLgbtqInfo =>
      'Une littérature inclusive représentant les expériences de la communauté lesbienne, gay, bisexuelle, trans et queer.';

  @override
  String get categorySeriesTitle => 'Séries';

  @override
  String get categorySeriesInfo =>
      'Un ensemble de livres liés par une intrigue ou des personnages communs.';

  @override
  String get categoryTitleChallengeTitle => 'Défi de titres';

  @override
  String get categoryTitleChallengeInfo =>
      'Des défis ou concours encourageant une réflexion créative sur les titres de livres.';

  @override
  String get mirrorsTitle => 'Miroirs';

  @override
  String get automaticMirrorOrder => 'Ordre automatique des miroirs';

  @override
  String get mirrorOrderAutoHint =>
      'Protection la plus simple d’abord, puis le plus rapide. Recommandé.';

  @override
  String get mirrorOrderManualHint =>
      'Manuel : utilisez les flèches pour définir votre ordre.';

  @override
  String get mirrorListUpToDate => 'La liste des miroirs est à jour';

  @override
  String mirrorListUpdated(int count) {
    return 'Liste des miroirs mise à jour : $count changement(s)';
  }

  @override
  String mirrorRefreshFailed(String error) {
    return 'Échec de l’actualisation : $error';
  }

  @override
  String get mirrorCatalogueUnreachable =>
      'Impossible de joindre open-slum.org – aucune liste de miroirs disponible';

  @override
  String get mirrorFooterNote =>
      'Les adresses des miroirs et leur état proviennent d’open-slum.org et sont actualisés automatiquement. Un miroir signalé DOWN n’est jamais contacté. La latence locale est mesurée par cet appareil lorsque vous touchez le bouton de vitesse.';

  @override
  String get mirrorLatencyTestTooltip => 'Tester la latence locale';

  @override
  String get mirrorLatencyHint =>
      'Les miroirs locaux n’ont pas encore été testés ; la recherche peut être plus lente. Le test les trie selon votre propre latence.';

  @override
  String get mirrorLatencyNeedsVerification => 'vérification requise';

  @override
  String get mirrorLatencyGoTest => 'Tester';

  @override
  String get mirrorLatencyNotTested => 'Latence locale non testée';

  @override
  String get mirrorLatencyTesting => 'Test de la latence locale…';

  @override
  String get mirrorLatencyTimeout => 'Délai local dépassé';

  @override
  String mirrorLatencyLocal(String latency) {
    return 'Local $latency';
  }

  @override
  String get mirrorLatencyJustNow => 'à l’instant';

  @override
  String get mirrorLatencyExpired => 'expiré';

  @override
  String mirrorLatencyDone(int reachable, int total, String fastest) {
    return 'Test local : $reachable/$total accessibles, plus rapide $fastest';
  }

  @override
  String get mirrorLatencyAllTimedOut =>
      'Test local terminé · aucun miroir n’a répondu';

  @override
  String get mirrorLatencyNoTargets => 'Aucun miroir activé à tester';

  @override
  String mirrorLatencyFailed(String error) {
    return 'Échec du test local : $error';
  }

  @override
  String get noMirrorsReported => 'Aucun miroir signalé';

  @override
  String get noMirrorsReportedHint =>
      'open-slum.org n’a pas (encore) d’entrée ou est injoignable.';

  @override
  String get couldNotLoadMirrors => 'Impossible de charger les miroirs';

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get reportedDownNeverContacted => 'signalé DOWN – jamais contacté';

  @override
  String get mirrorServiceLibgenHint =>
      'Téléchargements rapides sans challenge lorsqu’un miroir est disponible';

  @override
  String get mirrorServiceZlibHint =>
      'Les miroirs DiamWall se résolvent en arrière-plan';

  @override
  String get mirrorServiceWelibHint =>
      'Recherche protégée par Cloudflare, pages de livres ouvertes';

  @override
  String get mirrorServiceAnnasHint => 'Lecture, détails et téléchargements';

  @override
  String get mirrorStatusUp => 'En ligne';

  @override
  String get mirrorStatusDegraded => 'Dégradé';

  @override
  String get mirrorStatusProtected => 'Protégé';

  @override
  String get mirrorStatusDown => 'Hors ligne';

  @override
  String get searchEmptyQuery => 'Le champ de recherche est vide';

  @override
  String get filterTypeLabel => 'Type';

  @override
  String get filterSortLabel => 'Trier par';

  @override
  String get filterFileTypeLabel => 'Type de fichier';

  @override
  String get filterYearLabel => 'Année';

  @override
  String get filterAll => 'Tous';

  @override
  String get typeAnyBooks => 'Tous les livres';

  @override
  String get typeUnknownBooks => 'Livres inconnus';

  @override
  String get typeFictionBooks => 'Livres de fiction';

  @override
  String get typeNonfictionBooks => 'Livres non romanesques';

  @override
  String get typeComicBooks => 'Bandes dessinées';

  @override
  String get typeMagazine => 'Magazine';

  @override
  String get typeStandardsDocument => 'Document de normes';

  @override
  String get typeJournalArticle => 'Article de revue';

  @override
  String get sortMostRelevant => 'Plus pertinents';

  @override
  String get sortNewest => 'Plus récents';

  @override
  String get sortOldest => 'Plus anciens';

  @override
  String get sortLargest => 'Plus volumineux';

  @override
  String get sortSmallest => 'Plus petits';

  @override
  String get yearBefore1980 => 'Avant 1980';

  @override
  String get langEnglish => 'Anglais';

  @override
  String get langSpanish => 'Espagnol';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Allemand';

  @override
  String get langItalian => 'Italien';

  @override
  String get langPortuguese => 'Portugais';

  @override
  String get langRussian => 'Russe';

  @override
  String get langChinese => 'Chinois';

  @override
  String get langJapanese => 'Japonais';

  @override
  String get langKorean => 'Coréen';

  @override
  String get langArabic => 'Arabe';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langDutch => 'Néerlandais';

  @override
  String get langPolish => 'Polonais';

  @override
  String get langTurkish => 'Turc';

  @override
  String get langSwedish => 'Suédois';

  @override
  String get langIndonesian => 'Indonésien';

  @override
  String get langVietnamese => 'Vietnamien';

  @override
  String get langCzech => 'Tchèque';

  @override
  String get langGreek => 'Grec';

  @override
  String get langRomanian => 'Roumain';

  @override
  String get langHungarian => 'Hongrois';

  @override
  String get langUkrainian => 'Ukrainien';

  @override
  String get langHebrew => 'Hébreu';

  @override
  String get langThai => 'Thaï';

  @override
  String get langPersian => 'Persan';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langFinnish => 'Finnois';

  @override
  String get langNorwegian => 'Norvégien';

  @override
  String get langDanish => 'Danois';

  @override
  String get downloadsTitle => 'Téléchargements';

  @override
  String get downloadQueued => 'En file d’attente';

  @override
  String get downloadGettingMirrors => 'Récupération des miroirs…';

  @override
  String get downloadFindingMirror => 'Recherche d’un miroir…';

  @override
  String get downloadDownloading => 'Téléchargement';

  @override
  String get downloadPaused => 'En pause';

  @override
  String get downloadVerifying => 'Vérification';

  @override
  String get downloadCancelled => 'Annulé';

  @override
  String get downloadFailedGeneric => 'Échec du téléchargement';

  @override
  String get verifyAction => 'Vérifier';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get couldNotOpenLink => 'Impossible d’ouvrir le lien.';

  @override
  String get manualDownloadAction => 'Téléchargement manuel';

  @override
  String get fastDownloadStarted =>
      'Téléchargement rapide démarré en arrière-plan 🚀';

  @override
  String get welibNoDownloadLink =>
      'WeLib n’a pas proposé de lien de téléchargement pour ce livre.';

  @override
  String get welibPageUnreadable =>
      'Impossible de lire la page de téléchargement WeLib.';

  @override
  String get fileNotFoundDownloadFailed =>
      'Fichier introuvable. Le téléchargement a peut-être échoué.';

  @override
  String shareBookMessage(String title, String link) {
    return 'Découvrez ce livre passionnant : « $title »\nEn savoir plus : $link';
  }

  @override
  String get webviewWindowTitle => 'Vérification de l’accès – OpenLibExtended';

  @override
  String get webviewBrowserOpen => 'La fenêtre du navigateur est ouverte';

  @override
  String get webviewBrowserOpening => 'Ouverture de la fenêtre du navigateur…';

  @override
  String get webviewInstructions =>
      '1. Résolvez le CAPTCHA dans la fenêtre du navigateur\n2. Attendez le chargement complet de la page\n3. Cliquez sur « Terminé » ci-dessus pour continuer';

  @override
  String get webviewPreparingDownload => 'Préparation du téléchargement…';

  @override
  String get webviewPreparingHint =>
      'Veuillez patienter pendant la vérification de l’accès et la récupération des liens';

  @override
  String get changeStorageHint =>
      'Modifier l’emplacement d’enregistrement des livres';

  @override
  String versionWithBuild(String version, String build) {
    return 'Version $version+$build';
  }

  @override
  String get backupShareText => 'Sauvegarde OpenlibExtended';

  @override
  String get exportBackupTitle => 'Exporter la sauvegarde';

  @override
  String get exportBackupSubtitle =>
      'Enregistrer les paramètres, livres et instances dans un fichier JSON';

  @override
  String get importBackupTitle => 'Importer une sauvegarde';

  @override
  String get importBackupSubtitle =>
      'Restaurer depuis un fichier de sauvegarde (remplace les données actuelles)';

  @override
  String get providerWelibCatalog =>
      'Recherche protégée par Cloudflare et pages de livres ouvertes';

  @override
  String get errorWhatToDo => 'Que faire';

  @override
  String get errorVpnDescription =>
      'Un VPN peut aider à contourner les blocages régionaux et à accéder au contenu.';

  @override
  String get errorVerificationPrompt =>
      'Le site vous demande de confirmer que vous êtes humain. Nous allons ouvrir une fenêtre de navigateur pour effectuer la vérification.';

  @override
  String get errorVerificationReturn =>
      'Une fois la vérification terminée, revenez à l’application et appuyez sur « Réessayer ».';

  @override
  String get errorNoContent => 'Aucun contenu disponible';

  @override
  String get networkErrorNoInternetTitle => 'Pas de connexion Internet';

  @override
  String get networkErrorNoInternetSolution =>
      'Vérifiez votre connexion Internet. Assurez-vous que le Wi-Fi ou les données mobiles sont activés.';

  @override
  String get networkErrorCloudflareTitle =>
      'Accès bloqué par la protection DDoS';

  @override
  String get networkErrorCloudflareSolution =>
      'Ce site est protégé et bloque l’application. Essayez un VPN, changez le DNS pour 1.1.1.1 ou 8.8.8.8, ou vérifiez dans le navigateur.';

  @override
  String get networkErrorServerUnavailableTitle =>
      'Serveur temporairement indisponible';

  @override
  String get networkErrorServerUnavailableSolution =>
      'Le serveur rencontre des problèmes. Réessayez dans quelques minutes ou choisissez un autre miroir dans les paramètres.';

  @override
  String get networkErrorTimeoutTitle => 'Délai de la requête dépassé';

  @override
  String get networkErrorTimeoutSolution =>
      'Le serveur met trop de temps à répondre. Vérifiez votre connexion et réessayez.';

  @override
  String get networkErrorForbiddenTitle => 'Accès refusé';

  @override
  String get networkErrorForbiddenSolution =>
      'Vous n’avez pas l’autorisation d’accéder à cette ressource. Essayez un VPN, changez le DNS ou utilisez un autre miroir dans les paramètres.';

  @override
  String get networkErrorRateLimitedTitle => 'Trop de requêtes';

  @override
  String get networkErrorRateLimitedSolution =>
      'Trop de requêtes ont été envoyées. Attendez quelques minutes et réessayez.';

  @override
  String get networkErrorSslTitle => 'Échec de la connexion sécurisée';

  @override
  String get networkErrorSslSolution =>
      'Votre réseau bloque peut-être les connexions sécurisées. Essayez un VPN ou un autre réseau.';

  @override
  String get networkErrorDnsTitle => 'Serveur introuvable';

  @override
  String get networkErrorDnsSolution =>
      'Le site est injoignable. Votre fournisseur d’accès le bloque peut-être. Essayez un VPN ou changez le DNS pour 1.1.1.1 / 8.8.8.8.';

  @override
  String get networkErrorParseTitle =>
      'Impossible de lire les données de la source';

  @override
  String get networkErrorParseSolution =>
      'La source a renvoyé une page que l’application n’a pas pu lire. Changez de source ou de miroir et réessayez. Si le problème persiste, ouvrez les diagnostics et partagez les journaux.';

  @override
  String get networkErrorStorageTitle => 'Opération de stockage local échouée';

  @override
  String get networkErrorStorageSolution =>
      'Vérifiez l’espace libre et les autorisations de stockage, puis réessayez. Si le problème persiste, ouvrez les diagnostics et partagez les journaux.';

  @override
  String get networkErrorUnknownTitle => 'Une erreur est survenue';

  @override
  String get networkErrorUnknownSolution =>
      'Veuillez réessayer. Si le problème persiste, ouvrez les diagnostics et partagez les journaux.';

  @override
  String get errorDiagnostics => 'Diagnostics';

  @override
  String get errorCopyDiagnostics => 'Copier les diagnostics';

  @override
  String errorLocation(String location) {
    return 'Emplacement : $location';
  }

  @override
  String get errorStackTrace => 'Pile d’appels';

  @override
  String get errorEnvironment => 'Environnement';

  @override
  String get updatePermissionTitle => 'Autorisation requise';

  @override
  String get updatePermissionBody =>
      'Pour installer les mises à jour, OpenlibExtended a besoin de l’autorisation d’installer des paquets.\n\nCela permet à l’application d’installer automatiquement les nouvelles versions avec correctifs et nouveautés.\n\nVous serez redirigé vers les paramètres pour activer cette autorisation.';

  @override
  String get updateOpenSettings => 'Ouvrir les paramètres';

  @override
  String get updateDebugBuildWarning =>
      'Build de débogage détecté : la mise à jour peut échouer avec « Application non installée » en raison d’une signature différente. Désinstallez d’abord cette application.';

  @override
  String get updateOpeningInstaller =>
      'Ouverture de l’installateur… Si rien ne se passe, l’installation a échoué.';

  @override
  String get updateManualInstall => 'Installation manuelle';

  @override
  String get updateInstallationIssueTitle => 'Problème d’installation';

  @override
  String get updateInstallationIssueBody =>
      'L’installateur automatique n’a pas pu ouvrir l’APK. Cela peut arriver sur certaines versions d’Android.\n\nVous pouvez l’installer manuellement avec l’une de ces options :';

  @override
  String updateFileLabel(String file) {
    return 'Fichier : $file';
  }

  @override
  String get updateInstallationFailed => 'Échec de l’installation';

  @override
  String get updateMethodsTried => 'Méthodes essayées :';

  @override
  String get updateErrorsEncountered => 'Erreurs rencontrées :';

  @override
  String updateMethodNumber(int number) {
    return 'Méthode $number';
  }

  @override
  String get updateDownloadViaBrowser => 'Télécharger via le navigateur';

  @override
  String get updateInstallationErrorTitle => 'Erreur d’installation';

  @override
  String get updateOk => 'OK';

  @override
  String get updateTryManualInstall => 'Essayer l’installation manuelle';

  @override
  String updateInstallFailed(String error) {
    return 'Échec de l’installation de la mise à jour : $error';
  }

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String updateVersionAvailable(String version) {
    return 'La version $version est disponible !';
  }

  @override
  String get updatePreRelease => 'Préversion';

  @override
  String get updateWhatsNew => 'Nouveautés :';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateDownloadAndInstall => 'Télécharger et installer';

  @override
  String get updateDownloadFromGithub => 'Télécharger depuis GitHub';

  @override
  String get updateViewOnGithub => 'Voir sur GitHub';

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour';

  @override
  String get updateDownloadComplete => 'Téléchargement terminé';

  @override
  String updateVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get updateOpeningInstallerShort => 'Ouverture de l’installateur…';

  @override
  String get updateConnecting => 'Connexion…';

  @override
  String get updateFileNotFound => 'Fichier téléchargé introuvable';

  @override
  String updateFileCorrupted(String size) {
    return 'Le fichier téléchargé semble corrompu ($size seulement)';
  }

  @override
  String get updatePermissionDenied =>
      'L’autorisation d’installer des applications a été refusée. Vous pouvez toujours installer manuellement.';

  @override
  String get updateMayHaveFailedSilently =>
      'A peut-être échoué silencieusement';

  @override
  String get updateMethodOpenFile => 'Ouvrir le fichier';

  @override
  String get updateMethodApkSideload => 'Chargement APK';

  @override
  String get updateMethodPackageInstaller => 'Installateur de paquets';

  @override
  String get networkErrorBookNotFoundTitle => 'Livre introuvable';

  @override
  String get networkErrorBookNotFoundSolution =>
      'La page s’est chargée mais ne contenait aucun détail du livre. Le lien est peut-être obsolète – essayez de rechercher le titre.';

  @override
  String get networkErrorBookDetailsUnavailableTitle =>
      'Impossible de charger les détails du livre';

  @override
  String get networkErrorBookDetailsUnavailableSolution =>
      'Les informations du livre n’ont pas pu être récupérées. Réessayez ou utilisez un autre miroir dans les paramètres.';

  @override
  String get downloadNoWorkingMirrors =>
      'Aucun miroir fonctionnel disponible !';

  @override
  String get downloadAllMirrorsFailed => 'Tous les miroirs ont échoué !';

  @override
  String get downloadErrorGettingMirrors =>
      'Erreur lors de la récupération des miroirs';

  @override
  String downloadCouldNotSave(String error) {
    return 'Impossible d’enregistrer dans la bibliothèque : $error';
  }

  @override
  String get appLogsShareSubject => 'Journaux de l’application OpenlibExtended';

  @override
  String appLogsShareText(int minutes) {
    return 'Journaux de l’application OpenlibExtended des $minutes dernières minutes';
  }

  @override
  String notificationAlreadyDownloading(String title) {
    return 'Téléchargement déjà en cours : $title';
  }

  @override
  String notificationQueued(String title) {
    return 'En file d’attente : $title';
  }

  @override
  String get notificationStartingFastDownload =>
      'Démarrage du téléchargement rapide…';

  @override
  String get notificationVerifyingFile => 'Vérification du fichier…';

  @override
  String get notificationDownloadComplete => 'Téléchargement terminé !';

  @override
  String get notificationDownloadCompleteChecksumFailed =>
      'Téléchargement terminé (somme de contrôle invalide)';

  @override
  String get notificationChannelDescription =>
      'Notifications de progression des téléchargements de livres';

  @override
  String notificationDownloadingPercent(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String notificationFailed(String error) {
    return 'Échec : $error';
  }

  @override
  String get notificationDownloadTitle => 'Téléchargement';

  @override
  String get searchHintTitle => 'Trouvez votre prochaine lecture';

  @override
  String get searchHintBody =>
      'Recherchez par titre, auteur ou ISBN, ou utilisez les filtres ci-dessus.';

  @override
  String get homeSearchHint => 'Rechercher par titre, auteur ou ISBN';

  @override
  String get trendingThisWeek => 'Tendances de la semaine';

  @override
  String get keepExploring => 'Continuer à explorer';

  @override
  String get browseGenres => 'Parcourir par genre';

  @override
  String get settingsManage => 'Gérer';

  @override
  String get searchSourcesTitle => 'Sources de recherche';

  @override
  String get searchSourceAuto => 'Toutes';

  @override
  String get searchSourceAutoHint =>
      'Les quatre sources sont interrogées en même temps, résultats fusionnés';

  @override
  String get searchSourceOnlyHint =>
      'Afficher uniquement les résultats de cette source';

  @override
  String get bookDetailsTitle => 'Détails du livre';

  @override
  String get fileInfoTitle => 'Infos fichier';

  @override
  String get formatLabel => 'Format';

  @override
  String get publishedYearLabel => 'Publication';

  @override
  String get fileSizeLabel => 'Taille du fichier';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceAndDownload => 'Source et téléchargement';

  @override
  String get openAtSource => 'Ouvrir à la source';

  @override
  String get sourceWelib => 'WeLib';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get sourceStatusUntried => 'Non essayée';

  @override
  String get sourceStatusLocallyUnreachable =>
      'Injoignable depuis cet appareil';

  @override
  String sourcesSkippedLocally(String sources) {
    return '$sources ignoré(s) : injoignable(s) depuis cet appareil.';
  }

  @override
  String get retryAnyway => 'Essayer quand même';

  @override
  String get sourceStatusFailed => 'Échec';

  @override
  String sourceResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '1 livre',
    );
    return '$_temp0';
  }

  @override
  String get searchingTitle => 'Recherche en cours';

  @override
  String get searchingSourcesBody =>
      'Interroge les quatre sources en même temps, puis fusionne et déduplique les résultats.';

  @override
  String get loadMoreResults => 'Faites défiler pour charger la suite';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get noResultsSourcesBody =>
      'Aucune source n’a donné de résultat. Raccourcissez la requête ou effacez les filtres avant de réessayer.';

  @override
  String get modifySearch => 'Modifier la recherche';

  @override
  String get clearFiltersRetry => 'Effacer les filtres et réessayer';

  @override
  String get sourceSheetTitle => 'Changer de source';

  @override
  String sourceSheetSubtitle(String query) {
    return 'Voir les résultats de « $query » dans une source choisie.';
  }

  @override
  String get sourceAutoRecommended => 'Toutes les sources (combinées)';

  @override
  String get sourceSheetNote =>
      'S’applique uniquement à cette recherche. Votre source par défaut reste inchangée.';

  @override
  String get recentSearchesTitle => 'Recherches récentes';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get searchSuggestionsTitle => 'Suggestions de recherche';

  @override
  String get searchSuggestionsLive => 'En direct';

  @override
  String get searchRecentHint =>
      'Reprenez une recherche récente ou saisissez un nouveau mot-clé.';

  @override
  String searchInAllSources(String query) {
    return 'Rechercher « $query » dans toutes les sources';
  }

  @override
  String searchInSource(String query, String source) {
    return 'Rechercher « $query » dans $source';
  }

  @override
  String searchAutoScope(int count) {
    return 'Recherche dans $count sources à la fois';
  }

  @override
  String searchSourceOnlyScope(String source) {
    return '$source seulement';
  }

  @override
  String removeRecentSearch(String query) {
    return 'Supprimer « $query »';
  }

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get searchSupportHint =>
      'Recherchez par titre, auteur, ISBN ou MD5. Les quatre sources sont interrogées en parallèle.';

  @override
  String get tryThese => 'Essayez ceci';

  @override
  String get filtersAndAdvanced => 'Filtres et recherche avancée';

  @override
  String get resultsAutoMerged => 'Résultats fusionnés automatiquement';

  @override
  String get searchAdvancedHint =>
      'Besoin de préciser l’auteur, l’éditeur, l’année, la langue ou le format ? Passez à la recherche avancée.';

  @override
  String get searchApply => 'Appliquer et rechercher';

  @override
  String get resetFilters => 'Réinitialiser';

  @override
  String get anyValue => 'Tous';

  @override
  String get advancedFilterNote =>
      'Les filtres avancés ne s’appliquent qu’à cette recherche ; la source par défaut reste inchangée.';

  @override
  String get filterRelevance => 'Pertinence';

  @override
  String get searchAllSourcesLabel => 'Toutes les sources';

  @override
  String get sourceMarkAll => 'TOUT';

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
    return '$source recherche encore ; les résultats seront ajoutés automatiquement.';
  }

  @override
  String otherSources(String summary) {
    return 'Autres sources : $summary';
  }

  @override
  String sourcesResponded(int count) {
    return '$count sources ont répondu';
  }

  @override
  String get sourceStatusTitle => 'État des sources';

  @override
  String sourceStatusSummary(int ok, int failed) {
    return '$ok ont répondu, $failed en échec';
  }

  @override
  String sourceResponded(int count) {
    return 'Répondu · $count';
  }

  @override
  String get sourceTimedOut => 'Délai dépassé';

  @override
  String get searchAgain => 'Rechercher à nouveau';

  @override
  String sourceMirrorHint(String source) {
    return 'Depuis le miroir $source ; le MD5 est vérifié après le téléchargement.';
  }

  @override
  String get downloadThisBook => 'Télécharger le livre';

  @override
  String get navDownloads => 'Téléchargements';

  @override
  String get downloadCenterTitle => 'Centre de téléchargements';

  @override
  String downloadCenterSummary(int active, int paused, int queued) {
    return '$active en cours · $paused en pause · $queued en attente';
  }

  @override
  String get downloadCenterNoTasks => 'Aucune tâche de téléchargement';

  @override
  String get downloadCenterAllPause => 'Tout mettre en pause';

  @override
  String get downloadCenterAllResume => 'Tout reprendre';

  @override
  String get downloadCenterAll => 'Tous';

  @override
  String get downloadCenterActive => 'Actifs';

  @override
  String get downloadCenterCompleted => 'Terminés';

  @override
  String get downloadCenterFailed => 'Échoués';

  @override
  String get downloadCenterInProgress => 'En cours';

  @override
  String get downloadCenterNeedsAttention => 'À traiter';

  @override
  String get downloadCenterOrderHint => 'Dans l’ordre de la file';

  @override
  String get downloadCenterQueueMemory => 'File en mémoire uniquement';

  @override
  String get downloadCenterRemoveNote =>
      'Lors de la suppression d’une entrée, le fichier local peut aussi être supprimé ; la file reste en mémoire et ne reprend pas après la fermeture.';

  @override
  String get rangeResume => 'Reprise Range';

  @override
  String storagePathMessage(String path) {
    return 'Les fichiers sont enregistrés dans : $path';
  }

  @override
  String get downloadCenterRetryHint =>
      'Réessayer conserve la partie téléchargée';

  @override
  String get downloadCenterOpenHint => 'Touchez un titre pour voir les détails';

  @override
  String get downloadCenterCurrentProgress => 'Progression totale';

  @override
  String get downloadCenterSpeed => 'Vitesse actuelle';

  @override
  String get downloadCenterRemaining => 'Restant';

  @override
  String downloadCenterTodayCount(int count) {
    return 'Terminés aujourd’hui : $count';
  }

  @override
  String downloadCenterEtaSeconds(int seconds) {
    return 'Encore $seconds s';
  }

  @override
  String downloadCenterEtaMinutes(int minutes) {
    return 'Encore $minutes min';
  }

  @override
  String downloadCenterStorageSummary(int count, String size) {
    return 'Ce mois-ci : $count livres · $size';
  }

  @override
  String downloadCenterStorageLegend(String epub, String pdf) {
    return 'EPUB $epub · PDF $pdf';
  }

  @override
  String get downloadCenterRemoveRecord => 'Supprimer l’entrée';

  @override
  String get downloadCenterRemoveRecordBody =>
      'Seule l’entrée est supprimée ; le fichier local reste dans le dossier de téléchargement.';

  @override
  String get downloadCenterRemoveFile => 'Supprimer aussi le fichier';

  @override
  String get downloadCenterShowInFolder => 'Afficher dans le dossier';

  @override
  String get downloadCenterBookDetails => 'Détails du livre';

  @override
  String get share => 'Partager';

  @override
  String get downloadCenterEmptyTitle => 'Aucun téléchargement';

  @override
  String get downloadCenterEmptyBody =>
      'Touchez « Télécharger » sur la page d’un livre pour créer une tâche ici. Une fois terminé, vous pouvez l’ouvrir directement.';

  @override
  String get downloadCenterGoSearch => 'Rechercher des livres';

  @override
  String get downloadCenterTip =>
      'EPUB et PDF sont pris en charge. Un téléchargement en pause reprend au dernier octet.';

  @override
  String get downloadBook => 'Télécharger';

  @override
  String get homeTitle => 'Découvrir';

  @override
  String get homeEyebrow => 'Découvrir des livres';

  @override
  String get browseEyebrow => 'Parcourir';

  @override
  String get searchEyebrow => 'Sources de recherche';

  @override
  String get downloadEyebrow => 'Stockage local';

  @override
  String get settingsEyebrow => 'Préférences';

  @override
  String get trendingSource => 'Liste Goodreads';

  @override
  String categoryCount(int count) {
    return '$count catégories';
  }

  @override
  String get categorySearchHint => 'Rechercher dans les catégories';

  @override
  String get categoryInfoHint =>
      'Les catégories proviennent du catalogue SLUM et restent disponibles hors ligne pendant 24 heures.';

  @override
  String get searchSourcesIntro =>
      'Les quatre sources sont interrogées en parallèle. Les sources désactivées sont ignorées ; les adresses des miroirs proviennent du catalogue SLUM.';

  @override
  String get sourceOn => 'Activée';

  @override
  String get sourceOff => 'Désactivée';

  @override
  String get mirrorsShort => 'Miroirs';

  @override
  String mirrorNodeCount(int count) {
    return '$count nœuds';
  }

  @override
  String get refreshMirrors => 'Actualiser les miroirs';

  @override
  String get sourceBehaviorSection => 'Comportement des sources';

  @override
  String get displaySection => 'Affichage';

  @override
  String get currentLanguage => 'Langue actuelle';

  @override
  String get behaviorSection => 'Comportement';

  @override
  String get infoSection => 'Informations';

  @override
  String get thanksSection => 'Remerciements';

  @override
  String get changelogTitle => 'Journal des modifications';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get projectHome => 'Page du projet';

  @override
  String get slumCatalogue => 'Catalogue de miroirs SLUM';

  @override
  String get slumCatalogueSubtitle => 'open-slum.org';

  @override
  String get challengeSolverTitle => 'Solveur de défi';

  @override
  String get challengeSolverSubtitle =>
      'Vérification manuelle WebView en secours';

  @override
  String get aboutDisclaimer =>
      'Aucun contenu de livre n’est hébergé ici ; uniquement la recherche et les téléchargements via miroirs. Soutenez les auteurs.';

  @override
  String get maintenanceSection => 'Maintenance';

  @override
  String get languageCardHint =>
      'Langue de l\'interface, appliquée immédiatement';

  @override
  String get themeCardHint => 'Suivre le système, ou toujours clair ou sombre';

  @override
  String get fontSizeCardHint => 'S\'applique au texte de toute l\'application';

  @override
  String get fontPreviewSample =>
      'Une pièce sans livres est un corps sans âme.';

  @override
  String get themeFollowSystemShort => 'Système';

  @override
  String get themeLightShort => 'Clair';

  @override
  String get themeDarkShort => 'Sombre';

  @override
  String get sourceAllSearchedHint =>
      'Les quatre sources sont interrogées en même temps. Touchez une source pour changer de résultats.';

  @override
  String get tapToExpandLanguage => 'Touchez pour choisir la langue';

  @override
  String get tapToCollapseLanguage => 'Touchez pour réduire';

  @override
  String get sourceStatusSearching => 'Recherche…';

  @override
  String get verificationPageLoading =>
      'Chargement de la page de vérification. L’application continuera automatiquement.';

  @override
  String get verificationPageInstructions =>
      'Effectuez la vérification ci-dessous ; l’application continuera automatiquement.';

  @override
  String get challengeNeedsVerification =>
      'Vérification manuelle requise : la recherche reprend une fois validée';

  @override
  String get challengeNeedsVerificationRetry =>
      'Vérification manuelle requise – la prochaine recherche réutilisera la page validée.';

  @override
  String get challengeVerifyNow => 'Vérifier';

  @override
  String get languageNameEn => 'Anglais';

  @override
  String get languageNameEs => 'Espagnol';

  @override
  String get languageNameFr => 'Français';

  @override
  String get languageNameDe => 'Allemand';

  @override
  String get languageNameIt => 'Italien';

  @override
  String get languageNamePt => 'Portugais';

  @override
  String get languageNameRu => 'Russe';

  @override
  String get languageNameZh => 'Chinois';

  @override
  String get languageNameJa => 'Japonais';

  @override
  String get languageNameKo => 'Coréen';

  @override
  String get languageNameAr => 'Arabe';

  @override
  String get languageNameHi => 'Hindi';

  @override
  String get languageNameMl => 'Malayalam';

  @override
  String get languageNameNl => 'Néerlandais';

  @override
  String get languageNamePl => 'Polonais';

  @override
  String get languageNameTr => 'Turc';

  @override
  String get languageNameSv => 'Suédois';

  @override
  String get languageNameId => 'Indonésien';

  @override
  String get languageNameVi => 'Vietnamien';

  @override
  String get languageNameCs => 'Tchèque';

  @override
  String get languageNameEl => 'Grec';

  @override
  String get languageNameRo => 'Roumain';

  @override
  String get languageNameHu => 'Hongrois';

  @override
  String get languageNameUk => 'Ukrainien';

  @override
  String get languageNameHe => 'Hébreu';

  @override
  String get languageNameTh => 'Thaï';

  @override
  String get languageNameFa => 'Persan';

  @override
  String get languageNameBn => 'Bengali';

  @override
  String get languageNameFi => 'Finnois';

  @override
  String get languageNameNo => 'Norvégien';

  @override
  String get languageNameDa => 'Danois';
}
