import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_settings_group.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/widgets/delete_account_dialog.dart';
import 'package:kebda_zaman/core/services/biometric_service.dart';
import 'package:kebda_zaman/core/services/biometric_preference_store.dart';

/// The real account-management destination — reached from Profile's
/// "Edit Profile"/"Settings" entry point. Holds everything that used to be
/// crammed into Profile's own flat settings card (account editing,
/// language, preferences, support links, logout/delete), so Profile can
/// stay a high-level hub instead of duplicating this content.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSavingProfile = false;

  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _biometricBusy = false;
  KZBiometricKind _biometricKind = KZBiometricKind.none;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameCtrl = TextEditingController(text: user?.name);
    _phoneCtrl = TextEditingController(text: user?.phone);
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = ref.read(biometricServiceProvider);
    final supported = await biometricService.hasEnrolledBiometrics();
    final kind = supported
        ? await biometricService.availableKind()
        : KZBiometricKind.none;
    final user = ref.read(authNotifierProvider).user;
    final enabled = user != null
        ? await BiometricPreferenceStore.isEnabledFor(user.id)
        : false;
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
      _biometricKind = kind;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _handleBiometricToggle(bool wantsEnabled) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null || _biometricBusy) return;

    if (!wantsEnabled) {
      // Disabling never requires a biometric check, and never logs the user
      // out — it only stops future biometric prompts/actions.
      await BiometricPreferenceStore.disable();
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      return;
    }

    setState(() => _biometricBusy = true);
    final result = await ref
        .read(biometricServiceProvider)
        .authenticate(reasonKey: 'biometric.enable_reason'.tr());
    if (!mounted) return;
    setState(() => _biometricBusy = false);

    if (result is BiometricAuthSuccess) {
      await BiometricPreferenceStore.enableFor(user.id);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('biometric.enabled_success'.tr()),
          backgroundColor: KZ.primary,
        ),
      );
    } else if (result is! BiometricAuthCancelled) {
      // Cancellation is silent; every other failure gets a message. Either
      // way the preference is left untouched (still disabled).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('biometric.enable_failed'.tr()),
          backgroundColor: KZ.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // Same authNotifierProvider.updateProfile(name, phone) call the old
  // dialog made — no second profile-update implementation, no new
  // validation rules (the old dialog had none either).
  Future<void> _saveProfile() async {
    if (_isSavingProfile) return;
    setState(() => _isSavingProfile = true);
    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isSavingProfile = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.profile_updated'.tr()),
          backgroundColor: KZ.primary,
        ),
      );
    } else {
      final message =
          ref.read(authNotifierProvider).errorMessage ??
          'common.something_wrong'.tr();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: KZ.error));
    }
  }

  // Moved verbatim from Profile's _handleDeleteAccount.
  Future<void> _handleDeleteAccount() async {
    final deleted = await showDeleteAccountDialog(context);
    if (!deleted || !mounted) return;

    ref.invalidate(cartProvider);
    ref.invalidate(customerFavoritesProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('delete_account.success'.tr()),
        backgroundColor: KZ.primary,
      ),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isLoggedIn = authState.isLoggedIn;
    final currentLang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'settings.title'.tr()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // Account — a real inline form instead of the old native dialog.
          if (isLoggedIn && user != null) ...[
            KZSettingsGroupHeader('profile.edit_profile'.tr()),
            const SizedBox(height: 8),
            _buildEditProfileForm(),
            const SizedBox(height: 24),
          ],

          // Preferences
          KZSettingsGroupHeader('settings.preferences'.tr()),
          const SizedBox(height: 8),
          KZSettingsGroup(
            rows: [
              _buildLanguageRow(currentLang),
              // Only ever shown for a real (non-guest) logged-in account on
              // a device that actually has enrolled biometrics — guests
              // have no persistent password-based login to unlock later.
              if (_biometricSupported &&
                  isLoggedIn &&
                  user != null &&
                  !user.isGuest) ...[
                const KZSettingsDivider(),
                _buildBiometricRow(),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Other — support/about + the existing dashboard shortcut.
          KZSettingsGroupHeader('settings.support'.tr()),
          const SizedBox(height: 8),
          KZSettingsGroup(
            rows: [
              // Admin/cashier only — router-level protection already
              // redirects anyone else away from /admin/*, but the entry
              // point itself shouldn't be shown to customers/guests who
              // could never actually use it.
              if (user?.role == 'ADMIN' || user?.role == 'CASHIER') ...[
                KZSettingsRow(
                  icon: Icons.dashboard_customize_rounded,
                  title: 'nav.dashboard'.tr(),
                  onTap: () => context.go('/admin/dashboard'),
                ),
                const KZSettingsDivider(),
              ],
              KZSettingsRow(
                icon: Icons.headset_mic_rounded,
                title: 'settings.help'.tr(),
                onTap: () {},
              ),
              const KZSettingsDivider(),
              KZSettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'settings.privacy'.tr(),
                onTap: () => context.push('/legal/privacy'),
              ),
              const KZSettingsDivider(),
              KZSettingsRow(
                icon: Icons.info_outline_rounded,
                title: 'settings.terms'.tr(),
                onTap: () => context.push('/legal/terms'),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Account exit — separated from the groups above, exactly as it
          // was on Profile (extra space + a quiet hairline, no card
          // surface, no chevron on either row).
          Divider(height: 1, color: KZ.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 4),
          KZSettingsRow(
            icon: isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
            title: isLoggedIn ? 'profile.logout'.tr() : 'auth.login_btn'.tr(),
            iconColor: KZ.primary,
            titleColor: KZ.primary,
            showChevron: false,
            onTap: () async {
              if (isLoggedIn) {
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
          ),
          // Delete Account — a real, persistent account only. Guests don't
          // own a persistent account to delete, so this never renders.
          if (isLoggedIn && user != null && !user.isGuest)
            KZSettingsRow(
              icon: Icons.delete_forever_rounded,
              title: 'delete_account.tile_title'.tr(),
              iconColor: KZ.error,
              titleColor: KZ.error,
              showChevron: false,
              onTap: _handleDeleteAccount,
            ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: KZ.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: KZ.inputDecoration(label: 'auth.full_name'.tr()),
          ),
          const SizedBox(height: KZ.sp16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: KZ.inputDecoration(label: 'auth.phone'.tr()),
          ),
          const SizedBox(height: KZ.sp16),
          KZButton(
            label: 'common.save'.tr(),
            fullWidth: true,
            loading: _isSavingProfile,
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }

  // Moved verbatim from Profile — same setLocale + updateProfile(locale:)
  // calls, same pill-switcher visual language.
  // Label row on top, pill switcher on its own row below — a fixed-width
  // icon + label sharing a single row with a two-option pill switcher was
  // prone to overflow on narrow phones (the switcher's width isn't
  // negotiable, since both language options must always stay visible).
  // Stacking removes that competition entirely instead of trimming icon
  // sizes/padding to fit, which is the "cramped controls" this section
  // wants to avoid.
  IconData get _biometricIcon => switch (_biometricKind) {
    KZBiometricKind.face => Icons.face_retouching_natural_rounded,
    KZBiometricKind.fingerprint => Icons.fingerprint_rounded,
    _ => Icons.fingerprint_rounded,
  };

  String get _biometricSubtitle => switch (_biometricKind) {
    KZBiometricKind.face => 'settings.biometric_login_sub_face'.tr(),
    KZBiometricKind.fingerprint => 'settings.biometric_login_sub_fingerprint'.tr(),
    _ => 'settings.biometric_login_sub_generic'.tr(),
  };

  // Same row layout as _buildLanguageRow (icon + label, same padding), with
  // a trailing Switch instead of a pill-switcher — compact, no extra card,
  // consistent with the rest of this settings group.
  Widget _buildBiometricRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(_biometricIcon, color: KZ.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.biometric_login'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: KZ.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _biometricBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: _biometricEnabled,
                    activeColor: KZ.primaryContainer,
                    onChanged: _handleBiometricToggle,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(String currentLang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded, color: KZ.primary, size: 24),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguagePill(
                  label: 'العربية',
                  fontFamily: 'Alexandria',
                  selected: currentLang == 'ar',
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
                ),
                _buildLanguagePill(
                  label: 'English',
                  fontFamily: 'Plus Jakarta Sans',
                  selected: currentLang == 'en',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePill({
    required String label,
    required String fontFamily,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? KZ.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
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
          label,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

}
