import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/booking/booking_confirmation_screen.dart';
import '../../features/booking/booking_request_screen.dart';
import '../../features/bookings/booking_detail_screen.dart';
import '../../features/bookings/renter_dashboard_screen.dart';
import '../../features/car_details/car_details_screen.dart';
import '../../features/cars/cars_list_screen.dart';
import '../../features/fines/fines_screen.dart';
import '../../features/notifications/notification_preferences_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/verification_gate_screen.dart';
import '../../features/outstanding/outstanding_list_screen.dart';
import '../../features/payments/payments_history_screen.dart';
import '../../features/payments/record_payment_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/profile/documents_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/language_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/support_screen.dart';
import '../../features/profile/trust_level_screen.dart';
import '../../features/rental/active_rental_screen.dart';
import '../../features/rental/extend_rental_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/wallet/wallet_screen.dart';
import '../models/car.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Auth-gate redirect paths
// ---------------------------------------------------------------------------

const _publicPrefixes = ['/login', '/signup', '/splash', '/forgot-password'];
const _verificationGatePath = '/verification-gate';
const _verifyEmailPath = '/verify-email';
const _homePath = '/cars';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
// Gate logic (Option A — 2026-05-23 backend contract discovery):
//   1. Not authenticated              → /login
//   2. Authenticated, docs not verified → /verification-gate
//      (email-verified gate removed: ClientQm has no email_verified field;
//       login success implies email is verified per FastAPI backend behaviour)
//   3. Fully verified on auth pages   → /cars

class AppRouter {
  AppRouter._();

  static GoRouter buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _ProviderListenable(ref),
      redirect: (context, state) => _globalAuthRedirect(ref, state),
      routes: [
        // ----------------------------------------------------------------
        // Public / unauthenticated routes
        // ----------------------------------------------------------------
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return VerifyEmailScreen(
                email: extra?['email'] as String? ?? '');
          },
        ),
        GoRoute(
          path: '/verification-gate',
          builder: (context, state) => const VerificationGateScreen(),
        ),

        // ----------------------------------------------------------------
        // Authenticated + verified shell (4-tab scaffold)
        // ----------------------------------------------------------------
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            // Tab 1 — Cars
            GoRoute(
              path: '/cars',
              builder: (context, state) => const CarsListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => CarDetailsScreen(
                    carId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'book',
                      builder: (context, state) {
                        final extra =
                            state.extra as Map<String, dynamic>?;
                        final car = extra?['car'] as CarListing?;
                        final startDate =
                            extra?['startDate'] as DateTime? ??
                                DateTime.now().add(const Duration(days: 1));
                        final endDate =
                            extra?['endDate'] as DateTime? ??
                                DateTime.now().add(const Duration(days: 2));

                        if (car == null) {
                          return CarDetailsScreen(
                            carId: state.pathParameters['id']!,
                          );
                        }

                        return BookingRequestScreen(
                          car: car,
                          startDate: startDate,
                          endDate: endDate,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'confirm',
                          builder: (context, state) {
                            final extra =
                                state.extra as Map<String, dynamic>?;
                            return BookingConfirmationScreen(
                              carId: state.pathParameters['id']!,
                              bookingId:
                                  extra?['bookingId'] as String? ?? '',
                              startDate:
                                  extra?['startDate'] as DateTime? ??
                                      DateTime.now(),
                              endDate: extra?['endDate'] as DateTime? ??
                                  DateTime.now()
                                      .add(const Duration(days: 1)),
                              car: extra?['car'] as CarListing?,
                              estimatedTotal:
                                  extra?['estimatedTotal'] as int?,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Tab 2 — Bookings
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const RenterDashboardScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => BookingDetailScreen(
                    bookingId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),

            // Tab 3 — Active rental (hidden when no active rental)
            GoRoute(
              path: '/active',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final bookingId = extra?['bookingId'] as String?;
                return ActiveRentalScreen(bookingId: bookingId);
              },
              routes: [
                GoRoute(
                  path: 'extend',
                  builder: (context, state) => const ExtendRentalScreen(),
                ),
              ],
            ),

            // Tab 4 — Profile
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'documents',
                  builder: (context, state) => const DocumentsScreen(),
                ),
                GoRoute(
                  path: 'trust',
                  builder: (context, state) => const TrustLevelScreen(),
                ),
                GoRoute(
                  path: 'fines',
                  builder: (context, state) => const FinesScreen(),
                ),
                GoRoute(
                  path: 'payments',
                  builder: (context, state) =>
                      const PaymentsHistoryScreen(),
                ),
                GoRoute(
                  path: 'outstanding',
                  builder: (context, state) =>
                      const OutstandingListScreen(),
                ),
                GoRoute(
                  path: 'notifications-settings',
                  builder: (context, state) =>
                      const NotificationPreferencesScreen(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguageScreen(),
                ),
                GoRoute(
                  path: 'support',
                  builder: (context, state) => const SupportScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),

            // Wallet (legacy alias)
            GoRoute(
              path: '/wallet',
              builder: (context, state) => const WalletScreen(),
            ),

            // Notifications (any authenticated + verified)
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),

            // Record payment modal
            GoRoute(
              path: '/record-payment',
              builder: (context, state) => const RecordPaymentScreen(),
            ),
          ],
        ),
      ],
    );
  }

  /// Global redirect logic.
  ///
  /// Gate changes vs. previous implementation (2026-05-23):
  ///   - Email-verify gate REMOVED: ClientQm has no email_verified field.
  ///     Login success implies email is verified (Option A).
  ///   - After signup, screens push /verify-email programmatically.
  ///     After verify success, screens push /login.
  ///   - Document verification gate retained as-is.
  static String? _globalAuthRedirect(WidgetRef ref, GoRouterState state) {
    final user = ref.read(currentUserProvider);
    final location = state.uri.toString();

    // 1. Not authenticated → /login (allow public pages through)
    if (user == null) {
      final isPublic = _publicPrefixes.any((p) => location.startsWith(p)) ||
          location.startsWith(_verifyEmailPath);
      if (isPublic) return null;
      return '/login';
    }

    // 2. Authenticated — document verification gate
    final docStatus = user.verificationStatus;
    final isDocGatePath = location.startsWith(_verificationGatePath) ||
        location.startsWith('/profile/documents');
    if (docStatus == VerificationStatus.notStarted ||
        docStatus == VerificationStatus.pending ||
        docStatus == VerificationStatus.rejected) {
      if (isDocGatePath) return null;
      return _verificationGatePath;
    }

    // 3. Fully verified — bounce away from auth/onboarding pages
    final isOnboardingPage =
        _publicPrefixes.any((p) => location.startsWith(p)) ||
            location.startsWith(_verifyEmailPath) ||
            location.startsWith(_verificationGatePath);
    if (isOnboardingPage) return _homePath;

    return null;
  }
}

// ---------------------------------------------------------------------------
// Listenable that notifies GoRouter when auth state changes.
// ---------------------------------------------------------------------------
class _ProviderListenable extends ChangeNotifier {
  _ProviderListenable(WidgetRef ref) {
    ref.listen<AppUser?>(currentUserProvider, (previous, next) {
      if (previous != next) notifyListeners();
    });
  }
}
