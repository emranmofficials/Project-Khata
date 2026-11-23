import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// PRD সেকশন ১১.৬ অনুযায়ী স্থির স্কেলেটন লোডার (ঝিলিমিলি নয়, পরিচ্ছন্ন স্থির আকার)
class LoadingSkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingSkeletonCard({
    super.key,
    this.height = 80.0,
    this.width,
    this.borderRadius = AppSizes.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// একাধিক স্কেলেটন আইটেমের তালিকা লোডার
class LoadingSkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const LoadingSkeletonList({
    super.key,
    this.count = 4,
    this.itemHeight = 90.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => LoadingSkeletonCard(height: itemHeight),
    );
  }
}
