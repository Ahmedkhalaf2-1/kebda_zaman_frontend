import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifiers/menu_notifier.dart';
import '../notifiers/menu_offers_notifier.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_product_card.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

int _menuColumnCount(BuildContext context) {
  if (context.isDesktop) return 4;
  if (context.isTablet) return 3;
  return 2;
}

/// Responsive card extent, chosen so that a 70 % image block, a 2-line
/// KZ.itemTitle name (15 px × 1.3 leading = 39 dp for two lines), and the
/// price row all fit comfortably with 8 dp top / 6 dp bottom insets.
///
/// Verified at 360 dp (compact phone):
///   extent = 260 dp  →  imageH = 182 dp  →  info = 78 dp
///   content (78 − 14) = 64 dp  →  Expanded(name) = 64 − 4 − 20 = 40 dp ≥ 39 dp ✓
double _cardExtent(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 600) return 272.0; // tablet
  if (w >= 390) return 265.0; // large phone (390–599 dp)
  return 260.0; //              compact phone (360–389 dp)
}

/// A category and the (already-loaded) items that belong to it, built
/// locally from `MenuData` — no extra fetch, no repository mutation.
/// Categories with zero available items are dropped by [buildMenuSections]
/// rather than rendered as an empty section.
class MenuSection {
  final Category category;
  final List<MenuItem> items;

  const MenuSection({required this.category, required this.items});
}

