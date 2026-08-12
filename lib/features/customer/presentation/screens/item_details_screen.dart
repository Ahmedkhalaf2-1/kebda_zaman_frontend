import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

import '../notifiers/item_details_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_add_button.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_heart_button.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_quantity_stepper.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

class ItemDetailsScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String? cartItemId;

  const ItemDetailsScreen({super.key, required this.itemId, this.cartItemId});

  // Design Tokens matching Stitch Wagyu Burger HTML design
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color primaryFixedColor = KZ.primaryFixed;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerHighestColor = Color(0xFFE3E2DF);
  static const Color outlineVariantColor = KZ.outlineVariant;
  static const Color outlineColor = KZ.outline;
  static const Color tertiaryContainerColor = KZ.tertiaryContainer;
  static const Color errorColor = KZ.error;

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  int quantity = 1;
  final Map<String, String> selectedSingleOptions = {};
  final Map<String, List<String>> selectedMultipleOptions = {};
  final Map<String, Map<String, int>> extraQuantities = {};
  final Set<String> removedIngredients = {};
  final TextEditingController notesController = TextEditingController();
  bool _isInitialized = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cartItemId != null) {
        final cart = ref.read(cartProvider).valueOrNull;
        if (cart != null) {
          try {
            final cartItem = cart.items.firstWhere(
              (item) => item.id == widget.cartItemId,
            );
            if (!mounted) return;
            setState(() {
              quantity = cartItem.quantity;
              notesController.text = cartItem.specialInstructions;

              cartItem.selectedOptions.forEach((groupId, optionIds) {
                if (optionIds.isNotEmpty) {
                  if (optionIds.length == 1) {
                    selectedSingleOptions[groupId] = optionIds.first;
                  }
                  selectedMultipleOptions[groupId] = List.from(optionIds);
                }
              });
            });
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  double _calculateGroupPrice(ModifierGroup group) {
    double price = 0;
    if (group.selectionType == 'SINGLE') {
      final selectedOptId = selectedSingleOptions[group.id];
      if (selectedOptId != null) {
        final opt = group.options.firstWhere((o) => o.id == selectedOptId);
        price += opt.priceModifier;
        for (final nested in opt.nestedModifierGroups) {
          price += _calculateGroupPrice(nested);
        }
      }
    } else if (group.selectionType == 'MULTIPLE') {
      final selectedIds = selectedMultipleOptions[group.id] ?? [];
      for (final optId in selectedIds) {
        final opt = group.options.firstWhere((o) => o.id == optId);
        price += opt.priceModifier;
        for (final nested in opt.nestedModifierGroups) {
          price += _calculateGroupPrice(nested);
        }
      }
    } else if (group.selectionType == 'QUANTITY') {
      final quantities = extraQuantities[group.id] ?? {};
      quantities.forEach((optId, qty) {
        final opt = group.options.firstWhere((o) => o.id == optId);
        price += (opt.priceModifier * qty);
        for (final nested in opt.nestedModifierGroups) {
          price += (_calculateGroupPrice(nested) * qty);
        }
      });
    }
    return price;
  }

  double _calculateUnitPrice(MenuItem item) {
    double currentBasePrice = item.discountPrice ?? item.basePrice;
    for (final group in item.modifierGroups) {
      currentBasePrice += _calculateGroupPrice(group);
    }
    return currentBasePrice;
  }

  List<ModifierGroup> _getMissingRequiredGroups(List<ModifierGroup> groups) {
    final List<ModifierGroup> missing = [];
    for (final group in groups) {
      bool isSelected = false;
      if (group.selectionType == 'SINGLE') {
        final optId = selectedSingleOptions[group.id];
        isSelected = optId != null;
        if (isSelected) {
          final opt = group.options.firstWhere((o) => o.id == optId);
          missing.addAll(_getMissingRequiredGroups(opt.nestedModifierGroups));
        }
      } else if (group.selectionType == 'MULTIPLE') {
        final selectedIds = selectedMultipleOptions[group.id] ?? [];
        isSelected = selectedIds.isNotEmpty;
        for (final optId in selectedIds) {
          final opt = group.options.firstWhere((o) => o.id == optId);
          missing.addAll(_getMissingRequiredGroups(opt.nestedModifierGroups));
        }
      } else if (group.selectionType == 'QUANTITY') {
        final quantities = extraQuantities[group.id] ?? {};
        isSelected = quantities.isNotEmpty;
        quantities.forEach((optId, qty) {
          if (qty > 0) {
            final opt = group.options.firstWhere((o) => o.id == optId);
            missing.addAll(_getMissingRequiredGroups(opt.nestedModifierGroups));
          }
        });
      }

      if (group.isRequired && !isSelected) {
        missing.add(group);
      }
    }
    return missing;
  }

  // Section Header matching Stitch typography & spacing. `dense` renders a
  // nested modifier group's own header — one step quieter than a top-level
  // group so typography + indentation together read as "belongs to the
  // option above", not a brand-new independent section.
  Widget _buildSectionHeader({
    required String title,
    bool isRequired = false,
    String? subtitle,
    bool dense = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10.0 : 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dense ? title : title.toUpperCase(),
              style: dense
                  ? KZ.labelLarge.copyWith(color: ItemDetailsScreen.onSurfaceColor)
                  : KZ.sectionTitle.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ItemDetailsScreen.primaryFixedColor,
                borderRadius: BorderRadius.circular(KZ.radiusSm),
              ),
              child: Text(
                'item_details.required_badge'.tr(),
                style: KZ.statusLabel.copyWith(
                  color: ItemDetailsScreen.primaryColor,
                ),
              ),
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                subtitle,
                style: KZ.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isOptionSelected(ModifierGroup group, ModifierOption opt) {
    switch (group.selectionType) {
      case 'SINGLE':
        return selectedSingleOptions[group.id] == opt.id;
      case 'MULTIPLE':
        return (selectedMultipleOptions[group.id] ?? const []).contains(opt.id);
      case 'QUANTITY':
        return (extraQuantities[group.id]?[opt.id] ?? 0) > 0;
      default:
        return false;
    }
  }

  // Renders a modifier group as one flat, lightly-bordered container with
  // divided rows instead of a stack of individually-shadowed cards — the
  // selected state uses a restrained primary tint + left accent bar rather
  // than a heavy border/shadow per option. `depth > 0` is a nested group,
  // rendered directly beneath its selected parent option and indented —
  // purely presentational; the selection/pricing/validation logic that
  // already recurses into `nestedModifierGroups` (`_calculateGroupPrice`,
  // `_getMissingRequiredGroups`) is completely untouched.
  Widget _buildModifierGroupSection(
    BuildContext context,
    ModifierGroup group, {
    int depth = 0,
  }) {
    final nestedChildren = <Widget>[];
    for (final opt in group.options) {
      if (_isOptionSelected(group, opt) && opt.nestedModifierGroups.isNotEmpty) {
        for (final nested in opt.nestedModifierGroups) {
          nestedChildren.add(const SizedBox(height: 16));
          nestedChildren.add(
            _buildModifierGroupSection(context, nested, depth: depth + 1),
          );
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 28.0, left: depth > 0 ? 20.0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: group.name,
            isRequired: group.isRequired,
            subtitle: group.selectionType == 'MULTIPLE'
                ? 'item_details.max_selections'.tr(
                    namedArgs: {'max': '${group.maxSelections}'},
                  )
                : null,
            dense: depth > 0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ItemDetailsScreen.outlineVariantColor),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < group.options.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: ItemDetailsScreen.outlineVariantColor
                            .withValues(alpha: 0.5),
                      ),
                    _buildOptionRow(context, group, group.options[i]),
                  ],
                ],
              ),
            ),
          ),
          ...nestedChildren,
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    ModifierGroup group,
    ModifierOption opt,
  ) {
    switch (group.selectionType) {
      case 'MULTIPLE':
        return _buildMultipleOptionRow(context, group, opt);
      case 'QUANTITY':
        return _buildQuantityOptionRow(context, group, opt);
      default:
        return _buildSingleOptionRow(context, group, opt);
    }
  }

  Widget _buildSingleOptionRow(
    BuildContext context,
    ModifierGroup group,
    ModifierOption opt,
  ) {
    final isSelected = selectedSingleOptions[group.id] == opt.id;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSingleOptions[group.id] = opt.id;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ItemDetailsScreen.primaryColor.withValues(alpha: 0.06)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? ItemDetailsScreen.primaryColor
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 20,
              color: isSelected
                  ? ItemDetailsScreen.primaryColor
                  : ItemDetailsScreen.outlineVariantColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opt.name,
                style: KZ.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? ItemDetailsScreen.primaryColor
                      : KZ.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+${formatCurrency(opt.priceModifier, locale: context.locale)}',
              style: KZ.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleOptionRow(
    BuildContext context,
    ModifierGroup group,
    ModifierOption opt,
  ) {
    final selectedList = selectedMultipleOptions[group.id] ?? [];
    final isSelected = selectedList.contains(opt.id);
    final groupMap = extraQuantities[group.id] ?? {};
    final optQty = groupMap[opt.id] ?? (isSelected ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? ItemDetailsScreen.primaryColor.withValues(alpha: 0.06)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected
                ? ItemDetailsScreen.primaryColor
                : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: isSelected,
              activeColor: ItemDetailsScreen.primaryColor,
              side: const BorderSide(
                color: ItemDetailsScreen.outlineColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (val) {
                setState(() {
                  final list = List<String>.from(
                    selectedMultipleOptions[group.id] ?? [],
                  );
                  if (val == true) {
                    if (list.length < group.maxSelections) {
                      list.add(opt.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'item_details.max_selections'.tr(
                              namedArgs: {'max': '${group.maxSelections}'},
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    list.remove(opt.id);
                  }
                  selectedMultipleOptions[group.id] = list;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  opt.name,
                  style: KZ.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? ItemDetailsScreen.primaryColor
                        : KZ.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${formatCurrency(opt.priceModifier, locale: context.locale)}',
                  style: KZ.bodySmall,
                ),
              ],
            ),
          ),
          // Stepper (- 1 +)
          if (isSelected) ...[
            const SizedBox(width: 8),
            KZQuantityStepper(
              quantity: optQty,
              minQuantity: 0,
              maxQuantity: group.maxSelections,
              onChanged: (newQty) {
                setState(() {
                  if (newQty < 1) {
                    final map = Map<String, int>.from(
                      extraQuantities[group.id] ?? {},
                    );
                    map.remove(opt.id);
                    extraQuantities[group.id] = map;
                    final list = List<String>.from(
                      selectedMultipleOptions[group.id] ?? [],
                    );
                    list.remove(opt.id);
                    selectedMultipleOptions[group.id] = list;
                  } else {
                    final map = Map<String, int>.from(
                      extraQuantities[group.id] ?? {},
                    );
                    map[opt.id] = newQty;
                    extraQuantities[group.id] = map;
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityOptionRow(
    BuildContext context,
    ModifierGroup group,
    ModifierOption opt,
  ) {
    final groupMap = extraQuantities[group.id] ?? {};
    final optQty = groupMap[opt.id] ?? 0;
    final isSelected = optQty > 0;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? ItemDetailsScreen.primaryColor.withValues(alpha: 0.06)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected
                ? ItemDetailsScreen.primaryColor
                : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  opt.name,
                  style: KZ.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? ItemDetailsScreen.primaryColor
                        : KZ.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${formatCurrency(opt.priceModifier, locale: context.locale)}',
                  style: KZ.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          KZQuantityStepper(
            quantity: optQty,
            minQuantity: 0,
            maxQuantity: group.maxSelections,
            onChanged: (newQty) {
              setState(() {
                final map = Map<String, int>.from(
                  extraQuantities[group.id] ?? {},
                );
                if (newQty <= 0) {
                  map.remove(opt.id);
                } else {
                  map[opt.id] = newQty;
                }
                extraQuantities[group.id] = map;
              });
            },
          ),
        ],
      ),
    );
  }

  // Quick-add for an "Often Ordered With" recommendation: mirrors the
  // existing simple-item add-to-cart path used on menu/home cards. Recs with
  // required variants/modifiers route to Product Details instead, since a
  // valid selection can't be inferred here.
  void _handleQuickAdd(BuildContext context, MenuItem rec) {
    final hasRequired = rec.modifierGroups.any((g) => g.isRequired);
    if (hasRequired) {
      context.push('/menu/item/${rec.id}');
      return;
    }

    final name = rec.localizedName(context.locale.languageCode);
    final cartItem = CartItem(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: rec.id,
      productName: name,
      productImage: rec.imageUrl,
      basePrice: rec.discountPrice ?? rec.basePrice,
      quantity: 1,
      selectedOptions: const {},
      extraQuantities: const {},
      unitPrice: rec.discountPrice ?? rec.basePrice,
      lineTotal: rec.discountPrice ?? rec.basePrice,
    );
    ref.read(cartProvider.notifier).addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('home.added_to_cart'.tr(namedArgs: {'name': name})),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // "Often Ordered With" — recommendation summaries embedded on the item
  // details response only. Each summary is a plain MenuItem (no variants/
  // addonGroups/nested oftenOrderedWith), so tapping one just opens a fresh
  // ItemDetailsScreen for that item's own id via the existing route — no
  // duplicate screen, no recursive fetch here.
  Widget _buildOftenOrderedWithSection(
    BuildContext context,
    List<MenuItem> recommendations,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: 'product_details.often_ordered_with'.tr()),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return _OftenOrderedWithCard(
                  item: rec,
                  onTap: () => context.push('/menu/item/${rec.id}'),
                  onAdd: () => _handleQuickAdd(context, rec),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailsProvider(widget.itemId));
    final favoritesState = ref.watch(customerFavoritesProvider);
    final isFav = favoritesState.favoriteIds.contains(widget.itemId);

    return itemAsync.when(
      loading: () => const Scaffold(
        backgroundColor: ItemDetailsScreen.surfaceBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ItemDetailsScreen.primaryColor,
            ),
          ),
        ),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: ItemDetailsScreen.surfaceBg,
        appBar: AppBar(title: Text('item_details.title'.tr())),
        body: KZErrorState(
          message: 'home.failed_load'.tr(),
          retryLabel: 'home.retry'.tr(),
          onRetry: () => ref.invalidate(itemDetailsProvider(widget.itemId)),
        ),
      ),
      data: (item) {
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                if (widget.cartItemId == null) {
                  for (final group in item.modifierGroups) {
                    if (group.selectionType == 'SINGLE') {
                      final defaultOpt =
                          group.options.where((o) => o.isDefault).firstOrNull ??
                          group.options.firstOrNull;
                      if (defaultOpt != null) {
                        selectedSingleOptions[group.id] = defaultOpt.id;
                      }
                    } else if (group.selectionType == 'MULTIPLE') {
                      final defaultOpts = group.options
                          .where((o) => o.isDefault)
                          .map((o) => o.id)
                          .toList();
                      if (defaultOpts.isNotEmpty) {
                        selectedMultipleOptions[group.id] = defaultOpts;
                      }
                    }
                  }
                }
                _isInitialized = true;
              });
            }
          });
        }

        final unitPrice = _calculateUnitPrice(item);
        final totalPrice = unitPrice * quantity;
        final standardIngredients = ['Onion', 'Pickles', 'Tomato', 'Lettuce'];

        return Scaffold(
          backgroundColor: ItemDetailsScreen.surfaceBg,
          body: ResponsiveContainer(
            child: Stack(
              children: [
                // 1. Top Hero Image — the product itself is the visual
                // focus; height trimmed from the original 340px so it no
                // longer dominates the screen, and the no-image/error
                // fallback is now the same neutral, icon-based placeholder
                // used everywhere else a product photo is missing (see
                // KZFoodImage) instead of a full-bleed brand-red block
                // repeating the product name a second time (the title right
                // below already shows it once).
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: item.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: ItemDetailsScreen
                                      .surfaceContainerHighestColor,
                                ),
                                errorWidget: (context, url, err) =>
                                    const _HeroImageFallback(),
                              )
                            : const _HeroImageFallback(),
                      ),
                      // Just enough of a top scrim for the back/favorite
                      // glass buttons to stay legible — the bottom of the
                      // hero is already covered by the rounded content
                      // sheet, so it no longer needs its own dark wash.
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.25),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.35],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable Content Sheet (starts at Y=300px — flush
                // with the bottom of the 300px hero, no overlap — so more of
                // the product photo stays visible above the sheet than the
                // original 40px-overlap version).
                Positioned.fill(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 300)),
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: ItemDetailsScreen.surfaceBg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                offset: Offset(0, -6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Information
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge (manually assigned; independent
                                    // of isFeatured/isBestSeller)
                                    if (item.badge != null) ...[
                                      MenuItemBadgeChip(badge: item.badge!),
                                      const SizedBox(height: 12),
                                    ],

                                    // Title
                                    Text(
                                      item.localizedName(
                                        context.locale.languageCode,
                                      ),
                                      style: KZ.display.copyWith(fontSize: 28),
                                    ),
                                    const SizedBox(height: 6),

                                    // Description
                                    Text(
                                      item.localizedDescription(
                                        context.locale.languageCode,
                                      ),
                                      style: KZ.bodyLarge.copyWith(height: 1.4),
                                    ),

                                    // Calories (secondary, absent when null)
                                    if (item.calories != null) ...[
                                      const SizedBox(height: 8),
                                      MenuItemCaloriesText(
                                        calories: item.calories!,
                                      ),
                                    ],

                                    // Current price (sale price when
                                    // discounted) + optional compare-at
                                    const SizedBox(height: 12),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          formatCurrency(
                                            item.discountPrice ??
                                                item.basePrice,
                                            locale: context.locale,
                                          ),
                                          style: KZ.priceLarge,
                                        ),
                                        if (item.discountPrice != null) ...[
                                          const SizedBox(width: 8),
                                          MenuItemComparePriceText(
                                            compareAtPrice: item.basePrice,
                                            style: KZ.bodySmall.copyWith(
                                              color: KZ.error,
                                            ),
                                          ),
                                        ],
                                        if (item.compareAtPrice != null &&
                                            item.compareAtPrice! >
                                                item.basePrice) ...[
                                          const SizedBox(width: 8),
                                          MenuItemComparePriceText(
                                            compareAtPrice:
                                                item.compareAtPrice!,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Modifier Groups (Size, Extras, etc.)
                              for (final group in item.modifierGroups)
                                _buildModifierGroupSection(context, group),

                              // Often Ordered With (recommendations; details
                              // response only — hidden entirely when empty)
                              if (item.oftenOrderedWith.isNotEmpty)
                                _buildOftenOrderedWithSection(
                                  context,
                                  item.oftenOrderedWith,
                                ),

                              // Customize Ingredients Section
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      title: 'item_details.customization'.tr(),
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 12,
                                      children: standardIngredients.map((ing) {
                                        final isRemoved = removedIngredients
                                            .contains(ing);
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isRemoved) {
                                                removedIngredients.remove(ing);
                                              } else {
                                                removedIngredients.add(ing);
                                              }
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isRemoved
                                                  ? ItemDetailsScreen.errorColor
                                                        .withValues(alpha: 0.1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: isRemoved
                                                    ? ItemDetailsScreen
                                                          .errorColor
                                                    : ItemDetailsScreen
                                                          .outlineVariantColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isRemoved) ...[
                                                  const Icon(
                                                    Icons.block_rounded,
                                                    size: KZ.iconInline,
                                                    color: ItemDetailsScreen
                                                        .errorColor,
                                                  ),
                                                  const SizedBox(width: 6),
                                                ],
                                                Text(
                                                  'item_details.remove_ingredient'
                                                      .tr(
                                                        namedArgs: {
                                                          'name': ing,
                                                        },
                                                      ),
                                                  style: KZ.label.copyWith(
                                                    color: isRemoved
                                                        ? ItemDetailsScreen
                                                              .errorColor
                                                        : ItemDetailsScreen
                                                              .onSurfaceColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              // Special Instructions — kept visually
                              // secondary to required customization: no
                              // section header (the field's own floating
                              // label already says "Special Instructions",
                              // so a second uppercase heading above it would
                              // just repeat the same word) and no required
                              // badge, since notes are always optional.
                              TextField(
                                controller: notesController,
                                maxLines: 3,
                                style: KZ.body,
                                decoration: KZ.inputDecoration(
                                  label: 'item_details.notes'.tr(),
                                  hint: 'item_details.notes_hint'.tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Top Controls Bar (Back & Favorite Glass Buttons)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        button: true,
                        label: 'common.back'.tr(),
                        child: InkWell(
                          onTap: () => context.pop(),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: KZ.iconTapTargetMin,
                            height: KZ.iconTapTargetMin,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: ItemDetailsScreen.onSurfaceColor,
                              size: KZ.iconControl,
                            ),
                          ),
                        ),
                      ),
                      KZLottieHeartButton(
                        isFavorite: isFav,
                        semanticsLabel: 'profile.my_favorites'.tr(),
                        size: KZ.iconTapTargetMin,
                        iconSize: KZ.iconControl,
                        shadowOpacity: 0.15,
                        onTap: () async {
                          final success = await ref
                              .read(customerFavoritesProvider.notifier)
                              .toggleFavorite(widget.itemId);
                          if (!success && context.mounted) {
                            final err = ref
                                .read(customerFavoritesProvider)
                                .errorMessage;
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 4. Sticky Bottom CTA Footer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Quantity — belongs right next to Add to Cart
                        // rather than living elsewhere on the page; same
                        // exact `quantity` state used in the price
                        // calculation and the cart payload below, just
                        // finally exposed as a control (previously only
                        // settable by re-opening an existing cart line).
                        Semantics(
                          label: 'item_details.quantity'.tr(),
                          child: KZQuantityStepper(
                            quantity: quantity,
                            onChanged: (v) => setState(() => quantity = v),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Add to Cart Button — the one dominant action;
                        // the total price now lives inside it instead of a
                        // separate adjacent price block.
                        Expanded(
                          child: InkWell(
                            onTap: _isAddingToCart
                                ? null
                                : () async {
                                    // GET /menu/items/:id does not filter on isAvailable (unlike the list
                                    // endpoint), so an out-of-stock item is still reachable here directly —
                                    // must gate add-to-cart client-side (see 02_API_REFERENCE.md).
                                    if (!item.isAvailable) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'menu.item_unavailable'.tr(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    final missingRequired =
                                        _getMissingRequiredGroups(
                                          item.modifierGroups,
                                        );

                                    if (missingRequired.isNotEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'item_details.required_field_named'
                                                .tr(
                                                  namedArgs: {
                                                    'names': missingRequired
                                                        .map((e) => e.name)
                                                        .join(', '),
                                                  },
                                                ),
                                          ),
                                          backgroundColor:
                                              ItemDetailsScreen.errorColor,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    final allSelectedOptions =
                                        <String, List<String>>{};
                                    selectedSingleOptions.forEach(
                                      (k, v) => allSelectedOptions[k] = [v],
                                    );
                                    selectedMultipleOptions.forEach(
                                      (k, v) => allSelectedOptions[k] = v,
                                    );

                                    final flattenedQuantities = <String, int>{};
                                    for (final map in extraQuantities.values) {
                                      flattenedQuantities.addAll(map);
                                    }

                                    String finalInstructions = notesController
                                        .text
                                        .trim();
                                    if (removedIngredients.isNotEmpty) {
                                      final removeNote =
                                          'NO ${removedIngredients.join(', ').toUpperCase()}';
                                      finalInstructions =
                                          finalInstructions.isEmpty
                                          ? removeNote
                                          : '$finalInstructions ($removeNote)';
                                    }

                                    final cartItem = CartItem(
                                      id:
                                          widget.cartItemId ??
                                          'ci_${DateTime.now().millisecondsSinceEpoch}',
                                      menuItemId: item.id,
                                      productName: item.name,
                                      productImage: item.imageUrl,
                                      basePrice:
                                          item.discountPrice ?? item.basePrice,
                                      quantity: quantity,
                                      selectedOptions: allSelectedOptions,
                                      extraQuantities: flattenedQuantities,
                                      specialInstructions: finalInstructions,
                                      unitPrice: unitPrice,
                                      lineTotal: totalPrice,
                                    );

                                    setState(() => _isAddingToCart = true);
                                    try {
                                      // Editing an existing cart line (cartItemId set) must replace
                                      // that line in place — calling addItem() here would instead
                                      // create a brand-new line alongside the original, duplicating
                                      // the item in the cart.
                                      if (widget.cartItemId != null) {
                                        await ref
                                            .read(cartProvider.notifier)
                                            .replaceItem(
                                              widget.cartItemId!,
                                              cartItem,
                                            );
                                      } else {
                                        await ref
                                            .read(cartProvider.notifier)
                                            .addItem(cartItem);
                                      }

                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            widget.cartItemId != null
                                                ? 'item_details.updated_success'
                                                      .tr()
                                                : 'item_details.added_success'
                                                      .tr(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );

                                      context.pop();
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'common.something_wrong'.tr(),
                                          ),
                                          backgroundColor:
                                              ItemDetailsScreen.errorColor,
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isAddingToCart = false);
                                      }
                                    }
                                  },
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                            child: KZPressableScale(
                              enabled: !_isAddingToCart,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: ItemDetailsScreen.primaryColor
                                      .withValues(
                                        alpha: _isAddingToCart ? 0.7 : 1,
                                      ),
                                  borderRadius: BorderRadius.circular(
                                    KZ.radiusMd,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ItemDetailsScreen.primaryColor
                                          .withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration: KZMotion.durationFor(
                                    context,
                                    KZMotion.fast,
                                  ),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                  child: _isAddingToCart
                                      ? const SizedBox(
                                          key: ValueKey('adding'),
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : FittedBox(
                                          key: const ValueKey('idle'),
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.cartItemId != null
                                                    ? 'item_details.update_cart'
                                                          .tr()
                                                    : 'item_details.add_to_cart'
                                                          .tr(),
                                                style: KZ.buttonLabel.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 1,
                                                height: 16,
                                                color: Colors.white
                                                    .withValues(alpha: 0.4),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                formatCurrency(
                                                  totalPrice,
                                                  locale: context.locale,
                                                ),
                                                style: KZ.buttonLabel.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Neutral hero placeholder for a missing/failed product photo — the same
/// icon-based treatment [KZFoodImage] uses everywhere else a product photo
/// is absent, so a hero without a real image never invents artwork or
/// falls back to a full-bleed brand-red block.
class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ItemDetailsScreen.surfaceContainerHighestColor,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 64,
          color: ItemDetailsScreen.outlineColor,
        ),
      ),
    );
  }
}

/// Small "Often Ordered With" card — mirrors the existing compact product
/// card proportions used elsewhere in the app (fixed width, image-over-text,
/// one-line title), but intentionally excludes compare-at price per the
/// recommendation-summary contract (no variants/addonGroups either, so no
/// discount context is available to show).
class _OftenOrderedWithCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _OftenOrderedWithCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: KZCard(
        padding: const EdgeInsets.all(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: KZFoodImage(
                    imageUrl: item.imageUrl,
                    borderRadius: BorderRadius.circular(KZ.radiusSm),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: MenuItemBadgeChip(badge: item.badge!),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.localizedName(context.locale.languageCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KZ.labelLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    formatCurrency(item.basePrice, locale: context.locale),
                    style: KZ.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                KZLottieAddButton(
                  onTap: onAdd,
                  semanticsLabel: 'home.add_to_cart'.tr(),
                  size: 24,
                  backgroundColor: KZ.primary,
                  iconColor: Colors.white,
                  iconSize: 16,
                ),
              ],
            ),
            if (item.calories != null) ...[
              const SizedBox(height: 2),
              MenuItemCaloriesText(calories: item.calories!),
            ],
          ],
        ),
      ),
    );
  }
}
