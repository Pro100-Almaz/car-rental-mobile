import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/bookings/renter_dashboard_screen.dart';
import '../../features/car_details/car_details_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/wallet/wallet_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/car/:id',
        builder: (_, state) =>
            CarDetailsScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bookings',
        builder: (_, _) => const RenterDashboardScreen(),
      ),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
  );
}
