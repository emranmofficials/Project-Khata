/// দৈনিক এন্ট্রি মডেল (Daily Entry Model)
class DailyEntryModel {
  final String id;
  final String projectId;
  final String? projectName;
  final DateTime entryDate;
  final String status; // 'open', 'submitted', 'locked', 'handover_required'
  final String openedBy;
  final String? openedByName;
  final bool isBackdated;
  final String? backdateReason;
  final int workersPresentCount;
  final DateTime? submittedAt;
  final DateTime? lockedAt;

  const DailyEntryModel({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.entryDate,
    required this.status,
    required this.openedBy,
    this.openedByName,
    this.isBackdated = false,
    this.backdateReason,
    this.workersPresentCount = 0,
    this.submittedAt,
    this.lockedAt,
  });

  bool get isOpen => status == 'open';
  bool get isSubmitted => status == 'submitted';
  bool get isLocked => status == 'locked';
  bool get isHandoverRequired => status == 'handover_required';

  String get statusBengaliLabel {
    switch (status) {
      case 'open':
        return 'খোলা';
      case 'submitted':
        return 'জমা';
      case 'locked':
        return 'অনুমোদিত';
      case 'handover_required':
        return 'হস্তান্তর প্রয়োজন';
      default:
        return status;
    }
  }

  factory DailyEntryModel.fromJson(Map<String, dynamic> json) {
    final project = json['projects'] as Map<String, dynamic>?;
    final opener = json['profiles'] as Map<String, dynamic>?;

    return DailyEntryModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      projectName: project?['name'] as String?,
      entryDate: DateTime.parse(json['entry_date'] as String),
      status: json['status'] as String? ?? 'open',
      openedBy: json['opened_by'] as String,
      openedByName: opener?['name'] as String?,
      isBackdated: json['is_backdated'] as bool? ?? false,
      backdateReason: json['backdate_reason'] as String?,
      workersPresentCount: (json['attendance_count'] as num?)?.toInt() ?? 0,
      submittedAt: json['submitted_at'] != null ? DateTime.tryParse(json['submitted_at']) : null,
      lockedAt: json['locked_at'] != null ? DateTime.tryParse(json['locked_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'entry_date': entryDate.toIso8601String().substring(0, 10),
      'status': status,
      'opened_by': openedBy,
      'is_backdated': isBackdated,
      'backdate_reason': backdateReason,
    };
  }
}
