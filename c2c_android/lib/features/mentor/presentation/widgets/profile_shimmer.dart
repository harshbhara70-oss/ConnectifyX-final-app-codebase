import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.045,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Identity Header Skeleton
          _buildBoxShimmer(height: 190, radius: 20),
          const SizedBox(height: 14),

          // Action Toolbar Skeleton
          Row(
            children: [
              Expanded(flex: 3, child: _buildBoxShimmer(height: 44, radius: 14)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildBoxShimmer(height: 44, radius: 14)),
            ],
          ),
          const SizedBox(height: 14),

          // Stats 4-Column Grid Skeleton
          Row(
            children: [
              Expanded(child: _buildBoxShimmer(height: 70, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _buildBoxShimmer(height: 70, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _buildBoxShimmer(height: 70, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _buildBoxShimmer(height: 70, radius: 14)),
            ],
          ),
          const SizedBox(height: 16),

          // Credentials Card Skeleton
          _buildBoxShimmer(height: 210, radius: 18),
          const SizedBox(height: 14),

          // Availability Switch Card Skeleton
          _buildBoxShimmer(height: 85, radius: 18),
          const SizedBox(height: 14),

          // Domain Expertise Card Skeleton
          _buildBoxShimmer(height: 140, radius: 18),
        ],
      ),
    );
  }

  Widget _buildBoxShimmer({required double height, double radius = 16}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
