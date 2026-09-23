import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../features/customer/presentation/screens/card_payment_screen.dart';
import '../../features/customer/presentation/screens/saved_cards_screen.dart';
import '../../features/customer/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/presentation/screens/order_review_screen.dart';
import '../../features/customer/presentation/screens/login_screen.dart';
import '../../features/customer/presentation/screens/signup_screen.dart';
import '../../features/customer/presentation/screens/forgot_password_screen.dart';
import '../../features/customer/presentation/screens/reset_password_screen.dart';
import '../../features/customer/presentation/screens/splash_screen.dart';
import '../../features/customer/presentation/screens/language_select_screen.dart';
import '../../features/customer/presentation/screens/onboarding_screen.dart';
import '../../features/customer/presentation/screens/auth_choice_screen.dart';
import '../../features/customer/presentation/screens/privacy_policy_screen.dart';
import '../../features/customer/presentation/screens/terms_of_service_screen.dart';
import '../../features/customer/presentation/shells/customer_shell.dart';
import '../../features/admin/presentation/shells/admin_shell.dart';
import '../../features/admin/presentation/screens/dashboard_screen.dart';
import '../../features/admin/presentation/screens/menu_management_screen.dart';
import '../../features/admin/presentation/screens/admin_food_form_screen.dart';
import '../../features/admin/presentation/screens/admin_category_form_screen.dart';
import '../../features/admin/presentation/screens/admin_promo_form_screen.dart';
import '../../features/admin/presentation/screens/menu_offers_screen.dart';
import '../../features/admin/presentation/screens/admin_menu_offer_form_screen.dart';
import '../../features/admin/presentation/screens/order_management_screen.dart';
import '../../features/admin/presentation/screens/offers_screen.dart';
import '../../features/admin/presentation/screens/restaurant_profile_screen.dart';
import '../../features/admin/presentation/screens/working_hours_screen.dart';
import '../../features/admin/presentation/screens/order_settings_screen.dart';
import '../../features/admin/presentation/screens/pricing_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_notification_center_screen.dart';
import '../../features/admin/presentation/screens/admin_order_details_screen.dart';
import '../../features/admin/presentation/screens/admin_order_sound_settings_screen.dart';
import '../../features/admin/presentation/screens/kitchen_queue_screen.dart';
import '../../features/admin/presentation/screens/kitchen_ticket_screen.dart';
import '../../features/admin/presentation/screens/staff_management_screen.dart';
import '../../features/admin/presentation/screens/driver_management_screen.dart';
import '../../features/driver/presentation/shells/driver_shell.dart';
import '../../features/driver/presentation/screens/driver_orders_screen.dart';
import '../../features/driver/presentation/screens/driver_history_screen.dart';
import '../../features/driver/presentation/screens/driver_order_details_screen.dart';
import '../../features/driver/presentation/screens/driver_account_screen.dart';
import '../../features/admin/presentation/screens/customer_management_screen.dart';
import '../../features/admin/presentation/screens/customer_details_screen.dart';
import '../../features/admin/presentation/screens/admin_reviews_screen.dart';
import '../../features/customer/presentation/notifiers/auth_notifier.dart';
import '../../features/shared/domain/models/order.dart';
import '../../features/shared/domain/models/menu_item.dart';
import '../../features/shared/domain/models/category.dart';
import '../../features/shared/domain/models/promo_code.dart';
import '../../features/shared/domain/models/menu_offer.dart';
import '../../features/shared/domain/models/address.dart';
import 'kz_page_transitions.dart';

