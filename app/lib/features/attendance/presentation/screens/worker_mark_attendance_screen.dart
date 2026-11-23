import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

/// PRD সেকশন ৯.২ অনুযায়ী শ্রমিকের নিজস্ব হাজিরা প্রদান স্ক্রিন
class WorkerMarkAttendanceScreen extends ConsumerStatefulWidget {
  const WorkerMarkAttendanceScreen({super.key});

  @override
  ConsumerState<WorkerMarkAttendanceScreen> createState() => _WorkerMarkAttendanceScreenState();
}

class _WorkerMarkAttendanceScreenState extends ConsumerState<WorkerMarkAttendanceScreen> {
  bool _isLocating = false;
  String? _selectedEntryId;
  String? _selectedProjectName;
  bool _alreadyMarked = false;

  void _handleMarkAttendance() async {
    final user = ref.read(authStateProvider).user;
    if (user == null || _selectedEntryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে প্রথমে প্রজেক্ট নির্বাচন করুন')),
      );
      return;
    }

    setState(() => _isLocating = true);

    try {
      double? lat;
      double? lng;
      double? accuracy;

      // জিপিএস পারমিশন ও লোকেশন গ্রহণ (PRD Rule 37 & 40)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = pos.latitude;
        lng = pos.longitude;
        accuracy = pos.accuracy;
      }

      final res = await ref.read(attendanceActionProvider.notifier).markAttendance(
        entryId: _selectedEntryId!,
        workerId: user.id,
        status: 'present',
        lat: lat,
        lng: lng,
        accuracy: accuracy,
      );

      setState(() => _alreadyMarked = true);

      if (mounted) {
        final locStatus = res['location_status'];
        final isVerified = locStatus == 'verified';
        final distance = res['distance_m'];

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
            title: Row(
              children: [
                Icon(
                  isVerified ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: isVerified ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(isVerified ? 'হাজিরা সম্পন্ন' : 'অনুমোদনের অপেক্ষায়'),
              ],
            ),
            content: Text(
              isVerified
                  ? 'আপনার আজকের হাজিরা সাইটের জিও-ফেন্স সীমার মধ্যে সঠিক হিসেবে গৃহীত হয়েছে।'
                  : 'আপনি সাইটের সীমানার বাইরে (${BengaliFormatter.toBengaliNumber(distance ?? 0)} মিটার দূরে) অবস্থান করছেন। ঠিকাদারের অনুমোদন সাপেক্ষে হাজিরা চূড়ান্ত হবে।',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
                child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedProjectName ?? 'সাইট হাজিরা দিন'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // নির্দেশনামূলক কার্ড
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.workerPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.workerPrimary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.workerPrimary, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'সাইটে উপস্থিত থেকে হাজিরা দিন',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'হাজিরা দেওয়ার সময় আপনার ফোনের জিপিএস অবস্থান সাইটের জিও-ফেন্স ব্যাসার্ধের সাথে মিলিয়ে যাচাই করা হবে।',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // প্রজেক্ট সিলেক্টর (আজকের খোলা এন্ট্রি)
            const Text(
              'প্রজেক্ট নির্বাচন করুন:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: _selectedEntryId != null ? AppColors.workerPrimary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: _selectedEntryId != null ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.apartment_rounded, color: AppColors.workerPrimary),
                title: const Text(
                  'ধানমন্ডি লেকভিউ রেসিডেন্স',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('আজকের দৈনিক এন্ট্রি খোলা রয়েছে', style: TextStyle(fontSize: 12, color: AppColors.success)),
                trailing: Radio<String>(
                  value: 'demo-entry-1',
                  groupValue: _selectedEntryId,
                  activeColor: AppColors.workerPrimary,
                  onChanged: (val) {
                    setState(() {
                      _selectedEntryId = val;
                      _selectedProjectName = 'ধানমন্ডি লেকভিউ রেসিডেন্স';
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedEntryId = 'demo-entry-1';
                    _selectedProjectName = 'ধানমন্ডি লেকভিউ রেসিডেন্স';
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // হাজিরা বোতাম
            ElevatedButton.icon(
              onPressed: (_isLocating || _alreadyMarked || _selectedEntryId == null)
                  ? null
                  : _handleMarkAttendance,
              icon: _isLocating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _alreadyMarked ? 'হাজিরা সম্পন্ন হয়েছে' : AppStrings.markAttendance,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.workerPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'নোট: একদিনে শুধুমাত্র একটি প্রজেক্টেই হাজিরা প্রদান করা সম্ভব। একবার হাজিরা দেওয়ার পর পরিবর্তন করা যাবে না।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
