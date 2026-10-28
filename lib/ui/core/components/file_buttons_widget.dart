// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/data/models/file_name.dart';
import 'package:openlib/ui/core/components/detail_bottom_bar.dart';
import 'package:openlib/ui/core/components/delete_dialog_widget.dart';
import 'package:openlib/ui/core/open_book.dart';

class FileOpenAndDeleteButtons extends StatelessWidget {
  final String id;
  final String format;
  final String? fileName;

  /// Removes the record and its file; the dialog reports success itself,
  /// so the callback only has to refresh whatever list is on screen.
  final Future<void> Function(FileName) onDeleteFile;

  /// Runs after the delete was handed off - a library route pops itself,
  /// while the detail page stays and re-renders.
  final VoidCallback? onDelete;

  const FileOpenAndDeleteButtons(
      {super.key,
      required this.id,
      required this.format,
      this.fileName,
      required this.onDeleteFile,
      this.onDelete});

  // Get actual filename - uses fileName if provided, otherwise falls back to id.format
  String get actualFileName => fileName ?? "$id.$format";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DetailBottomBar(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => openBookExternally(
              fileName: actualFileName,
              format: format,
              context: context,
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(l10n.open),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: l10n.delete,
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return ShowDeleteDialog(
                    id: id,
                    format: format,
                    fileName: fileName,
                    onDeleteFile: onDeleteFile,
                    onDelete: onDelete,
                  );
                });
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
