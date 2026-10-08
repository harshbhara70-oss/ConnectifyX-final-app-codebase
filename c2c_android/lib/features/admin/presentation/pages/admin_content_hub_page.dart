import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_content_hub_bloc.dart';
import '../../bloc/admin_content_hub_event.dart';
import '../../bloc/admin_content_hub_state.dart';
import '../../data/models/admin_content_models.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminContentHubPage extends StatelessWidget {
  const AdminContentHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminContentHubBloc()..add(const FetchContentHubData()),
      child: const _AdminContentHubView(),
    );
  }
}

class _AdminContentHubView extends StatefulWidget {
  const _AdminContentHubView();

  @override
  State<_AdminContentHubView> createState() => _AdminContentHubViewState();
}

class _AdminContentHubViewState extends State<_AdminContentHubView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // CREATE ROADMAP MODAL WITH SAFE INSETS & OVERFLOW PREVENTION
  // ---------------------------------------------------------------------------
  void _showAddRoadmapModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController();
    String selectedCategory = 'Tech';
    String selectedStatus = 'Published';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final screenWidth = MediaQuery.sizeOf(ctx).width;
          final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
          final navBarHeight = MediaQuery.paddingOf(ctx).bottom;
          final modalTitleSize = (screenWidth * 0.046).clamp(16.0, 19.0);
          final labelSize = (screenWidth * 0.030).clamp(11.0, 12.0);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: (screenWidth * 0.05).clamp(16.0, 22.0),
                  right: (screenWidth * 0.05).clamp(16.0, 22.0),
                  top: 18,
                  bottom: bottomInset > 0 ? bottomInset + 12 : navBarHeight + 16,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Create Track',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: modalTitleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TRACK TITLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., AI & ML Track',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CATEGORY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['Tech', 'Business', 'Non-Tech', 'Design'].map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            c,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedCategory = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['Published', 'Under Review', 'Draft'].map((s) {
                                        final display = s == 'Under Review' ? 'In Review' : s;
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            display,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedStatus = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleController.text.trim().isEmpty) return;
                                HapticFeedback.lightImpact();
                                context.read<AdminContentHubBloc>().add(
                                      CreateRoadmapAction(
                                        title: titleController.text.trim(),
                                        category: selectedCategory,
                                        status: selectedStatus,
                                      ),
                                    );
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D28D9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Save Track',
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
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UPLOAD RESOURCE MODAL WITH SAFE INSETS & OVERFLOW PREVENTION
  // ---------------------------------------------------------------------------
  void _showAddResourceModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Tech';
    String selectedType = 'PDF';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final screenWidth = MediaQuery.sizeOf(ctx).width;
          final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
          final navBarHeight = MediaQuery.paddingOf(ctx).bottom;
          final modalTitleSize = (screenWidth * 0.046).clamp(16.0, 19.0);
          final labelSize = (screenWidth * 0.030).clamp(11.0, 12.0);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: (screenWidth * 0.05).clamp(16.0, 22.0),
                  right: (screenWidth * 0.05).clamp(16.0, 22.0),
                  top: 18,
                  bottom: bottomInset > 0 ? bottomInset + 12 : navBarHeight + 16,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Add Resource',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: modalTitleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'RESOURCE TITLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., DSA Core Blueprint',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'SUMMARY NOTE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Brief summary of topics covered...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CATEGORY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['Tech', 'Business', 'Non-Tech'].map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            c,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedCategory = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FORMAT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedType,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['PDF', 'Video', 'Code', 'Document'].map((t) {
                                        final display = t == 'Document' ? 'Docs' : t;
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(
                                            display,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedType = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleController.text.trim().isEmpty) return;
                                HapticFeedback.lightImpact();
                                context.read<AdminContentHubBloc>().add(
                                      CreateResourceAction(
                                        title: titleController.text.trim(),
                                        category: selectedCategory,
                                        type: selectedType,
                                        description: descController.text.trim(),
                                      ),
                                    );
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D28D9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Upload File',
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
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EDIT ROADMAP MODAL WITH SAFE INSETS & OVERFLOW PREVENTION
  // ---------------------------------------------------------------------------
  void _showEditRoadmapModal(BuildContext context, AdminRoadmapModel roadmap) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController(text: roadmap.title);
    String selectedCategory = roadmap.category;
    String selectedStatus = roadmap.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final screenWidth = MediaQuery.sizeOf(ctx).width;
          final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
          final navBarHeight = MediaQuery.paddingOf(ctx).bottom;
          final modalTitleSize = (screenWidth * 0.046).clamp(16.0, 19.0);
          final labelSize = (screenWidth * 0.030).clamp(11.0, 12.0);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: (screenWidth * 0.05).clamp(16.0, 22.0),
                  right: (screenWidth * 0.05).clamp(16.0, 22.0),
                  top: 18,
                  bottom: bottomInset > 0 ? bottomInset + 12 : navBarHeight + 16,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Edit Track',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: modalTitleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TRACK TITLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CATEGORY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCategory,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['Tech', 'Business', 'Non-Tech', 'Design'].map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            c,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedCategory = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                                      items: ['Published', 'Under Review', 'Draft'].map((s) {
                                        final display = s == 'Under Review' ? 'In Review' : s;
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            display,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => selectedStatus = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleController.text.trim().isEmpty) return;
                                HapticFeedback.lightImpact();
                                final updated = roadmap.copyWith(
                                  title: titleController.text.trim(),
                                  category: selectedCategory,
                                  status: selectedStatus,
                                );
                                context.read<AdminContentHubBloc>().add(UpdateRoadmapAction(updated));
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D28D9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Update',
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
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN SCAFFOLD BODY
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontalPadding = (screenWidth * 0.045).clamp(12.0, 20.0);

    return BlocConsumer<AdminContentHubBloc, AdminContentHubState>(
      listener: (context, state) {
        if (state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage!,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: const AdminSidebarDrawer(),
          appBar: _buildAppBar(context, screenWidth, state),
          body: SafeArea(
            bottom: true,
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AdminContentHubBloc>().add(const FetchContentHubData(isRefresh: true));
              },
              color: const Color(0xFF6D28D9),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.only(
                  bottom: bottomInset == 0 ? 20.0 : bottomInset + 24.0,
                  top: 14.0,
                  left: horizontalPadding,
                  right: horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Header Banner with "+ Add Track / File" Button
                    _buildHeaderBanner(context, screenWidth, state),
                    const SizedBox(height: 14),

                    // 2. Navigation Sub-Tabs: [Tracks] | [Resources]
                    _buildSubTabs(context, screenWidth, state),
                    const SizedBox(height: 14),

                    // 3. Filter & Search Bar
                    _buildFilterSearchBar(context, screenWidth, state),
                    const SizedBox(height: 14),

                    // 4. Metric Stats Summary Strip
                    _buildStatsSummary(context, screenWidth, state),
                    const SizedBox(height: 14),

                    // 5. Main Content: Roadmaps or Resource Library
                    if (state.status == ContentHubStatus.loading && state.roadmaps.isEmpty)
                      _buildShimmerList()
                    else if (state.activeTab == ContentHubTab.roadmaps)
                      _buildRoadmapsList(context, screenWidth, state)
                    else
                      _buildResourcesList(context, screenWidth, state),

                    const SizedBox(height: 14),

                    // 6. Pagination Footer
                    _buildPaginationFooter(context, screenWidth, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // APPBAR
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth, AdminContentHubState state) {
    final titleSize = (screenWidth * 0.042).clamp(15.0, 17.0);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
        onPressed: () {
          HapticFeedback.lightImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.bookOpen, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Content Hub',
              style: GoogleFonts.plusJakartaSans(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (state.isMock) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
              ),
              child: Text(
                'Mock *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/student/notifications');
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 0.8),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER BANNER WITH SHORT MOBILE SYNONYMS
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBanner(BuildContext context, double screenWidth, AdminContentHubState state) {
    final titleSize = (screenWidth * 0.052).clamp(18.0, 22.0);
    final subtitleSize = (screenWidth * 0.033).clamp(12.0, 13.5);
    final isRoadmapsTab = state.activeTab == ContentHubTab.roadmaps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Hub',
            style: GoogleFonts.plusJakartaSans(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Manage career tracks, modules & learning files.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isRoadmapsTab) {
                  _showAddRoadmapModal(context);
                } else {
                  _showAddResourceModal(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                elevation: 1,
                shadowColor: const Color(0xFF6D28D9).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
              label: Text(
                isRoadmapsTab ? 'Add Track' : 'Upload File',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUB TABS
  // ---------------------------------------------------------------------------
  Widget _buildSubTabs(BuildContext context, double screenWidth, AdminContentHubState state) {
    final tabLabelSize = (screenWidth * 0.034).clamp(12.5, 14.0);

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AdminContentHubBloc>().add(const SelectContentTab(ContentHubTab.roadmaps));
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: state.activeTab == ContentHubTab.roadmaps ? const Color(0xFF6D28D9) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.activeTab == ContentHubTab.roadmaps ? const Color(0xFF6D28D9) : AppColors.border,
                  width: 0.8,
                ),
                boxShadow: state.activeTab == ContentHubTab.roadmaps
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.map,
                    size: 15,
                    color: state.activeTab == ContentHubTab.roadmaps ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tracks',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: tabLabelSize,
                      fontWeight: FontWeight.w700,
                      color: state.activeTab == ContentHubTab.roadmaps ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AdminContentHubBloc>().add(const SelectContentTab(ContentHubTab.resources));
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: state.activeTab == ContentHubTab.resources ? const Color(0xFF6D28D9) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.activeTab == ContentHubTab.resources ? const Color(0xFF6D28D9) : AppColors.border,
                  width: 0.8,
                ),
                boxShadow: state.activeTab == ContentHubTab.resources
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.folder,
                    size: 15,
                    color: state.activeTab == ContentHubTab.resources ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Resources',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: tabLabelSize,
                      fontWeight: FontWeight.w700,
                      color: state.activeTab == ContentHubTab.resources ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER & SEARCH BAR WITH SHORT SYNONYMS
  // ---------------------------------------------------------------------------
  Widget _buildFilterSearchBar(BuildContext context, double screenWidth, AdminContentHubState state) {
    final isRoadmapsTab = state.activeTab == ContentHubTab.roadmaps;
    final filterTextSize = (screenWidth * 0.030).clamp(11.0, 12.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF).withValues(alpha: 0.7), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: isRoadmapsTab ? state.roadmapCategoryFilter : state.resourceCategoryFilter,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: filterTextSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All Categories', child: Text('All')),
                        DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                        DropdownMenuItem(value: 'Business', child: Text('Business')),
                        DropdownMenuItem(value: 'Non-Tech', child: Text('Non-Tech')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.lightImpact();
                          if (isRoadmapsTab) {
                            context.read<AdminContentHubBloc>().add(UpdateRoadmapCategoryFilter(val));
                          } else {
                            context.read<AdminContentHubBloc>().add(UpdateResourceCategoryFilter(val));
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: isRoadmapsTab ? state.roadmapStatusFilter : state.resourceTypeFilter,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: filterTextSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: isRoadmapsTab
                          ? const [
                              DropdownMenuItem(value: 'Status: All', child: Text('All Status')),
                              DropdownMenuItem(value: 'Published', child: Text('Published')),
                              DropdownMenuItem(value: 'Under Review', child: Text('In Review')),
                              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                            ]
                          : const [
                              DropdownMenuItem(value: 'All Types', child: Text('All Types')),
                              DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                              DropdownMenuItem(value: 'Video', child: Text('Video')),
                              DropdownMenuItem(value: 'Code', child: Text('Code')),
                              DropdownMenuItem(value: 'Document', child: Text('Docs')),
                            ],
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.lightImpact();
                          if (isRoadmapsTab) {
                            context.read<AdminContentHubBloc>().add(UpdateRoadmapStatusFilter(val));
                          } else {
                            context.read<AdminContentHubBloc>().add(UpdateResourceTypeFilter(val));
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<AdminContentHubBloc>().add(UpdateContentSearchQuery(val));
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: filterTextSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: isRoadmapsTab ? 'Search tracks...' : 'Search library...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: filterTextSize,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(LucideIcons.search, size: 14, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 13, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        context.read<AdminContentHubBloc>().add(const UpdateContentSearchQuery(''));
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border, width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border, width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATS SUMMARY STRIP
  // ---------------------------------------------------------------------------
  Widget _buildStatsSummary(BuildContext context, double screenWidth, AdminContentHubState state) {
    return RepaintBoundary(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
              screenWidth: screenWidth,
              title: 'Tracks',
              value: '${state.totalRoadmapsCount}',
              icon: LucideIcons.layers,
              color: const Color(0xFF6D28D9),
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              screenWidth: screenWidth,
              title: 'Published',
              value: '${state.publishedRoadmapsCount}',
              icon: LucideIcons.checkCircle2,
              color: const Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              screenWidth: screenWidth,
              title: 'Files',
              value: '${state.totalResourcesCount}',
              icon: LucideIcons.fileText,
              color: const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required double screenWidth,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final valueSize = (screenWidth * 0.052).clamp(18.0, 22.0);
    final labelSize = (screenWidth * 0.031).clamp(11.5, 13.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ROADMAPS LIST
  // ---------------------------------------------------------------------------
  Widget _buildRoadmapsList(BuildContext context, double screenWidth, AdminContentHubState state) {
    final roadmaps = state.paginatedRoadmaps;

    if (roadmaps.isEmpty) {
      return _buildEmptyState(
        title: 'No Tracks Found',
        message: 'Adjust your search filters or create a new career roadmap track.',
        buttonLabel: 'Add Track',
        onTap: () => _showAddRoadmapModal(context),
      );
    }

    final titleSize = (screenWidth * 0.038).clamp(13.5, 15.5);
    final metaSize = (screenWidth * 0.030).clamp(11.0, 12.0);

    return RepaintBoundary(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: roadmaps.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (ctx, index) {
          final rm = roadmaps[index];
          final isSelected = state.selectedRoadmapIds.contains(rm.id);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF6D28D9) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.4 : 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditRoadmapModal(context, rm),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.read<AdminContentHubBloc>().add(ToggleRoadmapStarAction(rm.id));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8, top: 1),
                              child: Icon(
                                rm.starred ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 20,
                                color: rm.starred ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rm.title.toTitleCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.moreVertical, size: 16, color: AppColors.textSecondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showEditRoadmapModal(context, rm);
                              } else if (val == 'star') {
                                context.read<AdminContentHubBloc>().add(ToggleRoadmapStarAction(rm.id));
                              } else if (val == 'publish') {
                                context.read<AdminContentHubBloc>().add(
                                      UpdateRoadmapAction(rm.copyWith(status: 'Published')),
                                    );
                              } else if (val == 'draft') {
                                context.read<AdminContentHubBloc>().add(
                                      UpdateRoadmapAction(rm.copyWith(status: 'Draft')),
                                    );
                              } else if (val == 'delete') {
                                _showDeleteRoadmapDialog(context, rm);
                              }
                            },
                            itemBuilder: (popCtx) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.edit2, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text('Edit Track', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'star',
                                child: Row(
                                  children: [
                                    Icon(rm.starred ? LucideIcons.starOff : LucideIcons.star, size: 14, color: const Color(0xFFF59E0B)),
                                    const SizedBox(width: 8),
                                    Text(rm.starred ? 'Unstar' : 'Star Track', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              if (rm.status != 'Published')
                                PopupMenuItem(
                                  value: 'publish',
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.checkCircle, size: 14, color: Color(0xFF059669)),
                                      const SizedBox(width: 8),
                                      Text('Set Live', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              if (rm.status != 'Draft')
                                PopupMenuItem(
                                  value: 'draft',
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.fileClock, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 8),
                                      Text('To Draft', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
                                    const SizedBox(width: 8),
                                    Text('Delete', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              rm.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                          _buildStatusBadge(rm.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: metaSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${rm.completion}%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: metaSize,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6D28D9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (rm.completion / 100).clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6D28D9)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.users, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${rm.enrollments} Learners',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: metaSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                rm.lastUpdated,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: metaSize,
                                  color: AppColors.textMuted,
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
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESOURCES LIST
  // ---------------------------------------------------------------------------
  Widget _buildResourcesList(BuildContext context, double screenWidth, AdminContentHubState state) {
    final resources = state.paginatedResources;

    if (resources.isEmpty) {
      return _buildEmptyState(
        title: 'No Files Found',
        message: 'Adjust your format filters or upload a new resource guide.',
        buttonLabel: 'Upload File',
        onTap: () => _showAddResourceModal(context),
      );
    }

    final titleSize = (screenWidth * 0.036).clamp(13.0, 15.0);
    final metaSize = (screenWidth * 0.030).clamp(11.0, 12.0);

    return RepaintBoundary(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: resources.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (ctx, index) {
          final res = resources[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showResourceDetailModal(context, res);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getResourceTypeColor(res.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getResourceTypeIcon(res.type),
                              size: 17,
                              color: _getResourceTypeColor(res.type),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  res.title.toTitleCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                                if (res.description.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    res.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: metaSize,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              res.starred ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18,
                              color: res.starred ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.read<AdminContentHubBloc>().add(ToggleResourceStarAction(res.id));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              res.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: _getResourceTypeColor(res.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              res.type == 'Document' ? 'Docs' : res.type,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _getResourceTypeColor(res.type),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border, width: 0.6),
                            ),
                            child: Text(
                              res.fileSize,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.download, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${res.downloads} downloads',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: metaSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            res.lastUpdated,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: metaSize,
                              color: AppColors.textMuted,
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
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS BADGE
  // ---------------------------------------------------------------------------
  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);
    String display = status;

    if (status.toLowerCase() == 'published') {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
      border = const Color(0xFFA7F3D0);
      display = 'Live';
    } else if (status.toLowerCase() == 'under review') {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
      border = const Color(0xFFFDE68A);
      display = 'In Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        display,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Color _getResourceTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return const Color(0xFFEF4444);
      case 'VIDEO':
        return const Color(0xFF8B5CF6);
      case 'CODE':
        return const Color(0xFF10B981);
      case 'DOCUMENT':
      case 'DOCS':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getResourceTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return LucideIcons.fileText;
      case 'VIDEO':
        return LucideIcons.video;
      case 'CODE':
        return LucideIcons.code;
      case 'DOCUMENT':
      case 'DOCS':
        return LucideIcons.fileCode;
      default:
        return LucideIcons.file;
    }
  }

  // ---------------------------------------------------------------------------
  // PAGINATION FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildPaginationFooter(BuildContext context, double screenWidth, AdminContentHubState state) {
    final isRoadmapsTab = state.activeTab == ContentHubTab.roadmaps;
    final totalPages = isRoadmapsTab ? state.totalRoadmapPages : state.totalResourcePages;
    final totalResults = isRoadmapsTab ? state.filteredRoadmaps.length : state.filteredResources.length;

    if (totalResults == 0) return const SizedBox.shrink();

    final startIndex = ((state.currentPage - 1) * state.itemsPerPage) + 1;
    final endIndex = min(state.currentPage * state.itemsPerPage, totalResults);
    final metaSize = (screenWidth * 0.030).clamp(11.0, 12.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '$startIndex-$endIndex of $totalResults',
              style: GoogleFonts.plusJakartaSans(
                fontSize: metaSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final pageNum = index + 1;
              final isCurrent = pageNum == state.currentPage;

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<AdminContentHubBloc>().add(ChangeContentPage(pageNum));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF6D28D9) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent ? const Color(0xFF6D28D9) : AppColors.border,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$pageNum',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState({
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bookOpen, size: 26, color: Color(0xFF6D28D9)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: Text(
              buttonLabel,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER SKELETON
  // ---------------------------------------------------------------------------
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (_, itemIndex) => Container(
          height: 115,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE ROADMAP CONFIRMATION DIALOG
  // ---------------------------------------------------------------------------
  void _showDeleteRoadmapDialog(BuildContext context, AdminRoadmapModel roadmap) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Track',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${roadmap.title}"?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              HapticFeedback.lightImpact();
              context.read<AdminContentHubBloc>().add(DeleteRoadmapAction(roadmap.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESOURCE DETAIL SHEET WITH SAFE INSETS & OVERFLOW PREVENTION
  // ---------------------------------------------------------------------------
  void _showResourceDetailModal(BuildContext context, AdminResourceModel res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final screenWidth = MediaQuery.sizeOf(modalCtx).width;
        final navBarHeight = MediaQuery.paddingOf(modalCtx).bottom;
        final modalTitleSize = (screenWidth * 0.046).clamp(16.0, 19.0);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(modalCtx).height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: (screenWidth * 0.05).clamp(16.0, 22.0),
                right: (screenWidth * 0.05).clamp(16.0, 22.0),
                top: 18,
                bottom: navBarHeight + 16,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getResourceTypeColor(res.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            res.type == 'Document' ? 'Docs' : res.type,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getResourceTypeColor(res.type),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      res.title.toTitleCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: modalTitleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    if (res.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        res.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Category', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                              Text(res.category, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Size', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                              Text(res.fileSize, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Author', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                              Flexible(
                                child: Text(
                                  res.author,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              context.read<AdminContentHubBloc>().add(DeleteResourceAction(res.id));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.error),
                            label: Text('Delete', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(modalCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Downloading "${res.title}"...',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFF0F172A),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6D28D9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(LucideIcons.download, size: 15),
                            label: Text('Download', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
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
      },
    );
  }
}
