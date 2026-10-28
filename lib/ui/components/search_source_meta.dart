import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/search_manager.dart';

/// Shown while the saved order (MyLibraryDb) is still loading; the user's
/// own order always wins over this.
const List<SearchProviderId> fallbackSearchSourceOrder =
    defaultSearchSourceOrder;

String sourceMark(SearchProviderId id) {
  return switch (id) {
    SearchProviderId.libgen => 'LG',
    SearchProviderId.zlibrary => 'ZL',
    SearchProviderId.welib => 'WL',
    SearchProviderId.annasArchive => 'AA',
  };
}

String sourceLabel(AppLocalizations l10n, SearchProviderId id) {
  return switch (id) {
    SearchProviderId.libgen => l10n.sourceLibgen,
    SearchProviderId.zlibrary => l10n.sourceZlib,
    SearchProviderId.welib => l10n.sourceWelib,
    SearchProviderId.annasArchive => l10n.sourceAnnas,
  };
}

String sourceShortLabel(AppLocalizations l10n, SearchProviderId id) {
  return switch (id) {
    SearchProviderId.libgen => l10n.sourceLibgen,
    SearchProviderId.zlibrary => l10n.sourceZlib,
    SearchProviderId.welib => l10n.sourceWelib,
    SearchProviderId.annasArchive => l10n.sourceAnnasShort,
  };
}
