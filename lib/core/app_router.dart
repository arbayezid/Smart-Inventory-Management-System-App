import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/super_admin/super_admin_shell.dart';
import '../providers/auth_provider.dart';

/// A [ChangeNotifier] that bridges Riverpod's [authProvider] state into a
/// [Listenable] that GoRouter can subscribe to. This allows a single GoRouter
/// instance to be created once and refresh only its redirect logic — rather
/// than being fully recreated — whenever authentication state changes.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(this._ref) {
    // Listen to the authProvider and notify GoRouter whenever it changes.
    _ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  AuthState get _authState => _ref.read(authProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _authState;

    // While loading the persisted session, don't redirect anywhere.
    if (authState.isLoading) return null;

    final isLoggedIn = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/register';
    final isSuperAdminRoute = state.matchedLocation == '/super-admin';
    final isSuperAdmin = authState.user?.role == 'SuperAdmin';

    if (!isLoggedIn) {
      // Not logged in: only allow login or register screens.
      if (isLoggingIn || isRegistering) return null;
      return '/login';
    }

    // Logged in: redirect away from auth screens to the correct dashboard.
    if (isLoggingIn || isRegistering) {
      return isSuperAdmin ? '/super-admin' : '/';
    }

    // Prevent a SuperAdmin from landing on the shop-owner dashboard.
    if (isSuperAdmin && state.matchedLocation == '/') {
      return '/super-admin';
    }

    // Prevent a ShopOwner from accessing the super-admin route.
    if (!isSuperAdmin && isSuperAdminRoute) {
      return '/';
    }

    return null;
  }
}

/// The single [GoRouter] instance for the app. Using [refreshListenable] with
/// a Riverpod-backed [ChangeNotifier] ensures the router is created **once**
/// and only re-evaluates its [redirect] callback when auth state changes,
/// preventing the new-router-on-every-rebuild flash bug.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/super-admin',
        builder: (context, state) => const SuperAdminShell(),
      ),
    ],
  );

  // Dispose the notifier when the provider is disposed.
  ref.onDispose(notifier.dispose);

  return router;
});
