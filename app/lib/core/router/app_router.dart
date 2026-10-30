import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/contractor_login_screen.dart';
import '../../features/auth/presentation/screens/contractor_register_screen.dart';
import '../../features/auth/presentation/screens/create_organization_screen.dart';
import '../../features/auth/presentation/screens/member_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/client_dashboard.dart';
import '../../features/contractor/domain/models/contractor_models.dart' show MemberRole;
import '../../features/contractor/presentation/contractor_shell.dart';
import '../../features/contractor/presentation/screens/contractor_screens.dart';
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
import '../../features/notifications/presentation/screens/notification_center_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final needsOrg = ref.watch(needsOrganizationProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading) return '/';

      final user = authState.value;
      final matchedLoc = state.matchedLocation;
      final isLoggingIn = matchedLoc.startsWith('/login');
      final isRegistering = matchedLoc == '/register-contractor';
      final isCreatingOrg = matchedLoc == '/create-organization';
      final isChangingPassword = matchedLoc == '/change-password';

      // 1. Contractor has Supabase account but no organization/profile yet
      if (needsOrg) {
        return isCreatingOrg ? null : '/create-organization';
      }

      // 2. Not logged in
      if (user == null) {
        if (isRegistering || isLoggingIn) return null;
        return '/login/member';
      }

      // 3. Mandatory Password Change Guard
      if (user.mustChangePassword) {
        return isChangingPassword ? null : '/change-password';
      }

      // 4. If password change is done, do not allow staying on /change-password
      if (isChangingPassword) {
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

      // 5. If logged in and navigating to auth/splash/create-org screens, redirect to role dashboard
      if (isLoggingIn || isRegistering || isCreatingOrg || matchedLoc == '/') {
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
        redirect: (_, __) => '/login/member',
      ),
      GoRoute(
        path: '/login/member',
        builder: (context, state) => const MemberLoginScreen(),
      ),
      GoRoute(
        path: '/login/contractor',
        builder: (context, state) => const ContractorLoginScreen(),
      ),
      GoRoute(
        path: '/create-organization',
        builder: (context, state) => const CreateOrganizationScreen(),
      ),
      GoRoute(
        path: '/register-contractor',
        builder: (context, state) => const ContractorRegisterScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ContractorShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contractor',
                builder: (context, state) => const ContractorDashboardScreen(),
              ),
            ],
          ),
          // Branch 2: Projects
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contractor/projects',
                builder: (context, state) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const ContractorCreateProjectScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ContractorProjectDetailsScreen(projectId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          return ProjectEditScreen(projectId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Workers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contractor/workers',
                builder: (context, state) => const WorkersScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const AddMemberScreen(
                      initialRole: MemberRole.worker,
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return WorkerDetailsScreen(workerId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/contractor/supervisors/new',
                builder: (context, state) => const AddMemberScreen(
                  initialRole: MemberRole.supervisor,
                ),
              ),
              GoRoute(
                path: '/contractor/supervisors/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return SupervisorDetailsScreen(supervisorId: id);
                },
              ),
            ],
          ),
          // Branch 4: Accounts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contractor/accounts',
                builder: (context, state) => const AccountsScreen(),
                routes: [
                  GoRoute(
                    path: 'projects/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ContractorProjectAccountsScreen(projectId: id);
                    },
                  ),
                  GoRoute(
                    path: 'wages',
                    builder: (context, state) => const WagesScreen(),
                  ),
                  GoRoute(
                    path: 'payments',
                    builder: (context, state) => const PaymentsScreen(),
                  ),
                  GoRoute(
                    path: 'client-payments',
                    builder: (context, state) =>
                        const ClientPaymentsScreen(),
                  ),
                  GoRoute(
                    path: 'materials',
                    builder: (context, state) => const MaterialsScreen(),
                  ),
                  GoRoute(
                    path: 'site-expenses',
                    builder: (context, state) => const SiteExpensesScreen(),
                  ),
                  GoRoute(
                    path: 'bill-statements',
                    builder: (context, state) =>
                        const BillStatementsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 5: More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contractor/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'approvals',
                    builder: (context, state) =>
                        const EntryApprovalsScreen(),
                  ),
                  GoRoute(
                    path: 'company',
                    builder: (context, state) =>
                        const CompanyProfileScreen(),
                  ),
                  GoRoute(
                    path: 'designations',
                    builder: (context, state) =>
                        const DesignationsScreen(),
                  ),
                  GoRoute(
                    path: 'supervisor-pay',
                    builder: (context, state) =>
                        const SupervisorPayScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const MyProfileScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'audit-log',
                    builder: (context, state) => const AuditLogScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
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
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
    ],
  );
});
