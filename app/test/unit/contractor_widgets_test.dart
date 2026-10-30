import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/theme/contractor_theme.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

void main() {
  group('Contractor UI Widgets Tests (HeroSummaryCard & QuickAction)', () {
    testWidgets('HeroSummaryCard renders title, amount, badgeText and subtitle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ContractorTheme.getTheme(isDark: false),
          home: const Scaffold(
            body: HeroSummaryCard(
              title: 'সর্বমোট প্রজেক্ট বাজেট',
              amount: '৳ ২,৫০,০০০',
              badgeText: '৩টি চলমান প্রজেক্ট',
              subtitle: 'বাজেট নিয়ন্ত্রণ সন্তোষজনক',
              secondaryText: 'প্রজেক্ট খাতা',
            ),
          ),
        ),
      );

      expect(find.text('সর্বমোট প্রজেক্ট বাজেট'), findsOneWidget);
      expect(find.text('৳ ২,৫০,০০০'), findsOneWidget);
      expect(find.text('৩টি চলমান প্রজেক্ট'), findsOneWidget);
      expect(find.text('বাজেট নিয়ন্ত্রণ সন্তোষজনক'), findsOneWidget);
      expect(find.text('প্রজেক্ট খাতা'), findsOneWidget);
    });

    testWidgets('HeroSummaryCard responds to onTap event', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroSummaryCard(
              title: 'বাজেট',
              amount: '৳ ১০০',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HeroSummaryCard));
      expect(tapped, isTrue);
    });

    testWidgets('QuickAction renders icon, label and handles tap event',
        (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAction(
              icon: Icons.add_business_rounded,
              label: 'নতুন প্রজেক্ট',
              onTap: () => actionTapped = true,
              badgeCount: 2,
            ),
          ),
        ),
      );

      expect(find.text('নতুন প্রজেক্ট'), findsOneWidget);
      expect(find.byIcon(Icons.add_business_rounded), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byType(QuickAction));
      expect(actionTapped, isTrue);
    });

    testWidgets(
        'SectionTitleRow renders title and actionTitle, and handles tap',
        (tester) async {
      var seeAllTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionTitleRow(
              title: 'চলমান প্রজেক্ট',
              actionTitle: 'সব দেখুন',
              onActionTap: () => seeAllTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('চলমান প্রজেক্ট'), findsOneWidget);
      expect(find.text('সব দেখুন'), findsOneWidget);

      await tester.tap(find.text('সব দেখুন'));
      expect(seeAllTapped, isTrue);
    });

    testWidgets(
        'IconTile renders icon, title, subtitle, and trailing title text',
        (tester) async {
      var tileTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconTile(
              icon: Icons.apartment_rounded,
              title: 'মেঘনা ভিউ রেসিডেন্স',
              subtitle: 'মিরপুর ১০, ঢাকা',
              trailingTitle: '৳ ১,৫০,০০০',
              trailingSubtitle: 'চলমান',
              onTap: () => tileTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
      expect(find.text('মেঘনা ভিউ রেসিডেন্স'), findsOneWidget);
      expect(find.text('মিরপুর ১০, ঢাকা'), findsOneWidget);
      expect(find.text('৳ ১,৫০,০০০'), findsOneWidget);
      expect(find.text('চলমান'), findsOneWidget);

      await tester.tap(find.byType(IconTile));
      expect(tileTapped, isTrue);
    });

    testWidgets('ProjectProgressBar renders label and percentage text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectProgressBar(
              progress: 0.75,
              label: 'কাজের অগ্রগতি',
              percentageText: '৭৫%',
            ),
          ),
        ),
      );

      expect(find.text('কাজের অগ্রগতি'), findsOneWidget);
      expect(find.text('৭৫%'), findsOneWidget);
    });

    testWidgets('ModernOverviewStrip renders active projects, workers and approvals', (tester) async {
      var projectTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernOverviewStrip(
              activeProjects: 4,
              workersPresent: 28,
              pendingApprovals: 3,
              onProjectsTap: () => projectTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('৪টি'), findsOneWidget);
      expect(find.text('২৮ জন'), findsOneWidget);
      expect(find.text('৩টি'), findsOneWidget);
      expect(find.text('চলমান প্রজেক্ট'), findsOneWidget);
      expect(find.text('আজ উপস্থিত'), findsOneWidget);
      expect(find.text('অনুমোদন বাকি'), findsOneWidget);

      await tester.tap(find.text('৪টি'));
      expect(projectTapped, isTrue);
    });

    testWidgets('FinancialRatioBar renders income and expense amounts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialRatioBar(
              income: 500000,
              expense: 350000,
            ),
          ),
        ),
      );

      expect(find.textContaining('মোট আয়:'), findsOneWidget);
      expect(find.textContaining('ব্যয়:'), findsOneWidget);
    });

    testWidgets('EmptyState.placeholder renders title, subtitle and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ContractorTheme.getTheme(isDark: false),
          home: const Scaffold(
            body: EmptyState.placeholder(
              title: 'খসড়া পৃষ্ঠা',
              subtitle: 'এই ফিচারটি শীঘ্রই আসছে',
            ),
          ),
        ),
      );

      expect(find.text('খসড়া পৃষ্ঠা'), findsOneWidget);
      expect(find.text('এই ফিচারটি শীঘ্রই আসছে'), findsOneWidget);
      expect(find.byIcon(Icons.construction_outlined), findsOneWidget);
    });
  });

  group('Contractor Helper Functions Unit Tests', () {
    test('toBn(\'12\') returns \'১২\' and handles numbers correctly', () {
      expect(toBn('12'), '১২');
      expect(toBn(12), '১২');
      expect(toBn('100 মিটার'), '১০০ মিটার');
      expect(toBn(null), '');
    });

    test('greetingByHour returns appropriate greeting based on hour', () {
      final morning = DateTime(2026, 1, 1, 8, 0); // 8 AM -> শুভ সকাল
      final afternoon = DateTime(2026, 1, 1, 13, 0); // 1 PM -> শুভ দুপুর
      final evening = DateTime(2026, 1, 1, 19, 0); // 7 PM -> শুভ সন্ধ্যা
      final night = DateTime(2026, 1, 1, 23, 0); // 11 PM -> শুভ সন্ধ্যা

      expect(greetingByHour(morning), 'শুভ সকাল');
      expect(greetingByHour(afternoon), 'শুভ দুপুর');
      expect(greetingByHour(evening), 'শুভ সন্ধ্যা');
      expect(greetingByHour(night), 'শুভ সন্ধ্যা');
    });
  });
}
