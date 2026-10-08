import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CareerRoadmapsShimmer extends StatelessWidget {
  const CareerRoadmapsShimmer({super.key});

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
          // Stat Metrics Skeletons
          Row(
            children: [
              Expanded(child: _buildMetricShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricShimmer()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricShimmer()),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar Skeleton
          _buildBoxShimmer(height: 48, radius: 14),
          const SizedBox(height: 14),

          // Filter Chips Skeleton
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                _buildBoxShimmer(width: 70, height: 32, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 90, height: 32, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 110, height: 32, radius: 20),
                const SizedBox(width: 8),
                _buildBoxShimmer(width: 80, height: 32, radius: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Student Roadmap Cards Skeletons
          _buildCardShimmer(),
          const SizedBox(height: 16),
          _buildCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildMetricShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 160,
                        height: 11,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Checklist Items
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      highlightColor: const Color(0xFFF8FAFC),
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
