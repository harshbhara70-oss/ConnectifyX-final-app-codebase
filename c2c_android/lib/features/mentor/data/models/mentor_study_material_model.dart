import 'package:equatable/equatable.dart';

/// Single study material document in the Shared Material Library
class MentorStudyMaterialModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final String uploadedAt;
  final String size;
  final String fileUrl;
  final String description;
  final int downloadCount;
  final bool isMock;

  const MentorStudyMaterialModel({
    required this.id,
    required this.title,
    required this.category,
    required this.uploadedAt,
    this.size = '1.5 MB',
    this.fileUrl = '',
    this.description = '',
    this.downloadCount = 0,
    this.isMock = false,
  });

  factory MentorStudyMaterialModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorStudyMaterialModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Study Document',
      category: json['category'] as String? ?? 'PDFs',
      uploadedAt: json['uploadedAt'] as String? ??
          (json['createdAt'] != null
              ? json['createdAt'].toString().split('T')[0]
              : 'Recent'),
      size: json['size'] as String? ?? '1.5 MB',
      fileUrl: json['fileUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'uploadedAt': uploadedAt,
      'size': size,
      'fileUrl': fileUrl,
      'description': description,
      'downloadCount': downloadCount,
    };
  }

  MentorStudyMaterialModel copyWith({
    String? id,
    String? title,
    String? category,
    String? uploadedAt,
    String? size,
    String? fileUrl,
    String? description,
    int? downloadCount,
    bool? isMock,
  }) {
    return MentorStudyMaterialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      size: size ?? this.size,
      fileUrl: fileUrl ?? this.fileUrl,
      description: description ?? this.description,
      downloadCount: downloadCount ?? this.downloadCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        uploadedAt,
        size,
        fileUrl,
        description,
        downloadCount,
        isMock,
      ];
}

/// Aggregated Study Material Library Payload
class MentorStudyMaterialPayload extends Equatable {
  final List<MentorStudyMaterialModel> resources;
  final int totalCount;
  final int categoriesCount;
  final int totalDownloads;
  final bool isMock;

  const MentorStudyMaterialPayload({
    required this.resources,
    required this.totalCount,
    required this.categoriesCount,
    required this.totalDownloads,
    this.isMock = false,
  });

  factory MentorStudyMaterialPayload.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final list = (json['resources'] as List<dynamic>?) ?? [];
    final parsed = list
        .map((e) => MentorStudyMaterialModel.fromJson(e as Map<String, dynamic>, isMock: isMock))
        .toList();

    return MentorStudyMaterialPayload(
      resources: parsed,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? parsed.length,
      categoriesCount: (json['categoriesCount'] as num?)?.toInt() ??
          Set<String>.from(parsed.map((e) => e.category)).length,
      totalDownloads: (json['totalDownloads'] as num?)?.toInt() ??
          parsed.fold(0, (sum, e) => sum + e.downloadCount),
      isMock: isMock,
    );
  }

  MentorStudyMaterialPayload copyWith({
    List<MentorStudyMaterialModel>? resources,
    int? totalCount,
    int? categoriesCount,
    int? totalDownloads,
    bool? isMock,
  }) {
    return MentorStudyMaterialPayload(
      resources: resources ?? this.resources,
      totalCount: totalCount ?? this.totalCount,
      categoriesCount: categoriesCount ?? this.categoriesCount,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        resources,
        totalCount,
        categoriesCount,
        totalDownloads,
        isMock,
      ];
}
