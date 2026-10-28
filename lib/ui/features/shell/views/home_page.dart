import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/features/trending/views/categories_page.dart';
import 'package:openlib/ui/core/components/active_downloads_widget.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/page_header.dart';
import 'package:openlib/ui/core/components/pill_tabs.dart';
import 'package:openlib/ui/features/trending/views/trending_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  static const _pages = <Widget>[
    TrendingPage(),
    GenresPage(),
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _pages.length,
      vsync: this,
      initialIndex: ref.read(homePageSelectedIndexProvider),
    );
    _tabController.addListener(_syncMode);
    ref.listenManual<int>(homePageSelectedIndexProvider, (previous, next) {
      if (next != _tabController.index) {
        _tabController.animateTo(next);
      }
    });
  }

  void _syncMode() {
    final index = _tabController.index;
    if (ref.read(homePageSelectedIndexProvider) != index) {
      ref.read(homePageSelectedIndexProvider.notifier).state = index;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(homePageSelectedIndexProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ContentWidth(
        maxWidth: 900,
        child: Column(
          children: [
            PageHeader(
              eyebrow:
                  selectedIndex == 0 ? l10n.homeEyebrow : l10n.browseEyebrow,
              title: selectedIndex == 0 ? l10n.homeTitle : l10n.genres,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ActiveDownloadsWidget(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HomeSearchButton(
                hint: selectedIndex == 0
                    ? l10n.homeSearchHint
                    : l10n.categorySearchHint,
                showFilter: selectedIndex == 0,
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 1;
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
