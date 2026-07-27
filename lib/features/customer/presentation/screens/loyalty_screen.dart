import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';
import '../notifiers/loyalty_notifier.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'loyalty.title'.tr()),
      body: loyaltyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'home.failed_load'.tr(),
          retryLabel: 'home.retry'.tr(),
          onRetry: () => ref.invalidate(loyaltyProvider),
        ),
        data: (data) {
          final balance = data.account.pointsBalance;
          return RefreshIndicator(
            color: KZ.primary,
            onRefresh: () async => ref.invalidate(loyaltyProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: KZ.sp16,
              ),
              children: [
                // Points Hero Card
                Container(
                  padding: const EdgeInsets.all(KZ.sp24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [KZ.primary, KZ.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(KZ.radiusXl),
                    boxShadow: KZ.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: KZ.sp6),
                          Text(
                            'loyalty.balance_header'.tr(),
                            style: KZ.statusLabel.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KZ.sp12),
                      Text(
                        '$balance',
                        style: KZ.display.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'loyalty.points_available'.tr(),
                        style: KZ.body.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: KZ.sp20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(KZ.radiusSm),
                        child: LinearProgressIndicator(
                          value: ((balance % 1000) / 1000).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: KZ.sp8),
                      Text(
                        'loyalty.points_to_next'.tr(
                          namedArgs: {'points': '${1000 - (balance % 1000)}'},
                        ),
                        style: KZ.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KZ.sp24),

                // How it works
                Text('loyalty.how_it_works'.tr(), style: KZ.labelLarge),
                const SizedBox(height: KZ.sp8),
                Container(
                  decoration: KZ.cardDecoration(),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.monetization_on_rounded,
                        title: 'loyalty.earn_title'.tr(),
                        subtitle: 'loyalty.earn_sub'.tr(
                          namedArgs: {
                            'points': '${data.settings.loyaltyPointsPerStep}',
                            'egp': data.settings.loyaltyEgpStep.toStringAsFixed(
                              0,
                            ),
                          },
                        ),
                      ),
                      KZ.divider,
                      _InfoTile(
                        icon: Icons.card_giftcard_rounded,
                        title: 'loyalty.redeem_title'.tr(),
                        subtitle: 'loyalty.redeem_sub'.tr(
                          namedArgs: {
                            'min':
                                '${data.settings.loyaltyMinRedemptionPoints}',
                          },
                        ),
                      ),
                      KZ.divider,
                      _InfoTile(
                        icon: Icons.verified_rounded,
                        title: 'loyalty.no_expire_title'.tr(),
                        subtitle: 'loyalty.no_expire_sub'.tr(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KZ.sp24),

                // Points History
                Text('loyalty.history'.tr(), style: KZ.labelLarge),
                const SizedBox(height: KZ.sp8),
                if (data.history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(KZ.sp24),
                    decoration: KZ.cardDecoration(),
                    child: Center(
                      child: Text(
                        'loyalty.no_history'.tr(),
                        textAlign: TextAlign.center,
                        style: KZ.bodySmall,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: KZ.cardDecoration(),
                    child: Column(
                      children: List.generate(data.history.length, (index) {
                        final tx = data.history[index];
                        final isEarned = tx.type == LoyaltyTransactionType.earn;
                        final titleStr = isEarned
                            ? (tx.orderId != null
                                  ? 'loyalty.earned_order'.tr(
                                      namedArgs: {'id': '${tx.orderId}'},
                                    )
                                  : 'loyalty.earned'.tr())
                            : 'loyalty.redeemed'.tr();
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isEarned
                                    ? KZ.primaryFixed
                                    : KZ.surfaceContainer,
                                child: Icon(
                                  isEarned
                                      ? Icons.add_circle_outline_rounded
                                      : Icons.remove_circle_outline_rounded,
                                  color: isEarned ? KZ.primary : KZ.secondary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                titleStr,
                                style: KZ.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: KZ.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
                                style: KZ.caption,
                              ),
                              trailing: Text(
                                '${isEarned ? '+' : '-'}${tx.points} ${'common.pts'.tr()}',
                                style: KZ.price.copyWith(
                                  color: isEarned ? KZ.tertiary : KZ.error,
                                ),
                              ),
                            ),
                            if (index < data.history.length - 1) KZ.divider,
                          ],
                        );
                      }),
                    ),
                  ),
                const SizedBox(height: KZ.sp32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(KZ.sp8),
        decoration: const BoxDecoration(
          color: KZ.primaryFixed,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: KZ.primary, size: 20),
      ),
      title: Text(
        title,
        style: KZ.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: KZ.onSurface,
        ),
      ),
      subtitle: Text(subtitle, style: KZ.bodySmall),
    );
  }
}
