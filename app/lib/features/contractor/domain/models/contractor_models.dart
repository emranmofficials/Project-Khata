import 'package:flutter/material.dart';

enum ProjectType {
  sqft('স্কয়ার ফিট'),
  contract('চুক্তি ভিত্তিক'),
  daily('রোজ ভিত্তিক');

  final String displayName;
  const ProjectType(this.displayName);
}

enum ProjectStatus {
  planned('পরিকল্পনা', Color(0xFF64748B)),
  active('চলমান', Color(0xFF1E3A8A)),
  completed('সম্পন্ন', Color(0xFF0F766E)),
  onHold('স্থগিত', Color(0xFFD97706));

  final String displayName;
  final Color color;
  const ProjectStatus(this.displayName, this.color);
}

enum MemberRole {
  supervisor('সুপারভাইজার'),
  worker('শ্রমিক');

  final String displayName;
  const MemberRole(this.displayName);
}

class ContractorException implements Exception {
  final String message;
  const ContractorException(this.message);

  @override
  String toString() => message;
}

class DashboardSummary {
  final int workersPresentToday;
  final int activeProjectsCount;
  final double totalBudget;
  final int todayEntriesCount;
  final int pendingApprovalsCount;
  final int handoverRequiredCount;
  final String companyName;

  const DashboardSummary({
    required this.workersPresentToday,
    required this.activeProjectsCount,
    required this.totalBudget,
    required this.todayEntriesCount,
    required this.pendingApprovalsCount,
    required this.handoverRequiredCount,
    required this.companyName,
  });
}

class EntryPreview {
  final String id;
  final String projectId;
  final String projectName;
  final DateTime entryDate;
  final String supervisorName;
  final int workerCount;
  final String status;
  final bool isBackdated;
  final bool isOutsideSite;

  const EntryPreview({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.entryDate,
    required this.supervisorName,
    required this.workerCount,
    required this.status,
    this.isBackdated = false,
    this.isOutsideSite = false,
  });
}

class ClientInfo {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String? photoUrl;

  const ClientInfo({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.photoUrl,
  });
}

class SupervisorAssignment {
  final String id;
  final String supervisorId;
  final String supervisorName;
  final String supervisorMobile;
  final DateTime assignedAt;

  const SupervisorAssignment({
    required this.id,
    required this.supervisorId,
    required this.supervisorName,
    required this.supervisorMobile,
    required this.assignedAt,
  });
}

class ProjectSummary {
  final String id;
  final String name;
  final ProjectType type;
  final String clientName;
  final String clientMobile;
  final int workerCount;
  final ProjectStatus status;
  final double? budget;
  final String address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;

  const ProjectSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.clientName,
    required this.clientMobile,
    required this.workerCount,
    required this.status,
    this.budget,
    required this.address,
    required this.lat,
    required this.lng,
    this.geofenceRadiusM = 150,
  });
}

class ProjectDetails {
  final String id;
  final String name;
  final ProjectType type;
  final ClientInfo client;
  final String address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;
  final double? budget;
  final ProjectStatus status;
  final List<SupervisorAssignment> supervisors;
  final int workerCount;
  final List<EntryPreview> recentEntries;
  final String? coverImageUrl;

