import 'models/worker_model.dart';

abstract class WorkerRepository {
  /// প্রতিষ্ঠানের সকল শ্রমিক ও সুপারভাইজার তালিকা
  Future<List<WorkerModel>> getWorkers({String? roleFilter, String? searchQuery});

  /// প্রতিষ্ঠানের পদবি তালিকা (Designations)
  Future<List<Map<String, dynamic>>> getDesignations();

  /// নতুন পদবি যুক্ত করা
  Future<Map<String, dynamic>> addDesignation({
    required String name,
    required double dailyRate,
    double overtimeRatePerHour = 0.0,
  });

  /// নতুন কর্মী (শ্রমিক বা সুপারভাইজার) যোগ করা
  Future<WorkerModel> addWorker({
    required String name,
    required String mobile,
    required String role, // 'worker' or 'supervisor'
    String? designationId,
    String? email,
  });

  /// কর্মীর স্ট্যাটাস পরিবর্তন (সক্রিয় / নিষ্ক্রিয়)
  Future<void> toggleWorkerStatus({
    required String workerId,
    required bool isActive,
  });
}
