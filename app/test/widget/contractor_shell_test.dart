import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_strings.dart';
import 'package:project_khata/core/theme/contractor_theme.dart';
import 'package:project_khata/features/contractor/presentation/contractor_shell.dart';
import 'package:project_khata/features/contractor/presentation/screens/projects/create_project_screen.dart';

void main() {
  group('Contractor UI Widget Tests', () {
    testWidgets('ContractorShell renders 5 navigation destinations', (tester) async {
      final testRouter = GoRouter(
        initialLocation: '/contractor',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ContractorShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/contractor',
                    builder: (context, state) => const Scaffold(body: Text('হোম স্ক্রিন')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/contractor/projects',
                    builder: (context, state) => const Scaffold(body: Text('প্রজেক্ট স্ক্রিন')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/contractor/workers',
                    builder: (context, state) => const Scaffold(body: Text('শ্রমিক স্ক্রিন')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/contractor/accounts',
                    builder: (context, state) => const Scaffold(body: Text('হিসাব স্ক্রিন')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/contractor/more',
                    builder: (context, state) => const Scaffold(body: Text('আরও স্ক্রিন')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: ContractorTheme.getTheme(isDark: false),
            routerConfig: testRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(ContractorStrings.home), findsOneWidget);
      expect(find.text(ContractorStrings.projects), findsOneWidget);
      expect(find.text(ContractorStrings.workersTab), findsOneWidget);
      expect(find.text(ContractorStrings.accounts), findsOneWidget);
      expect(find.text(ContractorStrings.more), findsOneWidget);
    });

    testWidgets('ContractorCreateProjectScreen validates invalid mobile number', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ContractorTheme.getTheme(isDark: false),
            home: const ContractorCreateProjectScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'আমার নতুন প্রজেক্ট');
      await tester.enterText(textFields.at(1), 'ধানমন্ডি, ঢাকা');
      await tester.enterText(textFields.at(2), 'মালিক সাহেব');
      await tester.enterText(textFields.at(3), '012345');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(FilledButton, ContractorStrings.createNewProject);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidMobile), findsOneWidget);
    });
  });
}
