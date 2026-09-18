import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

/// The DRIVER role's account/logout surface — read-only profile info (name,
/// email, phone) plus the one action a driver actually needs here. No
/// profile editing: drivers are admin-managed accounts (`/admin/drivers`),
/// never self-service.
class DriverAccountScreen extends ConsumerWidget {
  const DriverAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            AdminPageHeader(title: 'driver_app.account_title'.tr()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(KZ.sp16),
                    decoration: BoxDecoration(
                      color: KZ.surface,
                      borderRadius: BorderRadius.circular(KZ.radiusMd),
                      border: Border.all(
                        color: KZ.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: KZ.itemTitle),
                        if (user?.email != null && user!.email!.isNotEmpty) ...[
                          const SizedBox(height: KZ.sp8),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            text: user.email!,
                          ),
                        ],
                        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                          const SizedBox(height: KZ.sp8),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            text: user.phone!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: KZ.sp24),
                  KZButton(
                    label: 'profile.logout'.tr(),
                    variant: KZButtonVariant.destructive,
                    fullWidth: true,
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: KZ.onSurfaceVariant),
        const SizedBox(width: KZ.sp8),
        Expanded(child: Text(text, style: KZ.bodySmall)),
      ],
    );
  }
}
