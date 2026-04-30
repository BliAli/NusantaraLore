import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/biometric_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/explore/presentation/explore_screen.dart';
import 'features/explore/presentation/budaya_detail_screen.dart';
import 'features/explore/presentation/budaya_map_screen.dart';
import 'features/games/presentation/games_menu_screen.dart';
import 'features/games/presentation/kuis_mitos_screen.dart';
import 'features/games/presentation/puzzle_batik_screen.dart';
import 'features/games/presentation/tebak_wayang_screen.dart';
import 'features/ai_penjaga/presentation/penjaga_screen.dart';
import 'features/converter/presentation/converter_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometric,
        builder: (context, state) => const BiometricScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: AppRoutes.budayaDetail,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return BudayaDetailScreen(budayaId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const BudayaMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.games,
            builder: (context, state) => const GamesMenuScreen(),
          ),
          GoRoute(
            path: AppRoutes.kuisMitos,
            builder: (context, state) => const KuisMitosScreen(),
          ),
          GoRoute(
            path: AppRoutes.puzzleBatik,
            builder: (context, state) => const PuzzleBatikScreen(),
          ),
          GoRoute(
            path: AppRoutes.tebakWayang,
            builder: (context, state) => const TebakWayangScreen(),
          ),
          GoRoute(
            path: AppRoutes.penjaga,
            builder: (context, state) => const PenjagaScreen(),
          ),
          GoRoute(
            path: AppRoutes.converter,
            builder: (context, state) => const ConverterScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class NusantaraLoreApp extends ConsumerWidget {
  const NusantaraLoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorPrimary,
          primary: kColorPrimary,
          secondary: kColorSecondary,
          surface: kColorSurface,
          error: kColorError,
        ),
        scaffoldBackgroundColor: kColorBackground,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: kColorPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kColorPrimary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      routerConfig: router,
    );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/explore') ||
        location.startsWith('/home/map') ||
        location.startsWith('/home/search')) {
      return 1;
    }
    if (location.startsWith('/home/games')) {
      return 2;
    }
    if (location.startsWith('/home/penjaga')) {
      return 3;
    }
    if (location.startsWith('/home/profile') ||
        location.startsWith('/home/converter')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.explore);
            case 2:
              context.go(AppRoutes.games);
            case 3:
              context.go(AppRoutes.penjaga);
            case 4:
              context.go(AppRoutes.profile);
          }
        },
        backgroundColor: kColorSurface,
        indicatorColor: kColorPrimary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: kColorPrimary),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: kColorPrimary),
            label: AppStrings.navExplore,
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports, color: kColorPrimary),
            label: AppStrings.navGames,
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: kColorPrimary),
            label: AppStrings.navPenjaga,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: kColorPrimary),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
