import '../domain/models/contractor_models.dart';
import 'contractor_repository.dart';

class MockContractorRepository implements ContractorRepository {
  ContractorCompanyProfile _company = const ContractorCompanyProfile(
    name: 'বিসমিল্লাহ বিল্ডার্স লিমিটেড',
    address: 'প্লট ১২, রোড ৪, সেক্টর ৯, উত্তরা, ঢাকা',
    phone: '01711000000',
    logoUrl: null,
  );

  final List<ClientInfo> _clients = [
    const ClientInfo(
      id: 'client-1',
      name: 'মোঃ রফিকুল ইসলাম',
      mobile: '01711223344',
      email: 'rafiq@example.com',
    ),
    const ClientInfo(
      id: 'client-2',
      name: 'ফারহানা আহমেদ',
      mobile: '01811223344',
      email: 'farhana@example.com',
    ),
  ];

  final List<Designation> _designations = [
    const Designation(
      id: 'des-1',
      name: 'রাজমিস্ত্রি (হেড)',
      dailyWage: 1200,
      overtimeRatePerHour: 150,
    ),
    const Designation(
      id: 'des-2',
      name: 'সাধারণ রাজমিস্ত্রি',
      dailyWage: 950,
      overtimeRatePerHour: 120,
    ),
    const Designation(
      id: 'des-3',
      name: 'রড মিস্ত্রি',
      dailyWage: 1000,
      overtimeRatePerHour: 130,
    ),
    const Designation(
      id: 'des-4',
      name: 'যোগালি / হেল্পার',
      dailyWage: 650,
      overtimeRatePerHour: 80,
    ),
    const Designation(
      id: 'des-5',
      name: 'সাইট সুপারভাইজার',
      dailyWage: 1400,
      overtimeRatePerHour: 180,
    ),
  ];

  late final List<MemberDetails> _members = [
    MemberDetails(
      id: 'sup-1',
      name: 'তারেক মাহমুদ',
      mobile: '01722334455',
      role: MemberRole.supervisor,
      designationId: 'des-5',
      designationName: 'সাইট সুপারভাইজার',
      dailyWage: 1400,
      overtimeRate: 180,
      isActive: true,
      assignedProjects: ['proj-1', 'proj-2'],
      totalPresentDays: 24,
      pendingWages: 2800,
      hasLoggedIn: true,
      attendanceHistory: [
        AttendanceHistoryItem(
          id: 'att-s1',
          workDate: DateTime.now().subtract(const Duration(days: 1)),
          projectName: 'মেঘনা ভিউ রেসিডেন্স',
          status: 'উপস্থিত',
          overtimeHours: 2,
          earnedAmount: 1760,
        ),
      ],
    ),
    MemberDetails(
      id: 'sup-2',
      name: 'আব্দুল করিম',
      mobile: '01733445566',
      role: MemberRole.supervisor,
      designationId: 'des-5',
      designationName: 'সাইট সুপারভাইজার',
      dailyWage: 1400,
      overtimeRate: 180,
      isActive: true,
      assignedProjects: ['proj-3'],
      totalPresentDays: 20,
      pendingWages: 0,
      hasLoggedIn: true,
      attendanceHistory: [],
    ),
    MemberDetails(
      id: 'wrk-1',
      name: 'মোবারক হোসেন',
      mobile: '01822334455',
      role: MemberRole.worker,
      designationId: 'des-1',
      designationName: 'রাজমিস্ত্রি (হেড)',
      dailyWage: 1200,
      overtimeRate: 150,
      isActive: true,
      assignedProjects: [],
      totalPresentDays: 22,
      pendingWages: 2400,
      hasLoggedIn: true,
      attendanceHistory: [
        AttendanceHistoryItem(
          id: 'att-w1',
          workDate: DateTime.now().subtract(const Duration(days: 1)),
          projectName: 'মেঘনা ভিউ রেসিডেন্স',
          status: 'উপস্থিত',
          overtimeHours: 1,
          earnedAmount: 1350,
        ),
      ],
    ),
    MemberDetails(
      id: 'wrk-2',
      name: 'সুমন চন্দ্র শীল',
      mobile: '01833445566',
      role: MemberRole.worker,
      designationId: 'des-2',
      designationName: 'সাধারণ রাজমিস্ত্রি',
      dailyWage: 950,
      overtimeRate: 120,
      isActive: true,
      assignedProjects: [],
      totalPresentDays: 21,
      pendingWages: 1900,
      hasLoggedIn: true,
      attendanceHistory: [],
    ),
    MemberDetails(
      id: 'wrk-3',
      name: 'জাহাঙ্গীর আলম',
      mobile: '01944556677',
      role: MemberRole.worker,
      designationId: 'des-4',
      designationName: 'যোগালি / হেল্পার',
      dailyWage: 650,
      overtimeRate: 80,
      isActive: true,
      assignedProjects: [],
      totalPresentDays: 26,
      pendingWages: 1300,
      hasLoggedIn: false,
      attendanceHistory: [],
    ),
  ];

