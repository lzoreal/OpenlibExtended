// Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

// Dart imports:
import 'dart:io';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/platform_utils.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

/// Warm paper and emerald give the reading-focused UI a calmer,
/// more editorial feel than the previous violet baseline.
const Color _seedColor = Color(0xFF0F6B5C);

/// Selectable color palettes. Light/dark mode is chosen separately, so every
/// palette ships both schemes.
enum AppPalette {
  emerald('emerald'),
  indigo('indigo'),
  burgundy('burgundy'),
  amber('amber'),
  violet('violet'),
  graphite('graphite');

  const AppPalette(this.preferenceValue);

  /// Stored in the preferences table; never localize this.
  final String preferenceValue;

  static AppPalette fromPreference(Object? value) => values.firstWhere(
        (palette) => palette.preferenceValue == value,
        orElse: () => AppPalette.emerald,
      );
}

class _PaletteSpec {
  const _PaletteSpec(this.seed, this.lightPaper, this.darkPaper);

  final Color seed;
  final Color lightPaper;
  final Color darkPaper;
}

/// One entry per palette: the seed drives the MD3 roles, the papers keep
/// the editorial background. Emerald stays hand-tuned (see [_emeraldScheme]).
const Map<AppPalette, _PaletteSpec> _paletteSpecs = {
  AppPalette.emerald:
      _PaletteSpec(Color(0xFF0F6B5C), Color(0xFFF4EFE6), Color(0xFF151310)),
  AppPalette.indigo:
      _PaletteSpec(Color(0xFF2F4B7C), Color(0xFFF1F2F6), Color(0xFF12151B)),
  AppPalette.burgundy:
      _PaletteSpec(Color(0xFF8C2F39), Color(0xFFF8F0ED), Color(0xFF1A1211)),
  AppPalette.amber:
      _PaletteSpec(Color(0xFF9A5B13), Color(0xFFF8F1E3), Color(0xFF1A150E)),
  AppPalette.violet:
      _PaletteSpec(Color(0xFF5B4B8A), Color(0xFFF4F1F8), Color(0xFF15121B)),
  AppPalette.graphite:
      _PaletteSpec(Color(0xFF4A4A4A), Color(0xFFF5F3F0), Color(0xFF131313)),
};

const double _cardRadius = SwissRadius.card;
const double _fieldRadius = SwissRadius.field;
const double _dialogRadius = SwissRadius.sheet;

Color _paperBackground(AppPalette palette, Brightness brightness) {
  final spec = _paletteSpecs[palette]!;
  return brightness == Brightness.light ? spec.lightPaper : spec.darkPaper;
}

