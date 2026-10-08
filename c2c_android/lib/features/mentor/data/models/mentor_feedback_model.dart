import 'package:equatable/equatable.dart';
import 'mentor_overview_model.dart';

/// Single candidate evaluation feedback record
class CandidateFeedbackEntry extends Equatable {
  final String id;
  final String studentName;
  final String college;
  final String branch;
  final String role;
  final String avatar;
  final String avatarBg;
  final int techRating; // 1 - 5
  final int commRating; // 1 - 5
  final int overallScore; // 0 - 100
  final String comments;
  final String timestamp;
  final bool isMock;

  const CandidateFeedbackEntry({
    required this.id,
    required this.studentName,
    required this.college,
    required this.branch,
    required this.role,
    required this.avatar,
    required this.avatarBg,
    required this.techRating,
    required this.commRating,
    required this.overallScore,
    required this.comments,
    required this.timestamp,
    this.isMock = false,
  });

  factory CandidateFeedbackEntry.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    final tech = (json['techRating'] as num?)?.toInt() ?? 4;
    final comm = (json['commRating'] as num?)?.toInt() ?? 4;
    final score = (json['score'] as num?)?.toInt() ?? (((tech * 20) + (comm * 20)) ~/ 2);

    return CandidateFeedbackEntry(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      studentName: json['studentName'] as String? ?? 'Candidate',
      college: json['college'] as String? ?? 'Campus Candidate',
      branch: json['branch'] as String? ?? 'CSE',
      role: json['role'] as String? ?? 'Developer',
      avatar: json['avatar'] as String? ?? 'CC',
      avatarBg: json['avatarBg'] as String? ?? '0xFF6366F1',
      techRating: tech,
      commRating: comm,
      overallScore: score,
      comments: json['notes'] as String? ?? json['comments'] as String? ?? 'Evaluation completed.',
      timestamp: json['timestamp'] as String? ?? json['time'] as String? ?? 'Today',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'college': college,
      'branch': branch,
      'role': role,
      'avatar': avatar,
      'avatarBg': avatarBg,
      'techRating': techRating,
      'commRating': commRating,
      'score': overallScore,
      'comments': comments,
      'timestamp': timestamp,
    };
  }

  CandidateFeedbackEntry copyWith({
    String? id,
    String? studentName,
    String? college,
    String? branch,
    String? role,
    String? avatar,
    String? avatarBg,
    int? techRating,
    int? commRating,
    int? overallScore,
    String? comments,
    String? timestamp,
    bool? isMock,
  }) {
    return CandidateFeedbackEntry(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      avatarBg: avatarBg ?? this.avatarBg,
      techRating: techRating ?? this.techRating,
      commRating: commRating ?? this.commRating,
      overallScore: overallScore ?? this.overallScore,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentName,
        college,
        branch,
        role,
        avatar,
        avatarBg,
        techRating,
        commRating,
        overallScore,
        comments,
        timestamp,
        isMock,
      ];
}

/// Aggregated Feedback screen payload
class MentorFeedbackData extends Equatable {
  final List<MentorStudentModel> students;
  final List<CandidateFeedbackEntry> feedbacks;
  final int totalEvaluationsCount;
  final double averageTechRating;
  final double averageCommRating;
  final int pendingCandidatesCount;
  final bool isMock;

  const MentorFeedbackData({
    required this.students,
    required this.feedbacks,
    required this.totalEvaluationsCount,
    required this.averageTechRating,
    required this.averageCommRating,
    required this.pendingCandidatesCount,
    this.isMock = false,
  });

  MentorFeedbackData copyWith({
    List<MentorStudentModel>? students,
    List<CandidateFeedbackEntry>? feedbacks,
    int? totalEvaluationsCount,
    double? averageTechRating,
    double? averageCommRating,
    int? pendingCandidatesCount,
    bool? isMock,
  }) {
    return MentorFeedbackData(
      students: students ?? this.students,
      feedbacks: feedbacks ?? this.feedbacks,
      totalEvaluationsCount: totalEvaluationsCount ?? this.totalEvaluationsCount,
      averageTechRating: averageTechRating ?? this.averageTechRating,
      averageCommRating: averageCommRating ?? this.averageCommRating,
      pendingCandidatesCount: pendingCandidatesCount ?? this.pendingCandidatesCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        students,
        feedbacks,
        totalEvaluationsCount,
        averageTechRating,
        averageCommRating,
        pendingCandidatesCount,
        isMock,
      ];
}
