import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeedbackShimmer extends StatelessWidget {
  const FeedbackShimmer({super.key});

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
          // Stat Metrics Grid Skeletons
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
          const SizedBox(height: 18),

          // Form Card Skeleton
          _buildBoxShimmer(height: 240, radius: 18),
          const SizedBox(height: 18),

          // Search Bar Skeleton
          _buildBoxShimmer(height: 48, radius: 14),
          const SizedBox(height: 14),

          // Feedback List Card Skeletons
          ...List.generate(3, (index) => _buildFeedbackCardShimmer()),
        ],
      ),
    );
  }

  Widget _buildMetricShimmer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: [
          _buildBoxShimmer(width: 40, height: 40, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxShimmer(width: 50, height: 16, radius: 4),
                const SizedBox(height: 4),
                _buildBoxShimmer(width: 80, height: 11, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBoxShimmer(width: 44, height: 44, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBoxShimmer(width: 120, height: 14, radius: 4),
                    const SizedBox(height: 5),
                    _buildBoxShimmer(width: 160, height: 11, radius: 4),
                  ],
                ),
              ),
              _buildBoxShimmer(width: 40, height: 20, radius: 6),
            ],
          ),
          const SizedBox(height: 12),
          _buildBoxShimmer(height: 40, radius: 8),
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
