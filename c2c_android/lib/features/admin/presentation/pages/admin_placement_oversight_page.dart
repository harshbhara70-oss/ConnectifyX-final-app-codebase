import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_placement_bloc.dart';
import '../../bloc/admin_placement_event.dart';
import '../../bloc/admin_placement_state.dart';
import '../../data/models/admin_placement_models.dart';
import '../../data/services/admin_csv_exporter.dart';
import '../widgets/admin_placement_calendar_widget.dart';
import '../widgets/admin_placement_drive_card.dart';
import '../widgets/admin_placement_drive_detail_sheet.dart';
import '../widgets/admin_placement_metric_card.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Production-ready Placement Oversight Page for Campus2Corporate Admin Module.
/// Guarantees 1:1 feature parity with web PlacementOversight.tsx, responsive clamped typography,
/// zero-overflow constraints, 120Hz Impeller performance, and live MongoDB state update support.
class AdminPlacementOversightPage extends StatelessWidget {
  const AdminPlacementOversightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPlacementBloc()..add(const FetchPlacementData()),
      child: const _AdminPlacementOversightView(),
    );
  }
}

class _AdminPlacementOversightView extends StatefulWidget {
  const _AdminPlacementOversightView();

  @override
  State<_AdminPlacementOversightView> createState() => _AdminPlacementOversightViewState();
}

