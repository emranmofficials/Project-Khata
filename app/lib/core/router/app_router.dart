import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/contractor_register_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/client_dashboard.dart';
import '../../features/dashboard/presentation/screens/contractor_dashboard.dart';
import '../../features/dashboard/presentation/screens/supervisor_dashboard.dart';
import '../../features/dashboard/presentation/screens/worker_dashboard.dart';
import '../../features/projects/domain/models/project.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/attendance/presentation/screens/daily_entry_screen.dart';
import '../../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../../features/accounts/presentation/screens/project_accounts_screen.dart';
import '../../features/accounts/presentation/screens/organization_payments_screen.dart';
import '../../features/accounts/presentation/screens/worker_wage_history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading) return '/';

      final user = authState.value;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register-contractor';

      // Not logged in
      if (user == null) {
        if (isRegistering) return null;
        return isLoggingIn ? null : '/login';
      }

      // Mandatory Password Change
      if (user.mustChangePassword) {
        return '/change-password';
      }

      // If already logged in and navigating to auth screens, redirect to role dashboard
      if (isLoggingIn || isRegistering || state.matchedLocation == '/' || state.matchedLocation == '/change-password') {
        switch (user.role) {
          case UserRole.contractor:
            return '/contractor';
          case UserRole.client:
            return '/client';
          case UserRole.supervisor:
            return '/supervisor';
          case UserRole.worker:
            return '/worker';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-contractor',
        builder: (context, state) => const ContractorRegisterScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/contractor',
        builder: (context, state) => const ContractorDashboard(),
      ),
      GoRoute(
        path: '/client',
        builder: (context, state) => const ClientDashboard(),
      ),
      GoRoute(
        path: '/supervisor',
        builder: (context, state) => const SupervisorDashboard(),
      ),
      GoRoute(
        path: '/worker',
        builder: (context, state) => const WorkerDashboard(),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/project-details',
        builder: (context, state) =>
            ProjectDetailsScreen(project: state.extra as Project),
      ),
      GoRoute(
        path: '/daily-entry',
        builder: (context, state) =>
            DailyEntryScreen(projectId: state.extra as String?),
      ),
      GoRoute(
        path: '/attendance-history',
        builder: (context, state) =>
            AttendanceHistoryScreen(workerId: state.extra as String?),
      ),
      GoRoute(
        path: '/project-accounts',
        builder: (context, state) =>
            ProjectAccountsScreen(project: state.extra as Project),
      ),
      GoRoute(
        path: '/organization-payments',
        builder: (context, state) => const OrganizationPaymentsScreen(),
      ),
      GoRoute(
        path: '/worker-wages',
        builder: (context, state) => const WorkerWageHistoryScreen(),
      ),
    ],
  );
});
