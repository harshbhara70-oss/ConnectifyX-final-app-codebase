import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_user_management_bloc.dart';
import '../../bloc/admin_user_management_event.dart';
import '../../bloc/admin_user_management_state.dart';
import '../../data/models/admin_user_models.dart';
import '../../data/services/admin_csv_exporter.dart';
import '../widgets/admin_sidebar_drawer.dart';
import '../widgets/admin_user_detail_sheet.dart';
import '../widgets/admin_user_edit_dialog.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AdminUserManagementBloc()..add(const FetchAdminUsers()),
      child: const _AdminUserManagementView(),
    );
  }
}

class _AdminUserManagementView extends StatefulWidget {
  const _AdminUserManagementView();

  @override
  State<_AdminUserManagementView> createState() => _AdminUserManagementViewState();
}

class _AdminUserManagementViewState extends State<_AdminUserManagementView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFeedback(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showExportSuccessSheet(BuildContext context, ExportResult result) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                top: 14,
                bottom: bottomInset > 0 ? 8 : 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.checkCircle2, size: 22, color: Color(0xFF16A34A)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CSV Export Complete',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${result.count} records saved to ${result.fileName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stacked Full-Width Action Buttons (Prevents overflow & cutoff)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.openExportedFile(result.filePath);
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: Text(
                        'Open File (Excel / Google Sheets)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.copyToClipboard(result.csvContent);
                        Navigator.pop(ctx);
                        _showFeedback(context, 'CSV data copied to clipboard!');
                      },
                      icon: const Icon(LucideIcons.copy, size: 16),
                      label: Text(
                        'Copy CSV to Clipboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  void _showDeleteConfirmation(BuildContext context, String id, UserRoleTab role, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Record',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "$name" from the master directory?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              context.read<AdminUserManagementBloc>().add(
                    DeleteUserAction(id: id, role: role),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom == 0
        ? 16.0
        : MediaQuery.paddingOf(context).bottom;

    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AdminSidebarDrawer(),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<AdminUserManagementBloc, AdminUserManagementState>(
          listenWhen: (prev, curr) =>
              prev.feedbackMessage != curr.feedbackMessage ||
              prev.errorMessage != curr.errorMessage ||
              prev.lastExportResult != curr.lastExportResult,
          listener: (context, state) {
            if (state.lastExportResult != null) {
              _showExportSuccessSheet(context, state.lastExportResult!);
            } else if (state.feedbackMessage != null) {
              _showFeedback(context, state.feedbackMessage!);
            }
            if (state.errorMessage != null) {
              _showFeedback(context, state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<AdminUserManagementBloc>().add(const FetchAdminUsers(isRefresh: true));
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 14.0,
                  bottom: bottomInset + 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Bar with Drawer Toggle, Portal Title, and Live/Mock Badge
                    _buildTopAppBar(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 2. Header Title & Subtitle Banner
                    _buildHeaderBanner(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 3. Quick Directory Summary Counters (Responsive 2x2 Grid)
                    _buildSummaryMetrics(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 4. Global Search & Export All Row
                    _buildSearchAndExportRow(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 5. Role Sub-Tabs (Students, Colleges, Recruiters)
                    _buildRoleSubTabs(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 6. Action Toolbar & Filter Dropdowns
                    _buildActionToolbarAndFilters(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 7. Master Directory Data Card List / Table
                    _buildDirectoryList(context, state, screenWidth),
                    const SizedBox(height: 14),

                    // 8. Pagination Controls Bar
                    _buildPaginationBar(context, state, screenWidth),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 1. TOP APP BAR (Overflow Proof)
  // ==========================================
  Widget _buildTopAppBar(BuildContext context, AdminUserManagementState state, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left drawer button + portal title
        Expanded(
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _scaffoldKey.currentState?.openDrawer();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.menu,
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Admin Management',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Live / Atlas Status Pill (RenderBox Protected)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: state.isMock ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: state.isMock ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.isMock ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                state.isMock ? '*Mock Data' : 'Atlas Live',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: state.isMock ? const Color(0xFFB45309) : const Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. HEADER BANNER
  // ==========================================
  Widget _buildHeaderBanner(BuildContext context, AdminUserManagementState state, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'User Management',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.052, 18.0, 22.0),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (state.isMock) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFDE68A),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Master Directory Oversight across Students, Institutions, and Corporate Recruiters.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. SUMMARY METRICS COUNTERS (Responsive 2x2 Grid)
  // ==========================================
  Widget _buildSummaryMetrics(BuildContext context, AdminUserManagementState state, double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return RepaintBoundary(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isSmallScreen ? 1.85 : (screenWidth < 414 ? 2.1 : 2.3),
        children: [
          _buildMetricCard(
            'Students',
            '${state.students.length}',
            LucideIcons.graduationCap,
            const Color(0xFF6366F1),
            screenWidth,
            isMock: state.isMock,
          ),
          _buildMetricCard(
            'Colleges',
            '${state.colleges.length}',
            LucideIcons.building2,
            const Color(0xFF0D9488),
            screenWidth,
            isMock: state.isMock,
          ),
          _buildMetricCard(
            'Recruiters',
            '${state.recruiters.length}',
            LucideIcons.briefcase,
            const Color(0xFF7C3AED),
            screenWidth,
            isMock: state.isMock,
          ),
          _buildMetricCard(
            'Placed',
            '${state.placedStudentsCount}',
            LucideIcons.award,
            const Color(0xFF16A34A),
            screenWidth,
            isMock: state.isMock,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    double screenWidth, {
    bool isMock = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Structured 40x40 Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),

          // Value & Label Tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        value,
                        maxLines: 1,
                        minFontSize: 13,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.065, 18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isMock) ...[
                      const SizedBox(width: 3),
                      Text(
                        '*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: FontWeight.w600,
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

  // ==========================================
  // 4. SEARCH & EXPORT ROW (Overflow Proof)
  // ==========================================
  Widget _buildSearchAndExportRow(BuildContext context, AdminUserManagementState state, double screenWidth) {
    return Row(
      children: [
        // Global Search Input
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<AdminUserManagementBloc>().add(UpdateSearchQuery(val));
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Global Search (Cmd+K)',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          context.read<AdminUserManagementBloc>().add(const UpdateSearchQuery(''));
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Export All Button (Flexible Width)
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<AdminUserManagementBloc>().add(const ExportDirectoryAction(onlySelected: false));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.download, size: 15, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'Export All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. ROLE SUB-TABS (Overflow Proof)
  // ==========================================
  Widget _buildRoleSubTabs(BuildContext context, AdminUserManagementState state, double screenWidth) {
    final tabs = [
      {'tab': UserRoleTab.students, 'label': 'Students', 'icon': LucideIcons.graduationCap},
      {'tab': UserRoleTab.colleges, 'label': 'Colleges', 'icon': LucideIcons.building2},
      {'tab': UserRoleTab.recruiters, 'label': 'Recruiters', 'icon': LucideIcons.briefcase},
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: tabs.map((item) {
          final tab = item['tab'] as UserRoleTab;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isActive = state.activeTab == tab;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<AdminUserManagementBloc>().add(SelectRoleTab(tab));
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                      width: 0.8,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // 6. ACTION TOOLBAR & FILTERS (Horizontal Scroll Safe)
  // ==========================================
  Widget _buildActionToolbarAndFilters(BuildContext context, AdminUserManagementState state, double screenWidth) {
    final hasSelected = state.selectedUserIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulk Actions Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Bulk Suspend
                _buildToolbarButton(
                  context,
                  label: 'Suspend',
                  icon: LucideIcons.ban,
                  bgColor: AppColors.errorLight,
                  borderColor: const Color(0xFFFECDD3),
                  textColor: AppColors.error,
                  enabled: hasSelected,
                  onTap: () {
                    context.read<AdminUserManagementBloc>().add(const BulkSuspendAction());
                  },
                ),
                const SizedBox(width: 6),

                // Bulk Delete
                _buildToolbarButton(
                  context,
                  label: 'Delete',
                  icon: LucideIcons.trash2,
                  bgColor: AppColors.inputFill,
                  borderColor: AppColors.border,
                  textColor: AppColors.textSecondary,
                  enabled: hasSelected,
                  onTap: () {
                    context.read<AdminUserManagementBloc>().add(const BulkDeleteAction());
                  },
                ),
                const SizedBox(width: 6),

                // Bulk Export
                _buildToolbarButton(
                  context,
                  label: 'Export Selected',
                  icon: LucideIcons.download,
                  bgColor: AppColors.primaryLight,
                  borderColor: const Color(0xFFE9D5FF),
                  textColor: AppColors.primary,
                  enabled: hasSelected,
                  onTap: () {
                    context.read<AdminUserManagementBloc>().add(const ExportDirectoryAction(onlySelected: true));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.inputFill, height: 1),
          const SizedBox(height: 10),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // College Dropdown
                _buildFilterDropdown(
                  value: state.selectedCollegeFilter,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Colleges')),
                    ...state.availableColleges.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      context.read<AdminUserManagementBloc>().add(UpdateCollegeFilter(val));
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Year Dropdown
                _buildFilterDropdown(
                  value: state.selectedYearFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Years')),
                    DropdownMenuItem(value: '2024', child: Text('2024')),
                    DropdownMenuItem(value: '2025', child: Text('2025')),
                    DropdownMenuItem(value: '2026', child: Text('2026')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      context.read<AdminUserManagementBloc>().add(UpdateYearFilter(val));
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Status Dropdown
                _buildFilterDropdown(
                  value: state.selectedStatusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Status: All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      context.read<AdminUserManagementBloc>().add(UpdateStatusFilter(val));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: textColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    final validValue = items.any((i) => i.value == value) ? value : items.first.value;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textMuted),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          items: items,
          onChanged: (val) {
            HapticFeedback.lightImpact();
            onChanged(val);
          },
        ),
      ),
    );
  }

  // ==========================================
  // 7. MASTER DIRECTORY CARD LIST
  // ==========================================
  Widget _buildDirectoryList(BuildContext context, AdminUserManagementState state, double screenWidth) {
    if (state.status == AdminUserStatus.loading) {
      return _buildShimmerLoading();
    }

    final bool allSelected = state.activeTotalCount > 0 &&
        state.paginatedStudents.every((s) => state.selectedUserIds.contains(s.id));

    Widget contentList;
    switch (state.activeTab) {
      case UserRoleTab.students:
        final students = state.paginatedStudents;
        if (students.isEmpty) {
          contentList = _buildEmptyState(context, 'No students match your directory filters.');
        } else {
          contentList = ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) => _buildStudentCard(context, students[idx], state, screenWidth),
          );
        }
        break;
      case UserRoleTab.colleges:
        final colleges = state.paginatedColleges;
        if (colleges.isEmpty) {
          contentList = _buildEmptyState(context, 'No institutions found in directory.');
        } else {
          contentList = ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: colleges.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) => _buildCollegeCard(context, colleges[idx], state, screenWidth),
          );
        }
        break;
      case UserRoleTab.recruiters:
        final recruiters = state.paginatedRecruiters;
        if (recruiters.isEmpty) {
          contentList = _buildEmptyState(context, 'No corporate recruiters onboarded yet.');
        } else {
          contentList = ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recruiters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) => _buildRecruiterCard(context, recruiters[idx], state, screenWidth),
          );
        }
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select All Checkbox Row (RenderBox Safe)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<AdminUserManagementBloc>().add(const ToggleSelectAllUserItems());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: allSelected,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            context.read<AdminUserManagementBloc>().add(const ToggleSelectAllUserItems());
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select All (${state.activeTotalCount} total)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${state.currentPage} of ${state.totalPages}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        contentList,
      ],
    );
  }

  // --- Student Card ---
  Widget _buildStudentCard(
    BuildContext context,
    AdminStudentModel student,
    AdminUserManagementState state,
    double screenWidth,
  ) {
    final isSelected = state.selectedUserIds.contains(student.id);
    final bool isSuspended = student.activeStatus.toLowerCase() == 'suspended';

    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            AdminUserDetailSheet.show(
              context,
              userModel: student,
              role: UserRoleTab.students,
              onToggleSuspend: () {
                context.read<AdminUserManagementBloc>().add(
                      ToggleSuspendUser(
                        id: student.id,
                        role: UserRoleTab.students,
                        currentStatus: student.activeStatus,
                      ),
                    );
              },
              onEdit: () {
                AdminUserEditDialog.show(
                  context,
                  userModel: student,
                  role: UserRoleTab.students,
                  onSave: (data) {
                    context.read<AdminUserManagementBloc>().add(
                          UpdateStudentAction(id: student.id, data: data),
                        );
                  },
                );
              },
              onDelete: () {
                _showDeleteConfirmation(context, student.id, UserRoleTab.students, student.name);
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tier: Checkbox + Avatar + Title & Email + Quick Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          context.read<AdminUserManagementBloc>().add(ToggleSelectUserItem(student.id));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        student.avatar,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 42,
                          height: 42,
                          color: AppColors.primaryLight,
                          child: const Icon(LucideIcons.user, size: 22, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Subtitle Tier (Expanded & Zero Overlap)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student.name.toTitleCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (student.isMock) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '*',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Action Menu
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        if (val == 'view') {
                          AdminUserDetailSheet.show(
                            context,
                            userModel: student,
                            role: UserRoleTab.students,
                            onToggleSuspend: () {
                              context.read<AdminUserManagementBloc>().add(
                                    ToggleSuspendUser(
                                      id: student.id,
                                      role: UserRoleTab.students,
                                      currentStatus: student.activeStatus,
                                    ),
                                  );
                            },
                            onEdit: () {
                              AdminUserEditDialog.show(
                                context,
                                userModel: student,
                                role: UserRoleTab.students,
                                onSave: (data) {
                                  context.read<AdminUserManagementBloc>().add(
                                        UpdateStudentAction(id: student.id, data: data),
                                      );
                                },
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(context, student.id, UserRoleTab.students, student.name);
                            },
                          );
                        } else if (val == 'edit') {
                          AdminUserEditDialog.show(
                            context,
                            userModel: student,
                            role: UserRoleTab.students,
                            onSave: (data) {
                              context.read<AdminUserManagementBloc>().add(
                                    UpdateStudentAction(id: student.id, data: data),
                                  );
                            },
                          );
                        } else if (val == 'suspend') {
                          context.read<AdminUserManagementBloc>().add(
                                ToggleSuspendUser(
                                  id: student.id,
                                  role: UserRoleTab.students,
                                  currentStatus: student.activeStatus,
                                ),
                              );
                        } else if (val == 'delete') {
                          _showDeleteConfirmation(context, student.id, UserRoleTab.students, student.name);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(LucideIcons.eye, size: 15, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('View Dossier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(LucideIcons.edit2, size: 15, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Edit Record'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'suspend',
                          child: Row(
                            children: [
                              Icon(isSuspended ? LucideIcons.checkCircle : LucideIcons.ban, size: 15, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Text(isSuspended ? 'Activate User' : 'Suspend User'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 15, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Middle Tier: College & Branch + CGPA Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.college,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            student.branch,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
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
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.award, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${student.cgpa} CGPA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bottom Tier: Badges (Progress, Placement, Status)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: [
                    // RMs Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student.rms,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // PRJs Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student.prjs,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // Placement Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: student.placementStatus == 'Placed'
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: student.placementStatus == 'Placed'
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        student.placementStatus,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: student.placementStatus == 'Placed'
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),

                    // Active Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSuspended ? AppColors.errorLight : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student.activeStatus.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSuspended ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- College Card ---
  Widget _buildCollegeCard(
    BuildContext context,
    AdminCollegeModel college,
    AdminUserManagementState state,
    double screenWidth,
  ) {
    final isSelected = state.selectedUserIds.contains(college.id);
    final bool isSuspended = college.status.toLowerCase() == 'suspended';

    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            AdminUserDetailSheet.show(
              context,
              userModel: college,
              role: UserRoleTab.colleges,
              onToggleSuspend: () {
                context.read<AdminUserManagementBloc>().add(
                      ToggleSuspendUser(
                        id: college.id,
                        role: UserRoleTab.colleges,
                        currentStatus: college.status,
                      ),
                    );
              },
              onEdit: () {
                AdminUserEditDialog.show(
                  context,
                  userModel: college,
                  role: UserRoleTab.colleges,
                  onSave: (data) {
                    context.read<AdminUserManagementBloc>().add(
                          UpdateCollegeAction(id: college.id, data: data),
                        );
                  },
                );
              },
              onDelete: () {
                _showDeleteConfirmation(context, college.id, UserRoleTab.colleges, college.name);
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Checkbox + Icon + Name + Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          context.read<AdminUserManagementBloc>().add(ToggleSelectUserItem(college.id));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.building2, size: 22, color: Color(0xFF0F766E)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  college.name.toTitleCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (college.isMock) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '*',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            college.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing Action Menu
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        if (val == 'view') {
                          AdminUserDetailSheet.show(
                            context,
                            userModel: college,
                            role: UserRoleTab.colleges,
                            onToggleSuspend: () {
                              context.read<AdminUserManagementBloc>().add(
                                    ToggleSuspendUser(
                                      id: college.id,
                                      role: UserRoleTab.colleges,
                                      currentStatus: college.status,
                                    ),
                                  );
                            },
                            onEdit: () {
                              AdminUserEditDialog.show(
                                context,
                                userModel: college,
                                role: UserRoleTab.colleges,
                                onSave: (data) {
                                  context.read<AdminUserManagementBloc>().add(
                                        UpdateCollegeAction(id: college.id, data: data),
                                      );
                                },
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(context, college.id, UserRoleTab.colleges, college.name);
                            },
                          );
                        } else if (val == 'edit') {
                          AdminUserEditDialog.show(
                            context,
                            userModel: college,
                            role: UserRoleTab.colleges,
                            onSave: (data) {
                              context.read<AdminUserManagementBloc>().add(
                                    UpdateCollegeAction(id: college.id, data: data),
                                  );
                            },
                          );
                        } else if (val == 'delete') {
                          _showDeleteConfirmation(context, college.id, UserRoleTab.colleges, college.name);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'view', child: Text('View Details')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit Institution')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Institution', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Middle Info Row
                Row(
                  children: [
                    const Icon(LucideIcons.landmark, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        college.university,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Badges (Zero Overlap Wrap)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: [
                    if (college.city.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${college.city}, ${college.state}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${college.studentsCount} Students',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSuspended ? AppColors.errorLight : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        college.status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSuspended ? AppColors.error : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Recruiter Card ---
  Widget _buildRecruiterCard(
    BuildContext context,
    AdminRecruiterModel recruiter,
    AdminUserManagementState state,
    double screenWidth,
  ) {
    final isSelected = state.selectedUserIds.contains(recruiter.id);
    final bool isInactive = recruiter.status.toLowerCase() != 'active';

    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            AdminUserDetailSheet.show(
              context,
              userModel: recruiter,
              role: UserRoleTab.recruiters,
              onToggleSuspend: () {
                context.read<AdminUserManagementBloc>().add(
                      ToggleSuspendUser(
                        id: recruiter.id,
                        role: UserRoleTab.recruiters,
                        currentStatus: recruiter.status,
                      ),
                    );
              },
              onEdit: () {
                AdminUserEditDialog.show(
                  context,
                  userModel: recruiter,
                  role: UserRoleTab.recruiters,
                  onSave: (data) {
                    context.read<AdminUserManagementBloc>().add(
                          UpdateRecruiterAction(id: recruiter.id, data: data),
                        );
                  },
                );
              },
              onDelete: () {
                _showDeleteConfirmation(context, recruiter.id, UserRoleTab.recruiters, recruiter.name);
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          context.read<AdminUserManagementBloc>().add(ToggleSelectUserItem(recruiter.id));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.briefcase, size: 22, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recruiter.name.toTitleCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (recruiter.isMock) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '*',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            recruiter.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing Action Menu
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        if (val == 'view') {
                          AdminUserDetailSheet.show(
                            context,
                            userModel: recruiter,
                            role: UserRoleTab.recruiters,
                            onToggleSuspend: () {
                              context.read<AdminUserManagementBloc>().add(
                                    ToggleSuspendUser(
                                      id: recruiter.id,
                                      role: UserRoleTab.recruiters,
                                      currentStatus: recruiter.status,
                                    ),
                                  );
                            },
                            onEdit: () {
                              AdminUserEditDialog.show(
                                context,
                                userModel: recruiter,
                                role: UserRoleTab.recruiters,
                                onSave: (data) {
                                  context.read<AdminUserManagementBloc>().add(
                                        UpdateRecruiterAction(id: recruiter.id, data: data),
                                      );
                                },
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(context, recruiter.id, UserRoleTab.recruiters, recruiter.name);
                            },
                          );
                        } else if (val == 'edit') {
                          AdminUserEditDialog.show(
                            context,
                            userModel: recruiter,
                            role: UserRoleTab.recruiters,
                            onSave: (data) {
                              context.read<AdminUserManagementBloc>().add(
                                    UpdateRecruiterAction(id: recruiter.id, data: data),
                                  );
                            },
                          );
                        } else if (val == 'delete') {
                          _showDeleteConfirmation(context, recruiter.id, UserRoleTab.recruiters, recruiter.name);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'view', child: Text('View Recruiter Profile')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit Record')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Recruiter', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Middle Info Row: Company + Designation
                Row(
                  children: [
                    const Icon(LucideIcons.building2, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${recruiter.company} • ${recruiter.designation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Badges
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: [
                    if (recruiter.phone.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          recruiter.phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isInactive ? AppColors.errorLight : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recruiter.status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isInactive ? AppColors.error : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 8. PAGINATION CONTROLS BAR (Responsive & Overflow Proof)
  // ==========================================
  Widget _buildPaginationBar(BuildContext context, AdminUserManagementState state, double screenWidth) {
    final int totalCount = state.activeTotalCount;
    final int totalPages = state.totalPages;
    final int current = state.currentPage;

    final int startItem = totalCount == 0 ? 0 : (current - 1) * state.itemsPerPage + 1;
    final int endItem = (current * state.itemsPerPage > totalCount) ? totalCount : current * state.itemsPerPage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Counter string (Protected with Expanded)
          Expanded(
            child: Text(
              'Showing $startItem-$endItem of $totalCount entries',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Pagination buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prev
              InkWell(
                onTap: current > 1
                    ? () {
                        HapticFeedback.lightImpact();
                        context.read<AdminUserManagementBloc>().add(ChangeDirectoryPage(current - 1));
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: current > 1 ? AppColors.inputFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'Prev',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: current > 1 ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Current Page Indicator Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$current / $totalPages',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Next
              InkWell(
                onTap: current < totalPages
                    ? () {
                        HapticFeedback.lightImpact();
                        context.read<AdminUserManagementBloc>().add(ChangeDirectoryPage(current + 1));
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: current < totalPages ? AppColors.inputFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: current < totalPages ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY & SHIMMER LOADING STATES
  // ==========================================
  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.users, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'No Directory Records',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AdminUserManagementBloc>().add(const UpdateSearchQuery(''));
              context.read<AdminUserManagementBloc>().add(const UpdateCollegeFilter('all'));
              context.read<AdminUserManagementBloc>().add(const UpdateStatusFilter('all'));
            },
            icon: const Icon(LucideIcons.rotateCcw, size: 14),
            label: const Text('Reset Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 14, color: AppColors.inputFill),
                      const SizedBox(height: 6),
                      Container(width: 200, height: 10, color: AppColors.inputFill),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(width: 180, height: 12, color: AppColors.inputFill),
            const Spacer(),
            Row(
              children: [
                Container(width: 60, height: 18, color: AppColors.inputFill),
                const SizedBox(width: 6),
                Container(width: 60, height: 18, color: AppColors.inputFill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
