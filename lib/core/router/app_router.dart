import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/booking/booking_confirmation_screen.dart';
import '../../features/bookings/renter_dashboard_screen.dart';
import '../../features/car_details/car_details_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/profile/documents_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/rental/active_rental_screen.dart';
import '../../features/rental/photo_inspection_screen.dart';
import '../../features/wallet/wallet_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(phone: extra?['phone'] as String? ?? '');
        },
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/car/:id',
        builder: (_, state) =>
            CarDetailsScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/confirm/:id',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BookingConfirmationScreen(
            carId: state.pathParameters['id']!,
            startDate: extra?['startDate'] as DateTime? ?? DateTime.now(),
            endDate: extra?['endDate'] as DateTime? ??
                DateTime.now().add(const Duration(days: 1)),
          );
        },
      ),
      GoRoute(
        path: '/bookings',
        builder: (_, _) => const RenterDashboardScreen(),
      ),
      GoRoute(
        path: '/rental/active/:bookingId',
        builder: (_, state) =>
            ActiveRentalScreen(bookingId: state.pathParameters['bookingId']!),
      ),
      GoRoute(
        path: '/rental/inspect/:bookingId',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhotoInspectionScreen(
            bookingId: state.pathParameters['bookingId']!,
            isCheckIn: extra?['isCheckIn'] as bool? ?? true,
          );
        },
      ),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/profile/documents', builder: (_, _) => const DocumentsScreen()),
    ],
  );
}
