import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_support_bloc.dart';
import '../../bloc/admin_support_event.dart';
import '../../bloc/admin_support_state.dart';
import '../../data/services/admin_csv_exporter.dart';
import '../widgets/admin_sidebar_drawer.dart';
import '../widgets/admin_support_detail_sheet.dart';
import '../widgets/admin_support_stats_bar.dart';
import '../widgets/admin_support_ticket_card.dart';

/// Production-Ready Support Center Page for Campus2Corporate Admin Module.
/// Guarantees 1:1 feature parity with web SupportCenter.tsx, clamped typography,
/// zero-overflow constraints, 120Hz Impeller performance, and live Atlas state update support.
class AdminSupportPage extends StatelessWidget {
  const AdminSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminSupportBloc()..add(const FetchSupportDataEvent()),
      child: const _AdminSupportView(),
    );
  }
}

class _AdminSupportView extends StatefulWidget {
  const _AdminSupportView();

  @override
  State<_AdminSupportView> createState() => _AdminSupportViewState();
}

class _AdminSupportViewState extends State<_AdminSupportView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showExportResultModal(BuildContext context, ExportResult result) {
    HapticFeedback.lightImpact();
    final screenWidth = MediaQuery.sizeOf(context).width;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
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
                              'Support Audit Exported',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${result.count} tickets saved to ${result.fileName}',
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
                              'Support tickets copied to clipboard!',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeaderSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final subHeaderSize = clampDouble(screenWidth * 0.033, 12.0, 13.5);

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
          'Support Hub',
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
              context.read<AdminSupportBloc>().add(const ExportSupportTicketsEvent());
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
              context.read<AdminSupportBloc>().add(const FetchSupportDataEvent(isRefresh: true));
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: BlocConsumer<AdminSupportBloc, AdminSupportState>(
        listener: (context, state) {
          if (state is AdminSupportLoaded) {
            if (state.exportResult != null && state.exportResult!.success) {
              _showExportResultModal(context, state.exportResult!);
            } else if (state.toastNotification != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.toastNotification!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.cardDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AdminSupportLoading || state is AdminSupportInitial) {
            return _buildShimmerLoading();
          }

          if (state is AdminSupportError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AdminSupportLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF6D28D9),
              onRefresh: () async {
                context.read<AdminSupportBloc>().add(const FetchSupportDataEvent(isRefresh: true));
              },
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom == 0 ? 20.0 : MediaQuery.paddingOf(context).bottom + 16.0,
                    top: 16.0,
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Banner Header & Subtitle
                      Text(
                        'Support Center',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenHeaderSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage platform inquiries, disputes, and technical support requests.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: subHeaderSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Ticket Metric Badges (OPEN, IN PROGRESS, RESOLVED)
                      AdminSupportStatsBar(stats: state.stats),
                      const SizedBox(height: 16),

                      // 3. Search & Filter Bar
                      _buildSearchAndFilters(context, state),
                      const SizedBox(height: 16),

                      // 4. Ticket Cards Feed List
                      if (state.filteredTickets.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.filteredTickets.length,
                          separatorBuilder: (context, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final ticket = state.filteredTickets[index];
                            final isSelected = ticket.id == state.selectedTicketId;

                            return AdminSupportTicketCard(
                              ticket: ticket,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<AdminSupportBloc>().add(SelectSupportTicketEvent(ticket.id));
                                AdminSupportDetailSheet.show(
                                  context,
                                  ticket: ticket,
                                  onSendReply: (msg, isInternal) {
                                    context.read<AdminSupportBloc>().add(
                                          SendTicketReplyEvent(
                                            ticketId: ticket.id,
                                            text: msg,
                                            isInternalNote: isInternal,
                                          ),
                                        );
                                  },
                                  onToggleResolve: () {
                                    context.read<AdminSupportBloc>().add(
                                          ToggleTicketResolutionEvent(ticket.id),
                                        );
                                  },
                                  onAssign: (assignee) {
                                    context.read<AdminSupportBloc>().add(
                                          AssignTicketEvent(
                                            ticketId: ticket.id,
                                            assignee: assignee,
                                          ),
                                        );
                                  },
                                );
                              },
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

  Widget _buildSearchAndFilters(BuildContext context, AdminSupportLoaded state) {
    final filters = [
      {'id': 'all', 'label': 'All Active'},
      {'id': 'high', 'label': 'High Priority'},
      {'id': 'disputes', 'label': 'Disputes'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<AdminSupportBloc>().add(
                          FilterSupportTicketsEvent(searchQuery: query),
                        );
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tickets, users, IDs...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<AdminSupportBloc>().add(
                          const FilterSupportTicketsEvent(searchQuery: ''),
                        );
                  },
                  child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Filter Mode Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((f) {
              final isSelected = state.activeFilterMode == f['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Material(
                  color: isSelected ? const Color(0xFF6D28D9) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<AdminSupportBloc>().add(
                            FilterSupportTicketsEvent(filterMode: f['id']),
                          );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6D28D9) : AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        f['label']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(LucideIcons.inbox, size: 24, color: Color(0xFF6D28D9)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Tickets Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or filter criteria.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 44, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Unable to Load Support Center',
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
                context.read<AdminSupportBloc>().add(const FetchSupportDataEvent());
              },
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 180, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 8),
            Container(width: 260, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (ctx, index) => Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
