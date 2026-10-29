enum EntryStatus {
  draft,
  submitted,
  approved,
  handoverRequired;

  String get value {
    switch (this) {
      case EntryStatus.draft:
        return 'draft';
      case EntryStatus.submitted:
        return 'submitted';
      case EntryStatus.approved:
        return 'approved';
      case EntryStatus.handoverRequired:
        return 'handover_required';
    }
  }

  String get bengaliLabel {
    switch (this) {
      case EntryStatus.draft:
        return 'ড্রাফট';
      case EntryStatus.submitted:
        return 'জমা হয়েছে';
      case EntryStatus.approved:
        return 'অনুমোদিত';
      case EntryStatus.handoverRequired:
        return 'হস্তান্তর প্রয়োজন';
    }
  }

  static EntryStatus fromString(String? value) {
    switch (value) {
      case 'submitted':
        return EntryStatus.submitted;
      case 'approved':
        return EntryStatus.approved;
      case 'handover_required':
        return EntryStatus.handoverRequired;
      case 'draft':
      default:
        return EntryStatus.draft;
    }
  }
}

class DailyEntry {
  final String id;
  final String organizationId;
  final String projectId;
  final String supervisorId;
  final DateTime entryDate;
  final String? workDescription;
  final EntryStatus status;
  final String? notes;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields for display
  final String? projectName;
  final String? supervisorName;

  const DailyEntry({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.supervisorId,
    required this.entryDate,
    this.workDescription,
    this.status = EntryStatus.draft,
    this.notes,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.projectName,
    this.supervisorName,
  });

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      entryDate: json['entry_date'] != null
          ? DateTime.parse(json['entry_date'] as String)
          : DateTime.now(),
      workDescription: json['work_description'] as String?,
      status: EntryStatus.fromString(json['status'] as String?),
      notes: json['notes'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      projectName: json['projects'] != null
          ? (json['projects'] as Map<String, dynamic>)['name'] as String?
          : null,
      supervisorName: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'supervisor_id': supervisorId,
      'entry_date':
          "${entryDate.year.toString().padLeft(4, '0')}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}",
      'work_description': workDescription,
      'status': status.value,
      'notes': notes,
      'photos': photos,
    };
  }

  DailyEntry copyWith({
    String? id,
    String? organizationId,
    String? projectId,
    String? supervisorId,
    DateTime? entryDate,
    String? workDescription,
    EntryStatus? status,
    String? notes,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectName,
    String? supervisorName,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      projectId: projectId ?? this.projectId,
      supervisorId: supervisorId ?? this.supervisorId,
      entryDate: entryDate ?? this.entryDate,
      workDescription: workDescription ?? this.workDescription,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectName: projectName ?? this.projectName,
      supervisorName: supervisorName ?? this.supervisorName,
    );
  }
}
