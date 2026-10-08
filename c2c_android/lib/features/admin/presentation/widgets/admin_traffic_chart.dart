import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_dashboard_models.dart';

/// Interactive 30-day traffic overview line chart.
/// Displays an Asterisk (*) badge because time-series traffic aggregation is currently mock.
class AdminTrafficChart extends StatelessWidget {
  final List<TrafficDataPointDto> trafficData;
  final String selectedPlatform;
  final Function(String) onPlatformChanged;

  const AdminTrafficChart({
    super.key,
    required this.trafficData,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.border,
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Platform Selector Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'TRAFFIC OVERVIEW (30D)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPlatform,
                      icon: const Icon(
                        LucideIcons.chevronDown,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      isDense: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: 'All Platforms',
                          child: Text('All Platforms'),
                        ),
                        DropdownMenuItem(
                          value: 'Web',
                          child: Text('Web'),
                        ),
                        DropdownMenuItem(
                          value: 'Mobile',
                          child: Text('Mobile'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.lightImpact();
                          onPlatformChanged(val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),

            // Chart Container
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (trafficData.length - 1).toDouble().clamp(0, 10),
                  minY: 0,
                  maxY: 10,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2.5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFF1F5F9),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < trafficData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                trafficData[idx].label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2.5,
                        getTitlesWidget: (value, meta) {
                          String text;
                          if (value == 0) {
                            text = '0';
                          } else if (value == 2.5) {
                            text = '2.5k';
                          } else if (value == 5.0) {
                            text = '5k';
                          } else if (value == 7.5) {
                            text = '7.5k';
                          } else if (value == 10.0) {
                            text = '10k';
                          } else {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                      left: BorderSide.none,
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => AppColors.cardDark,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final point = idx >= 0 && idx < trafficData.length
                              ? trafficData[idx]
                              : null;
                          final label = point != null
                              ? '${point.label}: ${point.displayVal}'
                              : '${spot.y}k visits';

                          return LineTooltipItem(
                            label,
                            GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trafficData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.accent,
                      barWidth: 3.0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3.5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: AppColors.accent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.30),
                            AppColors.accent.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
