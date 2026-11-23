/// ইউজার প্রোফাইল মডেল
class UserProfile {
  final String id;
  final String? organizationId;
  final String role; // 'contractor', 'client', 'supervisor', 'worker'
  final String name;
  final String mobile;
  final String? email;
  final String? photoUrl;
  final String? designationId;
  final bool mustChangePassword;
  final String status; // 'active', 'inactive'

  const UserProfile({
    required this.id,
    this.organizationId,
    required this.role,
    required this.name,
    required this.mobile,
    this.email,
    this.photoUrl,
    this.designationId,
    this.mustChangePassword = false,
    this.status = 'active',
  });

  bool get isContractor => role.toLowerCase() == 'contractor';
  bool get isSupervisor => role.toLowerCase() == 'supervisor';
  bool get isClient => role.toLowerCase() == 'client';
  bool get isWorker => role.toLowerCase() == 'worker';

  bool get hasOrganization => organizationId != null && organizationId!.isNotEmpty;
  bool get isActive => status.toLowerCase() == 'active';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String?,
      role: json['role'] as String? ?? 'worker',
      name: json['name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      designationId: json['designation_id'] as String?,
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'role': role,
      'name': name,
      'mobile': mobile,
      'email': email,
      'photo_url': photoUrl,
      'designation_id': designationId,
      'must_change_password': mustChangePassword,
      'status': status,
    };
  }

  UserProfile copyWith({
    String? id,
    String? organizationId,
    String? role,
    String? name,
    String? mobile,
    String? email,
    String? photoUrl,
    String? designationId,
    bool? mustChangePassword,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      designationId: designationId ?? this.designationId,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      status: status ?? this.status,
    );
  }
}
