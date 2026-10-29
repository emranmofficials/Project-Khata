import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../attendance/presentation/screens/attendance_history_screen.dart';

class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    final tabs = [
      _buildAttendanceTab(user),
      _buildWorkAndWagesTab(),
      _buildProfileTab(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        backgroundColor: AppColors.workerIndigo,
        foregroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.workerIndigo.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg, color: AppColors.workerIndigo),
            label: AppStrings.tabAttendance,
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments, color: AppColors.workerIndigo),
            label: AppStrings.tabWorkAndWages,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.workerIndigo),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'আজকের হাজিরা';
      case 1:
        return AppStrings.tabWorkAndWages;
      case 2:
        return AppStrings.tabProfile;
      default:
        return AppStrings.appNameBangla;
    }
  }

  Widget _buildAttendanceTab(UserProfile? user) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AttendanceHistoryScreen(
      workerId: user.id,
      showAppBar: false,
    );
  }

  Widget _buildWorkAndWagesTab() {
    return const Center(
      child: Text(
        'কাজ ও মজুরির হিসাব\n(ফেজ ৪-এ চালু হবে)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildProfileTab(UserProfile? user) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        icon: const Icon(Icons.logout),
        label: const Text(AppStrings.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.workerIndigo,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
