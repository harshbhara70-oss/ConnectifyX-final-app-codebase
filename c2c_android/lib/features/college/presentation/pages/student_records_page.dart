import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/components/custom_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';
import '../../bloc/student_directory_bloc.dart';
import '../../data/services/college_export_service.dart';
import '../../domain/models/college_student_model.dart';
import '../widgets/college_drawer.dart';

/// Available Mentors matching web `StudentRecordsView.tsx`
const List<Map<String, String>> kAvailableMentors = [
  {'id': 'm-1', 'name': 'Dr. Rajesh Kumar', 'area': 'Data Structures & Backend'},
  {'id': 'm-2', 'name': 'Prof. Anita Sharma', 'area': 'Embedded Systems & Hardware'},
  {'id': 'm-3', 'name': 'Alex Mercer', 'area': 'Full-Stack & System Design'},
  {'id': 'm-4', 'name': 'Dr. Sunita Deshmukh', 'area': 'Machine Learning & AI'},
];

/// Student Records — College Module
///
/// 1:1 Parity with website `src/components/dashboard/college/views/StudentRecordsView.tsx`
///
/// Features:
/// - Real MongoDB Atlas state updates with try/catch `isMock` boolean handling.
/// - Explicit asterisk `*` and "Soon" pill on mock/pending endpoints.
/// - Zero-overflow responsive layout with clamped font scales.
/// - Butter-smooth keyboard handling for Add, Edit, Mentor, and Email sheets.
/// - CSV Export of live filtered records.
/// - Grid & List view layout switcher.
class StudentRecordsPage extends StatelessWidget {
  const StudentRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentDirectoryBloc()..add(const FetchStudentsEvent()),
      child: const _StudentRecordsView(),
    );
  }
}

class _StudentRecordsView extends StatefulWidget {
  const _StudentRecordsView();

  @override
  State<_StudentRecordsView> createState() => _StudentRecordsViewState();
}

