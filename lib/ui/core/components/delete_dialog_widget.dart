// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/state/state.dart' show FileName;
import 'package:openlib/ui/core/components/snack_bar_widget.dart';

/// Confirms deletion, then hands the file identity to the caller: the page
/// owns the record/file removal so this dialog needs no state layer.
class ShowDeleteDialog extends StatelessWidget {
  final String id;
  final String format;
  final String? fileName;
  final Future<void> Function(FileName) onDeleteFile;

  /// Runs after the delete was handed off; a library route uses it to pop.
  final VoidCallback? onDelete;

  const ShowDeleteDialog(
      {super.key,
      required this.id,
      required this.format,
      this.fileName,
      required this.onDeleteFile,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.deleteBook),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      content: Text(l10n.deletePermanentWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () {
            // Pop and report first; the delete (and its membership
            // refresh) runs in the background like it always has.
            Navigator.of(context).pop();
            showSnackBar(context: context, message: l10n.bookDeleted);
            onDeleteFile(FileName(
              md5: id,
              format: format,
              fileName: fileName,
            ));
            onDelete?.call();
          },
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
