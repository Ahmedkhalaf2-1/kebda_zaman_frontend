import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/card_brand_gradient.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/saved_cards_notifier.dart';

/// "Saved Cards" management screen — list + delete only. Only ever displays
/// brand/last-four/expiry from `GET /payments/cards`: the backend never has
/// (and never returns) a full card number, so there is nothing more to show.
class SavedCardsScreen extends ConsumerWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedCardsNotifierProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(
        context: context,
        title: 'saved_cards.title'.tr(),
      ),
      body: state.isLoading && state.cards.isEmpty
          ? const Center(child: CircularProgressIndicator(color: KZ.primary))
          : state.errorMessage != null && state.cards.isEmpty
          ? KZErrorState(
              message: 'home.failed_load'.tr(),
              retryLabel: 'home.retry'.tr(),
              onRetry: () =>
                  ref.read(savedCardsNotifierProvider.notifier).loadCards(),
            )
          : state.cards.isEmpty
          ? KZEmptyState(
              icon: Icons.credit_card_off_rounded,
              title: 'saved_cards.empty_title'.tr(),
              message: 'saved_cards.empty_sub'.tr(),
            )
          : RefreshIndicator(
              color: KZ.primary,
              onRefresh: () =>
                  ref.read(savedCardsNotifierProvider.notifier).loadCards(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KZ.screenPadding,
                  KZ.sp16,
                  KZ.screenPadding,
                  KZ.sp32,
                ),
                itemCount: state.cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: KZ.sp12),
                itemBuilder: (context, index) {
                  return _SavedCardTile(card: state.cards[index]);
                },
              ),
            ),
    );
  }
}

/// Wallet-style card tile — same gradient-by-brand treatment as the
/// saved-card picker in checkout, so a saved card reads consistently as a
/// real payment method wherever it's shown in the app.
class _SavedCardTile extends ConsumerWidget {
  final SavedCard card;

  const _SavedCardTile({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiry =
        '${card.expMonth.toString().padLeft(2, '0')}/${(card.expYear % 100).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: BoxDecoration(
        gradient: cardBrandGradient(card.brand),
        borderRadius: BorderRadius.circular(KZ.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, color: Colors.white, size: 28),
          const SizedBox(width: KZ.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'saved_cards.card_label'.tr(
                          namedArgs: {
                            'brand': card.brand,
                            'lastFour': card.lastFour,
                          },
                        ),
                        style: KZ.itemTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (card.isDefault) ...[
                      const SizedBox(width: KZ.sp8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'saved_cards.default_badge'.tr(),
                          style: KZ.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'saved_cards.expires'.tr(namedArgs: {'expiry': expiry}),
                  style: KZ.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: KZ.iconControl,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('saved_cards.delete_title'.tr()),
        content: Text(
          'saved_cards.delete_body'.tr(
            namedArgs: {'lastFour': card.lastFour},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(savedCardsNotifierProvider.notifier).deleteCard(card.id);
            },
            child: Text(
              'common.delete'.tr(),
              style: const TextStyle(color: KZ.error),
            ),
          ),
        ],
      ),
    );
  }
}
