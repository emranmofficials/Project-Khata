import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/org_setup_screen.dart';
import '../../../client/presentation/screens/client_home_screen.dart';
import '../../../contractor/presentation/screens/contractor_home_screen.dart';
import '../../../contractor/presentation/screens/contractor_more_screen.dart';
import '../../../project/presentation/screens/project_list_screen.dart';
import '../../../accounting/presentation/screens/accounts_dashboard_screen.dart';
import '../../../supervisor/presentation/screens/supervisor_home_screen.dart';
import '../../../worker/presentation/screens/worker_home_screen.dart';

/// PRD সেকশন ৫ ও ১০.১ অনুযায়ী ভূমিকা-ভিত্তিক মূল নেভিগেশন রাউটার
class RootNavigationScreen extends ConsumerStatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  ConsumerState<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends ConsumerState<RootNavigationScreen> {
  int _contractorCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // ১. লোডিং স্টেট
    if (authState.isLoading && authState.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ২. লগইন না থাকলে লগইন স্ক্রিন
    if (!authState.isAuthenticated || authState.user == null) {
      return const LoginScreen();
    }

    final user = authState.user!;

    // ৩. প্রথম লগইনে পাসওয়ার্ড পরিবর্তন বাধ্যতামূলক (PRD Rule 4)
    if (user.mustChangePassword) {
      return const ChangePasswordScreen(isMandatory: true);
    }

    // ৪. ঠিকাদার প্রথমবার লগইন করলে প্রতিষ্ঠান সেটআপ বাধ্যতামূলক (PRD Section 6.1)
    if (user.isContractor && !user.hasOrganization) {
      return const OrgSetupScreen();
    }

    // ৫. ভূমিকা অনুযায়ী মূল স্ক্রিন প্রদর্শন
    if (user.isContractor) {
      return _buildContractorNav(context);
    } else if (user.isSupervisor) {
      return const SupervisorHomeScreen();
    } else if (user.isClient) {
      return const ClientHomeScreen();
    } else {
      return const WorkerHomeScreen();
    }
  }

  /// ঠিকাদারের জন্য ৫-ট্যাব নেভিগেশন (PRD সেকশন ৫.১)
  Widget _buildContractorNav(BuildContext context) {
    final screens = [
      const ContractorHomeScreen(),
      const ProjectListScreen(),
      const Scaffold(body: Center(child: Text('শ্রমিক ও সুপারভাইজার'))),
      const AccountsDashboardScreen(),
      const ContractorMoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _contractorCurrentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _contractorCurrentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _contractorCurrentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment_rounded),
            label: 'প্রজেক্ট',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'শ্রমিক',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'হিসাব',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'আরও',
          ),
        ],
      ),
    );
  }
}
