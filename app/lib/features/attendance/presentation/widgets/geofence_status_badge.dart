import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/bengali_formatter.dart';

class GeofenceStatusBadge extends StatelessWidget {
  final LocationResult? locationResult;
  final VoidCallback onRefresh;

  const GeofenceStatusBadge({
    super.key,
    required this.locationResult,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (locationResult == null) {
      return InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_searching, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'লোকেশন যাচাই করতে ট্যাপ করুন',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final isInside = locationResult!.isInside;
    final isUnavailable = locationResult!.locationStatus == 'location_unavailable';

    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;

    if (isUnavailable) {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade400;
      text = Colors.grey.shade800;
      icon = Icons.location_off;
      label = 'লোকেশন পাওয়া যায়নি';
    } else if (isInside) {
      bg = Colors.green.shade50;
      border = Colors.green.shade300;
      text = Colors.green.shade800;
      icon = Icons.check_circle_outline;
      label = 'সাইটের ভিতরে';
    } else {
      bg = Colors.amber.shade50;
      border = Colors.amber.shade300;
      text = Colors.amber.shade900;
      icon = Icons.warning_amber_rounded;
      label = 'সাইটের বাইরে';
    }

    final distance = locationResult!.distanceMeters;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: text),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const Spacer(),
              if (distance != null)
                Text(
                  'দূরত্ব: ${BengaliFormatter.toBnNumber(distance.round())} মিটার',
                  style: TextStyle(fontSize: 12, color: text),
                ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: onRefresh,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: text,
              ),
            ],
          ),
          if (!isInside && !isUnavailable) ...[
            const SizedBox(height: 6),
            const Text(
              'সতর্কতা: আপনি সাইটের নির্ধারিত সীমার বাইরে অবস্থান করছেন। হাজিরা ঠিকাদারের অনুমোদনের জন্য চিহ্নিত হবে।',
              style: TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ],
        ],
      ),
    );
  }
}