ColorScheme _emeraldScheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final isLight = brightness == Brightness.light;
  return base.copyWith(
    primary: isLight ? const Color(0xFF0F6B5C) : const Color(0xFF5FD0B8),
    onPrimary: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF06302A),
    primaryContainer:
        isLight ? const Color(0xFFD9EFE9) : const Color(0xFF123F37),
    onPrimaryContainer:
        isLight ? const Color(0xFF0A4C41) : const Color(0xFFA7EDDD),
    secondary: isLight ? const Color(0xFF4F6A62) : const Color(0xFFA8C6BC),
    onSecondary: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF23342E),
    secondaryContainer:
        isLight ? const Color(0xFFDCEBE6) : const Color(0xFF26403A),
    onSecondaryContainer:
        isLight ? const Color(0xFF173F38) : const Color(0xFFD7E8E2),
    tertiary: isLight ? const Color(0xFF96482A) : const Color(0xFFF0A184),
    onTertiary: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF52210A),
    tertiaryContainer:
        isLight ? const Color(0xFFFFE3D5) : const Color(0xFF4A2A1C),
    onTertiaryContainer:
        isLight ? const Color(0xFF4A1F0F) : const Color(0xFFFFE1D3),
    error: isLight ? const Color(0xFFB3261E) : const Color(0xFFFFB4AB),
    onError: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF690005),
    errorContainer: isLight ? const Color(0xFFFBE9E7) : const Color(0xFF49231F),
    onErrorContainer:
        isLight ? const Color(0xFF5F1410) : const Color(0xFFFFDAD6),
    surface: isLight ? const Color(0xFFFFFDF9) : const Color(0xFF1E1B17),
    onSurface: isLight ? const Color(0xFF211C17) : const Color(0xFFF3EBE1),
    surfaceContainerLowest:
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0F0D0B),
    surfaceContainerLow:
        isLight ? const Color(0xFFFAF5EC) : const Color(0xFF25211C),
    surfaceContainer:
        isLight ? const Color(0xFFF3ECE0) : const Color(0xFF2B2620),
    surfaceContainerHigh:
        isLight ? const Color(0xFFECE2D3) : const Color(0xFF332D26),
    surfaceContainerHighest:
        isLight ? const Color(0xFFEDE3D3) : const Color(0xFF3E372E),
    onSurfaceVariant:
        isLight ? const Color(0xFF665A4D) : const Color(0xFFB6AA9B),
    outline: isLight ? const Color(0xFFA99A89) : const Color(0xFF7C7266),
    outlineVariant: isLight ? const Color(0xFFE2D8CA) : const Color(0xFF3B352D),
    inverseSurface: isLight ? const Color(0xFF342F29) : const Color(0xFFF3EBE1),
    onInverseSurface:
        isLight ? const Color(0xFFF8F2EA) : const Color(0xFF211C17),
    inversePrimary: isLight ? const Color(0xFF6EE7D3) : const Color(0xFF0F6B5C),
  );
}

/// Seed-driven scheme with the palette's own paper ramp; emerald keeps its
/// hand-tuned roles so the default look does not change.
/// WCAG contrast ratio between two opaque colors.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Nudges [foreground] towards black (light backgrounds) or white (dark
/// ones) until it reads at [ratio] against [background]. Only colors that
/// already fail move, so the curated palettes keep their hue.
Color _ensureContrast(Color foreground, Color background,
    {double ratio = 4.5}) {
  if (_contrastRatio(foreground, background) >= ratio) return foreground;
  final darken = background.computeLuminance() > 0.5;
  var hsl = HSLColor.fromColor(foreground);
  var result = foreground;
  for (var i = 0; i < 50; i++) {
    hsl = hsl.withLightness(
      (hsl.lightness + (darken ? -0.02 : 0.02)).clamp(0.0, 1.0),
    );
    result = hsl.toColor();
    if (_contrastRatio(result, background) >= ratio) return result;
  }
  return result;
}

