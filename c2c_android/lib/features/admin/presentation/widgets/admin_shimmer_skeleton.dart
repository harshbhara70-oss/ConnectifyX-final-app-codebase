import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminShimmerSkeleton extends StatelessWidget {
  const AdminShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(width: 140, height: 24, radius: 6),
                Row(
                  children: [
                    _buildBox(width: 36, height: 36, radius: 10),
                    const SizedBox(width: 8),
                    _buildBox(width: 36, height: 36, radius: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar Skeleton
            _buildBox(width: double.infinity, height: 42, radius: 12),
            const SizedBox(height: 16),

            // System Health Banner Skeleton
            _buildBox(width: double.infinity, height: 86, radius: 16),
            const SizedBox(height: 16),

            // KPI Grid (Row 1)
            Row(
              children: [
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
              ],
            ),
            const SizedBox(height: 16),

            // KPI Grid (Row 2)
            Row(
              children: [
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBox(width: double.infinity, height: 118, radius: 16)),
              ],
            ),
            const SizedBox(height: 16),

            // Traffic Chart Skeleton
            _buildBox(width: double.infinity, height: 260, radius: 16),
            const SizedBox(height: 16),

            // Live Activity Stream Skeleton
            _buildBox(width: double.infinity, height: 220, radius: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
