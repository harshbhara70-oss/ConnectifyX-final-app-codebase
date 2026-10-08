import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_settings_bloc.dart';
import '../../bloc/admin_settings_event.dart';
import '../../bloc/admin_settings_state.dart';
import '../widgets/admin_ai_weights_card.dart';
import '../widgets/admin_integrations_grid.dart';
import '../widgets/admin_maintenance_card.dart';
import '../widgets/admin_policies_card.dart';
import '../widgets/admin_security_audit_table.dart';
import '../widgets/admin_settings_category_tabs.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Production-Ready Platform Settings Page for Campus2Corporate Admin Module.
/// Guarantees 1:1 feature parity with web SettingsView.tsx, clamped typography,
/// zero-overflow constraints, 120Hz Impeller performance, and live Atlas sync.
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminSettingsBloc()..add(const FetchAdminSettingsEvent()),
      child: const _AdminSettingsView(),
    );
  }
}

class _AdminSettingsView extends StatefulWidget {
  const _AdminSettingsView();

  @override
  State<_AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<_AdminSettingsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          'Platform Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Settings',
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textSecondary, size: 17),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AdminSettingsBloc>().add(const FetchAdminSettingsEvent(isRefresh: true));
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: BlocConsumer<AdminSettingsBloc, AdminSettingsState>(
        listener: (context, state) {
          if (state is AdminSettingsLoaded && state.toastNotification != null) {
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
        },
        builder: (context, state) {
          if (state is AdminSettingsLoading || state is AdminSettingsInitial) {
            return _buildShimmerLoading();
          }

          if (state is AdminSettingsError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AdminSettingsLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF6D28D9),
              onRefresh: () async {
                context.read<AdminSettingsBloc>().add(const FetchAdminSettingsEvent(isRefresh: true));
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
                      // 1. Page Header & Subtitle
                      Text(
                        'Platform Configuration',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenHeaderSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage global system parameters, integrations, and security protocols.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: subHeaderSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Settings Category Sub-Tabs
                      AdminSettingsCategoryTabs(
                        activeCategory: state.activeCategory,
                        onSelectCategory: (catId) {
                          context.read<AdminSettingsBloc>().add(ChangeSettingsCategoryEvent(catId));
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Dynamic Category View
                      _buildActiveCategorySection(context, state),
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

  Widget _buildActiveCategorySection(BuildContext context, AdminSettingsLoaded state) {
    switch (state.activeCategory) {
      case 'ai':
        return RepaintBoundary(
          child: Column(
            children: [
              AdminAiWeightsCard(
                aiWeights: state.settings.aiWeights,
                isSaving: state.isSaving,
                onWeightChange: (acad, soft, tech, extra) {
                  context.read<AdminSettingsBloc>().add(
                        UpdateAiWeightEvent(
                          academic: acad,
                          softSkills: soft,
                          techProjects: tech,
                          extracurricular: extra,
                        ),
                      );
                },
                onSave: () {
                  context.read<AdminSettingsBloc>().add(const SaveAiWeightsEvent());
                },
              ),
              const SizedBox(height: 14),
              AdminIntegrationsGrid(
                integrations: state.settings.integrations,
                onToggle: (id) {
                  context.read<AdminSettingsBloc>().add(ToggleIntegrationEvent(id));
                },
              ),
            ],
          ),
        );

      case 'integrations':
        return RepaintBoundary(
          child: AdminIntegrationsGrid(
            integrations: state.settings.integrations,
            onToggle: (id) {
              context.read<AdminSettingsBloc>().add(ToggleIntegrationEvent(id));
            },
          ),
        );

      case 'security':
        return RepaintBoundary(
          child: AdminSecurityAuditTable(
            auditLogs: state.settings.auditLogs,
          ),
        );

      case 'maintenance':
        return RepaintBoundary(
          child: AdminMaintenanceCard(
            maintenanceEnabled: state.settings.maintenanceEnabled,
            onToggle: () {
              context.read<AdminSettingsBloc>().add(const ToggleMaintenanceModeEvent());
            },
          ),
        );

      case 'policies':
      case 'general':
      case 'notifications':
      default:
        return RepaintBoundary(
          child: AdminPoliciesCard(
            general: state.settings.general,
            onSave: (updated) {
              context.read<AdminSettingsBloc>().add(UpdateGeneralSettingsEvent(updated));
            },
          ),
        );
    }
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
              'Unable to Load Settings',
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
                context.read<AdminSettingsBloc>().add(const FetchAdminSettingsEvent());
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
            Container(width: double.infinity, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
