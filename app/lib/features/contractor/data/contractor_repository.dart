import '../domain/models/contractor_models.dart';

abstract class ContractorRepository {
  Future<DashboardSummary> getDashboardSummary();

  Future<List<ProjectSummary>> getProjects({
    ProjectStatus? status,
    String? query,
  });

  Future<ProjectDetails> getProjectDetails(String id);

  Future<List<ClientInfo>> getClients();

  Future<ProjectDetails> createProject(NewProjectInput input);

  Future<ProjectDetails> updateProject(UpdateProjectInput input);

  Future<void> updateProjectStatus(String id, ProjectStatus status);

  Future<void> assignSupervisor(String projectId, String supervisorId);

  Future<void> unassignSupervisor(String projectId, String supervisorId);

  Future<List<MemberSummary>> getMembers(
    MemberRole role, {
    String? designationId,
    String? query,
  });

  Future<MemberDetails> getMemberDetails(String id);

  Future<MemberDetails> createMember(NewMemberInput input);

  Future<MemberDetails> updateMember(
    String id, {
    String? name,
    String? designationId,
    double? dailyWage,
  });

  Future<void> setMemberActive(String id, bool isActive);

  Future<void> resetMemberPassword(String id);

  Future<List<Designation>> getDesignations();

  Future<Designation> upsertDesignation({
    String? id,
    required String name,
    required double dailyWage,
    required double overtimeRatePerHour,
  });

  Future<ContractorCompanyProfile> getCompanyProfile();

  Future<void> updateCompanyProfile(ContractorCompanyProfile profile);

  Future<List<EntryPreview>> getEntries({String? projectId, DateTime? date});

  Future<List<EntryApproval>> getApprovals({ApprovalType? type});

  Future<void> approveEntry(String id);

  Future<void> rejectEntry(String id);

  Future<ExpenseReport> getAccountsSummary();

  Future<List<WageSummary>> getWages({
    String? projectId,
    String? workerId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<List<PaymentRecord>> getPayments();

  Future<void> allocatePayment({
    required String payeeId,
    required double amount,
    String? specificProjectId,
    String? note,
  });

  Future<List<ClientPayment>> getClientPayments({String? projectId});

  Future<void> recordClientPayment({
    required String projectId,
    required double amount,
    String? note,
  });

  Future<List<ContractorMaterial>> getMaterials({String? projectId});

  Future<List<SiteExpense>> getSiteExpenses({String? projectId});

  Future<void> reviewSiteExpense(String id, bool approve);

  Future<List<BillStatement>> getBillStatements({String? projectId});

  Future<BillStatement> generateBillStatement({
    required String projectId,
    required DateTime periodFrom,
    required DateTime periodTo,
    required String preset,
  });
}
