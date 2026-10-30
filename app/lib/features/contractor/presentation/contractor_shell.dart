import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/theme/contractor_theme.dart';

class ContractorShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ContractorShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? ContractorTheme.darkBorderColor : ContractorTheme.lightBorderColor;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? ContractorTheme.darkSurface : ContractorTheme.lightSurface,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 72,
            indicatorColor: (isDark
                    ? ContractorTheme.darkPrimaryNavy
                    : ContractorTheme.primaryNavy)
                .withValues(alpha: 0.14),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: ContractorStrings.tabHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment_rounded),
                label: ContractorStrings.tabProjects,
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: ContractorStrings.tabWorkers,
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: ContractorStrings.tabAccounts,
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz_outlined),
                selectedIcon: Icon(Icons.more_horiz_rounded),
                label: ContractorStrings.tabMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
