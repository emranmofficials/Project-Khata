import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/contractor_repository.dart';
import '../data/mock_contractor_repository.dart';
import '../domain/models/contractor_models.dart';

final contractorRepositoryProvider = Provider<ContractorRepository>((ref) {
  return MockContractorRepository();
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getDashboardSummary();
});

final projectsProvider = FutureProvider.autoDispose.family<List<ProjectSummary>, ProjectStatus?>((ref, status) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getProjects(status: status);
});

final projectDetailsProvider = FutureProvider.autoDispose.family<ProjectDetails, String>((ref, id) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getProjectDetails(id);
});

final membersProvider = FutureProvider.autoDispose.family<List<MemberSummary>, MemberRole>((ref, role) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getMembers(role);
});

final memberDetailsProvider = FutureProvider.autoDispose.family<MemberDetails, String>((ref, id) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getMemberDetails(id);
});

final designationsProvider = FutureProvider.autoDispose<List<Designation>>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getDesignations();
});

final companyProfileProvider = FutureProvider.autoDispose<ContractorCompanyProfile>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getCompanyProfile();
});

final approvalsProvider = FutureProvider.autoDispose.family<List<EntryApproval>, ApprovalType?>((ref, type) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getApprovals(type: type);
});

final accountsSummaryProvider = FutureProvider.autoDispose<ExpenseReport>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getAccountsSummary();
});

final wagesProvider = FutureProvider.autoDispose.family<List<WageSummary>, String?>((ref, projectId) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getWages(projectId: projectId);
});

final paymentsProvider = FutureProvider.autoDispose<List<PaymentRecord>>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getPayments();
});

final clientPaymentsProvider = FutureProvider.autoDispose.family<List<ClientPayment>, String?>((ref, projectId) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getClientPayments(projectId: projectId);
});

final materialsProvider = FutureProvider.autoDispose.family<List<ContractorMaterial>, String?>((ref, projectId) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getMaterials(projectId: projectId);
});

final siteExpensesProvider = FutureProvider.autoDispose.family<List<SiteExpense>, String?>((ref, projectId) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getSiteExpenses(projectId: projectId);
});

final billStatementsProvider = FutureProvider.autoDispose.family<List<BillStatement>, String?>((ref, projectId) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getBillStatements(projectId: projectId);
});

final todayEntriesProvider = FutureProvider.autoDispose<List<EntryPreview>>((ref) async {
  final repo = ref.watch(contractorRepositoryProvider);
  return repo.getEntries();
});