class _AdminPlacementOversightViewState extends State<_AdminPlacementOversightView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDriveDetailModal(BuildContext context, AdminPlacementDriveModel drive) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminPlacementDriveDetailSheet(
        drive: drive,
        onStatusUpdate: (newStatus) {
          context.read<AdminPlacementBloc>().add(
                UpdatePlacementDrive(drive.id, {'status': newStatus}),
              );
        },
        onDelete: () {
          context.read<AdminPlacementBloc>().add(DeletePlacementDrive(drive.id));
        },
      ),
    );
  }

  void _showExportResultModal(BuildContext context, ExportResult result) {
    HapticFeedback.lightImpact();
    final screenWidth = MediaQuery.sizeOf(context).width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: clampDouble(screenWidth * 0.05, 16.0, 22.0),
                right: clampDouble(screenWidth * 0.05, 16.0, 22.0),
                top: 14,
                bottom: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

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
                              'Report Export Complete',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${result.count} drives saved to ${result.fileName}',
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
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.fileSpreadsheet, size: 16, color: Color(0xFF6D28D9)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Location: ${result.filePath}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Open file button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.openExportedFile(result.filePath);
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: Text(
                        'Open in Excel / CSV Viewer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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

                  const SizedBox(height: 8),

                  // Copy to Clipboard button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.copyToClipboard(result.csvContent);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'CSV data copied to clipboard!',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.copy, size: 16, color: Color(0xFF6D28D9)),
                      label: Text(
                        'Copy CSV Data to Clipboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6D28D9),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFDDD6FE), width: 1.0),
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

  Future<void> _selectDateFilter(BuildContext context, AdminPlacementLoaded state) async {
    HapticFeedback.lightImpact();
    final bloc = context.read<AdminPlacementBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${_monthName(picked.month)} ${picked.day}, ${picked.year}';
      bloc.add(FilterPlacementDrives(dateQuery: formatted));
    }
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeaderSize = clampDouble(screenWidth * 0.050, 18.0, 22.0);
    final sectionHeaderSize = clampDouble(screenWidth * 0.040, 15.0, 17.0);
    final subHeaderSize = clampDouble(screenWidth * 0.032, 12.0, 13.5);
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminSidebarDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Placements',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(LucideIcons.download, color: Color(0xFF6D28D9), size: 19),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AdminPlacementBloc>().add(const ExportPlacementReport());
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textSecondary, size: 17),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AdminPlacementBloc>().add(const FetchPlacementData(isRefresh: true));
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: BlocConsumer<AdminPlacementBloc, AdminPlacementState>(
        listener: (context, state) {
          if (state is AdminPlacementLoaded) {
            if (state.exportResult != null && state.exportResult!.success) {
              _showExportResultModal(context, state.exportResult!);
            } else if (state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.actionMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1E293B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AdminPlacementLoading || state is AdminPlacementInitial) {
            return _buildShimmerLoading(context);
          }

          if (state is AdminPlacementError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AdminPlacementLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF6366F1),
              onRefresh: () async {
                context.read<AdminPlacementBloc>().add(const FetchPlacementData(isRefresh: true));
              },
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom == 0 ? 24.0 : MediaQuery.paddingOf(context).bottom + 16.0,
                    top: 16.0,
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header Banner & Subtitle
                      Text(
                        'Placement Oversight',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenHeaderSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Master control for all ongoing and upcoming placement drives.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: subHeaderSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Web 1:1 Filter Controls (College Dropdown, Company Dropdown, Date Picker, Export Report)
                      _buildWebParityFilterControls(context, state),

                      const SizedBox(height: 20),

                      // 3. Metric Summary Tiles (4 Cards with generous vertical spacing)
                      _buildMetricSummaryGrid(context, state, isSmallScreen),

                      const SizedBox(height: 24),

                      // 4. Master Placement Calendar & Critical Events Section
                      AdminPlacementCalendarWidget(
                        currentMonth: state.currentMonth,
                        events: state.events,
                        onMonthChanged: (newMonth) {
                          context.read<AdminPlacementBloc>().add(ChangeCalendarMonth(newMonth));
                        },
                      ),

                      const SizedBox(height: 24),

                      // 5. Active Drives Oversight Header & Search Filter
                      _buildDrivesSectionHeader(context, state, sectionHeaderSize),

                      const SizedBox(height: 12),

                      // Drives List / Empty State
                      if (state.filteredDrives.isEmpty)
                        _buildEmptyState(context)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.filteredDrives.length,
                          separatorBuilder: (context, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final drive = state.filteredDrives[index];
                            return AdminPlacementDriveCard(
                              drive: drive,
                              onTap: () => _showDriveDetailModal(context, drive),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WEB 1:1 FILTER CONTROLS (Colleges Dropdown, Companies Dropdown, Date, Export CTA)
  // ---------------------------------------------------------------------------
  Widget _buildWebParityFilterControls(BuildContext context, AdminPlacementLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdowns Row (College + Company)
        Row(
          children: [
            // College Dropdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.filters.selectedCollege,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    items: state.availableColleges.map((c) {
                      final label = c == 'all' ? 'All Colleges' : c;
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        HapticFeedback.lightImpact();
                        context.read<AdminPlacementBloc>().add(FilterPlacementDrives(college: val));
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Company Dropdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.filters.selectedCompany,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    items: state.availableCompanies.map((comp) {
                      final label = comp == 'all' ? 'All Companies' : comp;
                      return DropdownMenuItem<String>(
                        value: comp,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        HapticFeedback.lightImpact();
                        context.read<AdminPlacementBloc>().add(FilterPlacementDrives(company: val));
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Date Query & Export Report Button Row
        Row(
          children: [
            // Date Query Filter Button
            Expanded(
              child: InkWell(
                onTap: () => _selectDateFilter(context, state),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          state.filters.dateQuery.isNotEmpty ? state.filters.dateQuery : 'Filter Date',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: state.filters.dateQuery.isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (state.filters.dateQuery.isNotEmpty)
                        InkWell(
                          onTap: () {
                            context.read<AdminPlacementBloc>().add(const FilterPlacementDrives(dateQuery: ''));
                          },
                          child: const Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Export Report Button
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<AdminPlacementBloc>().add(const ExportPlacementReport());
              },
              icon: const Icon(LucideIcons.download, size: 14),
              label: Text(
                'Export Report',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIVE DRIVES SECTION HEADER & SEARCH INPUT
  // ---------------------------------------------------------------------------
  Widget _buildDrivesSectionHeader(
    BuildContext context,
    AdminPlacementLoaded state,
    double sectionHeaderSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Active Drives Oversight',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionHeaderSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECE6FE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${state.filteredDrives.length} Drives',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Filter drives... Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<AdminPlacementBloc>().add(SearchPlacementDrives(val));
            },
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Filter drives by company, college, role...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted),
              prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        context.read<AdminPlacementBloc>().add(const SearchPlacementDrives(''));
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // METRIC SUMMARY GRID (4 TILES WITH GENEROUS VERTICAL SPACE)
  // ---------------------------------------------------------------------------
  Widget _buildMetricSummaryGrid(
    BuildContext context,
    AdminPlacementLoaded state,
    bool isSmallScreen,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isSmallScreen ? 0.94 : 1.02,
      children: [
        AdminPlacementMetricCard(
          label: 'Active Drives',
          value: state.metrics.activeDrives.toString(),
          subtitle: state.metrics.activeDrivesGrowth,
          icon: LucideIcons.briefcase,
          isMock: state.metrics.isMock,
        ),
        AdminPlacementMetricCard(
          label: 'Colleges',
          value: state.metrics.participatingColleges.toString(),
          subtitle: '+4 this season',
          icon: LucideIcons.building2,
          isMock: state.metrics.isMock,
        ),
        AdminPlacementMetricCard(
          label: 'Applicants',
          value: _formatNumber(state.metrics.totalApplicants),
          subtitle: state.metrics.applicantsGrowth,
          icon: LucideIcons.users,
          isMock: state.metrics.isMock,
        ),
        AdminPlacementMetricCard(
          label: 'Offers Extended',
          value: _formatNumber(state.metrics.offersExtended),
          subtitle: state.metrics.offersGrowth,
          icon: LucideIcons.award,
          isMock: state.metrics.isMock,
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE VIEW
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECE6FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(LucideIcons.searchX, size: 22, color: Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No matching drives found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or clear the active filters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              context.read<AdminPlacementBloc>().add(const ResetPlacementFilters());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Reset Filters',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR VIEW
  // ---------------------------------------------------------------------------
  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 40, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              'Unable to load Placement Oversight',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdminPlacementBloc>().add(const FetchPlacementData(isRefresh: true));
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER SKELETON
  // ---------------------------------------------------------------------------
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 180, height: 22, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: 260, height: 14, color: Colors.white),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 44, color: Colors.white),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