ColorScheme _paletteScheme(AppPalette palette, Brightness brightness) {
  if (palette == AppPalette.emerald) return _emeraldScheme(brightness);
  final spec = _paletteSpecs[palette]!;
  final base = ColorScheme.fromSeed(
    seedColor: spec.seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final light = brightness == Brightness.light;
  final paper = light ? spec.lightPaper : spec.darkPaper;
  Color mix(Color from, Color to, double amount) =>
      Color.lerp(from, to, amount)!;
  return base.copyWith(
    surface: light ? mix(paper, Colors.white, 0.62) : mix(paper, Colors.white, 0.07),
    surfaceContainerLowest: light ? mix(paper, Colors.white, 0.92) : mix(paper, Colors.black, 0.30),
    surfaceContainerLow: light ? mix(paper, Colors.white, 0.32) : mix(paper, Colors.white, 0.11),
    surfaceContainer: light ? paper : mix(paper, Colors.white, 0.14),
    surfaceContainerHigh: light ? mix(paper, Colors.black, 0.06) : mix(paper, Colors.white, 0.18),
    surfaceContainerHighest: light ? mix(paper, Colors.black, 0.10) : mix(paper, Colors.white, 0.23),
    onSurface: light ? mix(paper, Colors.black, 0.86) : mix(paper, Colors.white, 0.92),
    onSurfaceVariant: light ? mix(paper, Colors.black, 0.62) : mix(paper, Colors.white, 0.72),
    outline: light ? mix(paper, Colors.black, 0.42) : mix(paper, Colors.white, 0.45),
    outlineVariant: light ? mix(paper, Colors.black, 0.22) : mix(paper, Colors.white, 0.26),
    inverseSurface: light ? mix(paper, Colors.black, 0.86) : mix(paper, Colors.white, 0.92),
    onInverseSurface: light ? mix(paper, Colors.white, 0.9) : mix(paper, Colors.black, 0.85),
  ).copyWith(
    // `fromSeed(fidelity)` keeps the seed's own tone, so a darker seed made
    // the tonal container dark in light mode. The design language (emerald)
    // is a pale container with dark text in light mode and the reverse in
    // dark mode; normalize that here.
    primaryContainer:
        light ? mix(base.primary, paper, 0.85) : mix(base.primary, paper, 0.80),
    onPrimaryContainer: _ensureContrast(
        light
            ? mix(base.primary, Colors.black, 0.45)
            : mix(base.primary, Colors.white, 0.60),
        light ? mix(base.primary, paper, 0.85) : mix(base.primary, paper, 0.80)),
    // Accent text (eyebrows, links, section labels) sits directly on the
    // paper; a seed that is too light there would be hard to read.
    primary: _ensureContrast(
        base.primary, light ? mix(paper, Colors.white, 0.62) : mix(paper, Colors.white, 0.07)),
    secondary: _ensureContrast(base.secondary, paper),
    tertiary: _ensureContrast(base.tertiary, paper),
    error: _ensureContrast(base.error, paper),
  );
}

/// The palette exposed for previews (theme picker swatches) so previews
/// always match the real theme instead of duplicating hex values.
ColorScheme openlibColorScheme(Brightness brightness,
        [AppPalette palette = AppPalette.emerald]) =>
    _paletteScheme(palette, brightness);

ThemeData _buildTheme(
    ColorScheme scheme,
    Brightness brightness,
    Color background,
  ) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Windows resolves missing CJK glyphs to a fallback face whose weight no
    // longer matches the Latin run, so one line renders part bold, part thin.
    // YaHei UI covers both scripts with one weight mapping.
    fontFamily: PlatformUtils.isWindows ? 'Microsoft YaHei UI' : null,
    fontFamilyFallback: const [
      'Microsoft YaHei UI',
      'Microsoft YaHei',
      'PingFang SC',
      'Noto Sans CJK SC',
      'Source Han Sans SC',
    ],
  );

  final textTheme = base.textTheme
      .apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      )
      .copyWith(
        displayLarge: swissText(
          size: SwissType.display,
          line: SwissType.displayLine,
          weight: FontWeight.w800,
        ).copyWith(color: scheme.onSurface),
        displayMedium: SwissText.headline.copyWith(color: scheme.onSurface),
        headlineMedium: SwissText.title.copyWith(color: scheme.onSurface),
        headlineSmall: SwissText.headline.copyWith(color: scheme.onSurface),
        titleLarge: SwissText.title.copyWith(color: scheme.onSurface),
        titleMedium: SwissText.subtitle.copyWith(color: scheme.onSurface),
        titleSmall: SwissText.bodyStrong.copyWith(color: scheme.onSurface),
        bodyLarge:
            swissText(size: 16, line: 24).copyWith(color: scheme.onSurface),
        bodyMedium: SwissText.body.copyWith(color: scheme.onSurface),
        bodySmall: SwissText.caption.copyWith(color: scheme.onSurfaceVariant),
        labelLarge: SwissText.label.copyWith(color: scheme.onSurface),
        labelMedium: SwissText.badge.copyWith(color: scheme.onSurfaceVariant),
        labelSmall: SwissText.micro.copyWith(color: scheme.onSurfaceVariant),
      )
      .apply(
        fontFamily: base.textTheme.bodyMedium?.fontFamily,
        fontFamilyFallback: base.textTheme.bodyMedium?.fontFamilyFallback,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      );

  const buttonShape = StadiumBorder();
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: background,
    canvasColor: scheme.surface,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      toolbarHeight: SwissGrid.appBar,
      titleTextStyle: textTheme.headlineSmall,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: scheme.shadow.withValues(alpha: 0.05),
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      floatingLabelStyle: textTheme.bodySmall?.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: buttonShape,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surface,
      selectedColor: scheme.primaryContainer,
      disabledColor: scheme.surfaceContainerLow,
      labelStyle: SwissText.micro.copyWith(color: scheme.onSurfaceVariant),
      secondaryLabelStyle:
          SwissText.micro.copyWith(color: scheme.onPrimaryContainer),
      side: BorderSide(color: scheme.outlineVariant),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          SwissText.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant;
        }),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0.0),
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: WidgetStatePropertyAll(textTheme.bodyLarge),
      hintStyle: WidgetStatePropertyAll(
        textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: textTheme.titleSmall,
      subtitleTextStyle: textTheme.bodySmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogRadius),
      ),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodySmall,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: scheme.surfaceContainerHighest,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
      ),
      textStyle: textTheme.bodyMedium,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
      dividerColor: scheme.outlineVariant,
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: SwissGrid.navbar,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: scheme.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

