import 'package:equatable/equatable.dart';

abstract class AdminPlacementEvent extends Equatable {
  const AdminPlacementEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all initial Placement Oversight data (Metrics, Drives, Events)
class FetchPlacementData extends AdminPlacementEvent {
  final bool isRefresh;

  const FetchPlacementData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Search drives query update
class SearchPlacementDrives extends AdminPlacementEvent {
  final String query;

  const SearchPlacementDrives(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter drives by college, company, type, status, or date
class FilterPlacementDrives extends AdminPlacementEvent {
  final String? college;
  final String? company;
  final String? type;
  final String? status;
  final String? dateQuery;

  const FilterPlacementDrives({
    this.college,
    this.company,
    this.type,
    this.status,
    this.dateQuery,
  });

  @override
  List<Object?> get props => [college, company, type, status, dateQuery];
}

/// Reset all filters to default ('all')
class ResetPlacementFilters extends AdminPlacementEvent {
  const ResetPlacementFilters();
}

/// Change calendar display month
class ChangeCalendarMonth extends AdminPlacementEvent {
  final DateTime month;

  const ChangeCalendarMonth(this.month);

  @override
  List<Object?> get props => [month];
}

/// Create a new placement drive
class CreatePlacementDrive extends AdminPlacementEvent {
  final Map<String, dynamic> driveData;

  const CreatePlacementDrive(this.driveData);

  @override
  List<Object?> get props => [driveData];
}

/// Update an existing placement drive
class UpdatePlacementDrive extends AdminPlacementEvent {
  final String id;
  final Map<String, dynamic> driveData;

  const UpdatePlacementDrive(this.id, this.driveData);

  @override
  List<Object?> get props => [id, driveData];
}

/// Delete a placement drive
class DeletePlacementDrive extends AdminPlacementEvent {
  final String id;

  const DeletePlacementDrive(this.id);

  @override
  List<Object?> get props => [id];
}

/// Export placement overview report to CSV
class ExportPlacementReport extends AdminPlacementEvent {
  const ExportPlacementReport();
}
