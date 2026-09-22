import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/models/booking_status.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import '../../modules/auth/screens/splash_screen.dart';
import '../../modules/auth/screens/onboarding_screen.dart';
import '../../modules/auth/screens/language_select_screen.dart';
import '../../modules/auth/screens/login_screen.dart';
import '../../modules/auth/screens/otp_screen.dart';
import '../../modules/auth/screens/register_screen.dart';
import '../../modules/customer/screens/profile_setup_screen.dart';
import '../../modules/customer/screens/customer_shell.dart';
import '../../modules/customer/screens/home/home_screen.dart';
import '../../modules/customer/screens/home/search_screen.dart';
import '../../modules/customer/screens/bookings/bookings_list_screen.dart';
import '../../modules/customer/screens/messages_list_screen.dart';
import '../../modules/customer/screens/profile/customer_profile_screen.dart';
import '../../modules/customer/screens/service_details_screen.dart';
import '../../modules/customer/screens/provider_profile_screen.dart';
import '../../modules/customer/screens/favorites_screen.dart';
import '../../modules/customer/screens/bookings/booking_wizard_screen.dart';
import '../../modules/customer/screens/bookings/booking_details_screen.dart';
import '../../modules/customer/screens/bookings/live_tracking_screen.dart';
import '../../modules/customer/screens/write_review_screen.dart';
import '../../modules/customer/screens/submit_complaint_screen.dart';
import '../../modules/customer/screens/chat_screen.dart';
import '../../modules/customer/screens/notifications/notifications_screen.dart';
import '../../modules/customer/screens/wallet/wallet_screen.dart';
import '../../modules/customer/screens/settings_screen.dart';
import '../../modules/customer/screens/language_settings_screen.dart';
import '../../modules/customer/screens/currency_settings_screen.dart';
import '../../modules/customer/screens/support_screen.dart';
import '../../modules/customer/screens/address_book_screen.dart';
import '../../modules/customer/screens/my_reviews_screen.dart';
import '../../modules/customer/screens/coupons_screen.dart';
import '../../modules/provider/screens/provider_shell.dart';
import '../../modules/provider/screens/provider_dashboard_screen.dart';
import '../../modules/provider/screens/booking_requests_feed_screen.dart';
import '../../modules/provider/screens/provider_bookings_screen.dart';
import '../../modules/provider/screens/provider_booking_details_screen.dart';
import '../../modules/provider/screens/earnings_screen.dart';
import '../../modules/provider/screens/withdraw_request_screen.dart';
import '../../modules/provider/screens/service_catalog_screen.dart';
import '../../modules/provider/screens/provider_inbox_screen.dart';
import '../../modules/provider/screens/provider_notifications_screen.dart';
import '../../modules/provider/screens/provider_settings_screen.dart';
import '../../modules/provider/screens/kyc_status_screen.dart';
import '../../modules/provider/screens/calendar_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AuthState>(ref.read(authNotifierProvider));
  ref.listen<AuthState>(authNotifierProvider, (prev, next) {
    authListenable.value = next;
  });

  const public = ['/splash', '/onboarding', '/language', '/login', '/otp', '/register'];
  const customerRoots = ['/home', '/search', '/bookings', '/inbox', '/profile'];
  String homeFor(UserRole? role) =>
      role == UserRole.provider ? '/p/dashboard' : '/home';

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;
      final isPublic = public.any((p) => loc.startsWith(p));

      if (!auth.isAuthenticated) {
        return isPublic ? null : '/login';
      }

      // Authenticated: keep users inside their role's area.
      final isProviderArea = loc.startsWith('/p/');
      if (auth.role == UserRole.provider && customerRoots.any((p) => loc.startsWith(p))) {
        return '/p/dashboard';
      }
      if (auth.role == UserRole.customer && isProviderArea) {
        return '/home';
      }
      if (isPublic && loc != '/splash') {
        return homeFor(auth.role);
      }
      if (auth.isAuthenticated &&
          !auth.isProfileComplete &&
          loc != '/profile-setup') {
        return '/profile-setup';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/language', builder: (_, __) => const LanguageSelectScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, s) => const OtpScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupScreen()),

      // ------------------------------------------------ Customer shell
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => CustomerShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
              routes: [
                GoRoute(
                  path: 'services/:slug',
                  builder: (_, s) => ServiceDetailsScreen(
                    slug: s.pathParameters['slug'] ?? '',
                    service: s.extra is Service ? s.extra as Service : null,
                  ),
                ),
                GoRoute(
                  path: 'providers/:id',
                  builder: (_, s) => ProviderProfileScreen(id: s.pathParameters['id'] ?? ''),
                ),
                GoRoute(path: 'favorites', builder: (_, __) => const FavoritesScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (_, __) => const NoTransitionPage(child: SearchScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/bookings',
              pageBuilder: (_, __) => const NoTransitionPage(child: BookingsListScreen()),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, s) => BookingWizardScreen(
                    serviceId: s.uri.queryParameters['service_id'],
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, s) => BookingDetailsScreen(id: s.pathParameters['id'] ?? ''),
                  routes: [
                    GoRoute(
                      path: 'track',
                      builder: (_, s) => LiveTrackingScreen(id: s.pathParameters['id'] ?? ''),
                    ),
                    GoRoute(
                      path: 'review',
                      builder: (_, s) => WriteReviewScreen(id: s.pathParameters['id'] ?? ''),
                    ),
                    GoRoute(
                      path: 'complaint',
                      builder: (_, s) => SubmitComplaintScreen(id: s.pathParameters['id'] ?? ''),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/inbox',
              pageBuilder: (_, __) => const NoTransitionPage(child: MessagesListScreen()),
              routes: [
                GoRoute(
                  path: ':threadId',
                  builder: (_, s) => ChatScreen(threadId: s.pathParameters['threadId'] ?? ''),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (_, __) => const NoTransitionPage(child: CustomerProfileScreen()),
            ),
          ]),
        ],
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'language', builder: (_, __) => const LanguageSettingsScreen()),
          GoRoute(path: 'currency', builder: (_, __) => const CurrencySettingsScreen()),
        ],
      ),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressBookScreen()),
      GoRoute(path: '/profile/reviews', builder: (_, __) => const MyReviewsScreen()),
      GoRoute(path: '/profile/coupons', builder: (_, __) => const CouponsScreen()),

      // ------------------------------------------------ Provider shell
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ProviderShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/p/dashboard',
              pageBuilder: (_, __) => const NoTransitionPage(child: ProviderDashboardScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/p/requests',
              pageBuilder: (_, __) => const NoTransitionPage(child: BookingRequestsFeedScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/p/bookings',
              pageBuilder: (_, __) => const NoTransitionPage(child: ProviderBookingsScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, s) =>
                      ProviderBookingDetailsScreen(id: s.pathParameters['id'] ?? ''),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/p/earnings',
              pageBuilder: (_, __) => const NoTransitionPage(child: EarningsScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/p/inbox',
              pageBuilder: (_, __) => const NoTransitionPage(child: ProviderInboxScreen()),
              routes: [
                GoRoute(
                  path: ':t',
                  builder: (_, s) => ChatScreen(threadId: s.pathParameters['t'] ?? ''),
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(path: '/p/withdraw', builder: (_, __) => const WithdrawRequestScreen()),
      GoRoute(path: '/p/services', builder: (_, __) => const ServiceCatalogScreen()),
      GoRoute(path: '/p/notifications', builder: (_, __) => const ProviderNotificationsScreen()),
      GoRoute(path: '/p/settings', builder: (_, __) => const ProviderSettingsScreen()),
      GoRoute(path: '/p/kyc', builder: (_, __) => const KycStatusScreen()),
      GoRoute(path: '/p/calendar', builder: (_, __) => const CalendarScreen()),
    ],
  );
}, name: 'routerProvider');
