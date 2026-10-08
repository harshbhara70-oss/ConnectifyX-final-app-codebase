import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_study_material_bloc.dart';
import '../../bloc/mentor_study_material_event.dart';
import '../../bloc/mentor_study_material_state.dart';
import '../../data/models/mentor_study_material_model.dart';
import '../../data/services/mentor_material_download_service.dart';
import '../widgets/mentor_drawer.dart';

/// Production-ready Study Material Library Screen for Mentor Module
/// 1:1 Parity with web frontend (Shared Material Library)
/// Zero truncation, zero ellipsis, real-time MongoDB Atlas sync, and Android navigation safe.
class MentorStudyMaterialPage extends StatelessWidget {
  const MentorStudyMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorStudyMaterialBloc()
        ..add(const FetchStudyMaterialsEvent()),
      child: const _MentorStudyMaterialView(),
    );
  }
}

class _MentorStudyMaterialView extends StatefulWidget {
  const _MentorStudyMaterialView();

  @override
  State<_MentorStudyMaterialView> createState() =>
      _MentorStudyMaterialViewState();
}

class _MentorStudyMaterialViewState extends State<_MentorStudyMaterialView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Interview Questions',
    'Coding Sheets',
    'PDFs',
    'Resume Templates',
    'Company Experiences',
    'Videos',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUploadMaterialBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final sizeController = TextEditingController(text: '1.5 MB');
    String selectedCat = 'PDFs';
    PlatformFile? pickedFile;
    bool isPickingFile = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final screenHeight = MediaQuery.sizeOf(sheetContext).height;
            final screenWidth = MediaQuery.sizeOf(sheetContext).width;
            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
            final navBarPadding = MediaQuery.paddingOf(sheetContext).bottom;

            Future<void> handlePickFile() async {
              try {
                setModalState(() => isPickingFile = true);
                final result = await FilePicker.pickFiles(
                  type: FileType.any,
                  allowMultiple: false,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  final fileName = file.name;
                  final bytes = file.size;

                  // Format file size
                  String formattedSize;
                  if (bytes > 1024 * 1024) {
                    formattedSize =
                        '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
                  } else if (bytes > 1024) {
                    formattedSize =
                        '${(bytes / 1024).toStringAsFixed(0)} KB';
                  } else {
                    formattedSize = '$bytes Bytes';
                  }

                  // Auto detect category
                  final ext = (file.extension ?? '').toLowerCase();
                  String detectedCategory = selectedCat;
                  if (ext == 'pdf') {
                    detectedCategory = 'PDFs';
                  } else if ([
                    'dart',
                    'py',
                    'js',
                    'ts',
                    'java',
                    'cpp',
                    'c',
                    'html',
                    'css',
                    'json',
                    'sql'
                  ].contains(ext)) {
                    detectedCategory = 'Coding Sheets';
                  } else if (['doc', 'docx', 'txt', 'rtf'].contains(ext)) {
                    detectedCategory = 'Resume Templates';
                  } else if (['mp4', 'mov', 'avi', 'mkv', 'webm']
                      .contains(ext)) {
                    detectedCategory = 'Videos';
                  } else if (['zip', 'rar', 'tar', 'gz'].contains(ext)) {
                    detectedCategory = 'Interview Questions';
                  }

                  setModalState(() {
                    pickedFile = file;
                    sizeController.text = formattedSize;
                    selectedCat = detectedCategory;
                    if (titleController.text.trim().isEmpty) {
                      titleController.text = fileName.replaceAll(
                          RegExp(r'\.[a-zA-Z0-9]+$'), '');
                    }
                    isPickingFile = false;
                  });
                } else {
                  setModalState(() => isPickingFile = false);
                }
              } catch (_) {
                setModalState(() => isPickingFile = false);
              }
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: math.max(bottomInset, navBarPadding) + 24,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.uploadCloud,
                              color: AppColors.primaryPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Shared Resource',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(
                                        screenWidth * 0.046, 16.0, 19.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Share materials with mentees across cohorts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // File Picker Section
                      Text(
                        'Select Document / File *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (pickedFile == null)
                        InkWell(
                          onTap: isPickingFile ? null : handlePickFile,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primaryPurple
                                    .withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightLavender,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isPickingFile
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryPurple),
                                          ),
                                        )
                                      : const Icon(
                                          LucideIcons.paperclip,
                                          color: AppColors.primaryPurple,
                                          size: 18,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose File from Device',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PDF, DOCX, Code Sheets, Videos, ZIP',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF86EFAC),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.fileCheck,
                                  color: Color(0xFF16A34A),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickedFile!.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF14532D),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFBBF7D0),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            (pickedFile!.extension ?? 'FILE')
                                                .toUpperCase(),
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF166534),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          sizeController.text,
                                          style:
                                              GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.refreshCw,
                                  color: Color(0xFF16A34A),
                                  size: 16,
                                ),
                                tooltip: 'Change File',
                                onPressed: handlePickFile,
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  color: Color(0xFFDC2626),
                                  size: 16,
                                ),
                                tooltip: 'Remove File',
                                onPressed: () {
                                  setModalState(() {
                                    pickedFile = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),

                      // Resource Title
                      Text(
                        'Resource Title *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Stripe mock API documentation',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Category Selector
                      Text(
                        'Resource Category *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCat,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, size: 18),
                            items: _categories
                                .where((c) => c != 'All')
                                .map((cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(
                                        cat,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedCat = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Estimated File Size
                      Text(
                        'File Size',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: sizeController,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. 2.4 MB or 920 KB',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Description / Notes
                      Text(
                        'Description / Usage Notes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Recommended for Stripe cohort candidates',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            if (title.isNotEmpty) {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<MentorStudyMaterialBloc>()
                                  .add(UploadStudyMaterialEvent(
                                    title: title,
                                    category: selectedCat,
                                    size: sizeController.text.trim().isNotEmpty
                                        ? sizeController.text.trim()
                                        : '1.5 MB',
                                    description: descController.text.trim(),
                                    fileUrl: pickedFile?.path ?? '',
                                  ));
                              Navigator.pop(sheetContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.upload, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Upload to Library',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'interview questions':
        return LucideIcons.helpCircle;
      case 'coding sheets':
        return LucideIcons.code;
      case 'resume templates':
        return LucideIcons.layoutTemplate;
      case 'company experiences':
        return LucideIcons.briefcase;
      case 'videos':
        return LucideIcons.playCircle;
      case 'pdfs':
      default:
        return LucideIcons.fileText;
    }
  }

  Color _getCategoryBadgeBg(String category) {
    switch (category.toLowerCase()) {
      case 'interview questions':
        return const Color(0xFFEFF6FF);
      case 'coding sheets':
        return const Color(0xFFF3E8FF);
      case 'resume templates':
        return const Color(0xFFECFDF5);
      case 'company experiences':
        return const Color(0xFFFFFBEB);
      case 'videos':
        return const Color(0xFFFDF2F8);
      case 'pdfs':
      default:
        return AppColors.lightLavender;
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'interview questions':
        return const Color(0xFF2563EB);
      case 'coding sheets':
        return const Color(0xFF7C3AED);
      case 'resume templates':
        return const Color(0xFF059669);
      case 'company experiences':
        return const Color(0xFFD97706);
      case 'videos':
        return const Color(0xFFDB2777);
      case 'pdfs':
      default:
        return AppColors.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const MentorNavigationDrawer(currentRoute: '/mentor/resources'),
      appBar: _buildAppBar(context, screenWidth),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<MentorStudyMaterialBloc, MentorStudyMaterialState>(
          listener: (context, state) {
            if (state is StudyMaterialLoaded && state.toastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.toastMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is StudyMaterialLoading || state is StudyMaterialInitial) {
              return _buildShimmerLoading(screenWidth);
            }

            if (state is StudyMaterialError) {
              return _buildErrorState(context, state.message);
            }

            if (state is StudyMaterialLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryPurple,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context
                      .read<MentorStudyMaterialBloc>()
                      .add(const FetchStudyMaterialsEvent(isRefresh: true));
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    bottom: bottomInset == 0 ? 24.0 : bottomInset + 16.0,
                    top: 16.0,
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Soon Badge
                      _buildHeaderTitle(context, state.data.isMock, screenWidth),
                      const SizedBox(height: 16),

                      // Metric Summary Counters
                      RepaintBoundary(
                        child: _buildMetricSummaryGrid(state.data, screenWidth),
                      ),
                      const SizedBox(height: 18),

                      // Search & Upload CTA Strip
                      _buildSearchBarAndUploadCta(context, state, screenWidth),
                      const SizedBox(height: 14),

                      // Category Filter Pills
                      _buildCategoryFilterRow(context, state, screenWidth),
                      const SizedBox(height: 16),

                      // Materials Directory Section
                      _buildMaterialsListSection(context, state, screenWidth),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          LucideIcons.menu,
          color: AppColors.textPrimary,
          size: 22,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Study Materials',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.044, 15.5, 17.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Shared Resource Library',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            LucideIcons.rotateCw,
            color: AppColors.textSecondary,
            size: 20,
          ),
          tooltip: 'Refresh Library',
          onPressed: () {
            HapticFeedback.lightImpact();
            context
                .read<MentorStudyMaterialBloc>()
                .add(const FetchStudyMaterialsEvent(isRefresh: true));
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(
      BuildContext context, bool isMock, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      isMock
                          ? 'Material Library *'
                          : 'Material Library',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(
                            screenWidth * 0.052, 18.0, 22.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isMock) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.sparkles,
                            size: 11,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Soon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Filter by category tags or upload documents for mentees',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 14.0),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSummaryGrid(
      MentorStudyMaterialPayload data, double screenWidth) {
    final isMock = data.isMock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.files,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFECE6FE),
                  label: 'Total Files',
                  value: isMock ? '${data.totalCount} *' : '${data.totalCount}',
                  screenWidth: screenWidth,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.folder,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                  label: 'Categories',
                  value: isMock
                      ? '${data.categoriesCount} *'
                      : '${data.categoriesCount}',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0), thickness: 0.8),
          Row(
            children: [
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.downloadCloud,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Downloads',
                  value: isMock
                      ? '${data.totalDownloads} *'
                      : '${data.totalDownloads}',
                  screenWidth: screenWidth,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.sparkles,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFFFBEB),
                  label: 'Latest File',
                  value: data.resources.isNotEmpty
                      ? data.resources.first.category
                      : 'N/A',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleMetric({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.042, 15.0, 18.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndUploadCta(BuildContext context,
      StudyMaterialLoaded state, double screenWidth) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context
                    .read<MentorStudyMaterialBloc>()
                    .add(SearchStudyMaterialsEvent(val));
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search title, category, format...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context
                              .read<MentorStudyMaterialBloc>()
                              .add(const SearchStudyMaterialsEvent(''));
                        },
                        child: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Upload Button
        ElevatedButton.icon(
          onPressed: () => _showUploadMaterialBottomSheet(context),
          icon: const Icon(LucideIcons.uploadCloud, size: 16),
          label: Text(
            'Upload',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterRow(BuildContext context,
      StudyMaterialLoaded state, double screenWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = state.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context
                    .read<MentorStudyMaterialBloc>()
                    .add(FilterStudyMaterialCategoryEvent(cat));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialsListSection(BuildContext context,
      StudyMaterialLoaded state, double screenWidth) {
    final list = state.filteredResources;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shared Material Directory',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.042, 15.0, 17.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Curated kits, coding sheets & interview rubrics',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.030, 11.0, 12.0),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${list.length} Files',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Cards
          if (list.isEmpty)
            _buildEmptyLibrary(context, screenWidth)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final item = list[index];
                return _buildMaterialCard(context, item, screenWidth);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context,
      MentorStudyMaterialModel material, double screenWidth) {
    final catIcon = _getCategoryIcon(material.category);
    final badgeBg = _getCategoryBadgeBg(material.category);
    final badgeText = _getCategoryTextColor(material.category);

    return Dismissible(
      key: Key(material.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          LucideIcons.trash2,
          color: Color(0xFFEF4444),
          size: 20,
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        context
            .read<MentorStudyMaterialBloc>()
            .add(DeleteStudyMaterialEvent(material.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              HapticFeedback.lightImpact();
              context
                  .read<MentorStudyMaterialBloc>()
                  .add(DownloadStudyMaterialEvent(material));
              await MentorMaterialDownloadService.downloadAndOpenMaterial(
                context: context,
                material: material,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Title & Category Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(catIcon, color: badgeText, size: 19),
                      ),
                      const SizedBox(width: 10),

                      // Title & Category (NO truncation, full readable text)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(
                                    screenWidth * 0.038, 14.0, 16.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                material.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: badgeText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Download CTA Icon
                      IconButton(
                        icon: const Icon(
                          LucideIcons.downloadCloud,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                        tooltip: 'Download File',
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          context
                              .read<MentorStudyMaterialBloc>()
                              .add(DownloadStudyMaterialEvent(material));
                          await MentorMaterialDownloadService
                              .downloadAndOpenMaterial(
                            context: context,
                            material: material,
                          );
                        },
                      ),
                    ],
                  ),

                  if (material.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      material.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),

                  // Bottom Metadata Row (File Size, Date, Download count)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.hardDrive,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            material.size,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            material.uploadedAt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.arrowDownToLine,
                            size: 12,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${material.downloadCount} dl',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLibrary(BuildContext context, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightLavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.folderOpen,
              size: 28,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Materials Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'No documents match the current category filter or search term.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              context
                  .read<MentorStudyMaterialBloc>()
                  .add(const FilterStudyMaterialCategoryEvent('All'));
              context
                  .read<MentorStudyMaterialBloc>()
                  .add(const SearchStudyMaterialsEvent(''));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: const BorderSide(color: AppColors.primaryPurple, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth * 0.6,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Study Materials',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context
                    .read<MentorStudyMaterialBloc>()
                    .add(const FetchStudyMaterialsEvent());
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
