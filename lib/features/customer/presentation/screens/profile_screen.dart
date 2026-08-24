import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_settings_group.dart';

final localAvatarProvider = StateNotifierProvider<LocalAvatarNotifier, String?>(
  (ref) {
    return LocalAvatarNotifier();
  },
);

class LocalAvatarNotifier extends StateNotifier<String?> {
  LocalAvatarNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('local_avatar_path');
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_avatar_path', picked.path);
      state = picked.path;
    }
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final localAvatarPath = ref.watch(localAvatarProvider);
    final user = authState.user;
    final userName = user != null && user.name.isNotEmpty
        ? user.name
        : 'profile.guest_name'.tr();
    final userEmail =
        user != null && user.email != null && user.email!.isNotEmpty
        ? user.email!
        : (user != null
              ? (user.phone ?? 'profile.no_contact_info'.tr())
              : 'profile.guest_email'.tr());

    final loyaltyAsync = ref.watch(loyaltyProvider);

    return Scaffold(
      backgroundColor: KZ.surface, // #fcf9f5 (our brand cream background)
      body: ResponsiveContainer(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Bar Header matching Menu & Cart height (64px) ──
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: KZ.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'app_name'.tr(),
                      style: KZ.pageTitle.copyWith(
                        color: KZ.primary, // #8c2b00
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          ref.read(localAvatarProvider.notifier).pickImage(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KZ.primaryFixed.withValues(alpha: 0.3),
                          border: Border.all(color: KZ.primary, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: localAvatarPath != null
                            ? Image.file(
                                File(localAvatarPath),
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: KZ.primary,
                                size: 22,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Main Content ──
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  children: [
                    // 1. Profile Avatar & Info Section (matching HTML)
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // 96x96 Avatar circle with primary border
                              GestureDetector(
                                onTap: () => ref
                                    .read(localAvatarProvider.notifier)
                                    .pickImage(),
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KZ.surface,
                                    border: Border.all(
                                      color: KZ.primary,
                                      width: 4,
                                    ),
                                  ),
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFE2E8F0), // slate-200
                                    ),
                                    child: localAvatarPath != null
                                        ? Image.file(
                                            File(localAvatarPath),
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            size: 56,
                                            color: Color(
                                              0xFF94A3B8,
                                            ), // slate-400
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KZ.display.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KZ.bodySmall,
                          ),
                          if (!authState.isLoggedIn) ...[
                            const SizedBox(height: 16),
                            KZButton(
                              onPressed: () => context.push('/login'),
                              icon: Icons.login_rounded,
                              label: 'auth.login_btn'.tr(),
                              pill: true,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2. Kebda Rewards Loyalty Card (matching HTML with our rich terracotta brand)
                    _buildLoyaltyCard(context, loyaltyAsync),

                    const SizedBox(height: 32),

                    // 3. Quick Actions — compact horizontal tiles instead of
                    // tall centered-icon cards, so the section scans faster
                    // and wastes less vertical space.
                    Text('profile.quick_actions'.tr(), style: KZ.sectionTitle),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.6,
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'nav.orders'.tr(),
                          onTap: () => context.go('/orders'),
                        ),
                        _buildQuickActionCard(
                          icon: Icons.favorite_rounded,
                          title: 'profile.my_favorites'.tr(),
                          onTap: () => context.push('/profile/favorites'),
                        ),
                        _buildQuickActionCard(
                          icon: Icons.location_on_rounded,
                          title: 'profile.addresses'.tr(),
                          onTap: () => context.push('/profile/addresses'),
                        ),
                        _buildQuickActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'profile.payments'.tr(),
                          onTap: () =>
                              context.push('/profile/payment-methods'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 4. Settings entry point — Profile stays the
                    // high-level hub; account editing, language,
                    // preferences, support links, and logout/delete now
                    // all live on the dedicated Settings screen so they're
                    // not duplicated here. Logged-in users land straight on
                    // "Edit Profile" (Settings opens with that in view);
                    // guests get a neutral "Settings" label since there's
                    // nothing of theirs to edit yet, but they can still
                    // reach language + login from there.
                    KZSettingsGroupHeader('profile.settings'.tr()),
                    const SizedBox(height: 8),
                    KZSettingsGroup(
                      rows: [
                        KZSettingsRow(
                          icon: authState.isLoggedIn
                              ? Icons.edit_rounded
                              : Icons.settings_rounded,
                          title: authState.isLoggedIn
                              ? 'profile.edit_profile'.tr()
                              : 'profile.settings'.tr(),
                          onTap: () => context.push('/profile/settings'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyCard(
    BuildContext context,
    AsyncValue<LoyaltyData> loyaltyAsync,
  ) {
    return loyaltyAsync.when(
      loading: () => Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KZ.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (e, st) => Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KZ.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                'common.something_wrong'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(loyaltyProvider),
                child: Text(
                  'common.retry'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final points = data.account.pointsBalance;
        final step = data.policy.egpStep;
        final ptsPerStep = data.policy.pointsPerStep;
        final minRedemption = data.policy.minRedemptionPoints;
        final ptsToRedeem = minRedemption > points ? minRedemption - points : 0;

        return InkWell(
          onTap: () => context.push('/profile/loyalty'),
          borderRadius: BorderRadius.circular(24), // rounded-3xl
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Derived from KZ.primary (not a disconnected hardcoded pair)
              // so the card's brand personality still traces back to the
              // one actual brand color instead of a stale duplicate.
              gradient: LinearGradient(
                colors: [KZ.primary, Color.lerp(KZ.primary, Colors.black, 0.18)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: KZ.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative circle in bottom right (matching HTML)
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                // Card Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Title + Points on left, Tag icon on right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'profile.rewards_card'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$points ${'common.pts'.tr()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: 0.5,
                          child: Icon(
                            Icons.local_offer_rounded,
                            size: 36,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Middle Row: Earn rate + points to redeem + Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'profile.earn_rate'.tr(
                              namedArgs: {
                                'pts': '$ptsPerStep',
                                'egp': step.toStringAsFixed(0),
                              },
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            minRedemption > points
                                ? 'profile.pts_to_redeem'.tr(
                                    namedArgs: {'pts': '$ptsToRedeem'},
                                  )
                                : 'profile.redeem_available'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progress Bar
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: minRedemption > 0
                            ? (points / minRedemption).clamp(0.0, 1.0)
                            : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom Row: Notice text
                    Text(
                      points > 0
                          ? 'profile.earned_notice'.tr(
                              namedArgs: {'points': '$points'},
                            )
                          : 'profile.place_order_notice'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Compact horizontal tile (icon left, label right) instead of a tall
  // centered-icon card — the icon still supports recognition without
  // dominating the tile, and the shorter fixed height (via the grid's
  // `childAspectRatio`) removes a lot of the previous empty vertical space.
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: KZ.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: KZ.primary, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KZ.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
