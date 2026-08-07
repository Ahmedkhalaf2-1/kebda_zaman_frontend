import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/widgets/delete_account_dialog.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';

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
  bool _darkMode = false;

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
                          const SizedBox(height: 20),
                          Text(
                            userName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: KZ.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: KZ.onSurfaceVariant,
                            ),
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

                    // 3. Quick Actions Section
                    Text(
                      'profile.quick_actions'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.25,
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('profile.payments'.tr()),
                                backgroundColor: KZ.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 4. Settings Section
                    Text(
                      'profile.settings'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16), // rounded-2xl
                        border: Border.all(
                          color: KZ.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: KZ.primary.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // App Language Row
                          _buildLanguageSettingRow(context),
                          _buildDivider(),

                          // Dark Mode Row
                          _buildDarkModeRow(),
                          _buildDivider(),

                          // Edit Profile
                          if (authState.isLoggedIn) ...[
                            _buildSettingRow(
                              icon: Icons.edit_rounded,
                              title: 'profile.edit_profile'.tr(),
                              onTap: () =>
                                  _showEditProfileDialog(context, user!),
                            ),
                            _buildDivider(),
                          ],

                          // Dashboard
                          _buildSettingRow(
                            icon: Icons.dashboard_customize_rounded,
                            title: 'nav.dashboard'.tr(),
                            onTap: () => context.go('/admin/dashboard'),
                          ),
                          _buildDivider(),

                          // Help & Support
                          _buildSettingRow(
                            icon: Icons.headset_mic_rounded,
                            title: 'settings.help'.tr(),
                            onTap: () {},
                          ),
                          _buildDivider(),

                          // Privacy Policy
                          _buildSettingRow(
                            icon: Icons.privacy_tip_outlined,
                            title: 'settings.privacy'.tr(),
                            onTap: () => context.push('/legal/privacy'),
                          ),
                          _buildDivider(),

                          // Terms of Service
                          _buildSettingRow(
                            icon: Icons.info_outline_rounded,
                            title: 'settings.terms'.tr(),
                            onTap: () => context.push('/legal/terms'),
                          ),
                          _buildDivider(),

                          // Logout Row (red tinted)
                          _buildLogoutRow(context),

                          // Delete Account — a real, persistent account only.
                          // Guests don't own a persistent account to delete,
                          // so this never renders for them.
                          if (authState.isLoggedIn &&
                              user != null &&
                              !user.isGuest) ...[
                            _buildDivider(),
                            _buildDeleteAccountRow(context),
                          ],
                        ],
                      ),
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: KZ.outlineVariant.withValues(
        alpha: 0.25,
      ), // divide-orange-50 equivalent
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
              gradient: const LinearGradient(
                colors: [Color(0xFFAA3600), Color(0xFF8C2B00)],
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'profile.rewards_card'.tr(),
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
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
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
                        Text(
                          'profile.earn_rate'.tr(
                            namedArgs: {
                              'pts': '$ptsPerStep',
                              'egp': step.toStringAsFixed(0),
                            },
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          minRedemption > points
                              ? 'profile.pts_to_redeem'.tr(
                                  namedArgs: {'pts': '$ptsToRedeem'},
                                )
                              : 'profile.redeem_available'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // rounded-2xl
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: KZ.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: KZ.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: KZ.primaryFixed.withValues(
                    alpha: 0.45,
                  ), // orange-100 tint
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: KZ.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KZ.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSettingRow(BuildContext context) {
    final currentLang = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KZ.primaryFixed.withValues(
                      alpha: 0.35,
                    ), // orange-50 tint
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: KZ.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'settings.language'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: KZ.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Inline Pill Switcher (matching HTML)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // slate-100
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (currentLang != 'ar') {
                      await context.setLocale(const Locale('ar'));
                      if (ref.read(authNotifierProvider).isLoggedIn) {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .updateProfile(locale: 'ar');
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: currentLang == 'ar'
                          ? KZ.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: currentLang == 'ar'
                          ? [
                              BoxShadow(
                                color: KZ.primary.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'العربية',
                      style: TextStyle(
                        // Always Arabic script regardless of active app
                        // locale, so pin the font instead of following the
                        // locale-driven ThemeData default.
                        fontFamily: 'Alexandria',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: currentLang == 'ar'
                            ? Colors.white
                            : const Color(0xFF64748B), // slate-500
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (currentLang != 'en') {
                      await context.setLocale(const Locale('en'));
                      if (ref.read(authNotifierProvider).isLoggedIn) {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .updateProfile(locale: 'en');
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: currentLang == 'en'
                          ? KZ.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: currentLang == 'en'
                          ? [
                              BoxShadow(
                                color: KZ.primary.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'English',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: currentLang == 'en'
                            ? Colors.white
                            : const Color(0xFF64748B), // slate-500
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KZ.primaryFixed.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dark_mode_rounded,
                    color: KZ.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'settings.dark_mode'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: KZ.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _darkMode,
            activeColor: KZ.primary,
            onChanged: (val) {
              setState(() {
                _darkMode = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: KZ.primaryFixed.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: KZ.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: KZ.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), // slate-400
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutRow(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (authState.isLoggedIn) {
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('profile.logged_out'.tr()),
                  backgroundColor: KZ.primary,
                ),
              );
              context.go('/login');
            }
          } else {
            context.push('/login');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // red-50 tint
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  authState.isLoggedIn
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  color: KZ.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  authState.isLoggedIn
                      ? 'profile.logout'.tr()
                      : 'auth.login_btn'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KZ.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountRow(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleDeleteAccount(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // red-50 tint
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: KZ.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  'delete_account.tile_title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KZ.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final deleted = await showDeleteAccountDialog(context);
    if (!deleted || !context.mounted) return;

    // Success cleanup: AuthNotifier.deleteAccount already cleared tokens,
    // stored session and auth state — this invalidates the remaining
    // user-scoped Riverpod state so nothing stale survives into the next
    // (unauthenticated) session, mirroring what navigating away from an
    // authenticated screen after logout already achieves for autodispose
    // providers.
    ref.invalidate(cartProvider);
    ref.invalidate(customerFavoritesProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('delete_account.success'.tr()),
        backgroundColor: KZ.primary,
      ),
    );
    // go() (not push()) replaces the whole stack, matching the existing
    // logout row — the back button cannot return to authenticated Profile.
    context.go('/login');
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(authNotifierProvider.notifier)
                  .updateProfile(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
