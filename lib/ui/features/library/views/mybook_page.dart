// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/share_book.dart';
import 'package:openlib/state/state.dart' show FileName;
import 'package:openlib/ui/core/components/book_info_widget.dart';
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/file_buttons_widget.dart';
import 'package:openlib/ui/core/components/share_icon.dart';
import 'package:openlib/ui/core/components/snack_bar_widget.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';

class BookPage extends StatelessWidget {
  const BookPage({
    super.key,
    required this.id,
    this.annaArchiveBaseUrl,
    required this.onDeleteFile,
  });

  final String id;
  final String? annaArchiveBaseUrl;
  final Future<void> Function(FileName) onDeleteFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookInfo = MyLibraryDb.instance.getId(id);

    return FutureBuilder<MyBook?>(
      future: bookInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final book = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.bookDetailsTitle),
              actions: [
                IconButton(
                  icon: ShareIcon(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    final outcome = await shareBook(
                        book.title, book.link, book.thumbnail ?? '',
                        fileName: book.fileName,
                        format: book.format,
                        message: l10n.shareBookMessage(book.title, book.link));
                    if (context.mounted && outcome == ShareOutcome.pathCopied) {
                      showSnackBar(
                          context: context, message: l10n.copiedBookPath);
                    }
                  },
                ),
              ],
            ),
            body: ContentWidth(
              maxWidth: 840,
              child: BookInfoWidget(
                data: book,
                source: sourceLabelForUrl(book.link, l10n),
                annaArchiveBaseUrl: annaArchiveBaseUrl,
              ),
            ),
            bottomNavigationBar: FileOpenAndDeleteButtons(
              id: book.id,
              format: book.format!,
              fileName: book.fileName,
              onDeleteFile: onDeleteFile,
              onDelete: () => Navigator.of(context).pop(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.bookDetailsTitle)),
            body: ContentWidth(
              maxWidth: 840,
              child: CustomErrorWidget(
                error: snapshot.error!,
                stackTrace: snapshot.stackTrace ?? StackTrace.empty,
                contextLabel: l10n.bookDetailsTitle,
                contextDetails: 'id=$id',
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.bookDetailsTitle)),
          body: const Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        );
      },
    );
  }
}
