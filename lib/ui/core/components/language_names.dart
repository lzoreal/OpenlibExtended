// Project imports:
import 'package:openlib/l10n/app_localizations.dart';

/// Turns the canonical code produced by `getLanguage` ("EN", "ZH", ...)
/// into the language's name in the current UI language.
String localizedLanguageName(AppLocalizations l10n, String code) =>
    switch (code.toUpperCase()) {
      'EN' => l10n.languageNameEn,
      'ES' => l10n.languageNameEs,
      'FR' => l10n.languageNameFr,
      'DE' => l10n.languageNameDe,
      'IT' => l10n.languageNameIt,
      'PT' => l10n.languageNamePt,
      'RU' => l10n.languageNameRu,
      'ZH' => l10n.languageNameZh,
      'JA' => l10n.languageNameJa,
      'KO' => l10n.languageNameKo,
      'AR' => l10n.languageNameAr,
      'HI' => l10n.languageNameHi,
      'ML' => l10n.languageNameMl,
      'NL' => l10n.languageNameNl,
      'PL' => l10n.languageNamePl,
      'TR' => l10n.languageNameTr,
      'SV' => l10n.languageNameSv,
      'ID' => l10n.languageNameId,
      'VI' => l10n.languageNameVi,
      'CS' => l10n.languageNameCs,
      'EL' => l10n.languageNameEl,
      'RO' => l10n.languageNameRo,
      'HU' => l10n.languageNameHu,
      'UK' => l10n.languageNameUk,
      'HE' => l10n.languageNameHe,
      'TH' => l10n.languageNameTh,
      'FA' => l10n.languageNameFa,
      'BN' => l10n.languageNameBn,
      'FI' => l10n.languageNameFi,
      'NO' => l10n.languageNameNo,
      'DA' => l10n.languageNameDa,
      _ => code,
    };
