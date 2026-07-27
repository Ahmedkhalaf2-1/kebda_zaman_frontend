import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KZ.screenPadding,
                  KZ.sp16,
                  KZ.screenPadding,
                  KZ.sp32 + 64,
                ),
                itemCount: state.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: KZ.sp12),
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  return _AddressCard(address: address);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: KZ.primaryContainer,
        foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: KZ.cardDecoration(
        color: address.isDefault
            ? KZ.primaryFixed.withValues(alpha: 0.3)
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                address.label.toLowerCase() == 'work'
                    ? Icons.work_rounded
                    : Icons.home_rounded,
                color: KZ.primary,
                size: 20,
              ),
              const SizedBox(width: KZ.sp8),
              Expanded(
                child: Text(
                  address.label.isNotEmpty
                      ? address.label
                      : 'addresses.title'.tr(),
                  style: KZ.itemTitle,
                ),
              ),
              if (address.isDefault)
                KZStatusBadge(
                  label: 'addresses.default_badge'.tr(),
                  icon: Icons.star_rounded,
                  color: KZ.primary,
                ),
            ],
          ),
          const SizedBox(height: KZ.sp8),
          Text(_formatAddress(address), style: KZ.body),
          if (address.notes != null && address.notes!.isNotEmpty) ...[
            const SizedBox(height: KZ.sp4),
            Text(address.notes!, style: KZ.bodySmall),
          ],
          const SizedBox(height: KZ.sp12),
          Row(
            children: [
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () => ref
                      .read(addressNotifierProvider.notifier)
                      .setDefaultAddress(address.id),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: KZ.iconInline,
                    color: KZ.primary,
                  ),
                  label: Text(
                    'addresses.set_default'.tr(),
                    style: KZ.label.copyWith(color: KZ.primary),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, KZ.iconTapTargetMin),
                  ),
                ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    context.push('/profile/addresses/edit', extra: address),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: KZ.secondary,
                  size: KZ.iconControl,
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, ref, address),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: KZ.error,
                  size: KZ.iconControl,
                ),
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
