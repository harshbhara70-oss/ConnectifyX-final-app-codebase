import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/college_student_model.dart';
import '../../data/services/student_directory_api_service.dart';
import '../widgets/college_drawer.dart';

class CollegeStudentDetailPage extends StatefulWidget {
  final String studentId;

  const CollegeStudentDetailPage({super.key, required this.studentId});

  @override
  State<CollegeStudentDetailPage> createState() => _CollegeStudentDetailPageState();
}

class _CollegeStudentDetailPageState extends State<CollegeStudentDetailPage> {
  late Future<CollegeStudentModel> _studentFuture;
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    _studentFuture = StudentDirectoryApiService().fetchStudentById(widget.studentId);
  }

  void _retry() {
    setState(() {
      _studentFuture = StudentDirectoryApiService().fetchStudentById(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/students'),
      appBar: AppBar(
        title: AutoSizeText(
          'Student Profile & AI Resume',
          maxLines: 1,
          minFontSize: 14,
          style: TextStyle(
            color: context.txtPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: context.surf,
        foregroundColor: context.txtPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/college/students');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student profile link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: FutureBuilder<CollegeStudentModel>(
          future: _studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              final msg = snapshot.error.toString().replaceAll('Exception: ', '');
              final isSoon = msg.toLowerCase().contains('not reachable') ||
                  msg.toLowerCase().contains('soon');
              return _buildSoonOrErrorState(
                context,
                message: msg,
                isSoon: isSoon,
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildSoonOrErrorState(
                context,
                message: 'Student record not found in database.',
                isSoon: false,
              );
            }

            final student = snapshot.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.paddingOf(context).bottom == 0 ? 24 : MediaQuery.paddingOf(context).bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeaderCard(context, student),
                  const SizedBox(height: 16),
                  _buildAcademicMetricsGrid(context, student),
                  const SizedBox(height: 16),
                  _buildReadinessBreakdownBanner(context, student),
                  const SizedBox(height: 16),
                  _buildAiResumeCard(context, student),
                  const SizedBox(height: 16),
                  _buildAppliedDrivesSection(context),
                  const SizedBox(height: 16),
                  _buildTpoActionButtons(context, student),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          _handleNavigation(index);
        },
        onFabPressed: () {},
      ),
    );
  }

  Widget _buildSoonOrErrorState(BuildContext context,
      {required String message, required bool isSoon}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.paddingOf(context).bottom == 0 ? 24 : MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSoon ? const Color(0xFFDDD6FE) : const Color(0xFFFECDD3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSoon ? context.priLight : AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSoon ? LucideIcons.hourglass : LucideIcons.alertCircle,
                size: 28,
                color: isSoon ? AppColors.primary : AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            AutoSizeText(
              isSoon ? 'Student Details — Soon' : 'Unable to Load Profile',
              maxLines: 1,
              minFontSize: 12,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.txtPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.txtSecondary, height: 1.35),
            ),
            if (isSoon) ...[
              const SizedBox(height: 8),
              Text(
                'GET /api/college/students/:id — endpoint dependency missing. Data appears automatically once the server exposes it.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: context.txtMuted, height: 1.3),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go('/college/students');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Records'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(LucideIcons.refreshCw, size: 14, color: Colors.white),
                  label: const Text('Retry', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Profile Header Card — backend-truthful fields only ---
  Widget _buildProfileHeaderCard(BuildContext context, CollegeStudentModel student) {
    final isActive = student.isActive;
    final statusBg = isActive ? AppColors.successLight : AppColors.errorLight;
    final statusColor = isActive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'student-avatar-${student.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: context.priLight,
                  child: Text(
                    student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            student.name.isNotEmpty ? student.name : 'Unnamed Candidate',
                            maxLines: 1,
                            minFontSize: 14,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.txtPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AutoSizeText(
                            student.status,
                            maxLines: 1,
                            minFontSize: 9,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AutoSizeText(
                      student.branch.isNotEmpty
                          ? '${student.branch}${student.semester != null ? ' · Sem ${student.semester}' : ''}'
                          : 'Branch — Soon',
                      maxLines: 1,
                      minFontSize: 11,
                      style: TextStyle(fontSize: 13, color: context.txtSecondary),
                    ),
                    const SizedBox(height: 2),
                    AutoSizeText(
                      student.location.isNotEmpty
                          ? student.location
                          : (student.createdAt != null
                              ? 'Registered ${student.createdAt!.year}'
                              : 'Campus2Corporate'),
                      maxLines: 1,
                      minFontSize: 10,
                      style: TextStyle(fontSize: 12, color: context.txtMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: AutoSizeText(
                  student.email.isNotEmpty ? student.email : 'No email on record',
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: context.txtSecondary),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: AutoSizeText(
                  student.phone.isNotEmpty ? student.phone : '—',
                  maxLines: 1,
                  minFontSize: 10,
                  style: TextStyle(fontSize: 12, color: context.txtSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Academic Metrics — real fields: CGPA, Percentage, Semester ---
  Widget _buildAcademicMetricsGrid(BuildContext context, CollegeStudentModel student) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            context: context,
            title: 'CGPA',
            value: student.cgpa.toStringAsFixed(2),
            subtitle: 'Scale 10.0',
            icon: LucideIcons.award,
            color: AppColors.primary,
            bgColor: context.priLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            context: context,
            title: 'PERCENTAGE',
            value: '${student.percentage.toStringAsFixed(1)}%',
            subtitle: 'Academic %',
            icon: LucideIcons.percent,
            color: AppColors.accentViolet,
            bgColor: context.aiBadgeBgColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            context: context,
            title: 'SEMESTER',
            value: student.semester?.toString() ?? '—',
            subtitle: student.semester != null ? 'Current Sem' : 'Soon',
            icon: LucideIcons.graduationCap,
            color: student.semester != null ? AppColors.success : AppColors.textMuted,
            bgColor: student.semester != null ? AppColors.successLight : context.surfAlt,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 7,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.txtMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            maxLines: 1,
            minFontSize: 12,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.txtPrimary),
          ),
          const SizedBox(height: 2),
          AutoSizeText(
            subtitle,
            maxLines: 1,
            minFontSize: 8,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- 3. Readiness Banner ---
  Widget _buildReadinessBreakdownBanner(BuildContext context, CollegeStudentModel student) {
    final score = student.readinessScore;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.target, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  AutoSizeText(
                    'Student Placement Readiness',
                    maxLines: 1,
                    minFontSize: 11,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.txtPrimary),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AutoSizeText(
                    '$score% Score',
                    maxLines: 1,
                    minFontSize: 9,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Evaluated across Technical Coding, Aptitude, Soft Skills, and Domain Benchmarks.',
            style: TextStyle(fontSize: 12, color: context.txtSecondary, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/college/analytics/readiness');
              },
              icon: const Icon(LucideIcons.sparkles, size: 16),
              label: const AutoSizeText(
                'View Detailed Readiness Breakdown →',
                maxLines: 1,
                minFontSize: 10,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. AI Resume & ATS — atsScore nullable ---
  Widget _buildAiResumeCard(BuildContext context, CollegeStudentModel student) {
    final atsScore = student.atsScore;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  'AI Resume & ATS Benchmark',
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.txtPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: atsScore != null ? AppColors.successLight : context.aiBadgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: atsScore == null ? Border.all(color: const Color(0xFFE9D5FF)) : null,
                ),
                child: AutoSizeText(
                  atsScore != null ? 'ATS: $atsScore/100' : 'ATS: Soon',
                  maxLines: 1,
                  minFontSize: 9,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: atsScore != null ? AppColors.success : AppColors.accentViolet,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            student.bio.isNotEmpty ? student.bio : 'No bio added yet.',
            style: TextStyle(
                fontSize: 13,
                color: student.bio.isNotEmpty ? context.txtSecondary : context.txtMuted,
                height: 1.4),
          ),
          const SizedBox(height: 14),
          Text(
            'Verified Skill Competencies:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.txtMuted),
          ),
          const SizedBox(height: 6),
          if (student.skills.isEmpty)
            Text('No skills added — Soon',
                style: TextStyle(fontSize: 12, color: context.txtMuted))
          else
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: student.skills.map((skill) {
                return Chip(
                  label: AutoSizeText(skill, maxLines: 1, minFontSize: 9, style: const TextStyle(fontSize: 11)),
                  backgroundColor: context.priLight,
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading AI Resume PDF for ${student.name}...')),
                );
              },
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: const AutoSizeText('Download AI Resume (PDF)', maxLines: 1, style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Applied Drives — endpoint not wired per student ---
  Widget _buildAppliedDrivesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  'Applied Placement Drives',
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.txtPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: context.aiBadgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.hourglass, size: 10, color: AppColors.accentViolet),
                    const SizedBox(width: 4),
                    Text('Soon',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentViolet)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.surfAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.hourglass, size: 14, color: AppColors.accentViolet),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Per-student drive applications need a dedicated endpoint.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.txtPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'GET /api/college/applications?student=:id — not exposed per student yet. Timeline will populate automatically once wired.',
                  style: TextStyle(fontSize: 11, color: context.txtMuted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. TPO Actions ---
  Widget _buildTpoActionButtons(BuildContext context, CollegeStudentModel student) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mock interview scheduled for ${student.name}')),
              );
            },
            icon: const Icon(LucideIcons.calendar, size: 14),
            label: const AutoSizeText('Schedule Mock', maxLines: 1, style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/college/operations/communication');
            },
            icon: const Icon(LucideIcons.send, size: 14),
            label: const AutoSizeText('Send Alert', maxLines: 1, style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        context.go('/college/drives');
        break;
      case 3:
        context.go('/college/students');
        break;
      case 4:
        context.go('/college/operations/config');
        break;
    }
  }
}
