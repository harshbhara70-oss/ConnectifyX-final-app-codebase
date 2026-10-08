import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_verification_bloc.dart';
import '../../bloc/admin_verification_event.dart';
import '../../bloc/admin_verification_state.dart';
import '../../data/models/admin_verification_models.dart';
import '../../data/services/admin_csv_exporter.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Production-ready Verification Queue Page for Campus2Corporate Admin Module.
/// Guarantees 1:1 feature parity with web VerificationQueue.tsx, responsive clamped typography,
/// zero-overflow constraints across all cards, 120Hz Impeller performance, and live MongoDB state update support.
class AdminVerificationQueuePage extends StatelessWidget {
  const AdminVerificationQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminVerificationBloc()..add(const FetchVerificationQueueData()),
      child: const _AdminVerificationQueueView(),
    );
  }
}

class _AdminVerificationQueueView extends StatefulWidget {
  const _AdminVerificationQueueView();

  @override
  State<_AdminVerificationQueueView> createState() => _AdminVerificationQueueViewState();
}

class _AdminVerificationQueueViewState extends State<_AdminVerificationQueueView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showRequestInfoDialog(BuildContext context, AdminVerificationCardModel card) {
    HapticFeedback.lightImpact();
    final queryController = TextEditingController();
    final screenWidth = MediaQuery.sizeOf(context).width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final keyboardInset = MediaQuery.viewInsetsOf(ctx).bottom;
        final titleSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
        final bodySize = clampDouble(screenWidth * 0.033, 12.0, 13.5);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: clampDouble(screenWidth * 0.05, 16.0, 22.0),
                right: clampDouble(screenWidth * 0.05, 16.0, 22.0),
                top: 14,
                bottom: keyboardInset > 0 ? keyboardInset + 14 : 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Pill Handle
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

                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE6FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.fileQuestion, size: 20, color: Color(0xFF6D28D9)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Info',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              card.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: bodySize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6D28D9),
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

                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 12),

                  Text(
                    'Specify additional verification documents or clarification required from the submitter:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: bodySize,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: queryController,
                    maxLines: 4,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. Please upload latest AICTE approval letter or official tax certificate.',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final query = queryController.text.trim();
                            Navigator.pop(ctx);
                            context.read<AdminVerificationBloc>().add(
                                  RequestVerificationInfoItem(
                                    card.id,
                                    query.isNotEmpty ? query : 'Verification documents requested',
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Send Request',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                              'Audit Log Export Complete',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${result.count} audit records saved to ${result.fileName}',
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

                  // Open File CTA
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

                  // Copy CSV Data CTA
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
                              'Audit log copied to clipboard!',
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
                        'Copy Audit Data to Clipboard',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeaderSize = clampDouble(screenWidth * 0.050, 18.0, 22.0);
    final subHeaderSize = clampDouble(screenWidth * 0.032, 12.0, 13.5);

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
          'Verifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Export Audit Log',
            icon: const Icon(LucideIcons.download, color: Color(0xFF6D28D9), size: 19),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AdminVerificationBloc>().add(const ExportVerificationAuditLog());
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
              context.read<AdminVerificationBloc>().add(const FetchVerificationQueueData(isRefresh: true));
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: BlocConsumer<AdminVerificationBloc, AdminVerificationState>(
        listener: (context, state) {
          if (state is AdminVerificationLoaded) {
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
          if (state is AdminVerificationLoading || state is AdminVerificationInitial) {
            return _buildShimmerLoading(context);
          }

          if (state is AdminVerificationError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AdminVerificationLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF6D28D9),
              onRefresh: () async {
                context.read<AdminVerificationBloc>().add(const FetchVerificationQueueData(isRefresh: true));
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
                      // 1. Breadcrumbs
                      Text(
                        'ADMIN > OVERSIGHT > VERIFICATION QUEUE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 2. Header & Export Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verification Queue',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: screenHeaderSize,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Manage and audit pending institutional approvals.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: subHeaderSize,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Export Audit Log Action Bar
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<AdminVerificationBloc>().add(const ExportVerificationAuditLog());
                          },
                          icon: const Icon(LucideIcons.download, size: 14, color: Color(0xFF6D28D9)),
                          label: Text(
                            'Export Audit Log',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Queue Filter Pills (Pending Colleges, Pending Recruiters, Flagged Content)
                      _buildQueuePills(context, state),

                      const SizedBox(height: 16),

                      // 4. Queue Status & Auto-Check Filters Cards Row / Stack
                      _buildQueueStatusAndFilters(context, state),

                      const SizedBox(height: 20),

                      // 5. Verification Cards Feed
                      if (state.displayedCards.isEmpty)
                        _buildEmptyState(context)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.displayedCards.length,
                          separatorBuilder: (context, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final card = state.displayedCards[index];
                            return _buildVerificationCard(context, card);
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
  // 3. QUEUE FILTER PILLS
  // ---------------------------------------------------------------------------
  Widget _buildQueuePills(BuildContext context, AdminVerificationLoaded state) {
    final pills = [
      {'id': 'colleges', 'label': 'Pending Colleges', 'count': state.collegesCount},
      {'id': 'recruiters', 'label': 'Pending Recruiters', 'count': state.recruitersCount},
      {'id': 'flagged', 'label': 'Flagged Content', 'count': state.flaggedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: pills.map((p) {
          final id = p['id'] as String;
          final label = p['label'] as String;
          final count = p['count'] as int;
          final isActive = state.activeTab == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: isActive ? const Color(0xFF6D28D9) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<AdminVerificationBloc>().add(ChangeVerificationTab(id));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? const Color(0xFF6D28D9) : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFECE6FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isActive ? Colors.white : const Color(0xFF6D28D9),
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

  // ---------------------------------------------------------------------------
  // 4. QUEUE STATUS & AUTO-CHECK FILTERS WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildQueueStatusAndFilters(BuildContext context, AdminVerificationLoaded state) {
    return Column(
      children: [
        // Queue Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUEUE STATUS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (state.queueStatus.isMock) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '*Mock',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'High Priority',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '${state.queueStatus.highPriority}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Standard',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '${state.queueStatus.standard}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Avg. Wait Time',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    state.queueStatus.avgWaitTime,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF6D28D9)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Auto-Check Filters Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
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
              Text(
                'AUTO-CHECK FILTERS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                'Domain Verified (8)',
                state.autoCheckFilters.domainVerifiedOnly,
                (val) {
                  context.read<AdminVerificationBloc>().add(ToggleAutoCheckFilter(domainVerified: val));
                },
              ),
              _buildCheckboxRow(
                'Docs Provided (11)',
                state.autoCheckFilters.docsProvidedOnly,
                (val) {
                  context.read<AdminVerificationBloc>().add(ToggleAutoCheckFilter(docsProvided: val));
                },
              ),
              _buildCheckboxRow(
                'Flagged by AI (3)',
                state.autoCheckFilters.flaggedByAiOnly,
                (val) {
                  context.read<AdminVerificationBloc>().add(ToggleAutoCheckFilter(flaggedByAi: val));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                activeColor: const Color(0xFF6D28D9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. ZERO-OVERFLOW RESPONSIVE VERIFICATION CARD (1:1 with VerificationQueue.tsx)
  // ---------------------------------------------------------------------------
  Widget _buildVerificationCard(BuildContext context, AdminVerificationCardModel card) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);

    Color cardBorder = const Color(0xFFE2E8F0);
    Color cardBg = Colors.white;

    if (card.status == 'approved') {
      cardBorder = const Color(0xFFA7F3D0);
      cardBg = const Color(0xFFF0FDF4);
    } else if (card.status == 'rejected') {
      cardBorder = const Color(0xFFFECDD3);
      cardBg = const Color(0xFFFFF1F2);
    }

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder, width: 0.8),
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
            // Top Row: Avatar Initial + Title Tier + Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6FE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDD6FE), width: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      card.title.isNotEmpty ? card.title[0] : 'V',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Badges Tier
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 2.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            card.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (card.isMock)
                            const Icon(LucideIcons.star, size: 10, color: Color(0xFFD97706)),
                        ],
                      ),
                      if (card.priority.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFECACA), width: 0.6),
                          ),
                          child: Text(
                            card.priority,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        card.submitted,
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
                if (card.status != 'pending') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: card.status == 'approved' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card.status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: card.status == 'approved' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 10),

            // Automated Audit Check Pills (Domain Match, Accreditation Doc, Tax ID, LinkedIn, Domain Link)
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                if (card.domainMatch)
                  _buildAuditPill('Domain Match', LucideIcons.checkCircle2, const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
                if (card.accreditationDoc)
                  _buildAuditPill('Accreditation Doc', LucideIcons.checkCircle2, const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
                if (card.taxIdVerified)
                  _buildAuditPill('Tax ID Verified', LucideIcons.checkCircle2, const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),

                // LinkedIn Status Pill
                _buildAuditPill(
                  card.linkedinStatus,
                  card.linkedinOk ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle,
                  card.linkedinOk ? const Color(0xFF059669) : const Color(0xFFD97706),
                  card.linkedinOk ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  card.linkedinOk ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                ),

                // Domain Link Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6FE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDD6FE), width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.domainUrl,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6D28D9),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(LucideIcons.externalLink, size: 10, color: Color(0xFF6D28D9)),
                    ],
                  ),
                ),
              ],
            ),

            // Action Buttons Tier with Wrap to prevent RenderFlex overflow on ANY device
            if (card.status == 'pending') ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Request Info Button
                    OutlinedButton(
                      onPressed: () => _showRequestInfoDialog(context, card),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Request Info',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // Reject Button
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<AdminVerificationBloc>().add(RejectVerificationItem(card.id));
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: Color(0xFFFECDD3), width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),

                    // Quick Verify Button
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<AdminVerificationBloc>().add(ApproveVerificationItem(card.id));
                      },
                      icon: const Icon(LucideIcons.sparkles, size: 12),
                      label: Text(
                        'Quick Verify',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuditPill(String label, IconData icon, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
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
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(LucideIcons.checkCheck, size: 22, color: Color(0xFF16A34A)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Queue is clear',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No pending verification items found in this section.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
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
              'Unable to load Verification Queue',
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
                context.read<AdminVerificationBloc>().add(const FetchVerificationQueueData(isRefresh: true));
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER LOADING SKELETON
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
            Container(width: 140, height: 14, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 22, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 40, color: Colors.white),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Container(height: 38, color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 38, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 120, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 160, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
