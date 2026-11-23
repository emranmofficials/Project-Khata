import 'models/project_model.dart';
import 'models/supervisor_assignment_model.dart';

/// প্রজেক্ট ব্যবস্থাপনা রিপোজিটরি ইন্টারফেস
abstract class ProjectRepository {
  /// প্রজেক্ট তালিকা লোড করা (স্ট্যাটাস ফিল্টার ও সার্চ অপশন সহ)
  Future<List<ProjectModel>> getProjects({
    String? statusFilter,
    String? searchQuery,
  });

  /// একটি প্রজেক্টের বিস্তারিত তথ্য লোড করা
  Future<ProjectModel> getProjectDetails(String projectId);

  /// নতুন প্রজেক্ট তৈরি (ক্লায়েন্ট ও সাইট লোকেশন সহ)
  Future<Map<String, dynamic>> createProject({
    required String name,
    required String type,
    required String address,
    required double lat,
    required double lng,
    int geofenceRadiusM = 150,
    double budget = 0.0,
    required String clientName,
    required String clientMobile,
    String status = 'active',
  });

  /// প্রজেক্টের তথ্য সম্পাদনা (ক্লায়েন্ট মোবাইল অপরিবর্তনযোগ্য)
  Future<void> updateProject({
    required String projectId,
    required String name,
    required String type,
    required String address,
    required double lat,
    required double lng,
    required int geofenceRadiusM,
    required String clientName,
    double budget = 0.0,
  });

  /// প্রজেক্টের স্ট্যাটাস পরিবর্তন (পরিকল্পনা, চলমান, সম্পন্ন, স্থগিত)
  Future<void> updateProjectStatus({
    required String projectId,
    required String newStatus,
  });

  /// প্রজেক্টে অ্যাসাইনকৃত সুপারভাইজারদের তালিকা
  Future<List<SupervisorAssignmentModel>> getProjectSupervisors(String projectId);

  /// প্রতিষ্ঠানের সব সক্রিয় সুপারভাইজারের তালিকা
  Future<List<Map<String, dynamic>>> getAllSupervisors();

  /// সুপারভাইজার অ্যাসাইনমেন্ট সিঙ্ক করা
  Future<void> syncSupervisors({
    required String projectId,
    required List<String> supervisorIds,
  });
}
