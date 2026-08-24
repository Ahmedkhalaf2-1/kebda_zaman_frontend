import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';

/// Customer "My Addresses" screen — list, add, edit, delete, set default.
/// Backed entirely by the existing [addressNotifierProvider] /
/// [AddressRepository] (`/me/addresses*`), per 02_API_REFERENCE.md.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressNotifierProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'addresses.title'.tr()),
      body: state.isLoading && state.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: KZ.primary))
          : state.errorMessage != null && state.addresses.isEmpty
          ? KZErrorState(
              message: 'home.failed_load'.tr(),
              retryLabel: 'home.retry'.tr(),
              onRetry: () =>
                  ref.read(addressNotifierProvider.notifier).loadAddresses(),
            )
          : state.addresses.isEmpty
          ? KZEmptyState(
              icon: Icons.location_off_rounded,
              title: 'addresses.empty_title'.tr(),
              message: 'addresses.empty_sub'.tr(),
              actionLabel: 'addresses.add'.tr(),
              onAction: () => context.push('/profile/addresses/add'),
            )
          : RefreshIndicator(
              color: KZ.primary,
              onRefresh: () =>
                  ref.read(addressNotifierProvider.notifier).loadAddresses(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KZ.screenPadding,
                  KZ.sp8,
                  KZ.screenPadding,
                  KZ.sp32 + 64,
                ),
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: KZ.primary,
                        size: 20,
                      ),
                      const SizedBox(width: KZ.sp8),
                      Text(
                        'addresses.count_label'.tr(
                          namedArgs: {'count': '${state.addresses.length}'},
                        ),
                        style: KZ.sectionTitle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: KZ.sp16),
                  for (final address in state.addresses) ...[
                    _AddressCard(address: address),
                    const SizedBox(height: KZ.sp12),
                  ],
                ],
              ),
            ),
      // Only shown once there's already a list to scroll through — the
      // empty state above has its own inline "Add Address" action, so a
      // second one floating over it would just be a redundant duplicate.
      floatingActionButton: state.addresses.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: KZ.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text(
                'addresses.add'.tr(),
                style: KZ.buttonLabel.copyWith(color: Colors.white),
              ),
              onPressed: () => context.push('/profile/addresses/add'),
            ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final Address address;

  const _AddressCard({required this.address});

  bool get _isWork => address.label.toLowerCase() == 'work';

  IconData get _icon => _isWork ? Icons.work_rounded : Icons.home_rounded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: KZ.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KZ.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: KZ.primary, size: 22),
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.label.isNotEmpty
                                ? address.label
                                : 'addresses.title'.tr(),
                            style: KZ.itemTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: KZ.sp8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KZ.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: KZ.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'addresses.default_badge'.tr(),
                                  style: KZ.caption.copyWith(
                                    color: KZ.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAddress(address),
                      style: KZ.body.copyWith(color: KZ.onSurfaceVariant),
                    ),
                    if (address.notes != null &&
                        address.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 14,
                            color: KZ.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address.notes!,
                              style: KZ.bodySmall.copyWith(
                                color: KZ.onSurfaceVariant.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp14),
          const Divider(height: 1, color: KZ.outlineVariant),
          const SizedBox(height: KZ.sp10),
          Row(
            children: [
              if (!address.isDefault)
                _CardAction(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'addresses.set_default'.tr(),
                  color: KZ.primary,
                  onTap: () => ref
                      .read(addressNotifierProvider.notifier)
                      .setDefaultAddress(address.id),
                ),
              const Spacer(),
              _CardAction(
                icon: Icons.edit_outlined,
                label: 'common.edit'.tr(),
                color: KZ.secondary,
                onTap: () =>
                    context.push('/profile/addresses/edit', extra: address),
              ),
              const SizedBox(width: KZ.sp16),
              _CardAction(
                icon: Icons.delete_outline_rounded,
                label: 'common.delete'.tr(),
                color: KZ.error,
                onTap: () => _confirmDelete(context, ref, address),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('addresses.delete_title'.tr()),
        content: Text(
          'addresses.delete_body'.tr(namedArgs: {'label': address.label}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(addressNotifierProvider.notifier)
                  .deleteAddress(address.id);
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

/// Small icon+label tap target shared by the three card actions (set
/// default / edit / delete) — replaces the old bare `IconButton`s with a
/// consistent, more legible row treatment.
class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KZ.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: KZ.label.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared "street, building, floor, apartment, city" formatter — mirrors the
/// same logic used at checkout so the address reads identically everywhere.
String _formatAddress(Address a) {
  final parts = <String>[
    a.street,
    a.building,
    if (a.floor != null && a.floor!.isNotEmpty)
      'addresses.floor_prefix'.tr(namedArgs: {'floor': a.floor!}),
    if (a.apartment != null && a.apartment!.isNotEmpty)
      'addresses.apartment_prefix'.tr(namedArgs: {'apartment': a.apartment!}),
    a.city,
  ];
  return parts.where((p) => p.isNotEmpty).join(', ');
}
