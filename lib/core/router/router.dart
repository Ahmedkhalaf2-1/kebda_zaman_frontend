import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/customer/presentation/screens/home_screen.dart';
import '../../features/customer/presentation/screens/search_screen.dart';
import '../../features/customer/presentation/screens/cart_screen.dart';
import '../../features/customer/presentation/screens/orders_screen.dart';
import '../../features/customer/presentation/screens/profile_screen.dart';
import '../../features/customer/presentation/screens/menu_screen.dart';
import '../../features/customer/presentation/screens/item_details_screen.dart';
import '../../features/customer/presentation/screens/checkout_screen.dart';
import '../../features/customer/presentation/screens/loyalty_screen.dart';
import '../../features/customer/presentation/screens/favorites_screen.dart';
import '../../features/customer/presentation/screens/addresses_screen.dart';
import '../../features/customer/presentation/screens/address_form_screen.dart';
import '../../features/customer/presentation/screens/settings_screen.dart';
import '../../features/customer/presentation/screens/order_success_screen.dart';
import '../../features/customer/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/presentation/screens/login_screen.dart';
import '../../features/customer/presentation/screens/signup_screen.dart';
import '../../features/customer/presentation/screens/splash_screen.dart';
import '../../features/customer/presentation/screens/language_select_screen.dart';
import '../../features/customer/presentation/screens/onboarding_screen.dart';
import '../../features/customer/presentation/screens/auth_choice_screen.dart';
import '../../features/customer/presentation/shells/customer_shell.dart';
import '../../features/admin/presentation/shells/admin_shell.dart';
import '../../features/admin/presentation/screens/dashboard_screen.dart';
import '../../features/admin/presentation/screens/menu_management_screen.dart';
import '../../features/admin/presentation/screens/admin_food_form_screen.dart';
import '../../features/admin/presentation/screens/admin_category_form_screen.dart';
import '../../features/admin/presentation/screens/admin_promo_form_screen.dart';
import '../../features/admin/presentation/screens/order_management_screen.dart';
import '../../features/admin/presentation/screens/offers_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_notification_center_screen.dart';
import '../../features/admin/presentation/screens/admin_order_details_screen.dart';
import '../../features/admin/presentation/screens/staff_management_screen.dart';
import '../../features/admin/presentation/screens/customer_management_screen.dart';
import '../../features/admin/presentation/screens/customer_details_screen.dart';
import '../../features/customer/presentation/notifiers/auth_notifier.dart';
import '../../features/shared/domain/models/order.dart';
import '../../features/shared/domain/models/menu_item.dart';
import '../../features/shared/domain/models/category.dart';
import '../../features/shared/domain/models/promo_code.dart';
import '../../features/shared/domain/models/address.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (!path.startsWith('/admin')) return null;

      final auth = ref.read(authNotifierProvider);
      final role = auth.user?.role;

      // Unauthenticated users never reach any /admin/* route.
      if (!auth.isLoggedIn) return '/login';

      // ADMIN has full access to every /admin/* route.
      if (role == 'ADMIN') return null;

      // A cashier may only reach Orders Management inside /admin — every
      // other admin section (dashboard metrics, menu, promos, settings,
      // staff, etc.) redirects back there even on a direct/manual navigation.
      if (role == 'CASHIER') {
        return path.startsWith('/admin/orders') ? null : '/admin/orders';
      }

      // Any other authenticated role (CUSTOMER, incl. guest) is not admin
      // staff at all — send them back to customer navigation.
      return '/home';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-select',
        builder: (context, state) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth-choice',
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'menu',
                    builder: (context, state) => const MenuScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: 'tracking/:id',
                    builder: (context, state) => OrderTrackingScreen(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'loyalty',
                    builder: (context, state) => const LoyaltyScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    builder: (context, state) => const AddressesScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const AddressFormScreen(),
                      ),
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => AddressFormScreen(
                          existingAddress: state.extra as Address?,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ItemDetailsScreen(
            itemId: state.pathParameters['id']!,
            cartItemId: extra?['cartItemId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/home/item/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ItemDetailsScreen(
            itemId: state.pathParameters['id']!,
            cartItemId: extra?['cartItemId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/menu/item/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ItemDetailsScreen(
            itemId: state.pathParameters['id']!,
            cartItemId: extra?['cartItemId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'success',
            builder: (context, state) =>
                OrderSuccessScreen(order: state.extra as Order),
            redirect: (context, state) {
              if (state.extra == null || state.extra is! Order) {
                return '/home';
              }
              return null;
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/menu',
            builder: (context, state) => const MenuManagementScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AdminFoodFormScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AdminFoodFormScreen(existingItem: state.extra as MenuItem?),
              ),
              GoRoute(
                path: 'add-category',
                builder: (context, state) => const AdminCategoryFormScreen(),
              ),
              GoRoute(
                path: 'edit-category',
                builder: (context, state) => AdminCategoryFormScreen(
                  existingCategory: state.extra as Category?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (context, state) => const OrderManagementScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => AdminOrderDetailsScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/order-notifications',
            builder: (context, state) => const AdminNotificationCenterScreen(),
          ),
          GoRoute(
            path: '/admin/offers',
            builder: (context, state) => const OffersManagementScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AdminPromoFormScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) => AdminPromoFormScreen(
                  existingPromo: state.extra as PromoCode?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const AdminNotificationsScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
          GoRoute(
            path: '/admin/staff',
            builder: (context, state) => const StaffManagementScreen(),
          ),
          GoRoute(
            path: '/admin/customers',
            builder: (context, state) => const CustomerManagementScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerDetailsScreen(
                  customerId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
