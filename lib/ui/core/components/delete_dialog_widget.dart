// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/state/state.dart' show FileName, deleteFileFromMyLib;
import 'package:openlib/ui/core/components/snack_bar_widget.dart';

class ShowDeleteDialog extends ConsumerWidget {
  final String id;
  final String format;
  final String? fileName;
  final Function onDelete;

  const ShowDeleteDialog(
      {super.key,
      required this.id,
      required this.format,
      this.fileName,
      required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ref.read(deleteFileFromMyLib(
                FileName(md5: id, format: format, fileName: fileName)));
            Navigator.of(context).pop();
            showSnackBar(context: context, message: l10n.bookDeleted);
            onDelete();
          },
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
