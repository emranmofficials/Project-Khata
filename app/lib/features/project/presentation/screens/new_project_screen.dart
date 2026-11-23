import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../providers/project_provider.dart';
import 'map_location_picker_screen.dart';

/// PRD সেকশন ৬.৩ (২) অনুযায়ী নতুন প্রজেক্ট ফর্ম (৪টি বিভাগ)
class NewProjectScreen extends ConsumerStatefulWidget {
  const NewProjectScreen({super.key});

  @override
  ConsumerState<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends ConsumerState<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  // ক. প্রজেক্টের তথ্য
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedType = 'contract'; // 'sqft', 'contract', 'daily'

  // খ. সাইট লোকেশন
  double? _selectedLat;
  double? _selectedLng;
  double _geofenceRadius = 150.0; // ১০০ থেকে ২০০ মিটার

  // গ. ক্লায়েন্টের তথ্য
  final _clientNameController = TextEditingController();
  final _clientMobileController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    _clientNameController.dispose();
    _clientMobileController.dispose();
    super.dispose();
  }

  void _openMapPicker() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          initialLat: _selectedLat,
          initialLng: _selectedLng,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLat = result['lat'] as double;
        _selectedLng = result['lng'] as double;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাইট লোকেশন বাধ্যতামূলক। দয়া করে মানচিত্র থেকে লোকেশন নির্বাচন করুন।'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
      final result = await ref.read(projectActionProvider.notifier).createProject(
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        lat: _selectedLat!,
        lng: _selectedLng!,
        geofenceRadiusM: _geofenceRadius.toInt(),
        budget: budget,
        clientName: _clientNameController.text.trim(),
        clientMobile: _clientMobileController.text.trim(),
      );

      if (mounted) {
        final isNewClient = result['is_new_client'] as bool? ?? false;
        final clientMobile = result['client_mobile'] as String? ?? '';
        final last6 = clientMobile.length >= 6 ? clientMobile.substring(clientMobile.length - 6) : '';

        // PRD সফল বার্তা প্রদর্শন
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('প্রজেক্ট তৈরি হয়েছে'),
              ],
            ),
            content: Text(
              isNewClient
                  ? 'নতুন প্রজেক্ট তৈরি সফল হয়েছে!\n\nনতুন ক্লায়েন্টের লগইন তথ্য:\nমোবাইল: $clientMobile\nপ্রাথমিক পাসওয়ার্ড: $last6'
                  : 'বিদ্যমান ক্লায়েন্টের সাথে নতুন প্রজেক্ট যুক্ত হয়েছে।',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // তালিকা স্ক্রিনে ফেরা
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocationSelected = _selectedLat != null && _selectedLng != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newProject),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // -----------------------------------------------------------
                // ক. প্রজেক্টের তথ্য
                // -----------------------------------------------------------
                _buildSectionTitle('ক. প্রজেক্টের প্রাথমিক তথ্য'),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'প্রজেক্টের নাম *',
                    hintText: 'যেমন: ধানমন্ডি লেকভিউ রেসিডেন্স',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'প্রজেক্টের নাম লেখা বাধ্যতামূলক';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // প্রজেক্ট ধরন সেগমেন্ট বাটন
                const Text(
                  'প্রজেক্টের ধরন *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'sqft', label: Text('স্কয়ার ফিট')),
                    ButtonSegment(value: 'contract', label: Text('চুক্তি ভিত্তিক')),
                    ButtonSegment(value: 'daily', label: Text('রোজ ভিত্তিক')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'সাইটের বিস্তারিত ঠিকানা *',
                    hintText: 'প্লট নং, রোড নং, এলাকা, শহর',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'সাইটের ঠিকানা দেওয়া বাধ্যতামূলক';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'চুক্তি মূল্য বা আনুমানিক বাজেট (ঐচ্ছিক)',
                    hintText: 'টাকার পরিমাণ',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                // -----------------------------------------------------------
                // খ. সাইট লোকেশন ও জিও-ফেন্স
                // -----------------------------------------------------------
                _buildSectionTitle('খ. সাইট লোকেশন ও জিও-ফেন্স (বাধ্যতামূলক)'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(
                      color: isLocationSelected ? AppColors.success : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isLocationSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isLocationSelected ? Icons.check_circle_rounded : Icons.map_outlined,
                            color: isLocationSelected ? AppColors.success : AppColors.contractorPrimary,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLocationSelected ? 'সাইট লোকেশন নির্ধারিত হয়েছে' : 'মানচিত্র থেকে লোকেশন নির্বাচন করুন',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                if (isLocationSelected)
                                  Text(
                                    'অক্ষাংশ: ${BengaliFormatter.toBengaliNumber(_selectedLat!.toStringAsFixed(5))}, দ্রাঘিমাংশ: ${BengaliFormatter.toBengaliNumber(_selectedLng!.toStringAsFixed(5))}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  )
                                else
                                  const Text(
                                    'লোকেশন ছাড়া প্রজেক্ট সংরক্ষণ করা যাবে না',
                                    style: TextStyle(fontSize: 12, color: AppColors.danger),
                                  ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _openMapPicker,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.contractorPrimary,
                              side: const BorderSide(color: AppColors.contractorPrimary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(isLocationSelected ? 'পরিবর্তন' : 'মানচিত্র খুলুন'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // জিও-ফেন্স স্লাইডার (১০০ থেকে ২০০ মিটার, ধাপ ১০, ডিফল্ট ১৫০)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'সাইট জিও-ফেন্স রেডিয়াস:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.contractorPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${BengaliFormatter.toBengaliNumber(_geofenceRadius.toInt())} মিটার',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.contractorPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _geofenceRadius,
                        min: 100.0,
                        max: 200.0,
                        divisions: 10,
                        activeColor: AppColors.contractorPrimary,
                        label: '${_geofenceRadius.toInt()} মিটার',
                        onChanged: (val) {
                          setState(() {
                            _geofenceRadius = val;
                          });
                        },
                      ),
                      const Text(
                        'সাহায্য: শ্রমিক/সুপারভাইজার এই সীমার মধ্যে থাকলে হাজিরা "সঠিক" ধরা হবে।',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // -----------------------------------------------------------
                // গ. ক্লায়েন্টের তথ্য
                // -----------------------------------------------------------
                _buildSectionTitle('গ. ক্লায়েন্টের তথ্য'),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'ক্লায়েন্টের নাম *',
                    hintText: 'জমির মালিক বা প্রজেক্ট ক্রেতার নাম',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'ক্লায়েন্টের নাম লেখা বাধ্যতামূলক';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _clientMobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'ক্লায়েন্টের মোবাইল নম্বর *',
                    hintText: '০১৩–০১৯ (১১ সংখ্যা)',
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'ক্লায়েন্টের মোবাইল নম্বর বাধ্যতামূলক';
                    }
                    final regExp = RegExp(r'^01[3-9]\d{8}$');
                    if (!regExp.hasMatch(val.trim())) {
                      return 'সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'নোট: এই মোবাইল আগে থেকে থাকলে বিদ্যমান ক্লায়েন্টের সাথে প্রজেক্ট যুক্ত হবে। না থাকলে নতুন ক্লায়েন্ট তৈরি হবে। প্রজেক্ট তৈরির পর মোবাইল পরিবর্তন করা যাবে না।',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 32),

                // -----------------------------------------------------------
                // ঘ. প্রজেক্ট সংরক্ষণ বোতাম
                // -----------------------------------------------------------
                ElevatedButton(
                  onPressed: (_isSubmitting || !isLocationSelected) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.contractorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isLocationSelected ? 'প্রজেক্ট তৈরি করুন' : 'সাইট লোকেশন বাধ্যতামূলক',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}
