import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';
import '../../bloc/post_job_bloc.dart';
import '../widgets/recruiter_side_nav.dart';

class PostJobPage extends StatelessWidget {
  const PostJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostJobBloc(),
      child: const _PostJobView(),
    );
  }
}

class _PostJobView extends StatefulWidget {
  const _PostJobView();

  @override
  State<_PostJobView> createState() => _PostJobViewState();
}

class _PostJobViewState extends State<_PostJobView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  void _showToolbarFeedback(String actionName) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              '$actionName formatting applied',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 14.0, 20.0);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const RecruiterSideNav(highlightRoute: '/recruiter/post-job'),
        appBar: _buildAppBar(context, screenWidth),
        body: SafeArea(
          bottom: true,
          child: BlocConsumer<PostJobBloc, PostJobState>(
            listener: (context, state) {
              if (state.isSuccess) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.asDraft
                                ? 'Job draft saved successfully!'
                                : '🎉 New job vacancy published successfully!',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                Future.delayed(const Duration(milliseconds: 1200), () {
                  if (context.mounted) {
                    if (Navigator.canPop(context)) {
                      context.pop();
                    } else {
                      context.go('/recruiter/dashboard');
                    }
                  }
                });
              } else if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 12.0,
                  bottom: bottomInset > 0 ? bottomInset + 20.0 : 28.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Breadcrumb & Header Action Bar (1:1 with Web PostJob.tsx)
                    _buildHeaderBar(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // Success Confirmation Card if submitted
                    if (state.isSuccess) ...[
                      _buildSuccessAlert(),
                      const SizedBox(height: 14),
                    ],

                    // 2. Role Information Card
                    _buildRoleInfoCard(context, state, screenWidth),
                    const SizedBox(height: 18),

                    // 3. Required Skills Card
                    _buildRequiredSkillsCard(context, state),
                    const SizedBox(height: 18),

                    // 4. Eligibility Criteria Card
                    _buildEligibilityCard(context, state),
                    const SizedBox(height: 18),

                    // 5. Instant Live Card Preview (Zero-Overflow Protected)
                    _buildLivePreviewCard(context, state),
                    const SizedBox(height: 20),

                    // 6. Bottom Publish / Draft Action Buttons
                    _buildBottomActionButtons(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    final titleFontSize = clampDouble(screenWidth * 0.044, 16.0, 19.0);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            HapticFeedback.selectionClick();
            Scaffold.of(ctx).openDrawer();
          },
          tooltip: 'Open navigation menu',
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFECE6FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.plusCircle,
              color: Color(0xFF5E17EB),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Post a New Job',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                BlocBuilder<PostJobBloc, PostJobState>(
                  builder: (context, state) {
                    if (state.isMock) {
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '*',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textSecondary, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/recruiter/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // --- 1. Header Bar with Breadcrumb & Quick Actions ---
  Widget _buildHeaderBar(BuildContext context, PostJobState state, double screenWidth) {
    final btnFontSize = clampDouble(screenWidth * 0.03, 11.0, 12.5);

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              GestureDetector(
                onTap: () => context.go('/recruiter/dashboard'),
                child: const Text(
                  'Postings',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 13, color: AppColors.textMuted),
              const Text(
                'Create New Job',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BouncyButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      context.read<PostJobBloc>().add(const SubmitJobPosting(asDraft: true));
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Draft',
                  style: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.w700, color: const Color(0xFF5E17EB)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            BouncyButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      context.read<PostJobBloc>().add(const SubmitJobPosting(asDraft: false));
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E17EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Publish',
                        style: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle2, color: Color(0xFF059669), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Job posting submitted successfully! Redirecting to dashboard...',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Role Information Card ---
  Widget _buildRoleInfoCard(BuildContext context, PostJobState state, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Role Information',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '* Mandatory fields',
                style: TextStyle(fontSize: 10.5, color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Job Title Field (Strict NO NUMBERS Rule from Web PostJob.tsx)
          const Text(
            'Job Title *',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            onChanged: (val) {
              context.read<PostJobBloc>().add(JobTitleChanged(val));
            },
            decoration: InputDecoration(
              hintText: 'e.g. Senior Full Stack Engineer (Letters only)',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: state.jobTitleError.isNotEmpty || state.errors.containsKey('jobTitle')
                  ? const Color(0xFFFEF2F2)
                  : AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.jobTitleError.isNotEmpty || state.errors.containsKey('jobTitle')
                      ? const Color(0xFFF87171)
                      : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.jobTitleError.isNotEmpty || state.errors.containsKey('jobTitle')
                      ? const Color(0xFFF87171)
                      : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          if (state.jobTitleError.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, size: 12, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    state.jobTitleError,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ),
          ] else if (state.errors.containsKey('jobTitle')) ...[
            const SizedBox(height: 4),
            Text(
              state.errors['jobTitle']!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'Numbers (0-9) are strictly prohibited in Job Title field.',
            style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          // 2. Job Description Field with Rich-Text Mockup
          const Text(
            'Job Description *',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.errors.containsKey('jobDescription') ? const Color(0xFFF87171) : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                // Scrollable rich-text toolbar mockup
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: const BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Bold'),
                          child: const Icon(LucideIcons.bold, size: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Italic'),
                          child: const Icon(LucideIcons.italic, size: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Underline'),
                          child: const Icon(LucideIcons.underline, size: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 14),
                        const Text('|', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Link'),
                          child: const Icon(LucideIcons.link, size: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Bullet list'),
                          child: const Icon(LucideIcons.list, size: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => _showToolbarFeedback('Numbered list'),
                          child: const Icon(LucideIcons.listOrdered, size: 15, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  onChanged: (val) {
                    context.read<PostJobBloc>().add(JobDescriptionChanged(val));
                  },
                  decoration: const InputDecoration(
                    hintText: 'Describe responsibilities, daily tasks, key requirements, and team dynamics...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35),
                ),
              ],
            ),
          ),
          if (state.errors.containsKey('jobDescription')) ...[
            const SizedBox(height: 4),
            Text(
              state.errors['jobDescription']!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 16),

          // 3. Job Type & Remote Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Type *',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<PostJobBloc>().add(const RemoteToggled());
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Remote',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      state.isRemote ? LucideIcons.toggleRight : LucideIcons.toggleLeft,
                      color: state.isRemote ? const Color(0xFF5E17EB) : AppColors.textMuted,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.jobType,
                isExpanded: true,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'Full-time Permanent', child: Text('Full-time Permanent')),
                  DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                  DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    context.read<PostJobBloc>().add(JobTypeChanged(val));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Office Location Field
          Text(
            state.isRemote ? 'Office Location (Remote Enabled)' : 'Office Location *',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _locationController,
            enabled: !state.isRemote,
            onChanged: (val) {
              context.read<PostJobBloc>().add(LocationChanged(val));
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
              hintText: state.isRemote ? 'Remote Position' : 'City, Country (e.g. Bangalore, India)',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: state.isRemote ? const Color(0xFFF1F5F9) : AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.errors.containsKey('location') ? const Color(0xFFF87171) : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.errors.containsKey('location') ? const Color(0xFFF87171) : AppColors.border,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          if (state.errors.containsKey('location')) ...[
            const SizedBox(height: 4),
            Text(
              state.errors['location']!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 16),

          // 5. Salary Range (Annual) Row (Zero-Overflow Protected)
          const Text(
            'Salary Range (Annual) *',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _salaryMinController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PostJobBloc>().add(SalaryMinChanged(val)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 14, color: AppColors.textSecondary),
                    prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    hintText: 'Min',
                    hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Text('TO', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _salaryMaxController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PostJobBloc>().add(SalaryMaxChanged(val)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 14, color: AppColors.textSecondary),
                    prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    hintText: 'Max',
                    hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.salaryCurrency,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'LPA', child: Text('LPA')),
                      DropdownMenuItem(value: 'INR', child: Text('INR')),
                    ],
                    onChanged: (val) {
                      if (val != null) context.read<PostJobBloc>().add(SalaryCurrencyChanged(val));
                    },
                  ),
                ),
              ),
            ],
          ),
          if (state.errors.containsKey('salaryMin') || state.errors.containsKey('salaryMax')) ...[
            const SizedBox(height: 4),
            const Text(
              'Please specify both minimum and maximum salary range.',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
        ],
      ),
    );
  }

  // --- 3. Required Skills Card ---
  Widget _buildRequiredSkillsCard(BuildContext context, PostJobState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Required Skills *',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                'Add skills',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Skill Chips
          if (state.skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(state.skills.length, (i) {
                final skill = state.skills[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD6C7FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5E17EB)),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<PostJobBloc>().add(SkillRemoved(i));
                        },
                        child: const Icon(LucideIcons.x, size: 12, color: Color(0xFF5E17EB)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          if (state.skills.isNotEmpty) const SizedBox(height: 12),

          // Input + Add Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSkillController,
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      context.read<PostJobBloc>().add(SkillAdded(val.trim()));
                      _newSkillController.clear();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a skill (e.g. Flutter, Docker)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final text = _newSkillController.text.trim();
                  if (text.isNotEmpty) {
                    HapticFeedback.selectionClick();
                    context.read<PostJobBloc>().add(SkillAdded(text));
                    _newSkillController.clear();
                  }
                },
                icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                label: const Text('Add', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E17EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
              ),
            ],
          ),
          if (state.errors.containsKey('skills')) ...[
            const SizedBox(height: 6),
            Text(
              state.errors['skills']!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
          ],
        ],
      ),
    );
  }

  // --- 4. Eligibility Criteria Card ---
  Widget _buildEligibilityCard(BuildContext context, PostJobState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Eligibility Criteria',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              BouncyButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.read<PostJobBloc>().add(const EligibilityRuleAdded());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Color(0xFF5E17EB)),
                      SizedBox(width: 4),
                      Text(
                        'Add Rule',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.eligibilityRules.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.eligibilityRules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final rule = state.eligibilityRules[idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rule #${idx + 1}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<PostJobBloc>().add(EligibilityRuleRemoved(rule.id));
                            },
                            child: const Icon(LucideIcons.trash2, size: 15, color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (val) {
                          context.read<PostJobBloc>().add(EligibilityRuleUpdated(id: rule.id, institutionTier: val));
                        },
                        decoration: InputDecoration(
                          labelText: 'INSTITUTION TIER',
                          labelStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          hintText: 'e.g. Tier 1 / IIT / NIT',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (val) {
                          context.read<PostJobBloc>().add(EligibilityRuleUpdated(id: rule.id, department: val));
                        },
                        decoration: InputDecoration(
                          labelText: 'DEPARTMENT',
                          labelStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          hintText: 'e.g. Computer Science',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (val) {
                          context.read<PostJobBloc>().add(EligibilityRuleUpdated(id: rule.id, requirement: val));
                        },
                        decoration: InputDecoration(
                          labelText: 'MIN SCORE / GPA',
                          labelStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          hintText: 'e.g. 60% or 7.0 CGPA',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'No eligibility criteria rules added yet.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  BouncyButton(
                    onPressed: () {
                      context.read<PostJobBloc>().add(const EligibilityRuleAdded());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE6FE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD6C7FE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.plus, size: 12, color: Color(0xFF5E17EB)),
                          SizedBox(width: 4),
                          Text(
                            'Add First Rule',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- 5. Instant Live Card Preview (Zero-Overflow Protected) ---
  Widget _buildLivePreviewCard(BuildContext context, PostJobState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Instant Card Preview',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE6FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE PREVIEW',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF5E17EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rendered Preview Card
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E17EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('C2C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.jobTitle.isNotEmpty ? state.jobTitle : 'Job Title Preview',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.jobType} • ${state.isRemote ? 'Remote' : (state.location.isNotEmpty ? state.location : 'Location')}',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.jobDescription.isNotEmpty
                      ? state.jobDescription
                      : 'Job description excerpt will appear here as you type in real-time...',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
                if (state.skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: state.skills.take(4).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE6FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF5E17EB)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Salary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Flexible(
                      child: Text(
                        state.salaryMin.isNotEmpty && state.salaryMax.isNotEmpty
                            ? '₹${state.salaryMin} - ₹${state.salaryMax} ${state.salaryCurrency}'
                            : '₹ Salary Range',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Candidates will see this preview card in their job search feed.',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // --- 6. Bottom Sticky Publish Buttons ---
  Widget _buildBottomActionButtons(BuildContext context, PostJobState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () {
                    context.read<PostJobBloc>().add(const SubmitJobPosting(asDraft: false));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E17EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: state.isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text(
                    'Publish Job Vacancy',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton(
            onPressed: state.isSubmitting
                ? null
                : () {
                    context.read<PostJobBloc>().add(const SubmitJobPosting(asDraft: true));
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Save as Draft',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5E17EB)),
            ),
          ),
        ),
      ],
    );
  }
}