/// Manually declared (not `@riverpod`-generated): riverpod_generator's 2.x
/// line hard-caps `analyzer` below the version freezed 4.x requires (see
/// pubspec.yaml's freezed/build_runner comments), and riverpod_generator
/// 4.x would force a breaking `riverpod`/`flutter_riverpod` 3.x bump across
/// every notifier in this app — far outside a codegen-toolchain fix. This
/// is the exact equivalent of what `@riverpod GoRouter router(Ref ref)`
/// used to generate (`AutoDisposeProvider<GoRouter>`, no tracked
/// dependencies, same name/lifecycle) — verified against the last-generated
/// `router.g.dart` before it was deleted.
final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      final auth = ref.read(authNotifierProvider);
      final role = auth.user?.role;

      final isAdminPath = path.startsWith('/admin');
      final isDriverPath = path.startsWith('/driver');

      // Unauthenticated users never reach any /admin/* or /driver/* route.
      if ((isAdminPath || isDriverPath) && !auth.isLoggedIn) {
        return '/login';
      }

      if (isDriverPath) {
        // Only an active DRIVER session may reach the driver app — any
        // other authenticated role (ADMIN/CASHIER/KITCHEN/CUSTOMER) is
        // bounced back to its own home, same "confined section" pattern
        // used for CASHIER/KITCHEN below.
        if (role == 'DRIVER') return null;
        return role == 'ADMIN'
            ? '/admin/dashboard'
            : role == 'CASHIER'
            ? '/admin/orders'
            : role == 'KITCHEN'
            ? '/admin/kitchen'
            : '/home';
      }

      if (isAdminPath) {
        // A DRIVER session never has any business in /admin/* — deep link
        // or stale navigation state must never leak them in.
        if (role == 'DRIVER') return '/driver/orders';

        // ADMIN has full access to every /admin/* route.
        if (role == 'ADMIN') return null;

        // A cashier may only reach Orders Management inside /admin — every
        // other admin section (dashboard metrics, menu, promos, settings,
        // staff, etc.) redirects back there even on a direct/manual navigation.
        if (role == 'CASHIER') {
          return path.startsWith('/admin/orders') ? null : '/admin/orders';
        }

        // Kitchen staff are pure ticket-viewers — confined to their own
        // queue/detail routes, same pattern as CASHIER above.
        if (role == 'KITCHEN') {
          return path.startsWith('/admin/kitchen') ? null : '/admin/kitchen';
        }

        // Any other authenticated role (CUSTOMER, incl. guest) is not admin
        // staff at all — send them back to customer navigation.
        return '/home';
      }

      // Outside /admin and /driver: a signed-in DRIVER must never reach
      // customer routes (deep link, stale navigation state, etc.) — the
      // pre-auth flow (splash/language-select/onboarding/auth-choice/login/
      // signup/legal) stays reachable for everyone regardless of role.
      const publicPreAuthPaths = {
        '/splash',
        '/language-select',
        '/onboarding',
        '/auth-choice',
        '/login',
        '/signup',
        '/legal/privacy',
        '/legal/terms',
        // Password recovery must stay reachable regardless of role/session
        // state (PASSWORD_RESET_API_CONTRACT.md) — a signed-in DRIVER
        // opening a reset link (their own or anyone else's) must never be
        // bounced back into the driver app before they can use it.
        '/forgot-password',
        '/reset-password',
      };
      if (auth.isLoggedIn &&
          role == 'DRIVER' &&
          !publicPreAuthPaths.contains(path)) {
        return '/driver/orders';
      }

      return null;
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
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: 'tracking/:id',
                    builder: (context, state) => OrderTrackingScreen(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'review/:id',
                    builder: (context, state) =>
                        OrderReviewScreen(orderId: state.pathParameters['id']!),
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
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'loyalty',
                    builder: (context, state) => const LoyaltyScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: 'payment-methods',
                    builder: (context, state) => const SavedCardsScreen(),
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
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const SignupScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => kzFadeSlidePage(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          // Defensively tolerant of a missing/duplicated/malformed `token`
          // param: `Uri.queryParameters` already collapses a repeated key to
          // its last value, and any other unexpected shape here just means
          // `token` reads as `null` — ResetPasswordScreen treats that as
          // "no token" rather than throwing.
          String? token;
          try {
            token = state.uri.queryParameters['token'];
          } catch (_) {
            token = null;
          }
          return kzFadeSlidePage(
            state: state,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const SearchScreen()),
      ),
      GoRoute(
        path: '/legal/privacy',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: '/legal/terms',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const TermsOfServiceScreen()),
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const CartScreen()),
      ),
      GoRoute(
        path: '/item/:id',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return kzFadeSlidePage(
            state: state,
            child: ItemDetailsScreen(
              itemId: state.pathParameters['id']!,
              cartItemId: extra?['cartItemId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/home/item/:id',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return kzFadeSlidePage(
            state: state,
            child: ItemDetailsScreen(
              itemId: state.pathParameters['id']!,
              cartItemId: extra?['cartItemId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/menu/item/:id',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return kzFadeSlidePage(
            state: state,
            child: ItemDetailsScreen(
              itemId: state.pathParameters['id']!,
              cartItemId: extra?['cartItemId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            kzFadeSlidePage(state: state, child: const CheckoutScreen()),
        routes: [
          GoRoute(
            path: 'success',
            pageBuilder: (context, state) => kzFadeSlidePage(
              state: state,
              child: OrderSuccessScreen(order: state.extra as Order),
            ),
            redirect: (context, state) {
              if (state.extra == null || state.extra is! Order) {
                return '/home';
              }
              return null;
            },
          ),
          GoRoute(
            path: 'card-payment',
            pageBuilder: (context, state) => kzFadeSlidePage(
              state: state,
              child: CardPaymentScreen(order: state.extra as Order),
            ),
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
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const DashboardScreen()),
          ),
          GoRoute(
            path: '/admin/menu',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const MenuManagementScreen()),
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
            path: '/admin/menu-offers',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const MenuOffersScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AdminMenuOfferFormScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) => AdminMenuOfferFormScreen(
                  existingOffer: state.extra as MenuOffer?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/orders',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const OrderManagementScreen()),
            routes: [
              // Nested under /admin/orders (not a standalone /admin/*
              // route) specifically so CASHIER — confined to the
              // /admin/orders prefix — can reach the order-sound-alert
              // settings too; this is a front-of-house device setting, not
              // an owner-only one. Declared BEFORE the ':id' route below so
              // this literal segment matches first — otherwise ':id' would
              // greedily capture "sound-alerts" as an order id.
              GoRoute(
                path: 'sound-alerts',
                pageBuilder: (context, state) => kzAdminPage(
                  state: state,
                  child: const AdminOrderSoundSettingsScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => AdminOrderDetailsScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/reviews',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const AdminReviewsScreen()),
          ),
          GoRoute(
            path: '/admin/kitchen',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const KitchenQueueScreen()),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    KitchenTicketScreen(orderId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/order-notifications',
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const AdminNotificationCenterScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/offers',
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const OffersManagementScreen(),
            ),
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
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const AdminNotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/restaurant-profile',
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const RestaurantProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/working-hours',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const WorkingHoursScreen()),
          ),
          GoRoute(
            path: '/admin/order-settings',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const OrderSettingsScreen()),
          ),
          GoRoute(
            path: '/admin/pricing-settings',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const PricingSettingsScreen()),
          ),
          GoRoute(
            path: '/admin/staff',
            pageBuilder: (context, state) =>
                kzAdminPage(state: state, child: const StaffManagementScreen()),
          ),
          GoRoute(
            path: '/admin/drivers',
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const DriverManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/customers',
            pageBuilder: (context, state) => kzAdminPage(
              state: state,
              child: const CustomerManagementScreen(),
            ),
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
      ShellRoute(
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: '/driver/orders',
            builder: (context, state) => const DriverOrdersScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => DriverOrderDetailsScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/driver/history',
            builder: (context, state) => const DriverHistoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => DriverOrderDetailsScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/driver/account',
            builder: (context, state) => const DriverAccountScreen(),
          ),
        ],
      ),
    ],
  );
});
