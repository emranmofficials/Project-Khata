class SupervisorAssignment {
  final String id;
  final String organizationId;
  final String projectId;
  final String supervisorId;
  final DateTime assignedAt;
  final DateTime? unassignedAt;

  // Joined supervisor profile
  final String? supervisorName;
  final String? supervisorMobile;

  const SupervisorAssignment({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.supervisorId,
    required this.assignedAt,
    this.unassignedAt,
    this.supervisorName,
    this.supervisorMobile,
  });

  bool get isActive => unassignedAt == null;

  factory SupervisorAssignment.fromJson(Map<String, dynamic> json) {
    return SupervisorAssignment(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      unassignedAt: json['unassigned_at'] != null
          ? DateTime.parse(json['unassigned_at'] as String)
          : null,
      supervisorName: json['supervisor']?['name'] as String?,
      supervisorMobile: json['supervisor']?['mobile'] as String?,
    );
  }
}
