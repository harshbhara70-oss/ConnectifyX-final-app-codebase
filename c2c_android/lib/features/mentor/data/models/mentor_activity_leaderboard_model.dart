import 'package:equatable/equatable.dart';

/// Single item in the Mentor Recent Activity Ticker Feed
class MentorActivityModel extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool done;
  final String createdAt;
  final bool isMock;

  const MentorActivityModel({
    required this.id,
    required this.text,
    required this.time,
    this.done = false,
    this.createdAt = '',
    this.isMock = false,
  });

  factory MentorActivityModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorActivityModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      text: json['text'] as String? ?? 'Activity logged',
      time: json['time'] as String? ?? 'Just now',
      done: json['done'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'time': time,
      'done': done,
      'createdAt': createdAt,
    };
  }

  MentorActivityModel copyWith({
    String? id,
    String? text,
    String? time,
    bool? done,
    String? createdAt,
    bool? isMock,
  }) {
    return MentorActivityModel(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, text, time, done, createdAt, isMock];
}

/// Single candidate entry on the High-Achiever Leaderboard Matrix
class MentorLeaderboardCandidateModel extends Equatable {
  final String id;
  final String rank;
  final String name;
  final String fit;
  final int score;
  final String college;
  final String branch;
  final List<String> skills;
  final String gapAreas;
  final String avatarBg;
  final String createdAt;
  final bool isMock;

  const MentorLeaderboardCandidateModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.fit,
    required this.score,
    this.college = 'Campus Candidate',
    this.branch = 'CSE',
    this.skills = const [],
    this.gapAreas = 'System Architecture Tuning',
    this.avatarBg = '#6366F1',
    this.createdAt = '',
    this.isMock = false,
  });

  factory MentorLeaderboardCandidateModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final skillsList = json['skills'];
    List<String> parsedSkills = [];
    if (skillsList is List) {
      parsedSkills = skillsList.map((e) => e.toString()).toList();
    }

    return MentorLeaderboardCandidateModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      rank: json['rank'] as String? ?? 'Rank 1',
      name: json['name'] as String? ?? json['studentName'] as String? ?? 'Candidate',
      fit: json['fit'] as String? ?? 'Tech Fit',
      score: (json['score'] as num?)?.toInt() ?? 0,
      college: json['college'] as String? ?? 'Campus Candidate',
      branch: json['branch'] as String? ?? 'CSE',
      skills: parsedSkills.isNotEmpty ? parsedSkills : const ['Java', 'DSA', 'React', 'Problem Solving'],
      gapAreas: json['gapAreas'] as String? ?? json['notes'] as String? ?? 'System Architecture Tuning',
      avatarBg: json['avatarBg'] as String? ?? '#6366F1',
      createdAt: json['createdAt'] as String? ?? '',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank': rank,
      'studentName': name,
      'fit': fit,
      'score': score,
      'college': college,
      'branch': branch,
      'skills': skills,
      'gapAreas': gapAreas,
      'avatarBg': avatarBg,
      'createdAt': createdAt,
    };
  }

  MentorLeaderboardCandidateModel copyWith({
    String? id,
    String? rank,
    String? name,
    String? fit,
    int? score,
    String? college,
    String? branch,
    List<String>? skills,
    String? gapAreas,
    String? avatarBg,
    String? createdAt,
    bool? isMock,
  }) {
    return MentorLeaderboardCandidateModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      fit: fit ?? this.fit,
      score: score ?? this.score,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      skills: skills ?? this.skills,
      gapAreas: gapAreas ?? this.gapAreas,
      avatarBg: avatarBg ?? this.avatarBg,
      createdAt: createdAt ?? this.createdAt,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rank,
        name,
        fit,
        score,
        college,
        branch,
        skills,
        gapAreas,
        avatarBg,
        createdAt,
        isMock,
      ];
}

/// Aggregated data payload for Activity & Leaderboard Screen
class MentorActivityLeaderboardData extends Equatable {
  final int totalActivities;
  final int completedActivities;
  final int averageScore;
  final String topCandidate;
  final List<MentorActivityModel> activityTicker;
  final List<MentorLeaderboardCandidateModel> leaderboard;
  final bool isMock;

  const MentorActivityLeaderboardData({
    required this.totalActivities,
    required this.completedActivities,
    required this.averageScore,
    required this.topCandidate,
    required this.activityTicker,
    required this.leaderboard,
    this.isMock = false,
  });

  factory MentorActivityLeaderboardData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final activitiesJson = (json['activityTicker'] as List<dynamic>?) ?? [];
    final leaderboardJson = (json['leaderboard'] as List<dynamic>?) ?? [];

    return MentorActivityLeaderboardData(
      totalActivities: (json['totalActivities'] as num?)?.toInt() ?? activitiesJson.length,
      completedActivities: (json['completedActivities'] as num?)?.toInt() ??
          activitiesJson.where((e) => e['done'] == true).length,
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 0,
      topCandidate: json['topCandidate'] as String? ?? 'N/A',
      activityTicker: activitiesJson
          .map((e) => MentorActivityModel.fromJson(e as Map<String, dynamic>, isMock: isMock))
          .toList(),
      leaderboard: leaderboardJson
          .map((e) => MentorLeaderboardCandidateModel.fromJson(e as Map<String, dynamic>, isMock: isMock))
          .toList(),
      isMock: isMock,
    );
  }

  MentorActivityLeaderboardData copyWith({
    int? totalActivities,
    int? completedActivities,
    int? averageScore,
    String? topCandidate,
    List<MentorActivityModel>? activityTicker,
    List<MentorLeaderboardCandidateModel>? leaderboard,
    bool? isMock,
  }) {
    return MentorActivityLeaderboardData(
      totalActivities: totalActivities ?? this.totalActivities,
      completedActivities: completedActivities ?? this.completedActivities,
      averageScore: averageScore ?? this.averageScore,
      topCandidate: topCandidate ?? this.topCandidate,
      activityTicker: activityTicker ?? this.activityTicker,
      leaderboard: leaderboard ?? this.leaderboard,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        totalActivities,
        completedActivities,
        averageScore,
        topCandidate,
        activityTicker,
        leaderboard,
        isMock,
      ];
}