  late final List<ProjectDetails> _projects = [
    ProjectDetails(
      id: 'proj-1',
      name: 'মেঘনা ভিউ রেসিডেন্স',
      type: ProjectType.sqft,
      client: _clients[0],
      address: 'বাড়ি #৪৫, রোড #১০, মিরপুর ১০, ঢাকা',
      lat: 23.8069,
      lng: 90.3687,
      geofenceRadiusM: 150,
      budget: 3500000,
      status: ProjectStatus.active,
      workerCount: 14,
      supervisors: [
        SupervisorAssignment(
          id: 'asg-1',
          supervisorId: 'sup-1',
          supervisorName: 'তারেক মাহমুদ',
          supervisorMobile: '01722334455',
          assignedAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ],
      recentEntries: [
        EntryPreview(
          id: 'entry-1',
          projectId: 'proj-1',
          projectName: 'মেঘনা ভিউ রেসিডেন্স',
          entryDate: DateTime.now(),
          supervisorName: 'তারেক মাহমুদ',
          workerCount: 12,
          status: 'খোলা',
        ),
      ],
    ),
    ProjectDetails(
      id: 'proj-2',
      name: 'কর্ণফুলী কমার্শিয়াল কমপ্লেক্স',
      type: ProjectType.contract,
      client: _clients[1],
      address: 'জিইসি মোড়, চট্টগ্রাম',
      lat: 22.3592,
      lng: 91.8215,
      geofenceRadiusM: 150,
      budget: 8500000,
      status: ProjectStatus.active,
      workerCount: 18,
      supervisors: [
        SupervisorAssignment(
          id: 'asg-2',
          supervisorId: 'sup-1',
          supervisorName: 'তারেক মাহমুদ',
          supervisorMobile: '01722334455',
          assignedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      recentEntries: [],
    ),
    ProjectDetails(
      id: 'proj-3',
      name: 'পদ্মা সেতু সংযোগ সড়ক সাইট',
      type: ProjectType.daily,
      client: _clients[0],
      address: 'মাওয়া ঘাট সংযোগ, মুন্সিগঞ্জ',
      lat: 23.4756,
      lng: 90.2635,
      geofenceRadiusM: 200,
      budget: 1800000,
      status: ProjectStatus.planned,
      workerCount: 8,
      supervisors: [
        SupervisorAssignment(
          id: 'asg-3',
          supervisorId: 'sup-2',
          supervisorName: 'আব্দুল করিম',
          supervisorMobile: '01733445566',
          assignedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
      recentEntries: [],
    ),
  ];

  final List<EntryApproval> _approvals = [
    EntryApproval(
      id: 'appr-1',
      type: ApprovalType.outsideSite,
      title: 'সাইটের বাইরে হাজিরা',
      subtitle: 'মিরপুর সাইট থেকে ২১০ মিটার দূরে হাজিরা',
      date: DateTime.now(),
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      actorName: 'মোবারক হোসেন (রাজমিস্ত্রি)',
      reason: 'গেট লক থাকায় দূর থেকে হাজিরা দেওয়া হয়েছে',
    ),
    EntryApproval(
      id: 'appr-2',
      type: ApprovalType.backdated,
      title: 'ব্যাকডেটেড এন্ট্রি অনুমোদন',
      subtitle: '৩ দিন আগের এন্ট্রি খোলার অনুরোধ',
      date: DateTime.now().subtract(const Duration(days: 3)),
      projectName: 'কর্ণফুলী কমার্শিয়াল কমপ্লেক্স',
      actorName: 'তারেক মাহমুদ (সুপারভাইজার)',
      reason: 'ইন্টারনেট সমস্যা ও মোবাইল হারিয়ে যাওয়ায় দেরি হয়েছে',
    ),
  ];

  final List<ContractorMaterial> _materials = [
    ContractorMaterial(
      id: 'mat-1',
      projectId: 'proj-1',
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      name: 'শাহ সিমেন্ট (Portland)',
      unit: 'ব্যাগ',
      qty: 150,
      unitPrice: 530,
      totalAmount: 79500,
      purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      addedByRole: 'contractor',
      isClientAdded: false,
    ),
    ContractorMaterial(
      id: 'mat-2',
      projectId: 'proj-1',
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      name: 'BSRM ১৬ মিমি রড',
      unit: 'টন',
      qty: 3.5,
      unitPrice: 94000,
      totalAmount: 329000,
      purchaseDate: DateTime.now().subtract(const Duration(days: 8)),
      addedByRole: 'client',
      isClientAdded: true, // Client added -> read only for contractor
    ),
  ];

  final List<SiteExpense> _siteExpenses = [
    SiteExpense(
      id: 'exp-1',
      projectId: 'proj-1',
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      category: 'সাইট জরুরি খরচ ও নাস্তা',
      amount: 1500,
      expenseDate: DateTime.now().subtract(const Duration(days: 1)),
      supervisorName: 'তারেক মাহমুদ',
      note: 'শ্রমিকদের রাতের ওভারটাইম নাস্তা',
      isApproved: false,
    ),
  ];

  final List<ClientPayment> _clientPayments = [
    ClientPayment(
      id: 'cp-1',
      projectId: 'proj-1',
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      amount: 500000,
      paymentDate: DateTime.now().subtract(const Duration(days: 15)),
      note: 'প্রথম কিস্তি পরিশোধ (চেক নং ৪৪৮৯)',
    ),
  ];

  final List<PaymentRecord> _payments = [
    PaymentRecord(
      id: 'pay-1',
      payeeId: 'wrk-1',
      payeeName: 'মোবারক হোসেন',
      payeeRole: MemberRole.worker,
      amount: 5000,
      paymentDate: DateTime.now().subtract(const Duration(days: 7)),
      method: 'নগদ',
      note: 'সাপ্তাহিক মজুরি পরিশোধ',
      allocations: [
        PaymentAllocation(
          id: 'alloc-1',
          projectId: 'proj-1',
          projectName: 'মেঘনা ভিউ রেসিডেন্স',
          allocatedAmount: 5000,
          method: 'fifo',
          allocatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
  ];

  final List<BillStatement> _billStatements = [
    BillStatement(
      id: 'bill-1',
      projectId: 'proj-1',
      projectName: 'মেঘনা ভিউ রেসিডেন্স',
      periodFrom: DateTime.now().subtract(const Duration(days: 30)),
      periodTo: DateTime.now(),
      preset: 'monthly',
      totalAmount: 485000,
      totalAttendanceDays: 142,
      isLocked: true,
      fileUrl: null,
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    int activeCount = _projects.where((p) => p.status == ProjectStatus.active).length;
    double totalBudget = _projects.fold(0.0, (sum, p) => sum + (p.budget ?? 0));
    int handoverCount = _approvals.where((a) => a.type == ApprovalType.handoverRequired).length;

    return DashboardSummary(
      workersPresentToday: 26,
      activeProjectsCount: activeCount,
      totalBudget: totalBudget,
      todayEntriesCount: 2,
      pendingApprovalsCount: _approvals.length,
      handoverRequiredCount: handoverCount,
      companyName: _company.name,
    );
  }

  @override
  Future<List<ProjectSummary>> getProjects({
    ProjectStatus? status,
    String? query,
  }) async {
    var list = _projects.map((p) => ProjectSummary(
          id: p.id,
          name: p.name,
          type: p.type,
          clientName: p.client.name,
          clientMobile: p.client.mobile,
          workerCount: p.workerCount,
          status: p.status,
          budget: p.budget,
          address: p.address,
          lat: p.lat,
          lng: p.lng,
          geofenceRadiusM: p.geofenceRadiusM,
        ));

    if (status != null) {
      list = list.where((p) => p.status == status);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.clientName.toLowerCase().contains(q) ||
          p.clientMobile.contains(q));
    }
    return list.toList();
  }

  @override
  Future<ProjectDetails> getProjectDetails(String id) async {
    final project = _projects.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const ContractorException('প্রজেক্টটি পাওয়া যায়নি'),
    );
    return project;
  }

  @override
  Future<List<ClientInfo>> getClients() async {
    return List.unmodifiable(_clients);
  }

  @override
  Future<ProjectDetails> createProject(NewProjectInput input) async {
    // 1. Client auto-linking logic:
    // If mobile already exists in the organization, link to that existing client
    final existingClient = _clients.firstWhere(
      (c) => c.mobile == input.clientMobile.trim(),
      orElse: () {
        final newClient = ClientInfo(
          id: 'client-${_clients.length + 1}',
          name: input.clientName.trim(),
          mobile: input.clientMobile.trim(),
        );
        _clients.add(newClient);
        return newClient;
      },
    );

    final newProject = ProjectDetails(
      id: 'proj-${_projects.length + 1}',
      name: input.name.trim(),
      type: input.type,
      client: existingClient,
      address: input.address.trim(),
      lat: input.lat,
      lng: input.lng,
      geofenceRadiusM: input.geofenceRadiusM,
      budget: input.budget,
      status: ProjectStatus.planned,
      supervisors: [],
      workerCount: 0,
      recentEntries: [],
    );

    _projects.add(newProject);
    return newProject;
  }

  @override
  Future<ProjectDetails> updateProject(UpdateProjectInput input) async {
    final index = _projects.indexWhere((p) => p.id == input.id);
    if (index == -1) {
      throw const ContractorException('প্রজেক্টটি পাওয়া যায়নি');
    }

    final current = _projects[index];

    // Client mobile cannot be modified in project update (as strictly specified in PRD & prompt)
    if (input.clientMobile != null &&
        input.clientMobile!.trim().isNotEmpty &&
        input.clientMobile!.trim() != current.client.mobile) {
      throw const ContractorException('ক্লায়েন্টের মোবাইল নম্বর পরিবর্তন করা যাবে না');
    }

    final updatedClient = ClientInfo(
      id: current.client.id,
      name: input.clientName.trim().isNotEmpty ? input.clientName.trim() : current.client.name,
      mobile: current.client.mobile, // Client mobile is strictly immutable!
      email: current.client.email,
      photoUrl: current.client.photoUrl,
    );

    final updated = current.copyWith(
      name: input.name.trim(),
      type: input.type,
      client: updatedClient,
      address: input.address.trim(),
      lat: input.lat,
      lng: input.lng,
      geofenceRadiusM: input.geofenceRadiusM,
      budget: input.budget,
      status: input.status,
    );

    _projects[index] = updated;
    return updated;
  }

  @override
  Future<void> updateProjectStatus(String id, ProjectStatus status) async {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(status: status);
    }
  }

  @override
  Future<void> assignSupervisor(String projectId, String supervisorId) async {
    final pIdx = _projects.indexWhere((p) => p.id == projectId);
    final sup = _members.firstWhere((m) => m.id == supervisorId);
    if (pIdx != -1) {
      final exists = _projects[pIdx].supervisors.any((s) => s.supervisorId == supervisorId);
      if (!exists) {
        final newAssignments = List<SupervisorAssignment>.from(_projects[pIdx].supervisors)
          ..add(SupervisorAssignment(
            id: 'asg-${DateTime.now().millisecondsSinceEpoch}',
            supervisorId: supervisorId,
            supervisorName: sup.name,
            supervisorMobile: sup.mobile,
            assignedAt: DateTime.now(),
          ));
        _projects[pIdx] = _projects[pIdx].copyWith(supervisors: newAssignments);

        if (!sup.assignedProjects.contains(projectId)) {
          sup.assignedProjects.add(projectId);
        }
      }
    }
  }

  @override
  Future<void> unassignSupervisor(String projectId, String supervisorId) async {
    final pIdx = _projects.indexWhere((p) => p.id == projectId);
    if (pIdx != -1) {
      final p = _projects[pIdx];
      final newAssignments = p.supervisors.where((s) => s.supervisorId != supervisorId).toList();
      _projects[pIdx] = p.copyWith(supervisors: newAssignments);

      // Business Rule: Open/unfinished entries become handover_required!
      _approvals.add(EntryApproval(
        id: 'handover-${DateTime.now().millisecondsSinceEpoch}',
        type: ApprovalType.handoverRequired,
        title: 'সুপারভাইজার সরানো হয়েছে (হস্তান্তর প্রয়োজন)',
        subtitle: '${p.name} প্রজেক্টের চলমান এন্ট্রি অন্য সুপারভাইজারকে হস্তান্তর করুন',
        date: DateTime.now(),
        projectName: p.name,
        actorName: 'সুপারভাইজার অপসারণ',
        reason: 'দায়িত্ব থেকে সুপারভাইজার অপসারিত হওয়ায় এন্ট্রিটি হস্তান্তর অবস্থায় আছে',
      ));
    }
  }

  @override
  Future<List<MemberSummary>> getMembers(
    MemberRole role, {
    String? designationId,
    String? query,
  }) async {
    var list = _members.where((m) => m.role == role);

    if (designationId != null && designationId.isNotEmpty) {
      list = list.where((m) => m.designationId == designationId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.mobile.contains(q) ||
          m.designationName.toLowerCase().contains(q));
    }

    return list
        .map((m) => MemberSummary(
              id: m.id,
              name: m.name,
              mobile: m.mobile,
              role: m.role,
              designationName: m.designationName,
              dailyWage: m.dailyWage,
              isActive: m.isActive,
              assignedProjectsCount: m.assignedProjects.length,
              totalPresentDays: m.totalPresentDays,
              pendingWages: m.pendingWages,
            ))
        .toList();
  }

  @override
  Future<MemberDetails> getMemberDetails(String id) async {
    return _members.firstWhere(
      (m) => m.id == id,
      orElse: () => throw const ContractorException('কর্মী পাওয়া যায়নি'),
    );
  }

  @override
  Future<MemberDetails> createMember(NewMemberInput input) async {
    final des = _designations.firstWhere(
      (d) => d.id == input.designationId,
      orElse: () => Designation(
        id: input.designationId,
        name: 'সাধারণ',
        dailyWage: input.dailyWage,
        overtimeRatePerHour: 100,
      ),
    );

    final newMember = MemberDetails(
      id: '${input.role.name}-${_members.length + 1}',
      name: input.name.trim(),
      mobile: input.mobile.trim(),
      role: input.role,
      designationId: des.id,
      designationName: des.name,
      dailyWage: input.dailyWage > 0 ? input.dailyWage : des.dailyWage,
      overtimeRate: des.overtimeRatePerHour,
      isActive: true,
      assignedProjects: [],
      totalPresentDays: 0,
      pendingWages: 0,
      attendanceHistory: [],
      hasLoggedIn: false,
    );

    _members.add(newMember);
    return newMember;
  }

  @override
  Future<MemberDetails> updateMember(
    String id, {
    String? name,
    String? designationId,
    double? dailyWage,
  }) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx == -1) throw const ContractorException('কর্মী পাওয়া যায়নি');

    final current = _members[idx];
    String desName = current.designationName;
    double otRate = current.overtimeRate;

    if (designationId != null) {
      final d = _designations.firstWhere((x) => x.id == designationId);
      desName = d.name;
      otRate = d.overtimeRatePerHour;
    }

    final updated = MemberDetails(
      id: current.id,
      name: name ?? current.name,
      mobile: current.mobile,
      role: current.role,
      designationId: designationId ?? current.designationId,
      designationName: desName,
      dailyWage: dailyWage ?? current.dailyWage,
      overtimeRate: otRate,
      isActive: current.isActive,
      assignedProjects: current.assignedProjects,
      totalPresentDays: current.totalPresentDays,
      pendingWages: current.pendingWages,
      attendanceHistory: current.attendanceHistory,
      hasLoggedIn: current.hasLoggedIn,
    );

    _members[idx] = updated;
    return updated;
  }

  @override
  Future<void> setMemberActive(String id, bool isActive) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final current = _members[idx];
      _members[idx] = MemberDetails(
        id: current.id,
        name: current.name,
        mobile: current.mobile,
        role: current.role,
        designationId: current.designationId,
        designationName: current.designationName,
        dailyWage: current.dailyWage,
        overtimeRate: current.overtimeRate,
        isActive: isActive,
        assignedProjects: current.assignedProjects,
        totalPresentDays: current.totalPresentDays,
        pendingWages: current.pendingWages,
        attendanceHistory: current.attendanceHistory,
        hasLoggedIn: current.hasLoggedIn,
      );
    }
  }

  @override
  Future<void> resetMemberPassword(String id) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      // Reverts password to last 6 digits of mobile; must change on next login
    }
  }

