import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/select_type_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/businesses/businesses_screen.dart';
import '../screens/businesses/business_detail_screen.dart';
import '../screens/craftsmen/craftsmen_screen.dart';
import '../screens/craftsmen/craftsman_detail_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/craftsman_dashboard_screen.dart';
import '../screens/profile/business_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),

    // Auth
    GoRoute(path: '/auth/select', builder: (_, __) => const SelectTypeScreen()),
    GoRoute(path: '/auth/login/:type', builder: (_, state) =>
        LoginScreen(type: state.pathParameters['type']!)),
    GoRoute(path: '/auth/register/:type', builder: (_, state) =>
        RegisterScreen(type: state.pathParameters['type']!)),

    // Businesses
    GoRoute(path: '/businesses', builder: (_, __) => const BusinessesScreen()),
    GoRoute(path: '/businesses/:domain', builder: (_, state) =>
        BusinessDetailScreen(domain: state.pathParameters['domain']!)),

    // Craftsmen
    GoRoute(path: '/craftsmen', builder: (_, __) => const CraftsmenScreen()),
    GoRoute(path: '/craftsmen/:username', builder: (_, state) =>
        CraftsmanDetailScreen(username: state.pathParameters['username']!)),

    // Categories
    GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),

    // Profile / Dashboards
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/craftsman/dashboard', builder: (_, __) => const CraftsmanDashboardScreen()),
    GoRoute(path: '/business/dashboard', builder: (_, __) => const BusinessDashboardScreen()),
  ],
);
