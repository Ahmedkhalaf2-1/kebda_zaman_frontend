import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentLocale = context.locale;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings.language'.tr(), style: KZ.sectionTitle),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: KZ.primary),
                title: const Text(
                  'English',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: currentLocale.languageCode == 'en'
                    ? const Icon(Icons.check_circle_rounded, color: KZ.primary)
                    : null,
                onTap: () async {
                  await context.setLocale(const Locale('en'));
                  if (ref.read(authNotifierProvider).isLoggedIn) {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .updateProfile(locale: 'en');
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: KZ.primary),
                title: const Text(
                  'العربية',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: currentLocale.languageCode == 'ar'
                    ? const Icon(Icons.check_circle_rounded, color: KZ.primary)
                    : null,
                onTap: () async {
                  await context.setLocale(const Locale('ar'));
                  if (ref.read(authNotifierProvider).isLoggedIn) {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .updateProfile(locale: 'ar');
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLangLabel = context.locale.languageCode == 'ar'
        ? 'العربية'
        : 'English';

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'settings.title'.tr()),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KZ.screenPadding,
          vertical: KZ.sp16,
        ),
        children: [
          Text('settings.preferences'.tr(), style: KZ.labelLarge),
          const SizedBox(height: KZ.sp8),
          Container(
            decoration: KZ.cardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.language_rounded,
                    color: KZ.primary,
                  ),
                  title: Text('settings.language'.tr(), style: KZ.body),
                  subtitle: Text(currentLangLabel, style: KZ.bodySmall),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: KZ.secondary,
                  ),
                  onTap: _showLanguageDialog,
                ),
                KZ.divider,
                SwitchListTile(
                  title: Text('settings.notifications'.tr(), style: KZ.body),
                  subtitle: Text(
                    'settings.notifications_sub'.tr(),
                    style: KZ.bodySmall,
                  ),
                  value: notificationsEnabled,
                  activeColor: KZ.primaryContainer,
                  onChanged: (val) =>
                      setState(() => notificationsEnabled = val),
                  secondary: const Icon(
                    Icons.notifications_active_outlined,
                    color: KZ.primary,
                  ),
                ),
                KZ.divider,
                SwitchListTile(
                  title: Text('settings.dark_mode'.tr(), style: KZ.body),
                  subtitle: Text(
                    'settings.dark_mode_sub'.tr(),
                    style: KZ.bodySmall,
                  ),
                  value: darkModeEnabled,
                  activeColor: KZ.primaryContainer,
                  onChanged: (val) => setState(() => darkModeEnabled = val),
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                    color: KZ.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp24),

          Text('settings.support'.tr(), style: KZ.labelLarge),
          const SizedBox(height: KZ.sp8),
          Container(
            decoration: KZ.cardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: KZ.primary,
                  ),
                  title: Text('settings.help'.tr(), style: KZ.body),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: KZ.secondary,
                  ),
                  onTap: () {},
                ),
                KZ.divider,
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: KZ.primary,
                  ),
                  title: Text('settings.contact'.tr(), style: KZ.body),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: KZ.secondary,
                  ),
                  onTap: () {},
                ),
                KZ.divider,
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: KZ.primary,
                  ),
                  title: Text('settings.privacy'.tr(), style: KZ.body),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: KZ.secondary,
                  ),
                  onTap: () => context.push('/legal/privacy'),
                ),
                KZ.divider,
                ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: KZ.primary,
                  ),
                  title: Text('settings.terms'.tr(), style: KZ.body),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: KZ.secondary,
                  ),
                  onTap: () => context.push('/legal/terms'),
                ),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp32),

          Center(child: Text('settings.version'.tr(), style: KZ.bodySmall)),
          const SizedBox(height: KZ.sp24),
        ],
      ),
    );
  }
}