  @override
  Future<List<Designation>> getDesignations() async {
    return List.unmodifiable(_designations);
  }

  @override
  Future<Designation> upsertDesignation({
    String? id,
    required String name,
    required double dailyWage,
    required double overtimeRatePerHour,
  }) async {
    if (id != null) {
      final idx = _designations.indexWhere((d) => d.id == id);
      if (idx != -1) {
        final updated = Designation(
          id: id,
          name: name,
          dailyWage: dailyWage,
          overtimeRatePerHour: overtimeRatePerHour,
        );
        _designations[idx] = updated;
        return updated;
      }
    }
    final created = Designation(
      id: 'des-${_designations.length + 1}',
      name: name,
      dailyWage: dailyWage,
      overtimeRatePerHour: overtimeRatePerHour,
    );
    _designations.add(created);
    return created;
  }

  @override
  Future<ContractorCompanyProfile> getCompanyProfile() async {
    return _company;
  }

  @override
  Future<void> updateCompanyProfile(ContractorCompanyProfile profile) async {
    _company = profile;
  }

  @override
  Future<List<EntryPreview>> getEntries({String? projectId, DateTime? date}) async {
    final list = <EntryPreview>[
      EntryPreview(
        id: 'entry-1',
        projectId: 'proj-1',
        projectName: 'মেঘনা ভিউ রেসিডেন্স',
        entryDate: DateTime.now(),
        supervisorName: 'তারেক মাহমুদ',
        workerCount: 12,
        status: 'খোলা',
      ),
      EntryPreview(
        id: 'entry-2',
        projectId: 'proj-2',
        projectName: 'কর্ণফুলী কমার্শিয়াল কমপ্লেক্স',
        entryDate: DateTime.now(),
        supervisorName: 'আব্দুল করিম',
        workerCount: 14,
        status: 'জমা দেওয়া হয়েছে',
      ),
    ];
    if (projectId != null) {
      return list.where((e) => e.projectId == projectId).toList();
    }
    return list;
  }

