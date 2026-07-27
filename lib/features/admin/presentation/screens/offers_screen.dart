import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/offers_admin_notifier.dart';

class OffersManagementScreen extends ConsumerWidget {
  const OffersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(offersAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers & Promos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/admin/offers/add');
            },
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (promos) {
          if (promos.isEmpty) {
            return const Center(child: Text('No promo codes found.'));
          }
          return ListView.builder(
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return ListTile(
                leading: const Icon(Icons.local_offer),
                title: Text(promo.code),
                subtitle: Text(
                  '${promo.discountType.name}: ${promo.value} | Min: ${promo.minOrderValue} EGP',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: promo.isActive,
                      onChanged: (val) {
                        ref
                            .read(offersAdminProvider.notifier)
                            .togglePromoAvailability(promo);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        context.push('/admin/offers/edit', extra: promo);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Promo?'),
                            content: Text('Delete ${promo.code}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(offersAdminProvider.notifier)
                                      .deletePromo(promo.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/offers/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
