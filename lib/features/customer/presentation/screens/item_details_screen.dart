import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

import '../notifiers/item_details_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
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

  // Section Header matching Stitch typography & spacing
  Widget _buildSectionHeader({
    required String title,
    bool isRequired = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: KZ.sectionTitle.copyWith(fontSize: 16),
          ),
          if (isRequired)
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
            )
          else if (subtitle != null)
            Text(subtitle, style: KZ.label),
        ],
      ),
    );
  }

  // Build Modifier Group Card
  Widget _buildModifierGroupSection(ModifierGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
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
          ),

          // SINGLE Selection (Radio Cards)
          if (group.selectionType == 'SINGLE')
            Column(
              children: group.options.map((opt) {
                final isSelected = selectedSingleOptions[group.id] == opt.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedSingleOptions[group.id] = opt.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ItemDetailsScreen.primaryFixedColor.withValues(
                                alpha: 0.3,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? ItemDetailsScreen.primaryColor
                              : ItemDetailsScreen.outlineVariantColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            opt.name,
                            style: KZ.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: KZ.onSurface,
                            ),
                          ),
                          Text(
                            opt.priceModifier == 0
                                ? '+0 ${'common.egp'.tr()}'
                                : '+${opt.priceModifier.toStringAsFixed(0)} ${'common.egp'.tr()}',
                            style: KZ.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          // MULTIPLE Selection (Checkbox Cards with Stepper)
          if (group.selectionType == 'MULTIPLE')
            Column(
              children: group.options.map((opt) {
                final selectedList = selectedMultipleOptions[group.id] ?? [];
                final isSelected = selectedList.contains(opt.id);
                final groupMap = extraQuantities[group.id] ?? {};
                final optQty = groupMap[opt.id] ?? (isSelected ? 1 : 0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? ItemDetailsScreen.primaryColor
                            : ItemDetailsScreen.outlineVariantColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'item_details.max_selections'.tr(
                                                namedArgs: {
                                                  'max':
                                                      '${group.maxSelections}',
                                                },
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
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.name,
                                  style: KZ.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: KZ.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${opt.priceModifier.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                  style: KZ.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Stepper (- 1 +)
                        if (isSelected)
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
                    ),
                  ),
                );
              }).toList(),
            ),

          // QUANTITY Selection (Stepper Card)
          if (group.selectionType == 'QUANTITY')
            Column(
              children: group.options.map((opt) {
                final groupMap = extraQuantities[group.id] ?? {};
                final optQty = groupMap[opt.id] ?? 0;
                final isSelected = optQty > 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? ItemDetailsScreen.primaryColor
                            : ItemDetailsScreen.outlineVariantColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.name,
                              style: KZ.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: KZ.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${opt.priceModifier.toStringAsFixed(0)} ${'common.egp'.tr()}',
                              style: KZ.bodySmall,
                            ),
                          ],
                        ),
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
                  ),
                );
              }).toList(),
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
                // 1. Top Hero Image Background (Height 340px)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 340,
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
                                errorWidget: (context, url, err) => Container(
                                  color: ItemDetailsScreen.primaryColor,
                                  child: Center(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: ItemDetailsScreen.primaryColor,
                                child: Center(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable Content Sheet (Starts at Y=300px to overlap 40px of Hero Image)
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
                                    // Best Seller Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ItemDetailsScreen
                                            .tertiaryContainerColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'item_details.best_seller'
                                            .tr()
                                            .toUpperCase(),
                                        style: KZ.statusLabel.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Title
                                    Text(
                                      item.name,
                                      style: KZ.display.copyWith(fontSize: 28),
                                    ),
                                    const SizedBox(height: 6),

                                    // Description
                                    Text(
                                      item.description,
                                      style: KZ.bodyLarge.copyWith(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),

                              // Modifier Groups (Size, Extras, etc.)
                              for (final group in item.modifierGroups)
                                _buildModifierGroupSection(group),

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

                              // Special Instructions Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                    title: 'item_details.notes'.tr(),
                                  ),
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
                      Semantics(
                        button: true,
                        label: 'profile.my_favorites'.tr(),
                        child: InkWell(
                          onTap: () async {
                            final success = await ref
                                .read(customerFavoritesProvider.notifier)
                                .toggleFavorite(widget.itemId);
                            if (!success && context.mounted) {
                              final err = ref.read(customerFavoritesProvider).errorMessage;
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
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: ItemDetailsScreen.primaryColor,
                              size: KZ.iconControl,
                            ),
                          ),
                        ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total Price Display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'item_details.total'.tr().toUpperCase(),
                              style: KZ.label,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  totalPrice.toStringAsFixed(0),
                                  style: KZ.priceLarge.copyWith(fontSize: 28),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'common.egp'.tr(),
                                  style: KZ.label.copyWith(
                                    color: ItemDetailsScreen.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),

                        // Add to Cart Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              // GET /menu/items/:id does not filter on isAvailable (unlike the list
                              // endpoint), so an out-of-stock item is still reachable here directly —
                              // must gate add-to-cart client-side (see 02_API_REFERENCE.md).
                              if (!item.isAvailable) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('menu.item_unavailable'.tr()),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final missingRequired = _getMissingRequiredGroups(
                                item.modifierGroups,
                              );

                              if (missingRequired.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'item_details.required_field_named'.tr(
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

                              String finalInstructions = notesController.text
                                  .trim();
                              if (removedIngredients.isNotEmpty) {
                                final removeNote =
                                    'NO ${removedIngredients.join(', ').toUpperCase()}';
                                finalInstructions = finalInstructions.isEmpty
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
                                basePrice: item.discountPrice ?? item.basePrice,
                                quantity: quantity,
                                selectedOptions: allSelectedOptions,
                                extraQuantities: flattenedQuantities,
                                specialInstructions: finalInstructions,
                                unitPrice: unitPrice,
                                lineTotal: totalPrice,
                              );

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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      widget.cartItemId != null
                                          ? 'item_details.updated_success'.tr()
                                          : 'item_details.added_success'.tr(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );

                                context.pop();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'common.something_wrong'.tr(),
                                    ),
                                    backgroundColor:
                                        ItemDetailsScreen.errorColor,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: ItemDetailsScreen.primaryColor,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.cartItemId != null
                                        ? 'item_details.update_cart'.tr()
                                        : 'item_details.add_to_cart'.tr(),
                                    style: KZ.buttonLabel.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.shopping_bag_rounded,
                                    color: Colors.white,
                                    size: KZ.iconControl,
                                  ),
                                ],
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
