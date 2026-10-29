enum ProjectType {
  sqft,
  contract,
  daily;

  static ProjectType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'sqft':
        return ProjectType.sqft;
      case 'contract':
        return ProjectType.contract;
      case 'daily':
        return ProjectType.daily;
      default:
        return ProjectType.daily;
    }
  }

  String toDbString() => name;

  String get displayName {
    switch (this) {
      case ProjectType.sqft:
        return 'স্কয়ার ফিট ভিত্তিক';
      case ProjectType.contract:
        return 'চুক্তি ভিত্তিক';
      case ProjectType.daily:
        return 'রোজ ভিত্তিক';
    }
  }
}

enum ProjectStatus {
  planned,
  active,
  completed,
  onHold;

  static ProjectStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'planned':
        return ProjectStatus.planned;
      case 'active':
        return ProjectStatus.active;
      case 'completed':
        return ProjectStatus.completed;
      case 'on_hold':
        return ProjectStatus.onHold;
      default:
        return ProjectStatus.active;
    }
  }

  String toDbString() {
    if (this == ProjectStatus.onHold) return 'on_hold';
    return name;
  }

  String get displayName {
    switch (this) {
      case ProjectStatus.planned:
        return 'পরিকল্পনা';
      case ProjectStatus.active:
        return 'চলমান';
      case ProjectStatus.completed:
        return 'সম্পন্ন';
      case ProjectStatus.onHold:
        return 'স্থগিত';
    }
  }
}

class Project {
  final String id;
  final String organizationId;
  final String clientId;
  final String name;
  final ProjectType type;
  final String? address;
  final double lat;
  final double lng;
  final int geofenceRadiusM;
  final DateTime startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final double? budget;
  final double? ratePerSqft;
  final double? totalSqft;
  final double? dailyWage;
  final String? note;
  final DateTime createdAt;

  // Joined client profile info
  final String? clientName;
  final String? clientMobile;

  const Project({
    required this.id,
    required this.organizationId,
    required this.clientId,
    required this.name,
    required this.type,
    this.address,
    required this.lat,
    required this.lng,
    required this.geofenceRadiusM,
    required this.startDate,
    this.endDate,
    required this.status,
    this.budget,
    this.ratePerSqft,
    this.totalSqft,
    this.dailyWage,
    this.note,
    required this.createdAt,
    this.clientName,
    this.clientMobile,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      clientId: json['client_id'] as String,
      name: json['name'] as String,
      type: ProjectType.fromString(json['type'] as String),
      address: json['address'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      geofenceRadiusM: json['geofence_radius_m'] as int? ?? 150,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: ProjectStatus.fromString(json['status'] as String),
      budget: (json['budget'] as num?)?.toDouble(),
      ratePerSqft: (json['rate_per_sqft'] as num?)?.toDouble(),
      totalSqft: (json['total_sqft'] as num?)?.toDouble(),
      dailyWage: (json['daily_wage'] as num?)?.toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      clientName: json['client']?['name'] as String?,
      clientMobile: json['client']?['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'client_id': clientId,
      'name': name,
      'type': type.toDbString(),
      'address': address,
      'lat': lat,
      'lng': lng,
      'geofence_radius_m': geofenceRadiusM,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null)
        'end_date': endDate!.toIso8601String().split('T').first,
      'status': status.toDbString(),
      if (budget != null) 'budget': budget,
      if (ratePerSqft != null) 'rate_per_sqft': ratePerSqft,
      if (totalSqft != null) 'total_sqft': totalSqft,
      if (dailyWage != null) 'daily_wage': dailyWage,
      if (note != null) 'note': note,
    };
  }
}
