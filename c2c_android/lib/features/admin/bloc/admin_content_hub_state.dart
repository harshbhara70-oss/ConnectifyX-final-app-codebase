import 'package:equatable/equatable.dart';
import '../data/models/admin_content_models.dart';
import 'admin_content_hub_event.dart';

enum ContentHubStatus { initial, loading, loaded, failure }

class AdminContentHubState extends Equatable {
  final ContentHubStatus status;
  final ContentHubTab activeTab;
  final List<AdminRoadmapModel> roadmaps;
  final List<AdminResourceModel> resources;
  final String roadmapCategoryFilter; // 'All Categories', 'Tech', 'Business', 'Non-Tech'
  final String roadmapStatusFilter; // 'Status: All', 'Published', 'Under Review', 'Draft'
  final String resourceCategoryFilter; // 'All Categories', 'Tech', 'Business', 'Non-Tech'
  final String resourceTypeFilter; // 'All Types', 'PDF', 'Video', 'Code', 'Document'
  final String searchQuery;
  final int currentPage;
  final int itemsPerPage;
  final Set<String> selectedRoadmapIds;
  final bool isMock;
  final String? errorMessage;
  final String? actionMessage;

  const AdminContentHubState({
    this.status = ContentHubStatus.initial,
    this.activeTab = ContentHubTab.roadmaps,
    this.roadmaps = const [],
    this.resources = const [],
    this.roadmapCategoryFilter = 'All Categories',
    this.roadmapStatusFilter = 'Status: All',
    this.resourceCategoryFilter = 'All Categories',
    this.resourceTypeFilter = 'All Types',
    this.searchQuery = '',
    this.currentPage = 1,
    this.itemsPerPage = 6,
    this.selectedRoadmapIds = const {},
    this.isMock = false,
    this.errorMessage,
    this.actionMessage,
  });

  /// Filtered roadmaps according to category, status, and search query
  List<AdminRoadmapModel> get filteredRoadmaps {
    return roadmaps.where((rm) {
      // Category filter
      if (roadmapCategoryFilter != 'All Categories' &&
          rm.category.toLowerCase() != roadmapCategoryFilter.toLowerCase()) {
        return false;
      }
      // Status filter
      if (roadmapStatusFilter != 'Status: All' &&
          rm.status.toLowerCase() != roadmapStatusFilter.toLowerCase()) {
        return false;
      }
      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = rm.title.toLowerCase().contains(q);
        final matchCategory = rm.category.toLowerCase().contains(q);
        final matchStatus = rm.status.toLowerCase().contains(q);
        if (!matchTitle && !matchCategory && !matchStatus) return false;
      }
      return true;
    }).toList();
  }

  /// Paginated roadmaps
  List<AdminRoadmapModel> get paginatedRoadmaps {
    final list = filteredRoadmaps;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = (startIndex + itemsPerPage).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  int get totalRoadmapPages {
    final count = filteredRoadmaps.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  /// Filtered resources according to category, type, and search query
  List<AdminResourceModel> get filteredResources {
    return resources.where((res) {
      // Category filter
      if (resourceCategoryFilter != 'All Categories' &&
          res.category.toLowerCase() != resourceCategoryFilter.toLowerCase()) {
        return false;
      }
      // Type filter
      if (resourceTypeFilter != 'All Types' &&
          res.type.toLowerCase() != resourceTypeFilter.toLowerCase()) {
        return false;
      }
      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = res.title.toLowerCase().contains(q);
        final matchDesc = res.description.toLowerCase().contains(q);
        final matchCat = res.category.toLowerCase().contains(q);
        final matchType = res.type.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc && !matchCat && !matchType) return false;
      }
      return true;
    }).toList();
  }

  /// Paginated resources
  List<AdminResourceModel> get paginatedResources {
    final list = filteredResources;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = (startIndex + itemsPerPage).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  int get totalResourcePages {
    final count = filteredResources.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  /// Metric Stats
  int get totalRoadmapsCount => roadmaps.length;
  int get publishedRoadmapsCount => roadmaps.where((r) => r.status.toLowerCase() == 'published').length;
  int get underReviewCount => roadmaps.where((r) => r.status.toLowerCase() == 'under review').length;
  int get totalResourcesCount => resources.length;

  AdminContentHubState copyWith({
    ContentHubStatus? status,
    ContentHubTab? activeTab,
    List<AdminRoadmapModel>? roadmaps,
    List<AdminResourceModel>? resources,
    String? roadmapCategoryFilter,
    String? roadmapStatusFilter,
    String? resourceCategoryFilter,
    String? resourceTypeFilter,
    String? searchQuery,
    int? currentPage,
    int? itemsPerPage,
    Set<String>? selectedRoadmapIds,
    bool? isMock,
    String? errorMessage,
    String? actionMessage,
  }) {
    return AdminContentHubState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      roadmaps: roadmaps ?? this.roadmaps,
      resources: resources ?? this.resources,
      roadmapCategoryFilter: roadmapCategoryFilter ?? this.roadmapCategoryFilter,
      roadmapStatusFilter: roadmapStatusFilter ?? this.roadmapStatusFilter,
      resourceCategoryFilter: resourceCategoryFilter ?? this.resourceCategoryFilter,
      resourceTypeFilter: resourceTypeFilter ?? this.resourceTypeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      selectedRoadmapIds: selectedRoadmapIds ?? this.selectedRoadmapIds,
      isMock: isMock ?? this.isMock,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        roadmaps,
        resources,
        roadmapCategoryFilter,
        roadmapStatusFilter,
        resourceCategoryFilter,
        resourceTypeFilter,
        searchQuery,
        currentPage,
        itemsPerPage,
        selectedRoadmapIds,
        isMock,
        errorMessage,
        actionMessage,
      ];
}
