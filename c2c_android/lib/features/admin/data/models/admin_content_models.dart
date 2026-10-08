import 'package:equatable/equatable.dart';

/// Represents a single Career Roadmap entity in the Admin Content Hub.
class AdminRoadmapModel extends Equatable {
  final String id;
  final String title;
  final bool starred;
  final String category; // 'Tech' | 'Business' | 'Non-Tech' | 'Design' | etc.
  final String status; // 'Published' | 'Under Review' | 'Draft'
  final String enrollments; // e.g., '4,281' or '--'
  final int completion; // percentage integer 0-100
  final String lastUpdated; // e.g., 'Oct 12, 2024'
  final bool isMock;

  const AdminRoadmapModel({
    required this.id,
    required this.title,
    this.starred = false,
    this.category = 'Tech',
    this.status = 'Draft',
    this.enrollments = '0',
    this.completion = 0,
    required this.lastUpdated,
    this.isMock = false,
  });

  factory AdminRoadmapModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminRoadmapModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Roadmap',
      starred: json['starred'] == true,
      category: json['category']?.toString() ?? 'Tech',
      status: json['status']?.toString() ?? 'Draft',
      enrollments: json['enrollments']?.toString() ?? (json['enrollmentCount']?.toString() ?? '0'),
      completion: (json['completion'] is num)
          ? (json['completion'] as num).toInt()
          : int.tryParse(json['completion']?.toString() ?? '0') ?? 0,
      lastUpdated: json['lastUpdated']?.toString() ?? json['updatedAt']?.toString() ?? 'Just now',
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'starred': starred,
      'category': category,
      'status': status,
      'enrollments': enrollments,
      'completion': completion,
      'lastUpdated': lastUpdated,
      'isMock': isMock,
    };
  }

  AdminRoadmapModel copyWith({
    String? id,
    String? title,
    bool? starred,
    String? category,
    String? status,
    String? enrollments,
    int? completion,
    String? lastUpdated,
    bool? isMock,
  }) {
    return AdminRoadmapModel(
      id: id ?? this.id,
      title: title ?? this.title,
      starred: starred ?? this.starred,
      category: category ?? this.category,
      status: status ?? this.status,
      enrollments: enrollments ?? this.enrollments,
      completion: completion ?? this.completion,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        starred,
        category,
        status,
        enrollments,
        completion,
        lastUpdated,
        isMock,
      ];
}

/// Represents a single Global Resource Library item.
class AdminResourceModel extends Equatable {
  final String id;
  final String title;
  final String category; // 'Tech' | 'Business' | 'Non-Tech' | 'Interview Prep' | 'Cheatsheet'
  final String type; // 'PDF' | 'Video' | 'Code' | 'Document' | 'Link'
  final String url;
  final String description;
  final String fileSize; // e.g., '14.2 MB'
  final String author;
  final String downloads; // e.g., '1,840'
  final String lastUpdated;
  final bool starred;
  final bool isMock;

  const AdminResourceModel({
    required this.id,
    required this.title,
    this.category = 'Tech',
    this.type = 'PDF',
    this.url = '',
    this.description = '',
    this.fileSize = '2.5 MB',
    this.author = 'Campus2Corporate Editorial',
    this.downloads = '0',
    required this.lastUpdated,
    this.starred = false,
    this.isMock = false,
  });

  factory AdminResourceModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminResourceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Resource',
      category: json['category']?.toString() ?? 'Tech',
      type: json['type']?.toString() ?? 'PDF',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '2.5 MB',
      author: json['author']?.toString() ?? 'Campus2Corporate Editorial',
      downloads: json['downloads']?.toString() ?? json['downloadsCount']?.toString() ?? '0',
      lastUpdated: json['lastUpdated']?.toString() ?? json['updatedAt']?.toString() ?? 'Just now',
      starred: json['starred'] == true,
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'type': type,
      'url': url,
      'description': description,
      'fileSize': fileSize,
      'author': author,
      'downloads': downloads,
      'lastUpdated': lastUpdated,
      'starred': starred,
      'isMock': isMock,
    };
  }

  AdminResourceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? type,
    String? url,
    String? description,
    String? fileSize,
    String? author,
    String? downloads,
    String? lastUpdated,
    bool? starred,
    bool? isMock,
  }) {
    return AdminResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      url: url ?? this.url,
      description: description ?? this.description,
      fileSize: fileSize ?? this.fileSize,
      author: author ?? this.author,
      downloads: downloads ?? this.downloads,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      starred: starred ?? this.starred,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        type,
        url,
        description,
        fileSize,
        author,
        downloads,
        lastUpdated,
        starred,
        isMock,
      ];
}

/// Helper extension for String title case formatting
extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
