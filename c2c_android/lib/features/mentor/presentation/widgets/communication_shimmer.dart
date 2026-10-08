import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommunicationShimmer extends StatelessWidget {
  const CommunicationShimmer({super.key});

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
          // Banner Skeleton
          _buildBoxShimmer(height: 84, radius: 18),
          const SizedBox(height: 16),

          // Search Bar Skeleton
          _buildBoxShimmer(height: 48, radius: 14),
          const SizedBox(height: 16),

          // Filter Chips Skeleton
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                _buildBoxShimmer(width: 90, height: 34, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 130, height: 34, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 145, height: 34, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 110, height: 34, radius: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact / Channel cards Skeleton
          ...List.generate(5, (index) => _buildContactCardShimmer()),
        ],
      ),
    );
  }

  Widget _buildContactCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: [
          _buildBoxShimmer(width: 44, height: 44, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxShimmer(width: 120, height: 14, radius: 4),
                const SizedBox(height: 6),
                _buildBoxShimmer(width: 180, height: 11, radius: 4),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildBoxShimmer(width: 38, height: 12, radius: 4),
        ],
      ),
    );
  }

  Widget _buildBoxShimmer({
    double? width,
    required double height,
    required double radius,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF1F5F9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
