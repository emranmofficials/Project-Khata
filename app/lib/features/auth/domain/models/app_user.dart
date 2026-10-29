import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

enum UserRole {
  contractor,
  client,
  supervisor,
  worker;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'contractor':
        return UserRole.contractor;
      case 'client':
        return UserRole.client;
      case 'supervisor':
        return UserRole.supervisor;
      case 'worker':
        return UserRole.worker;
      default:
        return UserRole.worker;
    }
  }

  String toDbString() => name;

  String get displayName {
    switch (this) {
      case UserRole.contractor:
        return AppStrings.roleContractor;
      case UserRole.client:
        return AppStrings.roleClient;
      case UserRole.supervisor:
        return AppStrings.roleSupervisor;
      case UserRole.worker:
        return AppStrings.roleWorker;
    }
  }

  Color get brandColor {
    switch (this) {
      case UserRole.contractor:
        return AppColors.contractorNavy;
      case UserRole.client:
        return AppColors.clientTeal;
      case UserRole.supervisor:
        return AppColors.supervisorAmber;
      case UserRole.worker:
        return AppColors.workerIndigo;
    }
  }
}

class UserProfile {
  final String id;
  final String organizationId;
  final UserRole role;
  final String name;
  final String? mobile;
  final String? email;
  final String? photoUrl;
  final String? address;
  final String? designationId;
  final bool mustChangePassword;
  final String status;
  final DateTime createdAt;
  final String? designationTitle;
  final double? dailyWage;

  const UserProfile({
    required this.id,
    required this.organizationId,
    required this.role,
    required this.name,
    this.mobile,
    this.email,
    this.photoUrl,
    this.address,
    this.designationId,
    required this.mustChangePassword,
    required this.status,
    required this.createdAt,
    this.designationTitle,
    this.dailyWage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final designation = json['designations'] as Map<String, dynamic>?;

    return UserProfile(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      role: UserRole.fromString(json['role'] as String),
      name: json['name'] as String,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      address: json['address'] as String?,
      designationId: json['designation_id'] as String?,
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      designationTitle: designation?['title'] as String?,
      dailyWage: designation?['daily_wage'] != null
          ? (designation!['daily_wage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'role': role.toDbString(),
      'name': name,
      'mobile': mobile,
      'email': email,
      'photo_url': photoUrl,
      'address': address,
      'designation_id': designationId,
      'must_change_password': mustChangePassword,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? mobile,
    String? photoUrl,
    String? address,
    bool? mustChangePassword,
    String? status,
  }) {
    return UserProfile(
      id: id,
      organizationId: organizationId,
      role: role,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      designationId: designationId,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

typedef AppUser = UserProfile;