class _StudentRecordsViewState extends State<_StudentRecordsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedDept = 'All Departments';
  String _selectedYear = 'All Batches';
  double _minCgpa = 0.0;
  String _statusFilter = 'All'; // 'All' | 'Placed' | 'Pending' | 'Unplaced'
  String _viewMode = 'grid'; // 'grid' | 'list'

  String? _toastMsg;
  bool _toastIsError = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted || msg.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _toastMsg = msg;
      _toastIsError = isError;
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && _toastMsg == msg) {
        setState(() => _toastMsg = null);
      }
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ST';
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _cgpaDot(double cgpa) {
    if (cgpa >= 8.0) return AppColors.success;
    if (cgpa >= 7.0) return AppColors.warning;
    return AppColors.error;
  }

  // -------------------------------------------------------------------------
  // Filters Logic
  // -------------------------------------------------------------------------

  List<String> _deptOptions(List<CollegeStudentModel> all) {
    final set = <String>{
      'Computer Science',
      'Electronics',
      'Mechanical',
      'Civil',
      'Information Technology',
    };
    for (final s in all) {
      if (s.department.trim().isNotEmpty) set.add(s.department.trim());
    }
    final sorted = set.toList()..sort();
    return ['All Departments', ...sorted];
  }

  List<String> _yearOptions(List<CollegeStudentModel> all) {
    final set = <String>{'2024 (Current)', '2025', '2026'};
    for (final s in all) {
      if (s.graduationYear.trim().isNotEmpty) set.add(s.graduationYear.trim());
    }
    final sorted = set.toList()..sort();
    return ['All Batches', ...sorted];
  }

  List<CollegeStudentModel> _applyFilters(List<CollegeStudentModel> src) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return src.where((s) {
      final matchesSearch = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.rollNumber.toLowerCase().contains(q) ||
          s.department.toLowerCase().contains(q) ||
          s.skills.any((k) => k.toLowerCase().contains(q));

      final matchesDept =
          _selectedDept == 'All Departments' || s.department == _selectedDept;

      final matchesYear =
          _selectedYear == 'All Batches' || s.graduationYear == _selectedYear;

      final matchesCgpa = s.cgpa >= _minCgpa;

      bool matchesStatus = true;
      if (_statusFilter == 'Placed') {
        matchesStatus = s.isPlaced;
      } else if (_statusFilter == 'Pending') {
        matchesStatus = s.isPending;
      } else if (_statusFilter == 'Unplaced') {
        matchesStatus = s.isUnplaced;
      }

      return matchesSearch && matchesDept && matchesYear && matchesCgpa && matchesStatus;
    }).toList();
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _searchCtrl.clear();
      _selectedDept = 'All Departments';
      _selectedYear = 'All Batches';
      _minCgpa = 0.0;
      _statusFilter = 'All';
    });
    _showToast('Filters reset to default settings.');
  }

  // -------------------------------------------------------------------------
  // -------------------------------------------------------------------------
  // CSV & PDF Export (Client-Side Production Ready)
  // -------------------------------------------------------------------------

  String _buildFilterSummary() {
    final parts = <String>[];
    if (_searchCtrl.text.trim().isNotEmpty) parts.add('Search: "${_searchCtrl.text.trim()}"');
    if (_selectedDept != 'All Departments') parts.add('Dept: $_selectedDept');
    if (_selectedYear != 'All Batches') parts.add('Batch: $_selectedYear');
    if (_minCgpa > 0) parts.add('Min CGPA: ${_minCgpa.toStringAsFixed(1)}');
    if (_statusFilter != 'All') parts.add('Status: $_statusFilter');
    return parts.isEmpty ? 'All Cohort' : parts.join(' | ');
  }

  Future<void> _exportCsv(List<CollegeStudentModel> filtered) async {
    HapticFeedback.mediumImpact();
    await CollegeExportService.exportStudentRecordsCsv(
      context,
      filtered,
      filterDescription: _buildFilterSummary(),
    );
  }

  Future<void> _exportPdf(List<CollegeStudentModel> filtered) async {
    HapticFeedback.mediumImpact();
    await CollegeExportService.exportStudentRecordsPdf(
      context,
      filtered,
    );
  }

  void _showExportOptionsSheet(List<CollegeStudentModel> filtered) {
    HapticFeedback.lightImpact();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        padding: EdgeInsets.only(
          left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
          right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
          top: 18,
          bottom: bottomPad == 0 ? 20.0 : bottomPad + 12.0,
        ),
        decoration: BoxDecoration(
          color: ctx.surf,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: ctx.brdr, width: 0.8),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.download, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Records',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.044, 15.5, 17.5),
                            fontWeight: FontWeight.w800,
                            color: ctx.txtPrimary,
                          ),
                        ),
                        Text(
                          '${filtered.length} candidates ready for export',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.029, 10.5, 11.5),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, size: 18),
                  ),
                ],
              ),
              Divider(color: ctx.brdr, height: 20),
              Text(
                'Choose export format. Data is generated instantly on-device without server delays.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                  fontWeight: FontWeight.w400,
                  color: ctx.txtSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),

              // Option 1: CSV Spreadsheet
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _exportCsv(filtered);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ctx.surfAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ctx.brdr, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.fileSpreadsheet, size: 20, color: Color(0xFF059669)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CSV Spreadsheet (.csv)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.034, 12.5, 13.5),
                                  fontWeight: FontWeight.w700,
                                  color: ctx.txtPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Excel, Google Sheets & TPO database ready',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.028, 10.0, 11.0),
                                  color: ctx.txtMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Option 2: PDF Executive Report
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _exportPdf(filtered);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ctx.surfAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ctx.brdr, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.fileText, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PDF Placement Report (.pdf)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.034, 12.5, 13.5),
                                  fontWeight: FontWeight.w700,
                                  color: ctx.txtPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Branded A4 landscape with KPIs & table',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.028, 10.0, 11.0),
                                  color: ctx.txtMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // -------------------------------------------------------------------------
  // MODALS & SHEETS (Butter-smooth Keyboard Handling)
  // -------------------------------------------------------------------------

  void _showAddStudentSheet() {
    HapticFeedback.lightImpact();
    final bloc = context.read<StudentDirectoryBloc>();
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final cgpaCtrl = TextEditingController(text: '8.50');
    final skillsCtrl = TextEditingController(text: 'React.js, Node.js, Python');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String dept = 'Computer Science';
    String gradYear = '2024 (Current)';
    String placementStatus = 'UNPLACED';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setModal) {
          final viewInset = MediaQuery.of(ctx).viewInsets.bottom;
          final bottomPad = MediaQuery.paddingOf(ctx).bottom;
          final screenWidth = MediaQuery.sizeOf(ctx).width;

          return Container(
            padding: EdgeInsets.only(
              left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              top: 18,
              bottom: viewInset > 0 ? viewInset + 16.0 : (bottomPad == 0 ? 20.0 : bottomPad + 12.0),
            ),
            decoration: BoxDecoration(
              color: ctx.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: ctx.brdr, width: 0.8),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.userPlus, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Register New Candidate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                            fontWeight: FontWeight.w800,
                            color: ctx.txtPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: ctx.brdr, height: 20),
                  _modalField(ctx, 'Student Full Name *', 'e.g. Arjun Mehta', nameCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalField(ctx, 'Roll Number *', 'e.g. CS2024-042', rollCtrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalField(
                          ctx,
                          'CGPA (0 - 10) *',
                          'e.g. 8.92',
                          cgpaCtrl,
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalDropdown<String>(
                          ctx,
                          label: 'Department',
                          value: dept,
                          items: const [
                            'Computer Science',
                            'Electronics',
                            'Mechanical',
                            'Civil',
                            'Information Technology'
                          ],
                          onChanged: (v) => setModal(() => dept = v ?? dept),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalDropdown<String>(
                          ctx,
                          label: 'Graduation Year',
                          value: gradYear,
                          items: const ['2024 (Current)', '2025', '2026'],
                          onChanged: (v) => setModal(() => gradYear = v ?? gradYear),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _modalDropdown<String>(
                    ctx,
                    label: 'Placement Status',
                    value: placementStatus,
                    items: const ['UNPLACED', 'PLACED', 'PENDING'],
                    onChanged: (v) => setModal(() => placementStatus = v ?? placementStatus),
                  ),
                  const SizedBox(height: 10),
                  _modalField(
                    ctx,
                    'Skills (comma separated)',
                    'React.js, Node.js, Python, AWS',
                    skillsCtrl,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalField(
                          ctx,
                          'Institutional Email',
                          'arjun@college.edu',
                          emailCtrl,
                          keyboard: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalField(
                          ctx,
                          'Phone',
                          '+91 98765 43210',
                          phoneCtrl,
                          keyboard: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: BouncyButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final roll = rollCtrl.text.trim();
                        final cgpaVal = double.tryParse(cgpaCtrl.text.trim()) ?? 8.0;

                        if (name.isEmpty) {
                          _showToast('Candidate name is required.', isError: true);
                          return;
                        }
                        if (cgpaVal < 0 || cgpaVal > 10) {
                          _showToast('CGPA must be between 0.0 and 10.0', isError: true);
                          return;
                        }

                        final skillsList = skillsCtrl.text
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        Navigator.pop(ctx);
                        bloc.add(CreateStudentEvent(studentData: {
                          'name': name,
                          'rollNumber': roll.isNotEmpty ? roll : 'Roll: CS2024-000',
                          'department': dept,
                          'branch': dept,
                          'graduationYear': gradYear,
                          'percentage': cgpaVal * 10,
                          'cgpa': cgpaVal,
                          'placementStatus': placementStatus,
                          'skills': skillsList.isNotEmpty ? skillsList : ['React.js', 'Python'],
                          'email': emailCtrl.text.trim().isNotEmpty
                              ? emailCtrl.text.trim()
                              : '${name.toLowerCase().replaceAll(' ', '.')}@college.edu',
                          'phone': phoneCtrl.text.trim(),
                        }));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Save Student Record',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditStudentSheet(CollegeStudentModel s) {
    HapticFeedback.lightImpact();
    final bloc = context.read<StudentDirectoryBloc>();
    final nameCtrl = TextEditingController(text: s.name);
    final rollCtrl = TextEditingController(text: s.rollNumber);
    final cgpaCtrl = TextEditingController(text: s.cgpa.toStringAsFixed(2));
    final skillsCtrl = TextEditingController(text: s.skills.join(', '));
    final emailCtrl = TextEditingController(text: s.email);
    final phoneCtrl = TextEditingController(text: s.phone);
    String dept = s.department;
    String gradYear = s.graduationYear;
    String placementStatus = s.placementStatus;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setModal) {
          final viewInset = MediaQuery.of(ctx).viewInsets.bottom;
          final bottomPad = MediaQuery.paddingOf(ctx).bottom;
          final screenWidth = MediaQuery.sizeOf(ctx).width;

          return Container(
            padding: EdgeInsets.only(
              left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              top: 18,
              bottom: viewInset > 0 ? viewInset + 16.0 : (bottomPad == 0 ? 20.0 : bottomPad + 12.0),
            ),
            decoration: BoxDecoration(
              color: ctx.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: ctx.brdr, width: 0.8),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Edit Student Record',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                            fontWeight: FontWeight.w800,
                            color: ctx.txtPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: ctx.brdr, height: 20),
                  _modalField(ctx, 'Student Full Name *', 'Name', nameCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalField(ctx, 'Roll Number', 'Roll Number', rollCtrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalField(
                          ctx,
                          'CGPA',
                          'CGPA',
                          cgpaCtrl,
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalDropdown<String>(
                          ctx,
                          label: 'Department',
                          value: dept,
                          items: const [
                            'Computer Science',
                            'Electronics',
                            'Mechanical',
                            'Civil',
                            'Information Technology'
                          ],
                          onChanged: (v) => setModal(() => dept = v ?? dept),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalDropdown<String>(
                          ctx,
                          label: 'Graduation Year',
                          value: gradYear,
                          items: const ['2024 (Current)', '2025', '2026'],
                          onChanged: (v) => setModal(() => gradYear = v ?? gradYear),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _modalDropdown<String>(
                    ctx,
                    label: 'Placement Status',
                    value: placementStatus,
                    items: const ['UNPLACED', 'PLACED', 'PENDING'],
                    onChanged: (v) => setModal(() => placementStatus = v ?? placementStatus),
                  ),
                  const SizedBox(height: 10),
                  _modalField(ctx, 'Skills', 'Skills', skillsCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _modalField(
                          ctx,
                          'Email',
                          'Email',
                          emailCtrl,
                          keyboard: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalField(
                          ctx,
                          'Phone',
                          'Phone',
                          phoneCtrl,
                          keyboard: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: BouncyButton(
                      onPressed: () {
                        final cgpaVal = double.tryParse(cgpaCtrl.text.trim()) ?? s.cgpa;
                        final skillsList = skillsCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        Navigator.pop(ctx);
                        bloc.add(UpdateStudentEvent(
                          id: s.id,
                          studentData: {
                            'name': nameCtrl.text.trim(),
                            'rollNumber': rollCtrl.text.trim(),
                            'department': dept,
                            'branch': dept,
                            'graduationYear': gradYear,
                            'cgpa': cgpaVal,
                            'percentage': cgpaVal * 10,
                            'placementStatus': placementStatus,
                            'skills': skillsList,
                            'email': emailCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                          },
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Update Record',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAssignMentorSheet(CollegeStudentModel s) {
    HapticFeedback.lightImpact();
    final bloc = context.read<StudentDirectoryBloc>();
    String mentor = kAvailableMentors[0]['name']!;
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setModal) {
          final viewInset = MediaQuery.of(ctx).viewInsets.bottom;
          final bottomPad = MediaQuery.paddingOf(ctx).bottom;
          final screenWidth = MediaQuery.sizeOf(ctx).width;

          return Container(
            padding: EdgeInsets.only(
              left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              top: 18,
              bottom: viewInset > 0 ? viewInset + 16.0 : (bottomPad == 0 ? 20.0 : bottomPad + 12.0),
            ),
            decoration: BoxDecoration(
              color: ctx.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: ctx.brdr, width: 0.8),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assign Mentor',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                                fontWeight: FontWeight.w800,
                                color: ctx.txtPrimary,
                              ),
                            ),
                            Text(
                              s.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: ctx.brdr, height: 20),
                  _modalDropdown<String>(
                    ctx,
                    label: 'Select Faculty Mentor',
                    value: mentor,
                    items: kAvailableMentors.map((m) => m['name']!).toList(),
                    itemLabel: (v) {
                      final match = kAvailableMentors.firstWhere((m) => m['name'] == v);
                      return '${match['name']} (${match['area']})';
                    },
                    onChanged: (v) => setModal(() => mentor = v ?? mentor),
                  ),
                  const SizedBox(height: 10),
                  _modalField(
                    ctx,
                    'Intervention Focus Notes',
                    'e.g. Needs 1-on-1 interview practice and coding mock assessments...',
                    notesCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Assigning faculty mentor helps unplaced candidates improve readiness scores.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: BouncyButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        bloc.add(AssignMentorEvent(
                          studentId: s.id,
                          studentName: s.name,
                          mentorName: mentor,
                          notes: notesCtrl.text.trim(),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Confirm Mentor Assignment',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEmailSheet(CollegeStudentModel s) {
    HapticFeedback.lightImpact();
    final bloc = context.read<StudentDirectoryBloc>();
    final subjectCtrl = TextEditingController(text: 'Placement Assistance & Career Guidance');
    final bodyCtrl = TextEditingController(
      text: 'Hi ${s.name},\n\nWe noticed your readiness score is currently ${s.readinessScore}%. Please schedule a 1-on-1 session with your placement coordinator.\n\nRegards,\nTPO Cell',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setModal) {
          final viewInset = MediaQuery.of(ctx).viewInsets.bottom;
          final bottomPad = MediaQuery.paddingOf(ctx).bottom;
          final screenWidth = MediaQuery.sizeOf(ctx).width;

          return Container(
            padding: EdgeInsets.only(
              left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
              top: 18,
              bottom: viewInset > 0 ? viewInset + 16.0 : (bottomPad == 0 ? 20.0 : bottomPad + 12.0),
            ),
            decoration: BoxDecoration(
              color: ctx.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: ctx.brdr, width: 0.8),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.mail, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Candidate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                                fontWeight: FontWeight.w800,
                                color: ctx.txtPrimary,
                              ),
                            ),
                            Text(
                              s.email.isNotEmpty ? s.email : s.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: ctx.brdr, height: 20),
                  _modalField(ctx, 'Subject *', 'Subject', subjectCtrl),
                  const SizedBox(height: 10),
                  _modalField(ctx, 'Message Body *', 'Message body...', bodyCtrl, maxLines: 4),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: BouncyButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        bloc.add(SendEmailEvent(
                          studentId: s.id,
                          studentName: s.name,
                          email: s.email,
                          subject: subjectCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.send, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Send Candidate Email',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(CollegeStudentModel s) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<StudentDirectoryBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: ctx.surf,
        title: Text(
          'Delete Student Record?',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Permanently remove "${s.name}" from your college cohort database? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: ctx.txtSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
          BouncyButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(DeleteStudentEvent(id: s.id));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.bg,
        drawer: const CollegeNavigationDrawer(currentRoute: '/college/students'),
        body: SafeArea(
          bottom: true,
          child: BlocListener<StudentDirectoryBloc, StudentDirectoryState>(
            listener: (ctx, state) {
              if (state is StudentDirectoryLoaded) {
                if (state.successMessage != null) {
                  _showToast(state.successMessage!);
                }
                if (state.errorMessage != null) {
                  _showToast(state.errorMessage!, isError: true);
                }
              } else if (state is StudentDirectoryError) {
                _showToast(state.message, isError: true);
              }
            },
            child: Stack(
              children: [
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    context.read<StudentDirectoryBloc>().add(const FetchStudentsEvent(isSilent: true));
                    await Future<void>.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                      right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                      top: 14.0,
                      bottom: bottomPad == 0 ? 110.0 : bottomPad + 96.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(screenWidth),
                            const SizedBox(height: 14),
                            _buildHeroHeader(screenWidth),
                            const SizedBox(height: 14),
                            BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
                              builder: (ctx, state) {
                                final all = state is StudentDirectoryLoaded ? state.students : <CollegeStudentModel>[];
                                return _buildSummaryGrid(all, screenWidth);
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildFilterCard(screenWidth),
                            const SizedBox(height: 14),
                            BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
                              builder: (ctx, state) {
                                if (state is StudentDirectoryLoading || state is StudentDirectoryInitial) {
                                  return _buildLoadingState();
                                }
                                if (state is StudentDirectoryError) {
                                  return _buildErrorState(state.message);
                                }

                                final loaded = state as StudentDirectoryLoaded;
                                final filtered = _applyFilters(loaded.students);

                                if (loaded.students.isEmpty) {
                                  return _buildEmptyCohortState();
                                }

                                if (filtered.isEmpty) {
                                  return _buildEmptyFilterState();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Showing ${filtered.length} of ${loaded.students.length} candidates',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                                              fontWeight: FontWeight.w600,
                                              color: context.txtSecondary,
                                            ),
                                          ),
                                          if (loaded.isMock) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.sparkles, size: 10, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Demo Cohort*',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    _buildRecordsList(filtered, screenWidth),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_toastMsg != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildToastNotification(_toastMsg!, isError: _toastIsError),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 3,
          onTap: (i) {
            if (i == 0) context.go('/college/dashboard');
            if (i == 1) context.go('/college/reports');
            if (i == 4) context.go('/college/settings');
          },
          onFabPressed: _showAddStudentSheet,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Top App Bar (Zero-Truncation Responsive Layout)
  // -------------------------------------------------------------------------

  Widget _buildTopBar(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          BouncyButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.surfAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.brdr, width: 0.8),
              ),
              child: Icon(
                Navigator.canPop(context) ? LucideIcons.arrowLeft : LucideIcons.menu,
                size: 18,
                color: context.txtPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student Records',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.044, 15.5, 17.5),
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Cohort Directory',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
            builder: (ctx, state) {
              final loaded = state is StudentDirectoryLoaded ? state.students : <CollegeStudentModel>[];
              final filtered = state is StudentDirectoryLoaded ? _applyFilters(loaded) : loaded;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BouncyButton(
                    onPressed: () => _showExportOptionsSheet(filtered),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.surfAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.brdr, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.download, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  BouncyButton(
                    onPressed: () {
                      context.read<StudentDirectoryBloc>().add(const FetchStudentsEvent(isSilent: true));
                      _showToast('Syncing candidate records with MongoDB...');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDDD6FE), width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.refreshCw, size: 15, color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Hero Action Banner (MediaQuery Adaptive with Zero-Overflow)
  // -------------------------------------------------------------------------

  Widget _buildHeroHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.038, 12.0, 16.0)),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TPO PORTAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.026, 9.5, 10.5),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Realtime Sync',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.028, 10.0, 11.5),
                          fontWeight: FontWeight.w600,
                          color: context.txtMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Candidate Performance & Profiles',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.044, 15.0, 17.5),
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Manage registrations, filter branches, review CGPA readiness, and coordinate mentor assignments.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.031, 11.0, 12.5),
              fontWeight: FontWeight.w400,
              color: context.txtSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
            builder: (ctx, state) {
              final loaded = state is StudentDirectoryLoaded ? state.students : <CollegeStudentModel>[];
              final filtered = state is StudentDirectoryLoaded ? _applyFilters(loaded) : loaded;

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BouncyButton(
                      onPressed: () => _showExportOptionsSheet(filtered),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: clampDouble(screenWidth * 0.030, 10.0, 12.0),
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfAlt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.brdr, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.download,
                              size: clampDouble(screenWidth * 0.038, 13.0, 15.0),
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Export CSV',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.031, 11.0, 12.5),
                                  fontWeight: FontWeight.w700,
                                  color: context.txtPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: BouncyButton(
                      onPressed: _showAddStudentSheet,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: clampDouble(screenWidth * 0.030, 10.0, 12.0),
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.userPlus,
                              size: clampDouble(screenWidth * 0.040, 14.0, 16.0),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Add Candidate',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  // -------------------------------------------------------------------------
  // Summary Metrics Grid
  // -------------------------------------------------------------------------

  Widget _buildSummaryGrid(List<CollegeStudentModel> all, double screenWidth) {
    final total = all.length;
    final placed = all.where((s) => s.isPlaced).length;
    final avgCgpa = total == 0 ? 0.0 : (all.fold<double>(0, (a, s) => a + s.cgpa) / total);
    final highPerformers = all.where((s) => s.cgpa >= 8.0).length;

    final tiles = [
      _SummaryTileData(
        label: 'TOTAL STUDENTS',
        value: '$total',
        icon: LucideIcons.users,
        accent: AppColors.primary,
        bg: AppColors.primaryLight,
      ),
      _SummaryTileData(
        label: 'PLACED CANDIDATES',
        value: '$placed',
        icon: LucideIcons.checkCircle2,
        accent: AppColors.success,
        bg: const Color(0xFFECFDF5),
      ),
      _SummaryTileData(
        label: 'AVERAGE CGPA',
        value: avgCgpa == 0 ? '—' : avgCgpa.toStringAsFixed(2),
        icon: LucideIcons.award,
        accent: AppColors.accentViolet,
        bg: AppColors.primaryLight,
      ),
      _SummaryTileData(
        label: 'HIGH PERFORMERS',
        value: '$highPerformers',
        icon: LucideIcons.trendingUp,
        accent: AppColors.warning,
        bg: const Color(0xFFFFFBEB),
      ),
    ];

    return RepaintBoundary(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 78,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (ctx, i) => _summaryTile(tiles[i], screenWidth),
      ),
    );
  }

  Widget _summaryTile(_SummaryTileData d, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: d.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(d.icon, size: 18, color: d.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  d.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.028, 11.0, 11.5),
                    fontWeight: FontWeight.w700,
                    color: context.txtMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  d.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.055, 18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Filter Card Component
  // -------------------------------------------------------------------------

  Widget _buildFilterCard(double screenWidth) {
    return BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
      builder: (ctx, state) {
        final all = state is StudentDirectoryLoaded ? state.students : <CollegeStudentModel>[];
        final deptOptions = _deptOptions(all);
        if (!deptOptions.contains(_selectedDept)) _selectedDept = 'All Departments';
        final yearOptions = _yearOptions(all);
        if (!yearOptions.contains(_selectedYear)) _selectedYear = 'All Batches';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: context.surfAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.brdr, width: 0.8),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search student records, roll numbers, skills...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: context.txtMuted),
                    prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                            onPressed: () => setState(() => _searchCtrl.clear()),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Department & Graduation Year Selectors
              Row(
                children: [
                  Expanded(
                    child: _filterDropdown<String>(
                      label: 'DEPARTMENT',
                      value: _selectedDept,
                      items: deptOptions,
                      onChanged: (v) => setState(() => _selectedDept = v ?? _selectedDept),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _filterDropdown<String>(
                      label: 'BATCH YEAR',
                      value: _selectedYear,
                      items: yearOptions,
                      onChanged: (v) => setState(() => _selectedYear = v ?? _selectedYear),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Min CGPA Range Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MIN CGPA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          color: context.txtMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _minCgpa.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: context.brdr,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.12),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _minCgpa.clamp(0.0, 10.0),
                      min: 0.0,
                      max: 10.0,
                      divisions: 20,
                      onChanged: (v) => setState(() => _minCgpa = v),
                    ),
                  ),
                ],
              ),

              // Placement Status Pill Toggle
              Text(
                'PLACEMENT STATUS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w800,
                  color: context.txtMuted,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: context.surfAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.brdr, width: 0.8),
                ),
                child: Row(
                  children: ['All', 'Placed', 'Pending', 'Unplaced'].map((st) {
                    final isActive = _statusFilter == st;
                    return Expanded(
                      child: BouncyButton(
                        onPressed: () => setState(() => _statusFilter = st),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            st,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : context.txtSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Reset Button & View Layout Switcher
              Row(
                children: [
                  BouncyButton(
                    onPressed: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.surfAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.brdr, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.rotateCcw, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            'Reset',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: context.txtSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.surfAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.brdr, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _viewToggleBtn(
                          icon: LucideIcons.layoutGrid,
                          active: _viewMode == 'grid',
                          onTap: () => setState(() => _viewMode = 'grid'),
                        ),
                        _viewToggleBtn(
                          icon: LucideIcons.list,
                          active: _viewMode == 'list',
                          onTap: () => setState(() => _viewMode = 'list'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _viewToggleBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return BouncyButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? context.surf : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 1)),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? AppColors.primary : context.txtMuted,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Records Layouts (Grid vs List)
  // -------------------------------------------------------------------------

  Widget _buildRecordsList(List<CollegeStudentModel> filtered, double screenWidth) {
    if (_viewMode == 'list') {
      return Column(
        children: [
          for (final s in filtered) ...[
            RepaintBoundary(
              child: _StudentListRow(
                student: s,
                onTap: () => context.push('/college/students/${s.id}'),
                onEdit: () => _showEditStudentSheet(s),
                onDelete: () => _confirmDelete(s),
                onMentor: () => _showAssignMentorSheet(s),
                onMail: () => _showEmailSheet(s),
                screenWidth: screenWidth,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    final isWide = screenWidth >= 640;
    if (!isWide) {
      return Column(
        children: [
          for (final s in filtered) ...[
            RepaintBoundary(
              child: _StudentRecordCard(
                student: s,
                onTap: () => context.push('/college/students/${s.id}'),
                onEdit: () => _showEditStudentSheet(s),
                onDelete: () => _confirmDelete(s),
                onMentor: () => _showAssignMentorSheet(s),
                onMail: () => _showEmailSheet(s),
                initials: _initials(s.name),
                cgpaDot: _cgpaDot(s.cgpa),
                screenWidth: screenWidth,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 320,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (gCtx, i) {
        final s = filtered[i];
        return RepaintBoundary(
          child: _StudentRecordCard(
            student: s,
            onTap: () => context.push('/college/students/${s.id}'),
            onEdit: () => _showEditStudentSheet(s),
            onDelete: () => _confirmDelete(s),
            onMentor: () => _showAssignMentorSheet(s),
            onMail: () => _showEmailSheet(s),
            initials: _initials(s.name),
            cgpaDot: _cgpaDot(s.cgpa),
            screenWidth: screenWidth,
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Loading, Empty, Error, and Toast States
  // -------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/loading_spinner.json', width: 100, height: 100, repeat: true),
          const SizedBox(height: 8),
          Text(
            'Fetching records from MongoDB...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.txtSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCohortState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        children: [
          Lottie.asset('assets/lottie/empty_state.json', width: 140, height: 140, repeat: true),
          const SizedBox(height: 8),
          Text(
            'No Student Records in Database',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your institution has not registered any candidate profiles yet. Tap below to register a student directly into the MongoDB Atlas database.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.txtSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          BouncyButton(
            onPressed: _showAddStudentSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.userPlus, size: 15, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(
                    'Register First Student',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertCircle, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            'No Student Records Found',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No candidate matches the selected department, graduation batch, or min CGPA filter. Try resetting search filters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.txtSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          BouncyButton(
            onPressed: _resetFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Reset All Filters',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDD3), width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.alertCircle, size: 28, color: AppColors.error),
          ),
          const SizedBox(height: 10),
          Text(
            'Connection Issue',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.txtSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          BouncyButton(
            onPressed: () => context.read<StudentDirectoryBloc>().add(const FetchStudentsEvent()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.refreshCw, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Retry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToastNotification(String msg, {required bool isError}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
              size: 16,
              color: isError ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _toastMsg = null),
              child: const Icon(LucideIcons.x, size: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Modal / Dropdown helpers
  // -------------------------------------------------------------------------

  Widget _modalField(
    BuildContext ctx,
    String label,
    String hint,
    TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: ctx.txtPrimary),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: ctx.surfAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ctx.brdr, width: 0.8),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: ctx.txtPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: ctx.txtMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modalDropdown<T>(
    BuildContext ctx, {
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: ctx.txtPrimary),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: ctx.surfAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ctx.brdr, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: ctx.txtPrimary),
              items: items
                  .map((e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(
                          itemLabel != null ? itemLabel(e) : e.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.0,
            fontWeight: FontWeight.w800,
            color: context.txtMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: context.surfAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.brdr, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 13, color: AppColors.textSecondary),
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: context.txtPrimary),
              items: items
                  .map((e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(
                          e.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Student Record Card Component
// ---------------------------------------------------------------------------

class _StudentRecordCard extends StatelessWidget {
  final CollegeStudentModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMentor;
  final VoidCallback onMail;
  final String initials;
  final Color cgpaDot;
  final double screenWidth;

  const _StudentRecordCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMentor,
    required this.onMail,
    required this.initials,
    required this.cgpaDot,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row: Avatar, Name, Roll, Status Badge, Context Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'student-avatar-${student.id}',
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.accentViolet],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                              fontWeight: FontWeight.w700,
                              color: context.txtPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student.displayRollNumber}  ·  ${student.department}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w400,
                              color: context.txtSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(student.placementStatus),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(LucideIcons.moreVertical, size: 16, color: context.txtSecondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: context.surf,
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(LucideIcons.edit, size: 14, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Edit Record', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(fontSize: 12, color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Metrics Row (CGPA & Projects)
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: 'CGPA',
                        value: student.cgpa.toStringAsFixed(2),
                        dotColor: cgpaDot,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        label: 'PROJECTS',
                        value: student.projectsCount < 10 ? '0${student.projectsCount}' : '${student.projectsCount}',
                        tag: student.projectsTag,
                        tagType: student.projectsTagType,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Readiness Score Bar
                _ReadinessScoreBar(score: student.readinessScore),
                const SizedBox(height: 10),

                // Skills Wrap
                _SkillsChipsWrap(skills: student.skills),
                const SizedBox(height: 10),

                // Bottom Action Tier
                if (student.isPlaced) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Hired by: ${student.hiredBy ?? "Top Recruiter"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: BouncyButton(
                          onPressed: onMentor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Assign Mentor',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncyButton(
                        onPressed: onMail,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.surfAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.brdr, width: 0.8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.mail, size: 15, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    final upper = status.toUpperCase();

    if (upper == 'PLACED') {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF059669);
    } else if (upper == 'PENDING') {
      bg = const Color(0xFFFFFBEB);
      text = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        upper,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Student List Row Component
// ---------------------------------------------------------------------------

class _StudentListRow extends StatelessWidget {
  final CollegeStudentModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMentor;
  final VoidCallback onMail;
  final double screenWidth;

  const _StudentListRow({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMentor,
    required this.onMail,
    required this.screenWidth,
  });

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return 'ST';
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return '${p[0][0]}${p[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Hero(
                  tag: 'student-avatar-${student.id}',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(student.name),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                          fontWeight: FontWeight.w700,
                          color: context.txtPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${student.department}  ·  ${student.displayRollNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: context.txtMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${student.cgpa.toStringAsFixed(2)} CGPA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: context.txtPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.readinessScore}% Ready',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: student.readinessScore >= 80 ? AppColors.primary : AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  icon: Icon(LucideIcons.moreVertical, size: 15, color: context.txtMuted),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: context.surf,
                  onSelected: (v) {
                    if (v == 'mentor') onMentor();
                    if (v == 'mail') onMail();
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'mentor',
                      child: Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 13, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Assign Mentor', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'mail',
                      child: Row(
                        children: [
                          Icon(LucideIcons.mail, size: 13, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text('Email Candidate', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.edit, size: 13, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 13, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontSize: 12, color: AppColors.error)),
                        ],
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
}

// ---------------------------------------------------------------------------
// Atomic Metric Box & Progress Bars
// ---------------------------------------------------------------------------

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? dotColor;
  final String? tag;
  final String? tagType;

  const _MetricBox({
    required this.label,
    required this.value,
    this.dotColor,
    this.tag,
    this.tagType,
  });

  @override
  Widget build(BuildContext context) {
    Color tagBg = context.surf;
    Color tagTxt = context.txtSecondary;
    if (tagType == 'success') {
      tagBg = const Color(0xFFECFDF5);
      tagTxt = const Color(0xFF059669);
    } else if (tagType == 'danger') {
      tagBg = const Color(0xFFFEE2E2);
      tagTxt = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              color: context.txtMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (dotColor != null) ...[
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: context.txtPrimary,
                    ),
                  ),
                ],
              ),
              if (tag != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: tagTxt,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadinessScoreBar extends StatelessWidget {
  final int score;
  const _ReadinessScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final Color barColor = score >= 80
        ? AppColors.primary
        : score >= 50
            ? const Color(0xFF4F46E5)
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Readiness Score',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: context.txtSecondary,
              ),
            ),
            Text(
              '$score%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (score.clamp(0, 100)) / 100,
            minHeight: 5,
            backgroundColor: context.surfAlt,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _SkillsChipsWrap extends StatelessWidget {
  final List<String> skills;
  const _SkillsChipsWrap({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.surfAlt,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'No skills added',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.txtMuted),
        ),
      );
    }

    final visible = skills.take(3).toList();
    final remaining = skills.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final sk in visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: context.surfAlt,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              sk,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: context.txtSecondary,
              ),
            ),
          ),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+$remaining more',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryTileData {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color bg;

  const _SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.bg,
  });
}
