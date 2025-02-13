
import 'package:doctors_web/routes/routes_name.dart';
import 'package:go_router/go_router.dart';

import '../screens/error_screen.dart';
import '../screens/home_screen.dart';


class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesName.homeScreenRoute,
    routes: <GoRoute>[
      GoRoute(
        path: RoutesName.homeScreenRoute,
        builder: (context, state) => const HomeScreen(),
      ),

      // Add more routes here
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),
  );
}
