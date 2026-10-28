// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/components/active_downloads_widget.dart';
import 'package:openlib/ui/core/components/page_header.dart';
import 'package:openlib/ui/core/components/pill_tabs.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/features/trending/views/categories_page.dart';
import 'package:openlib/ui/features/trending/views/trending_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onOpenSearch});

  /// The search shortcut used to flip the shell's tab index.
  final VoidCallback? onOpenSearch;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const _pages = <Widget>[
    TrendingPage(),
    GenresPage(),
  ];

  late final TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(_syncIndex);
  }

  void _syncIndex() {
    if (_tabController.index == _selectedIndex) return;
    setState(() => _selectedIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ContentWidth(
        maxWidth: 900,
        child: Column(
          children: [
            PageHeader(
              eyebrow:
                  _selectedIndex == 0 ? l10n.homeEyebrow : l10n.browseEyebrow,
              title: _selectedIndex == 0 ? l10n.homeTitle : l10n.genres,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ActiveDownloadsWidget(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HomeSearchButton(
                hint: _selectedIndex == 0
                    ? l10n.homeSearchHint
                    : l10n.categorySearchHint,
                showFilter: _selectedIndex == 0,
                onTap: () {
                  widget.onOpenSearch?.call();
                },
              ),
            ),
            PillTabs(
              controller: _tabController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              tabs: [
                Tab(text: l10n.trending),
                Tab(text: l10n.genres),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSearchButton extends StatelessWidget {
  const _HomeSearchButton({
    required this.hint,
    required this.showFilter,
    required this.onTap,
  });

  final String hint;
  final bool showFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          key: const ValueKey('home-search-field'),
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                if (showFilter)
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
