import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_settings_models.dart';

/// Card for AI Readiness Score Weights Sliders matching web SettingsView.tsx
class AdminAiWeightsCard extends StatelessWidget {
  final AdminAiWeightsModel aiWeights;
  final Function(int? academic, int? softSkills, int? techProjects, int? extracurricular) onWeightChange;
  final VoidCallback onSave;
  final bool isSaving;

  const AdminAiWeightsCard({
    super.key,
    required this.aiWeights,
    required this.onWeightChange,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleSize = (screenWidth * 0.038).clamp(14.0, 15.5);
    final total = aiWeights.totalWeight;
    final isTotal100 = total == 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.brain, size: 16, color: Color(0xFF6D28D9)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'AI Readiness Weights',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (aiWeights.isMock) ...[
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Total Weight Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isTotal100 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isTotal100 ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  'Total: $total%',
                  style: GoogleFonts.firaCode(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isTotal100 ? const Color(0xFF059669) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Slider 1: Academic Performance
          _buildSlider(
            title: 'Academic Performance',
            value: aiWeights.academicWeight,
            onChanged: (v) => onWeightChange(v.toInt(), null, null, null),
          ),
          const SizedBox(height: 12),

          // Slider 2: Soft Skills Assessment
          _buildSlider(
            title: 'Soft Skills Assessment',
            value: aiWeights.softSkillsWeight,
            onChanged: (v) => onWeightChange(null, v.toInt(), null, null),
          ),
          const SizedBox(height: 12),

          // Slider 3: Technical Project Portfolio
          _buildSlider(
            title: 'Technical Project Portfolio',
            value: aiWeights.techProjectsWeight,
            onChanged: (v) => onWeightChange(null, null, v.toInt(), null),
          ),
          const SizedBox(height: 12),

          // Slider 4: Extracurricular Leadership
          _buildSlider(
            title: 'Extracurricular Leadership',
            value: aiWeights.extracurricularWeight,
            onChanged: (v) => onWeightChange(null, null, null, v.toInt()),
          ),
          const SizedBox(height: 16),

          // Save CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onSave();
                    },
              icon: isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.checkCircle2, size: 15),
              label: Text(
                isSaving ? 'Saving...' : 'Save AI Weights',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6D28D9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: const Color(0xFF6D28D9),
            inactiveTrackColor: const Color(0xFFEDE9FE),
            thumbColor: const Color(0xFF6D28D9),
            overlayColor: const Color(0x206D28D9),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