  const ProjectDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.client,
    required this.address,
    required this.lat,
    required this.lng,
    required this.geofenceRadiusM,
    this.budget,
    required this.status,
    required this.supervisors,
    required this.workerCount,
    required this.recentEntries,
    this.coverImageUrl,
  });

  ProjectDetails copyWith({
    String? name,
    ProjectType? type,
    ClientInfo? client,
    String? address,
    double? lat,
    double? lng,
    int? geofenceRadiusM,
    double? budget,
    ProjectStatus? status,
    List<SupervisorAssignment>? supervisors,
    int? workerCount,
    List<EntryPreview>? recentEntries,
    String? coverImageUrl,
  }) {
    return ProjectDetails(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      client: client ?? this.client,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      geofenceRadiusM: geofenceRadiusM ?? this.geofenceRadiusM,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      supervisors: supervisors ?? this.supervisors,
      workerCount: workerCount ?? this.workerCount,
      recentEntries: recentEntries ?? this.recentEntries,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}

class AttendanceHistoryItem {
  final String id;
  final DateTime workDate;
  final String projectName;
  final String status;
  final double overtimeHours;
  final double earnedAmount;

  const AttendanceHistoryItem({
    required this.id,
    required this.workDate,
    required this.projectName,
    required this.status,
    this.overtimeHours = 0,
    required this.earnedAmount,
  });
}

class MemberSummary {
  final String id;
  final String name;
  final String mobile;
  final MemberRole role;
  final String designationName;
  final double dailyWage;
  final bool isActive;
  final int assignedProjectsCount;
  final int totalPresentDays;
  final double pendingWages;

  const MemberSummary({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.designationName,
    required this.dailyWage,
    required this.isActive,
    required this.assignedProjectsCount,
    required this.totalPresentDays,
    required this.pendingWages,
  });
}

class MemberDetails {
  final String id;
  final String name;
  final String mobile;
  final MemberRole role;
  final String designationId;
  final String designationName;
  final double dailyWage;
  final double overtimeRate;
  final bool isActive;
  final List<String> assignedProjects;
  final int totalPresentDays;
  final double pendingWages;
  final List<AttendanceHistoryItem> attendanceHistory;
  final bool hasLoggedIn;

  const MemberDetails({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.designationId,
    required this.designationName,
    required this.dailyWage,
    required this.overtimeRate,
    required this.isActive,
    required this.assignedProjects,
    required this.totalPresentDays,
    required this.pendingWages,
    required this.attendanceHistory,
    this.hasLoggedIn = false,
  });
}

class Designation {
  final String id;
  final String name;
  final double dailyWage;
  final double overtimeRatePerHour;

  const Designation({
    required this.id,
    required this.name,
    required this.dailyWage,
    required this.overtimeRatePerHour,
  });
}

class NewProjectInput {
  final String name;
  final ProjectType type;
  final String address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;
  final double? budget;
  final String clientName;
  final String clientMobile;

  const NewProjectInput({
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    this.geofenceRadiusM = 150,
    this.budget,
    required this.clientName,
    required this.clientMobile,
  });
}

class UpdateProjectInput {
  final String id;
  final String name;
  final ProjectType type;
  final String address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;
  final double? budget;
  final ProjectStatus status;
  final String clientName;
  final String? clientMobile;

  const UpdateProjectInput({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    required this.geofenceRadiusM,
    this.budget,
    required this.status,
    required this.clientName,
    this.clientMobile,
  });
}

class NewMemberInput {
  final String name;
  final String mobile;
  final MemberRole role;
  final String designationId;
  final double dailyWage;

  const NewMemberInput({
    required this.name,
    required this.mobile,
    required this.role,
    required this.designationId,
    required this.dailyWage,
  });
}

class WageSummary {
  final String id;
  final String workerId;
  final String workerName;
  final String designationName;
  final String projectName;
  final DateTime workDate;
  final double regularAmount;
  final double overtimeHours;
  final double overtimeAmount;
  final double totalEarned;

  const WageSummary({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.designationName,
    required this.projectName,
    required this.workDate,
    required this.regularAmount,
    required this.overtimeHours,
    required this.overtimeAmount,
    required this.totalEarned,
  });
}

class PaymentAllocation {
  final String id;
  final String projectId;
  final String projectName;
  final double allocatedAmount;
  final String method;
  final DateTime allocatedAt;

  const PaymentAllocation({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.allocatedAmount,
    required this.method,
    required this.allocatedAt,
  });
}

class PaymentRecord {
  final String id;
  final String payeeId;
  final String payeeName;
  final MemberRole payeeRole;
  final double amount;
  final DateTime paymentDate;
  final String method;
  final String? note;
  final List<PaymentAllocation> allocations;

  const PaymentRecord({
    required this.id,
    required this.payeeId,
    required this.payeeName,
    required this.payeeRole,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.note,
    required this.allocations,
  });
}

class ClientPayment {
  final String id;
  final String projectId;
  final String projectName;
  final double amount;
  final DateTime paymentDate;
  final String? note;

  const ClientPayment({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.amount,
    required this.paymentDate,
    this.note,
  });
}

class ContractorMaterial {
  final String id;
  final String projectId;
  final String projectName;
  final String name;
  final String unit;
  final double qty;
  final double unitPrice;
  final double totalAmount;
  final DateTime purchaseDate;
  final String addedByRole;
  final bool isClientAdded;

  const ContractorMaterial({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.name,
    required this.unit,
    required this.qty,
    required this.unitPrice,
    required this.totalAmount,
    required this.purchaseDate,
    required this.addedByRole,
    required this.isClientAdded,
  });
}

class SiteExpense {
  final String id;
  final String projectId;
  final String projectName;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String supervisorName;
  final String? note;
  final bool isApproved;

  const SiteExpense({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.supervisorName,
    this.note,
    required this.isApproved,
  });
}

class BillStatement {
  final String id;
  final String projectId;
  final String projectName;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String preset;
  final double totalAmount;
  final int totalAttendanceDays;
  final bool isLocked;
  final String? fileUrl;
  final DateTime generatedAt;

  const BillStatement({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.periodFrom,
    required this.periodTo,
    required this.preset,
    required this.totalAmount,
    required this.totalAttendanceDays,
    required this.isLocked,
    this.fileUrl,
    required this.generatedAt,
  });
}

enum ApprovalType {
  outsideSite('সাইটের বাইরে'),
  backdated('ব্যাকডেটেড এন্ট্রি'),
  handoverRequired('হস্তান্তর প্রয়োজন');

  final String label;
  const ApprovalType(this.label);
}

class EntryApproval {
  final String id;
  final ApprovalType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final String projectName;
  final String actorName;
  final String? reason;

  const EntryApproval({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.projectName,
    required this.actorName,
    this.reason,
  });
}

class ProjectAccountSummary {
  final String projectId;
  final String projectName;
  final double totalIncome;
  final double totalExpense;
  final double pendingDues;

  const ProjectAccountSummary({
    required this.projectId,
    required this.projectName,
    required this.totalIncome,
    required this.totalExpense,
    required this.pendingDues,
  });
}

class ExpenseReport {
  final double totalIncome;
  final double totalExpense;
  final double totalPendingWages;
  final double netBalance;
  final List<ProjectAccountSummary> projectBreakdowns;

  const ExpenseReport({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalPendingWages,
    required this.netBalance,
    required this.projectBreakdowns,
  });
}

class ContractorCompanyProfile {
  final String name;
  final String address;
  final String phone;
  final String? logoUrl;

  const ContractorCompanyProfile({
    required this.name,
    required this.address,
    required this.phone,
    this.logoUrl,
  });
}
