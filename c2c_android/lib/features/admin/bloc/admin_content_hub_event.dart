import 'package:equatable/equatable.dart';
import '../data/models/admin_content_models.dart';

abstract class AdminContentHubEvent extends Equatable {
  const AdminContentHubEvent();

  @override
  List<Object?> get props => [];
}

/// Initial or Pull-to-refresh fetch event
class FetchContentHubData extends AdminContentHubEvent {
  final bool isRefresh;
  const FetchContentHubData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Tab switcher: Roadmaps vs Resource Library
enum ContentHubTab { roadmaps, resources }

class SelectContentTab extends AdminContentHubEvent {
  final ContentHubTab tab;
  const SelectContentTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Filter events for Roadmaps
class UpdateRoadmapCategoryFilter extends AdminContentHubEvent {
  final String category;
  const UpdateRoadmapCategoryFilter(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateRoadmapStatusFilter extends AdminContentHubEvent {
  final String status;
  const UpdateRoadmapStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter events for Resource Library
class UpdateResourceCategoryFilter extends AdminContentHubEvent {
  final String category;
  const UpdateResourceCategoryFilter(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateResourceTypeFilter extends AdminContentHubEvent {
  final String type;
  const UpdateResourceTypeFilter(this.type);

  @override
  List<Object?> get props => [type];
}

/// Global Search filter
class UpdateContentSearchQuery extends AdminContentHubEvent {
  final String query;
  const UpdateContentSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

/// Roadmap item actions
class ToggleRoadmapStarAction extends AdminContentHubEvent {
  final String roadmapId;
  const ToggleRoadmapStarAction(this.roadmapId);

  @override
  List<Object?> get props => [roadmapId];
}

class CreateRoadmapAction extends AdminContentHubEvent {
  final String title;
  final String category;
  final String status;

  const CreateRoadmapAction({
    required this.title,
    required this.category,
    this.status = 'Draft',
  });

  @override
  List<Object?> get props => [title, category, status];
}

class UpdateRoadmapAction extends AdminContentHubEvent {
  final AdminRoadmapModel roadmap;
  const UpdateRoadmapAction(this.roadmap);

  @override
  List<Object?> get props => [roadmap];
}

class DeleteRoadmapAction extends AdminContentHubEvent {
  final String roadmapId;
  const DeleteRoadmapAction(this.roadmapId);

  @override
  List<Object?> get props => [roadmapId];
}

/// Resource item actions
class CreateResourceAction extends AdminContentHubEvent {
  final String title;
  final String category;
  final String type;
  final String description;
  final String url;
  final String fileSize;

  const CreateResourceAction({
    required this.title,
    required this.category,
    required this.type,
    this.description = '',
    this.url = '',
    this.fileSize = '2.5 MB',
  });

  @override
  List<Object?> get props => [title, category, type, description, url, fileSize];
}

class DeleteResourceAction extends AdminContentHubEvent {
  final String resourceId;
  const DeleteResourceAction(this.resourceId);

  @override
  List<Object?> get props => [resourceId];
}

class ToggleResourceStarAction extends AdminContentHubEvent {
  final String resourceId;
  const ToggleResourceStarAction(this.resourceId);

  @override
  List<Object?> get props => [resourceId];
}

/// Multi-select and pagination
class ToggleSelectRoadmapItem extends AdminContentHubEvent {
  final String roadmapId;
  const ToggleSelectRoadmapItem(this.roadmapId);

  @override
  List<Object?> get props => [roadmapId];
}

class ToggleSelectAllRoadmaps extends AdminContentHubEvent {
  const ToggleSelectAllRoadmaps();
}

class ChangeContentPage extends AdminContentHubEvent {
  final int page;
  const ChangeContentPage(this.page);

  @override
  List<Object?> get props => [page];
}