/// Groups [data]'s flat item list under each category, preserving both the
/// backend's category order (`data.categories` order) and each item's
/// original order within its category (a stable filter over `data.items`,
/// never re-sorted). Categories with no items are omitted.
List<MenuSection> buildMenuSections(MenuData data) {
  final sections = <MenuSection>[];
  for (final category in data.categories) {
    final items = data.items
        .where((item) => item.categoryId == category.id)
        .toList();
    if (items.isEmpty) continue;
    sections.add(MenuSection(category: category, items: items));
  }
  return sections;
}

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  // Design tokens matching the KZ design system
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerHighestColor = Color(0xFFE3E2DF);

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  // Measures where the pinned search+category bar ends, so section-active
  // detection and tap-to-scroll both target the same visual boundary.
  final GlobalKey _stickyHeaderKey = GlobalKey();

  // One stable GlobalKey per category id for its section header (scroll
  // target) and its tab chip (kept visible in the horizontal bar) — created
  // once per id and reused across rebuilds so measurements stay valid.
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey> _tabKeys = {};

  // A ValueNotifier rather than a plain State field + setState(): changing
  // the active category (on every tap AND on every section the user
  // scrolls past) only needs the sticky header's chip highlight to update —
  // routing it through setState() on this whole State forced a full
  // MenuScreen.build() re-run (recomputing buildMenuSections() and
  // re-diffing every section's sliver tree) on each change, which is real,
  // avoidable work landing precisely while the user is mid-scroll. Only the
  // ValueListenableBuilder wrapping the sticky header listens to this.
  final ValueNotifier<String?> _selectedCategoryIdNotifier = ValueNotifier(
    null,
  );

  @override
  void dispose() {
    _selectedCategoryIdNotifier.dispose();
    super.dispose();
  }

  // Guards [_updateActiveSectionFromScroll] to run at most once per rendered
  // frame. ScrollUpdateNotification fires far more often than once per frame
  // during a drag/fling; without this, its RenderBox walk over every
  // category section ran on every single one of those notifications, which
  // is real, repeated CPU work competing with the scroll itself for the
  // same frame budget.
  bool _sectionUpdateScheduled = false;

  /// True while a programmatic (tap-triggered) scroll animation is in flight.
  /// Prevents the manual-scroll listener from fighting the animation by
  /// reassigning the active category mid-flight.
  ///
  /// Released only in the [_scrollToCategory] `finally` block — after the
  /// 350 ms [Scrollable.ensureVisible] Future resolves — so the guard lasts
  /// the full animation, not just one frame. A single [Scrollable.ensureVisible]
  /// call handles the vertical section scroll; no secondary animateTo is run.
  bool _isProgrammaticScroll = false;

  GlobalKey _sectionKeyFor(String categoryId) =>
      _sectionKeys.putIfAbsent(categoryId, () => GlobalKey());

  GlobalKey _tabKeyFor(String categoryId) =>
      _tabKeys.putIfAbsent(categoryId, () => GlobalKey());

  // [animate] is false when this is called from the passive scroll listener
  // (a new section became active purely because the user is dragging the
  // main list) — an animated 350ms chip-scroll competing with the user's
  // own in-progress drag on every section change is what actually reads as
  // "laggy": two animations fighting for the same frames. Tap-driven
  // navigation ([_scrollToCategory]) is a deliberate, standalone action, so
  // it keeps the smooth animated scroll.
  void _ensureTabVisible(String categoryId, {bool animate = true}) {
    final ctx = _tabKeys[categoryId]?.currentContext;
    if (ctx == null) return;

    // Use Scrollable.maybeOf to get ONLY the horizontal scrollable and call ensureVisible on its position.
    // Calling the static Scrollable.ensureVisible(ctx) bubbles up and incorrectly scrolls the vertical CustomScrollView!
    final scrollable = Scrollable.maybeOf(ctx);
    final renderObject = ctx.findRenderObject();
    if (scrollable != null && renderObject != null) {
      scrollable.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Programmatically scrolls the main list to the section for [categoryId].
  ///
  /// Only [Scrollable.ensureVisible] is used for the vertical scroll —
  /// there is no secondary animateTo call for the same target.
  ///
  /// [_isProgrammaticScroll] is set before the animation and released in
  /// `finally` so the scroll listener is suppressed for the entire 350 ms
  /// animation regardless of how fast the Future actually resolves.
  Future<void> _scrollToCategory(String categoryId) async {
    _selectedCategoryIdNotifier.value = categoryId;
    _ensureTabVisible(categoryId);

    final ctx = _sectionKeys[categoryId]?.currentContext;
    if (ctx == null) return;

    _isProgrammaticScroll = true;
    try {
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) _isProgrammaticScroll = false;
    }
  }

  /// Scans rendered sections top-to-bottom and sets the active category to
  /// the last one whose header has scrolled past the sticky bar's bottom
  /// edge.
  ///
  /// A 16 dp dead-zone at each section boundary prevents rapid category
  /// flicker when the user scrolls exactly on a boundary — small scroll
  /// jitter near the threshold no longer bounces the selection back and
  /// forth.
  void _updateActiveSectionFromScroll(List<MenuSection> sections) {
    if (_isProgrammaticScroll || sections.isEmpty || !mounted) return;

    final headerBox =
        _stickyHeaderKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerBox == null || !headerBox.attached) return;
    final thresholdY = headerBox
        .localToGlobal(Offset(0, headerBox.size.height))
        .dy;

    String? activeId;
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final box =
          _sectionKeys[section.category.id]?.currentContext?.findRenderObject()
              as RenderBox?;

      if (box == null || !box.attached) {
        // Unmounted sections are typically above the viewport when scrolling down.
        // We tentatively set them as active. If the next visible section is below
        // the threshold, it will break and leave this as the active section.
        activeId = section.category.id;
        continue;
      }

      final topY = box.localToGlobal(Offset.zero).dy;
      // 16 dp dead-zone prevents flicker near section boundaries.
      if (topY <= thresholdY + 16) {
        activeId = section.category.id;
      } else {
        // This section is below the threshold. If activeId is still null,
        // it means we are at the very top of the list, so default to this first section.
        activeId ??= section.category.id;
        break;
      }
    }

    // Only the highlight color changes here (a cheap AnimatedContainer
    // fade inside KZChip) — deliberately NOT calling _ensureTabVisible.
    // Forcing the horizontal chip strip to scroll/jump every time the
    // active section changes, while the user's finger is still actively
    // dragging the vertical list, produced a stutter (and, in a later
    // attempt at this, a feedback loop via nested ScrollNotifications that
    // made the bar briefly snap back to the previous category). The chip
    // bar now only auto-scrolls on a deliberate tap (_scrollToCategory);
    // while scrolling, it simply highlights whichever chip is already on
    // screen (or doesn't, if the active one has scrolled out).
    if (activeId != null && activeId != _selectedCategoryIdNotifier.value) {
      _selectedCategoryIdNotifier.value = activeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuNotifierProvider);
    final favoritesState = ref.watch(customerFavoritesProvider);
    final favorites = favoritesState.favoriteIds;

    return Scaffold(
      backgroundColor: MenuScreen.surfaceBg,
      body: menuAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MenuScreen.primaryColor),
          ),
        ),
        error: (e, st) => KZErrorState(
          message: 'home.failed_load'.tr(),
          retryLabel: 'home.retry'.tr(),
          onRetry: () => ref.invalidate(menuNotifierProvider),
        ),
        data: (data) {
          final columnCount = _menuColumnCount(context);
          final sections = buildMenuSections(data);
          final extent = _cardExtent(context);

          // Fallback only — never written into the notifier here (mutating
          // it mid-build could notify a still-attached listener from the
          // previous frame while this build is still in progress). The
          // notifier's actual value is only ever set from the tap/scroll
          // handlers above, converging to this same id the first time
          // either one runs.
          final defaultCategoryId = sections.isNotEmpty
              ? sections.first.category.id
              : null;

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // NotificationListener bubbles ScrollNotifications from ANY
              // descendant Scrollable, not just this CustomScrollView's own
              // — including the horizontal category chip list nested inside
              // the sticky header. Without the axis check, _ensureTabVisible
              // scrolling that chip bar fires its own notification here,
              // re-triggering this same handler against a horizontal scroll
              // event; recomputing the active section from that (rather
              // than the real vertical position) is what produced the
              // brief "snaps back to the previous category" glitch.
              if (notification is ScrollUpdateNotification &&
                  notification.metrics.axis == Axis.vertical &&
                  !_sectionUpdateScheduled) {
                _sectionUpdateScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _sectionUpdateScheduled = false;
                  _updateActiveSectionFromScroll(sections);
                });
              }
              return false;
            },
            child: CustomScrollView(
              // Realistic single-restaurant menus (a handful of categories,
              // tens of items) comfortably fit a few rows ahead/behind the
              // viewport, so tap-to-scroll's GlobalKey lookups still resolve
              // reliably without needing an offset-estimation fallback —
              // lowered from 3000 (12x Flutter's ~250 default), which forced
              // ~11-12 extra rows of cards (each with two Lottie widgets +
              // a network image) to build/layout/paint while fully
              // offscreen, the main source of the scroll jank.
              cacheExtent: 1000,
              slivers: [
                // ── 1. Compact Branded Header ──
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: MenuScreen.surfaceBg.withValues(alpha: 0.9),
                  elevation: 0,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  toolbarHeight: 64,
                  titleSpacing: 16,
                  title: Text(
                    'menu.title'.tr(),
                    style: KZ.pageTitle.copyWith(
                      color: MenuScreen.primaryColor,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    // Cart Button (with item-count badge) — matches home
                    // screen's top-right action exactly.
                    Consumer(
                      builder: (context, ref, child) {
                        final cartAsync = ref.watch(cartProvider);
                        final itemCount =
                            cartAsync.valueOrNull?.items.fold<int>(
                              0,
                              (sum, i) => sum + i.quantity,
                            ) ??
                            0;

                        return Semantics(
                          button: true,
                          label: 'nav.cart'.tr(),
                          child: InkWell(
                            onTap: () => context.push('/cart'),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: KZ.iconTapTargetMin,
                              height: KZ.iconTapTargetMin,
                              alignment: Alignment.center,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    color: MenuScreen.primaryColor,
                                    size: KZ.iconAction,
                                  ),
                                  if (itemCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -6,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: KZ.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 17,
                                          minHeight: 17,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$itemCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // ── 2. Sticky Search + Category Selector — the only part
                // that needs to rebuild when the active category changes,
                // via the ValueListenableBuilder rather than a screen-wide
                // setState (see _selectedCategoryIdNotifier's doc comment).
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedCategoryIdNotifier,
                  builder: (context, selectedCategoryId, _) {
                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyMenuHeaderDelegate(
                        headerKey: _stickyHeaderKey,
                        categories: sections.map((s) => s.category).toList(),
                        selectedCategoryId:
                            selectedCategoryId ?? defaultCategoryId,
                        onSelectCategory: _scrollToCategory,
                        tabKeyFor: _tabKeyFor,
                      ),
                    );
                  },
                ),

                // ── 3. Menu Offers banner carousel (supplementary — never
                //      blocks the Menu itself; collapses on empty/error) ──
                const SliverToBoxAdapter(child: _MenuOffersCarousel()),

                // ── 4. Sectioned Product Grid ──
                if (sections.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: KZEmptyState(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'menu.no_items'.tr(),
                      ),
                    ),
                  )
                else
                  for (final section in sections) ...[
                    SliverToBoxAdapter(
                      child: Container(
                        key: _sectionKeyFor(section.category.id),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          section.category.localizedName(
                            context.locale.languageCode,
                          ),
                          style: KZ.sectionTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SliverPadding(
                      // 14 dp outer padding gives cards more breathing room
                      // than the previous 16 dp, while the 14 dp cross/main
                      // spacing keeps the two-column grid from feeling cramped.
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent: extent,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = section.items[index];
                          final isFav = favorites.contains(item.id);
                          return Consumer(
                            builder: (context, ref, child) {
                              return ProductGridCard(
                                item: item,
                                isFavorite: isFav,
                                onTap: () =>
                                    context.push('/menu/item/${item.id}'),
                                onAdd: () => _handleMenuAdd(context, ref, item),
                                onToggleFavorite: () async {
                                  final success = await ref
                                      .read(customerFavoritesProvider.notifier)
                                      .toggleFavorite(item.id);
                                  if (!success && context.mounted) {
                                    final err = ref
                                        .read(customerFavoritesProvider)
                                        .errorMessage;
                                    if (err != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(err),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          );
                        }, childCount: section.items.length),
                      ),
                    ),
                  ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sticky header: search bar + category tabs, pinned together ──

class _StickyMenuHeaderDelegate extends SliverPersistentHeaderDelegate {
  final GlobalKey headerKey;
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelectCategory;
  final GlobalKey Function(String categoryId) tabKeyFor;

  _StickyMenuHeaderDelegate({
    required this.headerKey,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.tabKeyFor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final languageCode = context.locale.languageCode;

    return Container(
      key: headerKey,
      color: MenuScreen.surfaceBg.withValues(alpha: 0.97),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Semantics(
              button: true,
              label: 'home.search_hint'.tr(),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(KZ.radiusLg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(KZ.radiusLg),
                  onTap: () => context.push('/search'),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: KZ.cardDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: MenuScreen.onSurfaceVariantColor,
                          size: KZ.iconControl,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'home.search_hint'.tr(),
                            style: KZ.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategoryId == cat.id;
                return KZChip(
                  key: tabKeyFor(cat.id),
                  label: cat.localizedName(languageCode),
                  selected: isSelected,
                  onTap: () => onSelectCategory(cat.id),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50 + 20 + 48 + 8;

  @override
  double get minExtent => 50 + 20 + 48 + 8;

  @override
  bool shouldRebuild(covariant _StickyMenuHeaderDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedCategoryId != selectedCategoryId;
  }
}

// ── Menu Offers banner carousel — real backend-managed banners linked to a
// Menu Item, replacing the previous static/mock "Weekly Special" strip. ──

/// Supplementary content: loads independently of `menuNotifierProvider` and
/// never shows a blocking spinner or error card of its own — while loading
/// it renders nothing (the section simply appears once data arrives), and
/// on either an empty list or a failed fetch it collapses entirely so the
/// Menu flows straight from the category tabs into the product grid.
class _MenuOffersCarousel extends ConsumerWidget {
  const _MenuOffersCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(customerMenuOffersProvider);

    return offersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (offers) {
        if (offers.isEmpty) return const SizedBox.shrink();
        return _MenuOffersPager(offers: offers);
      },
    );
  }
}

/// Owns the `PageView`/auto-advance lifecycle for the offers banner — split
/// out from [_MenuOffersCarousel] (a plain `ConsumerWidget`) so the
/// `PageController`/`Timer` live in a stable `State`, independent of how
/// often the surrounding provider rebuilds.
class _MenuOffersPager extends StatefulWidget {
  final List<MenuOffer> offers;

  const _MenuOffersPager({required this.offers});

  @override
  State<_MenuOffersPager> createState() => _MenuOffersPagerState();
}

class _MenuOffersPagerState extends State<_MenuOffersPager> {
  static const _autoAdvanceInterval = Duration(seconds: 5);
  static const _pageAnimationDuration = Duration(milliseconds: 400);
  static const double _bannerHeight = 160.0;
  static const double _horizontalPagePadding = 16.0;

  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  // True only while the user's finger is actively dragging the PageView —
  // set/cleared via the ScrollNotification below (not onPageChanged, which
  // also fires for the auto-advance's own animateToPage calls). The
  // auto-advance timer checks this before moving a page so it never fights
  // an in-progress manual swipe.
  bool _isUserDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoAdvanceIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _MenuOffersPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offers.length == widget.offers.length) return;

    // The offer list changed shape (e.g. a background re-fetch returned a
    // different count) — reconcile the current page back into range and
    // restart/stop auto-advance to match the new count, rather than leaving
    // a stale timer or an out-of-range page index.
    _autoAdvanceTimer?.cancel();
    if (widget.offers.isEmpty) {
      _currentPage = 0;
    } else if (_currentPage > widget.offers.length - 1) {
      _currentPage = widget.offers.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    }
    _startAutoAdvanceIfNeeded();
  }

  void _startAutoAdvanceIfNeeded() {
    if (widget.offers.length <= 1) return;
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceInterval, (_) {
      if (!mounted || _isUserDragging || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.offers.length;
      _pageController.animateToPage(
        next,
        duration: _pageAnimationDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Same normal horizontal page padding the rest of this screen already
    // uses (search bar, category chips, section headers) — the banner fills
    // exactly the remaining content width, no peek of a neighboring page.
    final cardWidth = screenWidth - _horizontalPagePadding * 2;
    final showDots = widget.offers.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('menu.offers_title'.tr(), style: KZ.sectionTitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPagePadding,
            ),
            child: SizedBox(
              height: _bannerHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _isUserDragging = true;
                  } else if (notification is ScrollEndNotification) {
                    _isUserDragging = false;
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.offers.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => _MenuOfferBanner(
                    offer: widget.offers[index],
                    width: cardWidth,
                    height: _bannerHeight,
                  ),
                ),
              ),
            ),
          ),
          if (showDots) ...[
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.offers.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentPage ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? KZ.primary
                            : KZ.outlineVariant,
                        borderRadius: BorderRadius.circular(KZ.radiusFull),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuOfferBanner extends StatelessWidget {
  final MenuOffer offer;
  final double width;
  final double height;

  const _MenuOfferBanner({
    required this.offer,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final title = offer.title?.trim();
    final description = offer.description?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasDescription = description != null && description.isNotEmpty;

    return Semantics(
      button: true,
      label: hasTitle ? title : 'menu.offers_title'.tr(),
      child: InkWell(
        // Authoritative link is menuItemId — never relies on the nested
        // menuItem summary being complete, and reuses the exact same
        // Product Details route a normal Menu Item card pushes. An
        // unavailable linked item still opens normally; availability is
        // enforced there, not here.
        onTap: () => context.push('/menu/item/${offer.menuItemId}'),
        borderRadius: BorderRadius.circular(KZ.radiusLg),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              KZFoodImage(
                imageUrl: offer.imageUrl,
                aspectRatio: width / height,
                borderRadius: BorderRadius.circular(KZ.radiusLg),
              ),
              if (hasTitle || hasDescription)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(KZ.radiusLg),
                      bottomRight: Radius.circular(KZ.radiusLg),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 24, 14, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasTitle)
                            Text(
                              title,
                              style: KZ.cardTitle.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (hasDescription) ...[
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: KZ.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared product grid card (kebda_zaman/core/widgets/kz_product_card.dart)
// used above — this is only the add-to-cart handler Menu's catalog grid
// needs, preserved exactly as it was on the old `_MenuProductCard`.
void _handleMenuAdd(BuildContext context, WidgetRef ref, MenuItem item) {
  if (!item.isAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('menu.item_unavailable'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final hasRequired = item.modifierGroups.any((g) => g.isRequired);
  if (hasRequired) {
    context.push('/menu/item/${item.id}');
  } else {
    final cartItem = CartItem(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: item.id,
      productName: item.name,
      productImage: item.imageUrl,
      basePrice: item.discountPrice ?? item.basePrice,
      quantity: 1,
      selectedOptions: {},
      extraQuantities: {},
      unitPrice: item.discountPrice ?? item.basePrice,
      lineTotal: item.discountPrice ?? item.basePrice,
    );
    ref.read(cartProvider.notifier).addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('home.added_to_cart'.tr(namedArgs: {'name': item.name})),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
