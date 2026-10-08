import 'dart:math';
import 'package:equatable/equatable.dart';
import '../data/models/admin_user_models.dart';
import '../data/services/admin_csv_exporter.dart';

enum AdminUserStatus { initial, loading, loaded, failure }

class AdminUserManagementState extends Equatable {
  final AdminUserStatus status;
  final UserRoleTab activeTab;
  final List<AdminStudentModel> students;
  final List<AdminCollegeModel> colleges;
  final List<AdminRecruiterModel> recruiters;
  final String searchQuery;
  final String selectedCollegeFilter;
  final String selectedYearFilter;
  final String selectedStatusFilter;
  final Set<String> selectedUserIds;
  final int currentPage;
  final int itemsPerPage;
  final bool isMock;
  final ExportResult? lastExportResult;
  final String? feedbackMessage;
  final String? errorMessage;

  const AdminUserManagementState({
    this.status = AdminUserStatus.initial,
    this.activeTab = UserRoleTab.students,
    this.students = const [],
    this.colleges = const [],
    this.recruiters = const [],
    this.searchQuery = '',
    this.selectedCollegeFilter = 'all',
    this.selectedYearFilter = 'all',
    this.selectedStatusFilter = 'all',
    this.selectedUserIds = const {},
    this.currentPage = 1,
    this.itemsPerPage = 6,
    this.isMock = false,
    this.lastExportResult,
    this.feedbackMessage,
    this.errorMessage,
  });

  AdminUserManagementState copyWith({
    AdminUserStatus? status,
    UserRoleTab? activeTab,
    List<AdminStudentModel>? students,
    List<AdminCollegeModel>? colleges,
    List<AdminRecruiterModel>? recruiters,
    String? searchQuery,
    String? selectedCollegeFilter,
    String? selectedYearFilter,
    String? selectedStatusFilter,
    Set<String>? selectedUserIds,
    int? currentPage,
    int? itemsPerPage,
    bool? isMock,
    ExportResult? lastExportResult,
    String? feedbackMessage,
    String? errorMessage,
  }) {
    return AdminUserManagementState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      students: students ?? this.students,
      colleges: colleges ?? this.colleges,
      recruiters: recruiters ?? this.recruiters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCollegeFilter: selectedCollegeFilter ?? this.selectedCollegeFilter,
      selectedYearFilter: selectedYearFilter ?? this.selectedYearFilter,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      isMock: isMock ?? this.isMock,
      lastExportResult: lastExportResult ?? this.lastExportResult,
      feedbackMessage: feedbackMessage,
      errorMessage: errorMessage,
    );
  }

  // --- Unique College List for Filter Dropdown ---
  List<String> get availableColleges {
    final set = <String>{};
    for (final s in students) {
      if (s.college.trim().isNotEmpty) set.add(s.college.trim());
    }
    for (final c in colleges) {
      if (c.name.trim().isNotEmpty) set.add(c.name.trim());
    }
    return set.toList()..sort();
  }

  // --- Filtered Students ---
  List<AdminStudentModel> get filteredStudents {
    return students.where((s) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = s.name.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.college.toLowerCase().contains(q) ||
            s.branch.toLowerCase().contains(q);
        if (!match) return false;
      }

      // 2. College Filter
      if (selectedCollegeFilter != 'all') {
        if (s.college.toLowerCase() != selectedCollegeFilter.toLowerCase()) {
          return false;
        }
      }

      // 3. Status Filter
      if (selectedStatusFilter != 'all') {
        if (s.activeStatus.toLowerCase() != selectedStatusFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // --- Filtered Colleges ---
  List<AdminCollegeModel> get filteredColleges {
    return colleges.where((c) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.university.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q);
        if (!match) return false;
      }

      // 2. Status Filter
      if (selectedStatusFilter != 'all') {
        if (c.status.toLowerCase() != selectedStatusFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // --- Filtered Recruiters ---
  List<AdminRecruiterModel> get filteredRecruiters {
    return recruiters.where((r) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = r.name.toLowerCase().contains(q) ||
            r.email.toLowerCase().contains(q) ||
            r.company.toLowerCase().contains(q) ||
            r.designation.toLowerCase().contains(q);
        if (!match) return false;
      }

      // 2. Status Filter
      if (selectedStatusFilter != 'all') {
        if (r.status.toLowerCase() != selectedStatusFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // --- Active Total Count ---
  int get activeTotalCount {
    switch (activeTab) {
      case UserRoleTab.students:
        return filteredStudents.length;
      case UserRoleTab.colleges:
        return filteredColleges.length;
      case UserRoleTab.recruiters:
        return filteredRecruiters.length;
    }
  }

  // --- Total Pages ---
  int get totalPages {
    final count = activeTotalCount;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  // --- Paginated Active Items ---
  List<AdminStudentModel> get paginatedStudents {
    final list = filteredStudents;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = min(startIndex + itemsPerPage, list.length);
    return list.sublist(startIndex, endIndex);
  }

  List<AdminCollegeModel> get paginatedColleges {
    final list = filteredColleges;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = min(startIndex + itemsPerPage, list.length);
    return list.sublist(startIndex, endIndex);
  }

  List<AdminRecruiterModel> get paginatedRecruiters {
    final list = filteredRecruiters;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = min(startIndex + itemsPerPage, list.length);
    return list.sublist(startIndex, endIndex);
  }

  // --- Placed Students Counter ---
  int get placedStudentsCount {
    return students.where((s) => s.placementStatus.toLowerCase() == 'placed').length;
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        students,
        colleges,
        recruiters,
        searchQuery,
        selectedCollegeFilter,
        selectedYearFilter,
        selectedStatusFilter,
        selectedUserIds,
        currentPage,
        itemsPerPage,
        isMock,
        lastExportResult,
        feedbackMessage,
        errorMessage,
      ];
}
