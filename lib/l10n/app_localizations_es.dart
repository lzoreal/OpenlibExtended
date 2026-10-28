// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OpenlibExtended';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Añadir';

  @override
  String get delete => 'Eliminar';

  @override
  String get retry => 'Reintentar';

  @override
  String get advancedSearch => 'Búsqueda avanzada';

  @override
  String get author => 'Autor';

  @override
  String get publisher => 'Editorial';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String resultsFor(String query) {
    return 'Resultados para «$query»';
  }

  @override
  String get followSystem => 'Seguir el sistema';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get languageSetting => 'Idioma';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get notificationsExplanation =>
      'OpenlibExtended necesita el permiso de notificaciones para mostrar el progreso de las descargas en segundo plano. Así puedes seguir tus descargas de libros aunque la aplicación esté minimizada.';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get enable => 'Activar';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get results => 'Resultados';

  @override
  String get loading => 'Cargando...';

  @override
  String get unknown => 'Desconocido';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutDescription =>
      'Una app de código abierto que descarga libros de bibliotecas clandestinas (Anna\'s Archive, LibGen, Z-Library) y los abre en tu lector preferido.';

  @override
  String get aboutForkNote =>
      'Este fork está mantenido por lzoreal para uso personal y actualizaciones de la comunidad.';

  @override
  String get aboutOriginalNote =>
      'Aplicación original de dstark5; fork ampliado de warreth (https://github.com/warreth/OpenlibExtended).';

  @override
  String get version => 'Versión';

  @override
  String get github => 'Github';

  @override
  String get thisForkByMaintainer => 'Este fork (por lzoreal)';

  @override
  String get reportAnIssue => 'Informar de un problema';

  @override
  String get originalProject => 'Proyecto original (por dstark5)';

  @override
  String get licence => 'Licencia';

  @override
  String get gplLicense => 'Licencia GPL v3.0';

  @override
  String couldNotLaunch(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get searchProvidersSection => 'Fuentes de búsqueda';

  @override
  String get searchOrderHint =>
      'Las cuatro fuentes se buscan a la vez. Este orden decide cómo se combinan los resultados y qué fuente se muestra primero. Mantén pulsada una tarjeta y arrástrala para reordenar.';

  @override
  String get searchOrderReset => 'Restablecer orden';

  @override
  String get libraryInstancesSection => 'Mirrors';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get generalSection => 'General';

  @override
  String get advancedSection => 'Avanzado';

  @override
  String get backupSection => 'Copia de seguridad';

  @override
  String get updatesSection => 'Actualizaciones';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get archiveInstance => 'Instancia de archivo';

  @override
  String get mirrorsAndProviders => 'Espejos y fuentes';

  @override
  String get fontSizeTitle => 'Tamaño de letra';

  @override
  String scaleValue(String value) {
    return 'Escala: ${value}x';
  }

  @override
  String get preview => 'Vista previa';

  @override
  String get storageLocation => 'Ubicación de almacenamiento';

  @override
  String get manualDownloadButton => 'Botón de descarga manual';

  @override
  String get backgroundVerification => 'Verificar en segundo plano';

  @override
  String get backgroundVerificationHint =>
      'Resuelve comprobaciones DDoS de forma invisible. En algunos dispositivos falla: desactívalo para abrir la ventana visible al momento';

  @override
  String get backgroundVerificationFix =>
      'Si la verificación sigue fallando, desactiva \"Verificar en segundo plano\" en Ajustes: algunos dispositivos no pueden resolver comprobaciones de forma invisible.';

  @override
  String get showManualDownloadHint =>
      'Mostrar botón para iniciar descargas manualmente';

  @override
  String get donationKeyTitle => 'Clave de donación de Anna\'s Archive';

  @override
  String get enterKeyForFasterDownloads =>
      'Introduce la clave para descargas más rápidas';

  @override
  String get aboutOpenlib => 'Acerca de OpenlibExtended';

  @override
  String get redoOnboarding => 'Repetir la introducción';

  @override
  String get resetAppSetup => 'Restablecer la configuración y empezar de nuevo';

  @override
  String get exportLogs => 'Exportar registros';

  @override
  String get shareDiagnosticLogs =>
      'Compartir registros de diagnóstico (últimos 5 min)';

  @override
  String failedExportLogs(String error) {
    return 'Error al exportar registros: $error';
  }

  @override
  String get donationKeyDialog => 'Clave de donación';

  @override
  String get enterYourKey => 'Introduce tu clave';

  @override
  String get instanceChanged => 'Instancia cambiada correctamente';

  @override
  String rankingFailed(String error) {
    return 'Error al clasificar: $error';
  }

  @override
  String get autoRankInstances => 'Clasificar instancias automáticamente';

  @override
  String get sortBySpeedOnStartup =>
      'Ordenar automáticamente por velocidad al iniciar';

  @override
  String get rankInstancesNow => 'Clasificar instancias ahora';

  @override
  String onLatestVersion(String version) {
    return 'Ya tienes la última versión ($version)';
  }

  @override
  String failedCheckUpdates(String error) {
    return 'Error al buscar actualizaciones: $error';
  }

  @override
  String get includeBetaUpdates => 'Incluir versiones beta';

  @override
  String get getPreReleaseVersions => 'Obtener versiones preliminares';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get backupSaved => 'Copia de seguridad guardada';

  @override
  String failedExportBackup(String error) {
    return 'Error al exportar la copia: $error';
  }

  @override
  String get backupRestored => 'Copia de seguridad restaurada';

  @override
  String failedImportBackup(String error) {
    return 'Error al importar la copia: $error';
  }

  @override
  String get atLeastOneSource => 'Se necesita al menos una fuente de búsqueda';

  @override
  String rankedFastest(String name, String time) {
    return '¡Clasificado! Más rápida: $name (${time}ms)';
  }

  @override
  String get rankingComplete => 'Clasificación completada';

  @override
  String get providerSourceOriginal =>
      'Se busca al final - protegido por DDoS-Guard';

  @override
  String get providerLibgenCatalog =>
      'Descargas rápidas y directas - se busca primero';

  @override
  String get providerZlibMirrors =>
      'Los espejos rotan; puede requerir inicio de sesión';

  @override
  String get themeTitle => 'Tema';

  @override
  String get saveBackupTitle => 'Guardar copia de seguridad';

  @override
  String get pickBackupFile => 'Elegir un archivo de copia';

  @override
  String get notABackup =>
      'Ese archivo no es una copia de seguridad de OpenlibExtended';

  @override
  String get donationKeyHelper =>
      'Se usa para descargas más rápidas en Anna\'s Archive';

  @override
  String get mirrorsTestedRanked =>
      'Espejos probados y clasificados por velocidad';

  @override
  String testingFailed(String error) {
    return 'Error al probar: $error';
  }

  @override
  String get addCustomMirror => 'Añadir espejo personalizado';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameHint => 'p. ej., Mi espejo de LibGen';

  @override
  String get serviceLabel => 'Servicio';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get pleaseFillAllFields => 'Rellena todos los campos';

  @override
  String get enterValidUrl => 'Introduce una URL válida con http:// o https://';

  @override
  String get mirrorAdded => 'Espejo añadido correctamente';

  @override
  String get deleteMirror => 'Eliminar espejo';

  @override
  String deleteMirrorConfirm(String name) {
    return '¿Seguro que quieres eliminar «$name»?';
  }

  @override
  String get mirrorDeleted => 'Espejo eliminado';

  @override
  String get cannotDeleteDefaultMirrors =>
      'No se pueden eliminar los espejos predeterminados';

  @override
  String get manageMirrors => 'Gestionar espejos';

  @override
  String get noMirrorsAvailable => 'No hay espejos disponibles';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get addMirror => 'Añadir espejo';

  @override
  String get testRankMirrors => 'Probar y clasificar espejos por velocidad';

  @override
  String get unreachable => 'inaccesible';

  @override
  String get open => 'Abrir';

  @override
  String get unableToOpenFile => '¡No se pudo abrir el archivo!';

  @override
  String get openInSite => 'Abrir en el sitio';

  @override
  String get bookDeleted => '¡Libro eliminado!';

  @override
  String get deleteBook => 'Eliminar libro';

  @override
  String get deletePermanentWarning =>
      'Esto es permanente y no se puede deshacer';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get showBlockedContent => 'Mostrar contenido de la página bloqueada';

  @override
  String get verifyInBrowser => 'Verificar en el navegador';

  @override
  String get manualVerificationRequired => 'Verificación manual requerida';

  @override
  String get systemBrowser => 'Navegador del sistema';

  @override
  String get embeddedBrowser => 'Navegador integrado';

  @override
  String get unableToOpenVerification =>
      'No se pudo abrir la página de verificación - no hay URL disponible';

  @override
  String get blockedPageContent => 'Contenido de la página bloqueada';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get tryUsingVpn => 'Prueba a usar una VPN';

  @override
  String get trending => 'Tendencias';

  @override
  String get genres => 'Géneros';

  @override
  String get copiedBookPath => 'Ruta del libro copiada al portapapeles';

  @override
  String get pauseDownload => 'Pausar descarga';

  @override
  String get resumeDownload => 'Reanudar descarga';

  @override
  String get cancelDownload => 'Cancelar descarga';

  @override
  String get copiedBookLink => 'Enlace del libro copiado al portapapeles';

  @override
  String get noMirrors => '¡No hay espejos disponibles!';

  @override
  String get downloadStartedBackground => 'Descarga iniciada en segundo plano';

  @override
  String get bookDownloaded => '¡Libro descargado!';

  @override
  String get selectStorageToContinue =>
      'Selecciona una carpeta de almacenamiento para continuar';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get next => 'Siguiente';

  @override
  String get welcomeTitle => 'Bienvenido a OpenlibExtended';

  @override
  String get welcomeSubtitle =>
      'Tu puerta de entrada personal a un mundo de conocimiento. Vamos a configurarlo todo.';

  @override
  String get whereToStoreBooks => '¿Dónde guardamos tus libros?';

  @override
  String get noPathSelected => 'Ninguna ruta seleccionada';

  @override
  String get selectFolder => 'Elegir carpeta';

  @override
  String get storageScanNote =>
      'Solo buscaremos archivos de libros electrónicos compatibles en esta carpeta. No se escanean subcarpetas.';

  @override
  String get automaticUpdates => 'Actualizaciones automáticas';

  @override
  String get enableAutoUpdates => 'Activar actualizaciones automáticas';

  @override
  String get autoUpdatesFdroidNote =>
      'No se recomienda si instalaste desde F-Droid (F-Droid gestiona las actualizaciones).';

  @override
  String get enableBetaUpdatesOnboarding => 'Activar versiones beta';

  @override
  String get betaUpdatesNote =>
      'Recibir versiones preliminares (beta) cuando estén disponibles.';

  @override
  String get supportAnnasArchive => 'Apoyar a Anna\'s Archive';

  @override
  String get donationPitch =>
      'Donar a Anna\'s Archive permite descargas más rápidas y les ayuda a mantener el servicio para todos. Puedes introducir tu clave secreta abajo.';

  @override
  String get annasSecretKey => 'Clave secreta de Anna\'s Archive';

  @override
  String get supportThisApp => 'Apoyar esta aplicación';

  @override
  String get sponsorPitch =>
      'Si te gusta esta aplicación, considera apoyar su desarrollo. ¡Me ayuda a dedicar más tiempo a mejorarla!';

  @override
  String get sponsorOnGithub => 'Patrocinar en GitHub';

  @override
  String get stayUpdated => 'Mantente al día';

  @override
  String get notifyOnComplete => 'Recibir aviso cuando terminen las descargas.';

  @override
  String get chooseTheme => 'Elige un tema';

  @override
  String get lightThemeShort => 'Claro';

  @override
  String get darkThemeShort => 'Oscuro';

  @override
  String get verifyingAccess => 'Verificando acceso';

  @override
  String get done => 'Hecho';

  @override
  String get noVoiceAvailable => 'No hay voz disponible para leer en voz alta';

  @override
  String get close => 'Cerrar';

  @override
  String get reloadHealthData => 'Recargar datos de salud';

  @override
  String addServiceMirror(String title) {
    return 'Añadir un espejo de $title';
  }

  @override
  String get deleteMirrorTooltip => 'Eliminar espejo';

  @override
  String searchingOn(String source) {
    return 'Resultados de $source';
  }

  @override
  String get sourceLibgen => 'LibGen';

  @override
  String get sourceZlib => 'Z-Library';

  @override
  String get sourceAnnas => 'Anna\'s Archive';

  @override
  String downloadFrom(String source) {
    return 'Descargando desde $source';
  }

  @override
  String get tryingNextSource =>
      'Sin resultados aquí, probando la siguiente fuente…';

  @override
  String get slowMirrorsSkipped => 'Usando espejos más rápidos';

  @override
  String whatsNewTitle(String version) {
    return 'Novedades de $version';
  }

  @override
  String get whatsNewIntro =>
      'OpenlibExtended se ha actualizado. Esto es lo que cambió.';

  @override
  String get whatsNewTabFeatures => 'Nuevas funciones';

  @override
  String get whatsNewTabSources => 'Fuentes y mirrors';

  @override
  String get whatsNewProvidersHint =>
      'Esta versión añade nuevos proveedores de búsqueda y mirrors. Actualiza tu lista para eliminar los mirrors muertos y añadir los nuevos; los tres proveedores quedarán activados.';

  @override
  String get whatsNewUpdateInstances => 'Actualizar lista de mirrors';

  @override
  String get whatsNewInstancesUpdated => 'Lista de mirrors actualizada';

  @override
  String get whatsNewContinue => 'Continuar';

  @override
  String get whatsNewFeatureSpeed =>
      'Las descargas empiezan más rápido: sin sondear mirrors, servidores rápidos primero y las puertas IPFS lentas al final.';

  @override
  String get whatsNewFeatureSourceLabels =>
      'Cada resultado de búsqueda y cada descarga muestra ahora de qué catálogo proviene.';

  @override
  String get whatsNewFeatureCovers =>
      'Las portadas de LibGen que faltan se obtienen de la página de detalle del libro.';

  @override
  String get categoryClassicsTitle => 'Clásicos';

  @override
  String get categoryClassicsInfo =>
      'Obras literarias atemporales, a menudo admiradas por su mérito artístico y su importancia cultural.';

  @override
  String get categoryRomanceTitle => 'Romance';

  @override
  String get categoryRomanceInfo =>
      'Historias centradas en relaciones románticas, que exploran el amor, la pasión y los vínculos emocionales.';

  @override
  String get categoryFictionTitle => 'Ficción';

  @override
  String get categoryFictionInfo =>
      'Literatura narrativa creada a partir de la imaginación, no basada en hechos reales.';

  @override
  String get categoryYoungAdultTitle => 'Juvenil';

  @override
  String get categoryYoungAdultInfo =>
      'Libros dirigidos a lectores adolescentes, que abordan temas propios de la adolescencia.';

  @override
  String get categoryFantasyTitle => 'Fantasía';

  @override
  String get categoryFantasyInfo =>
      'Un género con elementos mágicos, criaturas míticas y mundos fantásticos.';

  @override
  String get categoryScienceFictionTitle => 'Ciencia ficción';

  @override
  String get categoryScienceFictionInfo =>
      'Literatura que explora conceptos futuristas, tecnología avanzada y exploración espacial.';

  @override
  String get categoryNonfictionTitle => 'No ficción';

  @override
  String get categoryNonfictionInfo =>
      'Obras basadas en información factual, como ensayos, biografías y documentales.';

  @override
  String get categoryChildrenTitle => 'Infantil';

  @override
  String get categoryChildrenInfo =>
      'Libros para lectores jóvenes, a menudo con ilustraciones y narraciones sencillas.';

  @override
  String get categoryHistoryTitle => 'Historia';

  @override
  String get categoryHistoryInfo =>
      'Literatura que examina acontecimientos pasados, culturas y figuras históricas relevantes.';

  @override
  String get categoryMysteryTitle => 'Misterio';

  @override
  String get categoryMysteryInfo =>
      'Historias de suspense, a menudo con crímenes o enigmas por resolver.';

  @override
  String get categoryCoversTitle => 'Portadas';

  @override
  String get categoryCoversInfo =>
      'El arte y diseño que representan visualmente un libro e influyen en el interés del lector.';

  @override
  String get categoryHorrorTitle => 'Terror';

  @override
  String get categoryHorrorInfo =>
      'Un género diseñado para provocar miedo, angustia o terror mediante una narración de suspense.';

  @override
  String get categoryHistoricalFictionTitle => 'Novela histórica';

  @override
  String get categoryHistoricalFictionInfo =>
      'Novelas ambientadas en un periodo histórico concreto, que mezclan hechos reales con personajes ficticios.';

  @override
  String get categoryBestTitle => 'Mejores';

  @override
  String get categoryBestInfo =>
      'Libros aclamados por la crítica o populares, normalmente clasificados por rankings o premios.';

  @override
  String get categoryTitlesTitle => 'Títulos';

  @override
  String get categoryTitlesInfo =>
      'Los nombres de los libros, que a menudo reflejan sus temas o contenidos.';

  @override
  String get categoryMiddleGradeTitle => 'Secundaria';

  @override
  String get categoryMiddleGradeInfo =>
      'Libros para lectores de 8 a 12 años, con temas y personajes apropiados para su edad.';

  @override
  String get categoryParanormalTitle => 'Paranormal';

  @override
  String get categoryParanormalInfo =>
      'Historias con elementos sobrenaturales, como fantasmas, vampiros y seres de otro mundo.';

  @override
  String get categoryLoveTitle => 'Amor';

  @override
  String get categoryLoveInfo =>
      'Un tema que explora las complejidades y matices del amor en distintas formas y relaciones.';

  @override
  String get categoryQueerTitle => 'Queer';

  @override
  String get categoryQueerInfo =>
      'Literatura que representa diversas orientaciones sexuales e identidades de género dentro del espectro LGBTQ+.';

  @override
  String get categoryHistoricalRomanceTitle => 'Romance histórico';

  @override
  String get categoryHistoricalRomanceInfo =>
      'Novelas que combinan tramas románticas con un trasfondo histórico.';

  @override
  String get categoryContemporaryTitle => 'Contemporáneo';

  @override
  String get categoryContemporaryInfo =>
      'Obras ambientadas en la época actual, a menudo sobre temas sociales vigentes y personajes cercanos.';

  @override
  String get categoryThrillerTitle => 'Suspense';

  @override
  String get categoryThrillerInfo =>
      'Un género de suspense centrado en la emoción, la tensión y los giros inesperados.';

  @override
  String get categoryWomenTitle => 'Mujeres';

  @override
  String get categoryWomenInfo =>
      'Literatura que explora las experiencias, perspectivas y el empoderamiento de las mujeres.';

  @override
  String get categoryBiographyTitle => 'Biografía';

  @override
  String get categoryBiographyInfo =>
      'Obras de no ficción que narran la vida de una persona, destacando sus logros y desafíos.';

  @override
  String get categoryLgbtqTitle => 'LGBTQ';

  @override
  String get categoryLgbtqInfo =>
      'Literatura inclusiva que representa las experiencias de la comunidad lesbiana, gay, bisexual, trans y queer.';

  @override
  String get categorySeriesTitle => 'Series';

  @override
  String get categorySeriesInfo =>
      'Una colección de libros relacionados con una trama o personajes comunes.';

  @override
  String get categoryTitleChallengeTitle => 'Reto de títulos';

  @override
  String get categoryTitleChallengeInfo =>
      'Retos o concursos que fomentan la creatividad en torno a los títulos de libros.';

  @override
  String get mirrorsTitle => 'Espejos';

  @override
  String get automaticMirrorOrder => 'Orden automático de espejos';

  @override
  String get mirrorOrderAutoHint =>
      'Primero la protección más sencilla y luego el más rápido. Recomendado.';

  @override
  String get mirrorSortPriorityTitle => 'Prioridad del orden automático';

  @override
  String get mirrorSortPriorityHint =>
      '«Más rápido» ordena primero por tu latencia medida; «Protección más simple» pone delante los espejos sin verificación del navegador.';

  @override
  String get mirrorSortPrioritySpeed => 'Más rápido';

  @override
  String get mirrorSortPriorityProtection => 'Protección más simple';

  @override
  String get mirrorOrderManualHint =>
      'Manual: usa las flechas para definir tu propio orden.';

  @override
  String get mirrorListUpToDate => 'La lista de espejos está actualizada';

  @override
  String mirrorListUpdated(int count) {
    return 'Lista de espejos actualizada: $count cambio(s)';
  }

  @override
  String mirrorRefreshFailed(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String get mirrorCatalogueUnreachable =>
      'No se pudo conectar con open-slum.org: no hay lista de espejos disponible';

  @override
  String get mirrorFooterNote =>
      'Las direcciones de los espejos y su estado provienen de open-slum.org y se actualizan automáticamente. Nunca se contacta con un espejo marcado como DOWN. La latencia local la mide este dispositivo al pulsar el botón de velocidad.';

  @override
  String get mirrorLatencyTestTooltip => 'Probar latencia local';

  @override
  String get mirrorLatencyHint =>
      'Los espejos locales aún no se han probado; la búsqueda puede ser más lenta. La prueba los ordena según tu latencia.';

  @override
  String get mirrorLatencyNeedsVerification => 'requiere verificación';

  @override
  String get mirrorLatencyGoTest => 'Probar';

  @override
  String get mirrorLatencyNotTested => 'Latencia local sin probar';

  @override
  String get mirrorLatencyTesting => 'Probando latencia local…';

  @override
  String get mirrorLatencyTimeout => 'Tiempo de espera local agotado';

  @override
  String mirrorLatencyLocal(String latency) {
    return 'Local $latency';
  }

  @override
  String get mirrorLatencyJustNow => 'ahora mismo';

  @override
  String get mirrorLatencyExpired => 'caducado';

  @override
  String mirrorLatencyDone(int reachable, int total, String fastest) {
    return 'Prueba local: $reachable/$total accesibles, más rápido $fastest';
  }

  @override
  String get mirrorLatencyAllTimedOut =>
      'Prueba local finalizada · ningún espejo respondió';

  @override
  String get mirrorLatencyNoTargets => 'No hay espejos habilitados para probar';

  @override
  String mirrorLatencyFailed(String error) {
    return 'La prueba local falló: $error';
  }

  @override
  String get noMirrorsReported => 'No se han notificado espejos';

  @override
  String get noMirrorsReportedHint =>
      'open-slum.org no tiene entrada (todavía) o no se pudo conectar.';

  @override
  String get couldNotLoadMirrors => 'No se pudieron cargar los espejos';

  @override
  String get moveUp => 'Subir';

  @override
  String get moveDown => 'Bajar';

  @override
  String get reportedDownNeverContacted =>
      'marcado como DOWN: nunca se contacta';

  @override
  String get mirrorServiceLibgenHint =>
      'Descargas rápidas sin desafíos cuando hay un espejo disponible';

  @override
  String get mirrorServiceZlibHint =>
      'Los espejos DiamWall se resuelven en segundo plano';

  @override
  String get mirrorServiceWelibHint =>
      'Búsqueda protegida por Cloudflare, páginas de libros abiertas';

  @override
  String get mirrorServiceAnnasHint => 'Lectura, detalles y descargas';

  @override
  String get mirrorStatusUp => 'Activo';

  @override
  String get mirrorStatusDegraded => 'Degradado';

  @override
  String get mirrorStatusProtected => 'Protegido';

  @override
  String get mirrorStatusDown => 'Inactivo';

  @override
  String get searchEmptyQuery => 'El campo de búsqueda está vacío';

  @override
  String get filterTypeLabel => 'Tipo';

  @override
  String get filterSortLabel => 'Ordenar por';

  @override
  String get filterFileTypeLabel => 'Tipo de archivo';

  @override
  String get filterYearLabel => 'Año';

  @override
  String get filterAll => 'Todos';

  @override
  String get typeAnyBooks => 'Cualquier libro';

  @override
  String get typeUnknownBooks => 'Libros desconocidos';

  @override
  String get typeFictionBooks => 'Libros de ficción';

  @override
  String get typeNonfictionBooks => 'Libros de no ficción';

  @override
  String get typeComicBooks => 'Cómics';

  @override
  String get typeMagazine => 'Revista';

  @override
  String get typeStandardsDocument => 'Documento de normas';

  @override
  String get typeJournalArticle => 'Artículo de revista';

  @override
  String get sortMostRelevant => 'Más relevantes';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortOldest => 'Más antiguos';

  @override
  String get sortLargest => 'Más grandes';

  @override
  String get sortSmallest => 'Más pequeños';

  @override
  String get yearBefore1980 => 'Antes de 1980';

  @override
  String get langEnglish => 'Inglés';

  @override
  String get langSpanish => 'Español';

  @override
  String get langFrench => 'Francés';

  @override
  String get langGerman => 'Alemán';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langPortuguese => 'Portugués';

  @override
  String get langRussian => 'Ruso';

  @override
  String get langChinese => 'Chino';

  @override
  String get langJapanese => 'Japonés';

  @override
  String get langKorean => 'Coreano';

  @override
  String get langArabic => 'Árabe';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langDutch => 'Neerlandés';

  @override
  String get langPolish => 'Polaco';

  @override
  String get langTurkish => 'Turco';

  @override
  String get langSwedish => 'Sueco';

  @override
  String get langIndonesian => 'Indonesio';

  @override
  String get langVietnamese => 'Vietnamita';

  @override
  String get langCzech => 'Checo';

  @override
  String get langGreek => 'Griego';

  @override
  String get langRomanian => 'Rumano';

  @override
  String get langHungarian => 'Húngaro';

  @override
  String get langUkrainian => 'Ucraniano';

  @override
  String get langHebrew => 'Hebreo';

  @override
  String get langThai => 'Tailandés';

  @override
  String get langPersian => 'Persa';

  @override
  String get langBengali => 'Bengalí';

  @override
  String get langFinnish => 'Finés';

  @override
  String get langNorwegian => 'Noruego';

  @override
  String get langDanish => 'Danés';

  @override
  String get downloadsTitle => 'Descargas';

  @override
  String get downloadQueued => 'En cola';

  @override
  String get downloadGettingMirrors => 'Obteniendo espejos…';

  @override
  String get downloadFindingMirror => 'Buscando espejo…';

  @override
  String get downloadDownloading => 'Descargando';

  @override
  String get downloadPaused => 'En pausa';

  @override
  String get downloadVerifying => 'Verificando el archivo…';

  @override
  String get downloadCancelled => 'Cancelado';

  @override
  String get downloadFailedGeneric => 'Error de descarga';

  @override
  String get verifyAction => 'Verificar';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get noDescriptionAvailable => 'No hay descripción disponible';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace.';

  @override
  String get manualDownloadAction => 'Descarga manual';

  @override
  String get fastDownloadStarted =>
      'Descarga rápida iniciada en segundo plano 🚀';

  @override
  String get welibNoDownloadLink =>
      'WeLib no ofreció un enlace de descarga para este libro.';

  @override
  String get zlibDailyLimit =>
      'Z-Library alcanzó su límite diario de descargas para tu red. Vuelve a intentarlo mañana o inicia sesión en Z-Library en el navegador de la aplicación.';

  @override
  String get zlibSignIn =>
      'Z-Library pide iniciar sesión antes de descargar este libro.';

  @override
  String get zlibNoDownloadLink =>
      'Esta página de Z-Library no ofreció ningún enlace de descarga. El libro puede estar restringido o eliminado.';

  @override
  String get welibRateLimit =>
      'WeLib está limitando las descargas ahora mismo. Espera unos minutos y vuelve a intentarlo.';

  @override
  String get welibBotCheck =>
      'WeLib no dejó que la aplicación superara su comprobación antirrobots. Vuelve a intentarlo o abre el libro en el navegador de la aplicación.';

  @override
  String get welibPageUnreadable =>
      'No se pudo leer la página de descarga de WeLib.';

  @override
  String get fileNotFoundDownloadFailed =>
      'Archivo no encontrado. Es posible que la descarga haya fallado.';

  @override
  String shareBookMessage(String title, String link) {
    return 'Descubre este increíble libro: «$title»\nMás información: $link';
  }

  @override
  String get webviewWindowTitle => 'Verificar acceso - OpenlibExtended';

  @override
  String get webviewBrowserOpen => 'La ventana del navegador está abierta';

  @override
  String get webviewBrowserOpening => 'Abriendo la ventana del navegador…';

  @override
  String get webviewInstructions =>
      '1. Resuelve el CAPTCHA en la ventana del navegador\n2. Espera a que la página cargue por completo\n3. Pulsa «Listo» arriba para continuar';

  @override
  String get webviewPreparingDownload => 'Preparando la descarga…';

  @override
  String get webviewPreparingHint =>
      'Espera mientras verificamos el acceso y obtenemos los enlaces de descarga';

  @override
  String get changeStorageHint => 'Cambiar dónde se guardan los libros';

  @override
  String versionWithBuild(String version, String build) {
    return 'Versión $version+$build';
  }

  @override
  String get backupShareText => 'Copia de seguridad de OpenlibExtended';

  @override
  String get exportBackupTitle => 'Exportar copia de seguridad';

  @override
  String get exportBackupSubtitle =>
      'Guarda ajustes, libros e instancias en un archivo JSON';

  @override
  String get importBackupTitle => 'Importar copia de seguridad';

  @override
  String get importBackupSubtitle =>
      'Restaurar desde un archivo de copia de seguridad (reemplaza los datos actuales)';

  @override
  String get providerWelibCatalog =>
      'Búsqueda protegida por Cloudflare y páginas de libros abiertas';

  @override
  String get errorWhatToDo => 'Qué hacer';

  @override
  String get errorVpnDescription =>
      'Una VPN puede ayudar a eludir bloqueos regionales y acceder al contenido.';

  @override
  String get errorVerificationPrompt =>
      'El sitio te pide que confirmes que eres humano. Abriremos una ventana del navegador para completar la verificación.';

  @override
  String get errorVerificationReturn =>
      'Cuando termines la verificación, vuelve a la app y pulsa «Reintentar».';

  @override
  String get errorNoContent => 'No hay contenido disponible';

  @override
  String get networkErrorNoInternetTitle => 'Sin conexión a Internet';

  @override
  String get networkErrorNoInternetSolution =>
      'Comprueba tu conexión a Internet. Asegúrate de que el Wi-Fi o los datos móviles estén activados.';

  @override
  String get networkErrorCloudflareTitle =>
      'Acceso bloqueado por la protección DDoS';

  @override
  String get networkErrorCloudflareSolution =>
      'Este sitio está protegido y bloquea la app. Prueba una VPN, cambia el DNS a 1.1.1.1 u 8.8.8.8, o verifica en el navegador.';

  @override
  String get networkErrorServerUnavailableTitle =>
      'Servidor temporalmente no disponible';

  @override
  String get networkErrorServerUnavailableSolution =>
      'El servidor tiene problemas. Inténtalo de nuevo en unos minutos o elige otro espejo en Ajustes.';

  @override
  String get networkErrorTimeoutTitle => 'Se agotó el tiempo de espera';

  @override
  String get networkErrorTimeoutSolution =>
      'El servidor tarda demasiado en responder. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get networkErrorForbiddenTitle => 'Acceso denegado';

  @override
  String get networkErrorForbiddenSolution =>
      'No tienes permiso para acceder a este recurso. Prueba una VPN, cambia el DNS o usa otro espejo en Ajustes.';

  @override
  String get networkErrorRateLimitedTitle => 'Demasiadas solicitudes';

  @override
  String get networkErrorRateLimitedSolution =>
      'Se han enviado demasiadas solicitudes. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get networkErrorSslTitle => 'Error de conexión segura';

  @override
  String get networkErrorSslSolution =>
      'Tu red puede estar bloqueando las conexiones seguras. Prueba una VPN u otra red.';

  @override
  String get networkErrorDnsTitle => 'Servidor no encontrado';

  @override
  String get networkErrorDnsSolution =>
      'No se pudo llegar al sitio. Tu proveedor puede estar bloqueándolo. Prueba una VPN o cambia el DNS a 1.1.1.1 / 8.8.8.8.';

  @override
  String get networkErrorParseTitle =>
      'No se pudieron leer los datos de la fuente';

  @override
  String get networkErrorParseSolution =>
      'La fuente devolvió una página que la aplicación no pudo leer. Cambia de fuente o de espejo e inténtalo de nuevo. Si el problema continúa, abre el diagnóstico y comparte los registros.';

  @override
  String get networkErrorStorageTitle => 'Error en el almacenamiento local';

  @override
  String get networkErrorStorageSolution =>
      'Comprueba el espacio libre y los permisos de almacenamiento y vuelve a intentarlo. Si el problema continúa, abre el diagnóstico y comparte los registros.';

  @override
  String get networkErrorUnknownTitle => 'Algo salió mal';

  @override
  String get networkErrorUnknownSolution =>
      'Inténtalo de nuevo. Si el problema continúa, abre el diagnóstico y comparte los registros.';

  @override
  String get errorDiagnostics => 'Diagnóstico';

  @override
  String get errorCopyDiagnostics => 'Copiar diagnóstico';

  @override
  String errorLocation(String location) {
    return 'Ubicación: $location';
  }

  @override
  String get errorStackTrace => 'Pila de llamadas';

  @override
  String get errorEnvironment => 'Entorno';

  @override
  String get updatePermissionTitle => 'Permiso necesario';

  @override
  String get updatePermissionBody =>
      'Para instalar actualizaciones, OpenlibExtended necesita permiso para instalar paquetes.\n\nEsto permite que la app instale automáticamente nuevas versiones con correcciones y funciones nuevas.\n\nSe te llevará a Ajustes para activar este permiso.';

  @override
  String get updateOpenSettings => 'Abrir ajustes';

  @override
  String get updateDebugBuildWarning =>
      'Compilación de depuración detectada: la actualización puede fallar con «Aplicación no instalada» por una firma distinta. Desinstala primero esta app.';

  @override
  String get updateOpeningInstaller =>
      'Abriendo el instalador… Si no ocurre nada, la instalación ha fallado.';

  @override
  String get updateManualInstall => 'Instalación manual';

  @override
  String get updateInstallationIssueTitle => 'Problema de instalación';

  @override
  String get updateInstallationIssueBody =>
      'El instalador automático no pudo abrir el APK. Esto puede ocurrir en algunas versiones de Android.\n\nPuedes instalarlo manualmente con una de estas opciones:';

  @override
  String updateFileLabel(String file) {
    return 'Archivo: $file';
  }

  @override
  String get updateInstallationFailed => 'Error de instalación';

  @override
  String get updateMethodsTried => 'Métodos probados:';

  @override
  String get updateErrorsEncountered => 'Errores encontrados:';

  @override
  String updateMethodNumber(int number) {
    return 'Método $number';
  }

  @override
  String get updateDownloadViaBrowser => 'Descargar desde el navegador';

  @override
  String get updateInstallationErrorTitle => 'Error de instalación';

  @override
  String get updateOk => 'OK';

  @override
  String get updateTryManualInstall => 'Probar instalación manual';

  @override
  String updateInstallFailed(String error) {
    return 'No se pudo instalar la actualización: $error';
  }

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String updateVersionAvailable(String version) {
    return '¡La versión $version está disponible!';
  }

  @override
  String get updatePreRelease => 'Prelanzamiento';

  @override
  String get updateWhatsNew => 'Novedades:';

  @override
  String get updateLater => 'Más tarde';

  @override
  String get updateDownloadAndInstall => 'Descargar e instalar';

  @override
  String get updateDownloadFromGithub => 'Descargar desde GitHub';

  @override
  String get updateViewOnGithub => 'Ver en GitHub';

  @override
  String get updateDownloading => 'Descargando actualización';

  @override
  String get updateDownloadComplete => 'Descarga completada';

  @override
  String updateVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get updateOpeningInstallerShort => 'Abriendo el instalador…';

  @override
  String get updateConnecting => 'Conectando…';

  @override
  String get updateFileNotFound => 'No se encontró el archivo descargado';

  @override
  String updateFileCorrupted(String size) {
    return 'El archivo descargado parece estar dañado (solo $size)';
  }

  @override
  String get updatePermissionDenied =>
      'Se denegó el permiso para instalar apps. Aún puedes instalar manualmente.';

  @override
  String get updateMayHaveFailedSilently => 'Puede haber fallado sin aviso';

  @override
  String get updateMethodOpenFile => 'Abrir archivo';

  @override
  String get updateMethodApkSideload => 'Carga lateral de APK';

  @override
  String get updateMethodPackageInstaller => 'Instalador de paquetes';

  @override
  String get networkErrorBookNotFoundTitle => 'Libro no encontrado';

  @override
  String get networkErrorBookNotFoundSolution =>
      'La página cargó pero no contenía datos del libro. El enlace puede estar desactualizado: busca por el título.';

  @override
  String get networkErrorBookDetailsUnavailableTitle =>
      'No se pudieron cargar los detalles del libro';

  @override
  String get networkErrorBookDetailsUnavailableSolution =>
      'No se pudo obtener la información del libro. Inténtalo de nuevo o usa otro espejo en Ajustes.';

  @override
  String get downloadNoWorkingMirrors =>
      '¡No hay espejos funcionales disponibles!';

  @override
  String get downloadAllMirrorsFailed => '¡Todos los espejos fallaron!';

  @override
  String get downloadErrorGettingMirrors => 'Error al obtener los espejos';

  @override
  String downloadCouldNotSave(String error) {
    return 'No se pudo guardar en la biblioteca: $error';
  }

  @override
  String get appLogsShareSubject => 'Registros de la app OpenlibExtended';

  @override
  String appLogsShareText(int minutes) {
    return 'Registros de la app OpenlibExtended de los últimos $minutes minutos';
  }

  @override
  String notificationAlreadyDownloading(String title) {
    return 'Ya se está descargando: $title';
  }

  @override
  String notificationQueued(String title) {
    return 'En cola: $title';
  }

  @override
  String get notificationStartingFastDownload => 'Iniciando descarga rápida…';

  @override
  String get notificationVerifyingFile => 'Verificando archivo…';

  @override
  String get notificationDownloadComplete => '¡Descarga completada!';

  @override
  String get notificationDownloadCompleteChecksumFailed =>
      'Descarga completada (suma de comprobación fallida)';

  @override
  String get notificationChannelDescription =>
      'Notificaciones de progreso de descargas de libros';

  @override
  String notificationDownloadingPercent(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String notificationFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get notificationDownloadTitle => 'Descarga';

  @override
  String get searchHintTitle => 'Encuentra tu próxima lectura';

  @override
  String get searchHintBody =>
      'Busca por título, autor o ISBN, o usa los filtros de arriba.';

  @override
  String get homeSearchHint => 'Buscar por título, autor o ISBN';

  @override
  String get trendingThisWeek => 'Tendencias de la semana';

  @override
  String get keepExploring => 'Sigue explorando';

  @override
  String get browseGenres => 'Explorar por género';

  @override
  String get settingsManage => 'Gestionar';

  @override
  String get searchSourcesTitle => 'Fuentes de búsqueda';

  @override
  String get searchSourceAuto => 'Todas';

  @override
  String get searchSourceAutoHint =>
      'Las cuatro fuentes se buscan a la vez y los resultados se combinan';

  @override
  String get searchSourceOnlyHint =>
      'Solo se muestran los resultados de esta fuente';

  @override
  String get bookDetailsTitle => 'Detalles del libro';

  @override
  String get fileInfoTitle => 'Información del archivo';

  @override
  String get formatLabel => 'Formato';

  @override
  String get publishedYearLabel => 'Publicado';

  @override
  String get fileSizeLabel => 'Tamaño del archivo';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get sourceLabel => 'Fuente';

  @override
  String get sourceAndDownload => 'Fuente y descarga';

  @override
  String get openAtSource => 'Abrir en la fuente';

  @override
  String get sourceWelib => 'WeLib';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get sourceStatusUntried => 'Sin probar';

  @override
  String get sourceStatusLocallyUnreachable =>
      'No accesible desde este dispositivo';

  @override
  String sourcesSkippedLocally(String sources) {
    return '$sources omitido(s): no accesible(s) desde este dispositivo.';
  }

  @override
  String get retryAnyway => 'Intentar igualmente';

  @override
  String get sourceStatusFailed => 'Error';

  @override
  String sourceResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros',
      one: '1 libro',
    );
    return '$_temp0';
  }

  @override
  String get searchingTitle => 'Buscando';

  @override
  String get searchingSourcesBody =>
      'Consulta las cuatro fuentes a la vez y luego combina y elimina duplicados.';

  @override
  String get loadMoreResults => 'Desliza para cargar más';

  @override
  String noResultsFor(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String get noResultsSourcesBody =>
      'Ninguna fuente ofreció resultados. Acorta la búsqueda o borra los filtros y vuelve a intentarlo.';

  @override
  String get modifySearch => 'Editar búsqueda';

  @override
  String get clearFiltersRetry => 'Borrar filtros y reintentar';

  @override
  String get sourceSheetTitle => 'Cambiar fuente de búsqueda';

  @override
  String sourceSheetSubtitle(String query) {
    return 'Ver resultados de «$query» en la fuente elegida.';
  }

  @override
  String get sourceAutoRecommended => 'Todas las fuentes (combinadas)';

  @override
  String get sourceSheetNote =>
      'Solo se aplica a esta búsqueda. Tu fuente predeterminada no cambia.';

  @override
  String get recentSearchesTitle => 'Búsquedas recientes';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get searchSuggestionsTitle => 'Sugerencias de búsqueda';

  @override
  String get searchSuggestionsLive => 'En vivo';

  @override
  String get searchRecentHint =>
      'Retoma una búsqueda reciente o empieza con otra palabra.';

  @override
  String searchInAllSources(String query) {
    return 'Buscar «$query» en todas las fuentes';
  }

  @override
  String searchInSource(String query, String source) {
    return 'Buscar «$query» en $source';
  }

  @override
  String searchAutoScope(int count) {
    return 'Buscando en $count fuentes a la vez';
  }

  @override
  String searchSourceOnlyScope(String source) {
    return 'Solo $source';
  }

  @override
  String removeRecentSearch(String query) {
    return 'Eliminar «$query»';
  }

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get searchSupportHint =>
      'Busca por título, autor, ISBN o MD5. Las cuatro fuentes se consultan en paralelo.';

  @override
  String get tryThese => 'Prueba con esto';

  @override
  String get filtersAndAdvanced => 'Filtros y búsqueda avanzada';

  @override
  String get resultsAutoMerged => 'Resultados combinados automáticamente';

  @override
  String get searchAdvancedHint =>
      '¿Quieres limitar por autor, editorial, año, idioma o formato? Cambia a la búsqueda avanzada.';

  @override
  String get searchApply => 'Aplicar y buscar';

  @override
  String get resetFilters => 'Restablecer';

  @override
  String get anyValue => 'Cualquiera';

  @override
  String get advancedFilterNote =>
      'Los filtros avanzados solo se aplican a esta búsqueda; la fuente predeterminada no cambia.';

  @override
  String get filterRelevance => 'Relevancia';

  @override
  String get searchAllSourcesLabel => 'Todas las fuentes';

  @override
  String get sourceMarkAll => 'TODO';

  @override
  String get sourceAnnasShort => 'Anna\'s';

  @override
  String get sourceZlibShort => 'Z-Lib';

  @override
  String sourceCount(int count) {
    return '$count fuentes';
  }

  @override
  String sourceStillSearching(String source) {
    return '$source sigue buscando; los resultados se añadirán automáticamente.';
  }

  @override
  String otherSources(String summary) {
    return 'Otras fuentes: $summary';
  }

  @override
  String sourcesResponded(int count) {
    return '$count fuentes respondieron';
  }

  @override
  String get sourceStatusTitle => 'Estado de las fuentes';

  @override
  String sourceStatusSummary(int ok, int failed) {
    return '$ok respondieron, $failed fallaron';
  }

  @override
  String sourceResponded(int count) {
    return 'Respondió · $count';
  }

  @override
  String get sourceTimedOut => 'Tiempo agotado';

  @override
  String get searchAgain => 'Buscar de nuevo';

  @override
  String sourceMirrorHint(String source) {
    return 'Desde el espejo $source; el MD5 se verifica tras la descarga.';
  }

  @override
  String downloadInProgressPercent(int percent) {
    return 'Descargando $percent % · toca para pausar';
  }

  @override
  String downloadPausedPercent(int percent) {
    return 'En pausa al $percent % · toca para reanudar';
  }

  @override
  String get downloadPreparing => 'Preparando la descarga…';

  @override
  String downloadWaitingSeconds(int seconds) {
    return 'Esperando ${seconds}s';
  }

  @override
  String get downloadFailedRetry => 'La descarga falló · toca para reintentar';

  @override
  String get downloadCompletedShort => 'Descargado';

  @override
  String get downloadThisBook => 'Descargar libro';

  @override
  String get navDownloads => 'Descargas';

  @override
  String get downloadCenterTitle => 'Centro de descargas';

  @override
  String downloadCenterSummary(int active, int paused, int queued) {
    return '$active activas · $paused en pausa · $queued en cola';
  }

  @override
  String get downloadCenterNoTasks => 'Aún no hay tareas de descarga';

  @override
  String get downloadCenterAllPause => 'Pausar todo';

  @override
  String get downloadCenterAllResume => 'Reanudar todo';

  @override
  String get downloadCenterAll => 'Todas';

  @override
  String get downloadCenterActive => 'Activas';

  @override
  String get downloadCenterCompleted => 'Completadas';

  @override
  String get downloadCenterFailed => 'Fallidas';

  @override
  String get downloadCenterInProgress => 'En curso';

  @override
  String get downloadCenterNeedsAttention => 'Requiere atención';

  @override
  String get downloadCenterOrderHint => 'En orden de cola';

  @override
  String get downloadCenterQueueMemory => 'Cola solo en memoria';

  @override
  String get downloadCenterRemoveNote =>
      'Al eliminar un registro también puedes borrar el archivo local; la cola solo existe en memoria y no se reanuda al cerrar.';

  @override
  String get rangeResume => 'Reanudación por Range';

  @override
  String storagePathMessage(String path) {
    return 'Los archivos se guardan en: $path';
  }

  @override
  String get downloadCenterRetryHint => 'Reintentar conserva lo descargado';

  @override
  String get downloadCenterOpenHint => 'Toca un título para ver los detalles';

  @override
  String get downloadCenterCurrentProgress => 'Progreso total';

  @override
  String get downloadCenterSpeed => 'Velocidad actual';

  @override
  String get downloadCenterRemaining => 'Restante';

  @override
  String downloadCenterTodayCount(int count) {
    return 'Completadas hoy: $count';
  }

  @override
  String downloadCenterEtaSeconds(int seconds) {
    return 'Quedan $seconds s';
  }

  @override
  String downloadCenterEtaMinutes(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String downloadCenterStorageSummary(int count, String size) {
    return 'Este mes: $count libros · $size';
  }

  @override
  String downloadCenterStorageLegend(String epub, String pdf) {
    return 'EPUB $epub · PDF $pdf';
  }

  @override
  String get downloadCenterRemoveRecord => 'Eliminar registro';

  @override
  String get downloadCenterRemoveRecordBody =>
      'Solo se elimina el registro; el archivo local permanece en la carpeta de descargas.';

  @override
  String get downloadCenterRemoveFile => 'Eliminar también el archivo';

  @override
  String get downloadCenterSelect => 'Seleccionar';

  @override
  String get downloadCenterSelectAll => 'Seleccionar todo';

  @override
  String get downloadCenterDeselectAll => 'Deseleccionar todo';

  @override
  String downloadCenterSelectedCount(int count) {
    return 'Seleccionados: $count';
  }

  @override
  String downloadCenterDeleteSelected(int count) {
    return 'Eliminar $count';
  }

  @override
  String get downloadCenterShowInFolder => 'Mostrar en la carpeta';

  @override
  String get downloadCenterBookDetails => 'Detalles del libro';

  @override
  String get share => 'Compartir';

  @override
  String get downloadCenterEmptyTitle => 'Aún no hay descargas';

  @override
  String get downloadCenterEmptyBody =>
      'Pulsa «Descargar» en la página de un libro y la tarea aparecerá aquí. Cuando termine, podrás abrirlo directamente.';

  @override
  String get downloadCenterGoSearch => 'Buscar libros';

  @override
  String get downloadCenterTip =>
      'Se admiten EPUB y PDF. Al reanudar una descarga se continúa desde el último byte.';

  @override
  String get downloadBook => 'Descargar';

  @override
  String get homeTitle => 'Descubrir';

  @override
  String get homeEyebrow => 'Descubrir libros';

  @override
  String get browseEyebrow => 'Explorar';

  @override
  String get searchEyebrow => 'Fuentes de búsqueda';

  @override
  String get downloadEyebrow => 'Almacenamiento local';

  @override
  String get settingsEyebrow => 'Preferencias';

  @override
  String get trendingSource => 'Lista de Goodreads';

  @override
  String categoryCount(int count) {
    return '$count categorías';
  }

  @override
  String get categorySearchHint => 'Buscar en categorías';

  @override
  String get categoryInfoHint =>
      'Las categorías proceden del catálogo SLUM y se pueden consultar sin conexión durante 24 horas.';

  @override
  String get searchSourcesIntro =>
      'Las cuatro fuentes se consultan en paralelo. Las fuentes desactivadas se omiten; las direcciones de los espejos provienen del catálogo SLUM.';

  @override
  String get sourceOn => 'Activada';

  @override
  String get sourceOff => 'Desactivada';

  @override
  String get mirrorsShort => 'Espejos';

  @override
  String mirrorNodeCount(int count) {
    return '$count nodos';
  }

  @override
  String get refreshMirrors => 'Actualizar espejos';

  @override
  String get sourceBehaviorSection => 'Comportamiento de las fuentes';

  @override
  String get displaySection => 'Pantalla';

  @override
  String get currentLanguage => 'Idioma actual';

  @override
  String get behaviorSection => 'Comportamiento';

  @override
  String get infoSection => 'Información';

  @override
  String get thanksSection => 'Agradecimientos';

  @override
  String get changelogTitle => 'Registro de cambios';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get projectHome => 'Página del proyecto';

  @override
  String get slumCatalogue => 'Catálogo de espejos SLUM';

  @override
  String get slumCatalogueSubtitle => 'open-slum.org';

  @override
  String get challengeSolverTitle => 'Solucionador de desafíos';

  @override
  String get challengeSolverSubtitle =>
      'Verificación manual en WebView como respaldo';

  @override
  String get aboutDisclaimer =>
      'Aquí no se aloja contenido de libros; solo búsqueda en espejos y descargas. Apoya a los autores.';

  @override
  String get maintenanceSection => 'Mantenimiento';

  @override
  String get languageCardHint => 'Idioma de la interfaz, se aplica al instante';

  @override
  String get themeCardHint => 'Seguir el sistema, o siempre claro u oscuro';

  @override
  String get fontSizeCardHint => 'Se aplica al texto de toda la app';

  @override
  String get fontPreviewSample =>
      'Una habitación sin libros es un cuerpo sin alma.';

  @override
  String get themeFollowSystemShort => 'Sistema';

  @override
  String get themeLightShort => 'Claro';

  @override
  String get themeDarkShort => 'Oscuro';

  @override
  String get sourceAllSearchedHint =>
      'Las cuatro fuentes se buscan a la vez. Toca una fuente para cambiar los resultados.';

  @override
  String get tapToExpandLanguage => 'Toca para elegir el idioma';

  @override
  String get tapToCollapseLanguage => 'Toca para contraer';

  @override
  String get sourceStatusSearching => 'Buscando…';

  @override
  String get verificationPageLoading =>
      'Cargando la página de verificación. La app continuará automáticamente.';

  @override
  String get verificationPageInstructions =>
      'Completa la verificación abajo; la app continuará automáticamente.';

  @override
  String get challengeNeedsVerification =>
      'Se necesita verificación manual: la búsqueda continúa al superarla';

  @override
  String get challengeNeedsVerificationRetry =>
      'Se necesita verificación manual: la próxima búsqueda reutilizará la página verificada.';

  @override
  String get challengeVerifyNow => 'Verificar ahora';

  @override
  String get languageNameEn => 'Inglés';

  @override
  String get languageNameEs => 'Español';

  @override
  String get languageNameFr => 'Francés';

  @override
  String get languageNameDe => 'Alemán';

  @override
  String get languageNameIt => 'Italiano';

  @override
  String get languageNamePt => 'Portugués';

  @override
  String get languageNameRu => 'Ruso';

  @override
  String get languageNameZh => 'Chino';

  @override
  String get languageNameJa => 'Japonés';

  @override
  String get languageNameKo => 'Coreano';

  @override
  String get languageNameAr => 'Árabe';

  @override
  String get languageNameHi => 'Hindi';

  @override
  String get languageNameMl => 'Malayalam';

  @override
  String get languageNameNl => 'Neerlandés';

  @override
  String get languageNamePl => 'Polaco';

  @override
  String get languageNameTr => 'Turco';

  @override
  String get languageNameSv => 'Sueco';

  @override
  String get languageNameId => 'Indonesio';

  @override
  String get languageNameVi => 'Vietnamita';

  @override
  String get languageNameCs => 'Checo';

  @override
  String get languageNameEl => 'Griego';

  @override
  String get languageNameRo => 'Rumano';

  @override
  String get languageNameHu => 'Húngaro';

  @override
  String get languageNameUk => 'Ucraniano';

  @override
  String get languageNameHe => 'Hebreo';

  @override
  String get languageNameTh => 'Tailandés';

  @override
  String get languageNameFa => 'Persa';

  @override
  String get languageNameBn => 'Bengalí';

  @override
  String get languageNameFi => 'Finés';

  @override
  String get languageNameNo => 'Noruego';

  @override
  String get languageNameDa => 'Danés';
}
