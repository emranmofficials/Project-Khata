/// সুপারভাইজার অ্যাসাইনমেন্ট মডেল
class SupervisorAssignmentModel {
  final String id;
  final String supervisorId;
  final String name;
  final String mobile;
  final String? designationName;
  final DateTime assignedAt;
  final bool isAssigned;

  const SupervisorAssignmentModel({
    required this.id,
    required this.supervisorId,
    required this.name,
    required this.mobile,
    this.designationName,
    required this.assignedAt,
    this.isAssigned = true,
  });

  factory SupervisorAssignmentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return SupervisorAssignmentModel(
      id: json['id'] as String,
      supervisorId: json['supervisor_id'] as String,
      name: profile?['name'] as String? ?? 'সুপারভাইজার',
      mobile: profile?['mobile'] as String? ?? '',
      designationName: 'সাইট সুপারভাইজার',
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? '') ?? DateTime.now(),
      isAssigned: json['unassigned_at'] == null,
    );
  }
}