final Map<String, ThemeData> _themeCache = {};

/// Theme for [palette] in [brightness]. Built once per pair: rebuilding a
/// Material theme for every settings change would reset scroll positions.
ThemeData buildAppTheme(AppPalette palette, Brightness brightness) {
  final key = '${palette.preferenceValue}:${brightness.name}';
  final cached = _themeCache[key];
  if (cached != null) return cached;
  final theme = _buildTheme(
    _paletteScheme(palette, brightness),
    brightness,
    _paperBackground(palette, brightness),
  );
  _themeCache[key] = theme;
  return theme;
}

final ThemeData lightTheme = buildAppTheme(AppPalette.emerald, Brightness.light);
final ThemeData darkTheme = buildAppTheme(AppPalette.emerald, Brightness.dark);

/// Reads the persisted theme mode, falling back to the legacy dark flag.
Future<ThemeMode> getInitialTheme() async {
  try {
    final dataBase = MyLibraryDb.instance;
    final themePref =
        await dataBase.getPreference('themeMode').catchError((e) => null);
    if (themePref != null && themePref is String) {
      if (themePref == 'light') return ThemeMode.light;
      if (themePref == 'dark') return ThemeMode.dark;
      return ThemeMode.system;
    } else {
      final legacyDark =
          await dataBase.getPreference('darkMode').catchError((e) => null);
      if (legacyDark != null) {
        return (legacyDark == 0) ? ThemeMode.light : ThemeMode.dark;
      }
    }
  } catch (e) {
    // Ignore: a broken preference must not block startup.
  }
  return ThemeMode.system;
}

/// Reads the persisted palette; emerald when nothing (or garbage) is stored.
Future<AppPalette> getInitialPalette() async {
  try {
    final value = await MyLibraryDb.instance
        .getPreference('themePalette')
        .catchError((e) => null);
    return AppPalette.fromPreference(value);
  } catch (_) {
    return AppPalette.emerald;
  }
}

/// Keeps the Android system bar in step with the active palette.
void updateSystemUi(ThemeMode mode, AppPalette palette) {
  if (!Platform.isAndroid) return;
  var isDark = mode == ThemeMode.dark;
  if (mode == ThemeMode.system) {
    isDark = ui.PlatformDispatcher.instance.platformBrightness ==
        Brightness.dark;
  }
  final scheme = openlibColorScheme(
    isDark ? Brightness.dark : Brightness.light,
    palette,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: scheme.surface,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));
}
