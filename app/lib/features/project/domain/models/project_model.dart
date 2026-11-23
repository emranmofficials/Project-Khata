/// প্রজেক্ট মডেল (Project Model)
class ProjectModel {
  final String id;
  final String organizationId;
  final String name;
  final String type; // 'sqft', 'contract', 'daily'
  final String address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;
  final String status; // 'planned', 'active', 'completed', 'on_hold'
  final double budget;
  final String? clientName;
  final String? clientMobile;
  final int todayWorkersCount;
  final int assignedSupervisorsCount;
  final double progressPercentage;
  final DateTime? createdAt;

  const ProjectModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    this.geofenceRadiusM = 150,
    this.status = 'active',
    this.budget = 0.0,
    this.clientName,
    this.clientMobile,
    this.todayWorkersCount = 0,
    this.assignedSupervisorsCount = 0,
    this.progressPercentage = 0.0,
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPlanned => status.toLowerCase() == 'planned';
  bool get isOnHold => status.toLowerCase() == 'on_hold';

  String get typeBengaliLabel {
    switch (type.toLowerCase()) {
      case 'sqft':
        return 'স্কয়ার ফিট ভিত্তিক';
      case 'contract':
        return 'চুক্তি ভিত্তিক';
      case 'daily':
        return 'রোজ ভিত্তিক';
      default:
        return type;
    }
  }

  String get statusBengaliLabel {
    switch (status.toLowerCase()) {
      case 'planned':
        return 'পরিকল্পনা';
      case 'active':
        return 'চলমান';
      case 'completed':
        return 'সম্পন্ন';
      case 'on_hold':
        return 'স্থগিত';
      default:
        return status;
    }
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'contract',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      geofenceRadiusM: (json['geofence_radius_m'] as num?)?.toInt() ?? 150,
      status: json['status'] as String? ?? 'planned',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      clientName: json['client_name'] as String?,
      clientMobile: json['client_mobile'] as String?,
      todayWorkersCount: (json['today_workers_count'] as num?)?.toInt() ?? 0,
      assignedSupervisorsCount: (json['assigned_supervisors_count'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'type': type,
      'address': address,
      'lat': lat,
      'lng': lng,
      'geofence_radius_m': geofenceRadiusM,
      'status': status,
      'budget': budget,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? type,
    String? address,
    double? lat,
    double? lng,
    int? geofenceRadiusM,
    String? status,
    double? budget,
    String? clientName,
    String? clientMobile,
    int? todayWorkersCount,
    int? assignedSupervisorsCount,
    double? progressPercentage,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      geofenceRadiusM: geofenceRadiusM ?? this.geofenceRadiusM,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      clientName: clientName ?? this.clientName,
      clientMobile: clientMobile ?? this.clientMobile,
      todayWorkersCount: todayWorkersCount ?? this.todayWorkersCount,
      assignedSupervisorsCount: assignedSupervisorsCount ?? this.assignedSupervisorsCount,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
