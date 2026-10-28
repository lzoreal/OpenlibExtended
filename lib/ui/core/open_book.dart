// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:open_file/open_file.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/book_format.dart';
import 'package:openlib/data/services/files.dart' show getFilePath;
import 'package:openlib/ui/core/components/snack_bar_widget.dart';

/// Opens a downloaded book with the system/third-party reader. The app
/// deliberately has no built-in reader any more.
Future<void> openBookExternally({
  required String fileName,
  required String format,
  required BuildContext context,
}) async {
  final l10n = AppLocalizations.of(context);
  String path;
  try {
    path = await getFilePath(fileName);
  } catch (_) {
    if (context.mounted) {
      showSnackBar(
          context: context, message: l10n.fileNotFoundDownloadFailed);
    }
    return;
  }

  final mime = bookFormatMimeType(format);
  try {
    await OpenFile.open(path, linuxByProcess: true, type: mime);
  } catch (_) {
    if (context.mounted) {
      showSnackBar(context: context, message: l10n.unableToOpenFile);
    }
  }
}
