import 'package:equatable/equatable.dart';
import '../data/models/admin_placement_models.dart';
import '../data/services/admin_csv_exporter.dart';

abstract class AdminPlacementState extends Equatable {
  const AdminPlacementState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state
class AdminPlacementInitial extends AdminPlacementState {
  const AdminPlacementInitial();
}

/// Loading state (renders Shimmer matching layout)
class AdminPlacementLoading extends AdminPlacementState {
  const AdminPlacementLoading();
}

/// Fully loaded populated state
class AdminPlacementLoaded extends AdminPlacementState {
  final AdminPlacementMetricDto metrics;
  final List<AdminPlacementDriveModel> allDrives;
  final List<AdminPlacementDriveModel> filteredDrives;
  final List<AdminPlacementEventModel> events;
  final AdminPlacementFilterDto filters;
  final DateTime currentMonth;
  final List<String> availableColleges;
  final List<String> availableCompanies;
  final String? actionMessage;
  final bool isExporting;
  final ExportResult? exportResult;

  const AdminPlacementLoaded({
    required this.metrics,
    required this.allDrives,
    required this.filteredDrives,
    required this.events,
    required this.filters,
    required this.currentMonth,
    required this.availableColleges,
    required this.availableCompanies,
    this.actionMessage,
    this.isExporting = false,
    this.exportResult,
  });

  AdminPlacementLoaded copyWith({
    AdminPlacementMetricDto? metrics,
    List<AdminPlacementDriveModel>? allDrives,
    List<AdminPlacementDriveModel>? filteredDrives,
    List<AdminPlacementEventModel>? events,
    AdminPlacementFilterDto? filters,
    DateTime? currentMonth,
    List<String>? availableColleges,
    List<String>? availableCompanies,
    String? actionMessage,
    bool? isExporting,
    ExportResult? exportResult,
    bool clearExportResult = false,
  }) {
    return AdminPlacementLoaded(
      metrics: metrics ?? this.metrics,
      allDrives: allDrives ?? this.allDrives,
      filteredDrives: filteredDrives ?? this.filteredDrives,
      events: events ?? this.events,
      filters: filters ?? this.filters,
      currentMonth: currentMonth ?? this.currentMonth,
      availableColleges: availableColleges ?? this.availableColleges,
      availableCompanies: availableCompanies ?? this.availableCompanies,
      actionMessage: actionMessage,
      isExporting: isExporting ?? this.isExporting,
      exportResult: clearExportResult ? null : (exportResult ?? this.exportResult),
    );
  }

  @override
  List<Object?> get props => [
    metrics,
    allDrives,
    filteredDrives,
    events,
    filters,
    currentMonth,
    availableColleges,
    availableCompanies,
    actionMessage,
    isExporting,
    exportResult,
  ];
}

/// Error state with retry option
class AdminPlacementError extends AdminPlacementState {
  final String message;

  const AdminPlacementError(this.message);

  @override
  List<Object?> get props => [message];
}