  @override
  Future<List<EntryApproval>> getApprovals({ApprovalType? type}) async {
    if (type != null) {
      return _approvals.where((a) => a.type == type).toList();
    }
    return List.unmodifiable(_approvals);
  }

  @override
  Future<void> approveEntry(String id) async {
    _approvals.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> rejectEntry(String id) async {
    _approvals.removeWhere((a) => a.id == id);
  }

  @override
  Future<ExpenseReport> getAccountsSummary() async {
    return const ExpenseReport(
      totalIncome: 1350000,
      totalExpense: 920000,
      totalPendingWages: 8500,
      netBalance: 430000,
      projectBreakdowns: [
        ProjectAccountSummary(
          projectId: 'proj-1',
          projectName: 'মেঘনা ভিউ রেসিডেন্স',
          totalIncome: 850000,
          totalExpense: 520000,
          pendingDues: 330000,
        ),
        ProjectAccountSummary(
          projectId: 'proj-2',
          projectName: 'কর্ণফুলী কমার্শিয়াল কমপ্লেক্স',
          totalIncome: 500000,
          totalExpense: 400000,
          pendingDues: 100000,
        ),
      ],
    );
  }

  @override
  Future<List<WageSummary>> getWages({
    String? projectId,
    String? workerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return [
      WageSummary(
        id: 'wage-1',
        workerId: 'wrk-1',
        workerName: 'মোবারক হোসেন',
        designationName: 'রাজমিস্ত্রি (হেড)',
        projectName: 'মেঘনা ভিউ রেসিডেন্স',
        workDate: DateTime.now().subtract(const Duration(days: 1)),
        regularAmount: 1200,
        overtimeHours: 2,
        overtimeAmount: 300,
        totalEarned: 1500,
      ),
      WageSummary(
        id: 'wage-2',
        workerId: 'wrk-2',
        workerName: 'সুমন চন্দ্র শীল',
        designationName: 'সাধারণ রাজমিস্ত্রি',
        projectName: 'মেঘনা ভিউ রেসিডেন্স',
        workDate: DateTime.now().subtract(const Duration(days: 1)),
        regularAmount: 950,
        overtimeHours: 0,
        overtimeAmount: 0,
        totalEarned: 950,
      ),
    ];
  }

  @override
  Future<List<PaymentRecord>> getPayments() async {
    return List.unmodifiable(_payments);
  }

  @override
  Future<void> allocatePayment({
    required String payeeId,
    required double amount,
    String? specificProjectId,
    String? note,
  }) async {
    final member = _members.firstWhere((m) => m.id == payeeId);
    final pName = specificProjectId != null
        ? _projects.firstWhere((p) => p.id == specificProjectId).name
        : 'মেঘনা ভিউ রেসিডেন্স (FIFO)';

    final newPayment = PaymentRecord(
      id: 'pay-${_payments.length + 1}',
      payeeId: payeeId,
      payeeName: member.name,
      payeeRole: member.role,
      amount: amount,
      paymentDate: DateTime.now(),
      method: 'নগদ',
      note: note,
      allocations: [
        PaymentAllocation(
          id: 'alloc-${DateTime.now().millisecondsSinceEpoch}',
          projectId: specificProjectId ?? 'proj-1',
          projectName: pName,
          allocatedAmount: amount,
          method: specificProjectId != null ? 'manual' : 'fifo',
          allocatedAt: DateTime.now(),
        ),
      ],
    );

    _payments.insert(0, newPayment);
  }

  @override
  Future<List<ClientPayment>> getClientPayments({String? projectId}) async {
    if (projectId != null) {
      return _clientPayments.where((cp) => cp.projectId == projectId).toList();
    }
    return List.unmodifiable(_clientPayments);
  }

  @override
  Future<void> recordClientPayment({
    required String projectId,
    required double amount,
    String? note,
  }) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    _clientPayments.insert(
      0,
      ClientPayment(
        id: 'cp-${_clientPayments.length + 1}',
        projectId: projectId,
        projectName: project.name,
        amount: amount,
        paymentDate: DateTime.now(),
        note: note,
      ),
    );
  }

  @override
  Future<List<ContractorMaterial>> getMaterials({String? projectId}) async {
    if (projectId != null) {
      return _materials.where((m) => m.projectId == projectId).toList();
    }
    return List.unmodifiable(_materials);
  }

  @override
  Future<List<SiteExpense>> getSiteExpenses({String? projectId}) async {
    if (projectId != null) {
      return _siteExpenses.where((e) => e.projectId == projectId).toList();
    }
    return List.unmodifiable(_siteExpenses);
  }

  @override
  Future<void> reviewSiteExpense(String id, bool approve) async {
    final idx = _siteExpenses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      if (approve) {
        _siteExpenses[idx] = SiteExpense(
          id: _siteExpenses[idx].id,
          projectId: _siteExpenses[idx].projectId,
          projectName: _siteExpenses[idx].projectName,
          category: _siteExpenses[idx].category,
          amount: _siteExpenses[idx].amount,
          expenseDate: _siteExpenses[idx].expenseDate,
          supervisorName: _siteExpenses[idx].supervisorName,
          note: _siteExpenses[idx].note,
          isApproved: true,
        );
      } else {
        _siteExpenses.removeAt(idx);
      }
    }
  }

  @override
  Future<List<BillStatement>> getBillStatements({String? projectId}) async {
    if (projectId != null) {
      return _billStatements.where((b) => b.projectId == projectId).toList();
    }
    return List.unmodifiable(_billStatements);
  }

  @override
  Future<BillStatement> generateBillStatement({
    required String projectId,
    required DateTime periodFrom,
    required DateTime periodTo,
    required String preset,
  }) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final stmt = BillStatement(
      id: 'bill-${_billStatements.length + 1}',
      projectId: projectId,
      projectName: project.name,
      periodFrom: periodFrom,
      periodTo: periodTo,
      preset: preset,
      totalAmount: 320000,
      totalAttendanceDays: 95,
      isLocked: true, // Snapshot locked
      fileUrl: null, // Placeholder for PDF/Excel export
      generatedAt: DateTime.now(),
    );
    _billStatements.insert(0, stmt);
    return stmt;
  }
}
