import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';

/// PRD সেকশন ৬.৩ (২) খ অনুযায়ী ওপেনস্ট্রিটম্যাপ ভিত্তিক সাইট লোকেশন পিকার
/// (OpenStreetMap ব্যবহার করায় কোনো Google Maps API Key বা ক্রেডিট কার্ডের প্রয়োজন নেই)
class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late double _selectedLat;
  late double _selectedLng;
  final MapController _mapController = MapController();
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    // ডিফল্ট ঢাকা সেন্টার (23.8103, 90.4125) অথবা প্রদানকৃত কোঅর্ডিনেট
    _selectedLat = widget.initialLat ?? 23.8103;
    _selectedLng = widget.initialLng ?? 90.4125;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// ডিভাইসের সরাসরি জিপিএস চিপ থেকে বর্তমান অবস্থান সংগ্রহ
  Future<void> _fetchCurrentGpsLocation() async {
    setState(() => _isLoadingCurrentLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('জিপিএস পারমিশন স্থায়ীভাবে বন্ধ রয়েছে। অ্যাপ সেটিংসে গিয়ে চালু করুন।'),
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _selectedLat = pos.latitude;
          _selectedLng = pos.longitude;
        });

        // ম্যাপকে বর্তমান অবস্থানে মুভ করা
        _mapController.move(LatLng(_selectedLat, _selectedLng), 16.5);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('লোকেশন পেতে সমস্যা হয়েছে: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCurrentLocation = false);
      }
    }
  }

  void _confirmLocation() {
    Navigator.of(context).pop({
      'lat': _selectedLat,
      'lng': _selectedLng,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সাইট লোকেশন ও সীমানা নির্ধারণ'),
        actions: [
          IconButton(
            tooltip: 'বর্তমান জিপিএস লোকেশন',
            icon: _isLoadingCurrentLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location_rounded),
            onPressed: _fetchCurrentGpsLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ওপেনস্ট্রিটম্যাপ (OpenStreetMap - 100% Free, No API Key Required)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_selectedLat, _selectedLng),
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 18.5,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLat = point.latitude;
                  _selectedLng = point.longitude;
                });
              },
            ),
            children: [
              // ফ্রি ওপেনস্ট্রিটম্যাপ টাইলস
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.projectkhata.app',
              ),

              // ১৫০ মিটার সাইট সীমানা সার্কেল (PRD জিও-ফেন্স ভিউয়ালাইজেশন)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(_selectedLat, _selectedLng),
                    radius: 150.0,
                    useRadiusInMeter: true,
                    color: AppColors.contractorPrimary.withOpacity(0.18),
                    borderColor: AppColors.contractorPrimary,
                    borderStrokeWidth: 2.5,
                  ),
                ],
              ),

              // সাইট সেন্টার পিন মার্কার
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_selectedLat, _selectedLng),
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.danger,
                      size: 46,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // উপরের দিকনির্দেশনা ও সার্চ ব্যানার
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Card(
              elevation: 4,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, color: AppColors.contractorPrimary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'মানচিত্রে যেকোনো স্থানে ট্যাপ করে সাইট পিন বসান। নীল বৃত্তটি ১৫০মি সাইট সীমানা।',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // জুম ইন ও জুম আউট ফ্লোটিং বাটন
          Positioned(
            right: 16,
            bottom: 180,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(LatLng(_selectedLat, _selectedLng), zoom);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(LatLng(_selectedLat, _selectedLng), zoom);
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'current_loc_fab',
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  onPressed: _fetchCurrentGpsLocation,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // নিচের কনফার্মেশন ও কোঅর্ডিনেট কার্ড
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.contractorPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.share_location_rounded, color: AppColors.contractorPrimary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'নির্বাচিত সাইট কোঅর্ডিনেট',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'অক্ষাংশ: ${BengaliFormatter.toBengaliNumber(_selectedLat.toStringAsFixed(6))}  |  দ্রাঘিমাংশ: ${BengaliFormatter.toBengaliNumber(_selectedLng.toStringAsFixed(6))}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.contractorPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'এই সাইট লোকেশন নিশ্চিত করুন',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
