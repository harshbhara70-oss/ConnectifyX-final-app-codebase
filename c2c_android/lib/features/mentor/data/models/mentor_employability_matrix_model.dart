import 'package:equatable/equatable.dart';

/// Top-level Mentor Employability Matrix Dataset matching MentorDashboard.tsx Tab 4 & 5
class MentorEmployabilityMatrixData extends Equatable {
  final int overallEmployabilityIndex;
  final int totalMenteesEvaluated;
  final int eliteReadyCount;
  final int criticalGapsCount;
  final List<MentorEmployabilityVector> vectors;
  final List<MentorSkillGapBar> skillGapBars;
  final List<MentorLeaderboardEntry> leaderboard;
  final List<MentorActivityTickerItem> activityTicker;
  final bool isMock;

  const MentorEmployabilityMatrixData({
    required this.overallEmployabilityIndex,
    required this.totalMenteesEvaluated,
    required this.eliteReadyCount,
    required this.criticalGapsCount,
    required this.vectors,
    required this.skillGapBars,
    required this.leaderboard,
    required this.activityTicker,
    this.isMock = false,
  });

  factory MentorEmployabilityMatrixData.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorEmployabilityMatrixData(
      overallEmployabilityIndex: json['overallEmployabilityIndex'] is num
          ? (json['overallEmployabilityIndex'] as num).toInt()
          : 86,
      totalMenteesEvaluated: json['totalMenteesEvaluated'] is num
          ? (json['totalMenteesEvaluated'] as num).toInt()
          : 12,
      eliteReadyCount: json['eliteReadyCount'] is num
          ? (json['eliteReadyCount'] as num).toInt()
          : 5,
      criticalGapsCount: json['criticalGapsCount'] is num
          ? (json['criticalGapsCount'] as num).toInt()
          : 2,
      vectors: (json['vectors'] as List<dynamic>?)
              ?.map((e) => MentorEmployabilityVector.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      skillGapBars: (json['skillGapBars'] as List<dynamic>?)
              ?.map((e) => MentorSkillGapBar.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => MentorLeaderboardEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      activityTicker: (json['activityTicker'] as List<dynamic>?)
              ?.map((e) => MentorActivityTickerItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'overallEmployabilityIndex': overallEmployabilityIndex,
        'totalMenteesEvaluated': totalMenteesEvaluated,
        'eliteReadyCount': eliteReadyCount,
        'criticalGapsCount': criticalGapsCount,
        'vectors': vectors.map((e) => e.toJson()).toList(),
        'skillGapBars': skillGapBars.map((e) => e.toJson()).toList(),
        'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
        'activityTicker': activityTicker.map((e) => e.toJson()).toList(),
        'isMock': isMock,
      };

  MentorEmployabilityMatrixData copyWith({
    int? overallEmployabilityIndex,
    int? totalMenteesEvaluated,
    int? eliteReadyCount,
    int? criticalGapsCount,
    List<MentorEmployabilityVector>? vectors,
    List<MentorSkillGapBar>? skillGapBars,
    List<MentorLeaderboardEntry>? leaderboard,
    List<MentorActivityTickerItem>? activityTicker,
    bool? isMock,
  }) {
    return MentorEmployabilityMatrixData(
      overallEmployabilityIndex:
          overallEmployabilityIndex ?? this.overallEmployabilityIndex,
      totalMenteesEvaluated:
          totalMenteesEvaluated ?? this.totalMenteesEvaluated,
      eliteReadyCount: eliteReadyCount ?? this.eliteReadyCount,
      criticalGapsCount: criticalGapsCount ?? this.criticalGapsCount,
      vectors: vectors ?? this.vectors,
      skillGapBars: skillGapBars ?? this.skillGapBars,
      leaderboard: leaderboard ?? this.leaderboard,
      activityTicker: activityTicker ?? this.activityTicker,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        overallEmployabilityIndex,
        totalMenteesEvaluated,
        eliteReadyCount,
        criticalGapsCount,
        vectors,
        skillGapBars,
        leaderboard,
        activityTicker,
        isMock,
      ];
}

/// Dimensional vector for scorecard
class MentorEmployabilityVector extends Equatable {
  final String label;
  final int val;
  final int total;

  const MentorEmployabilityVector({
    required this.label,
    required this.val,
    this.total = 100,
  });

  factory MentorEmployabilityVector.fromJson(Map<String, dynamic> json) {
    return MentorEmployabilityVector(
      label: json['label']?.toString() ?? '',
      val: json['val'] is num ? (json['val'] as num).toInt() : 80,
      total: json['total'] is num ? (json['total'] as num).toInt() : 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'val': val,
        'total': total,
      };

  @override
  List<Object?> get props => [label, val, total];
}

/// Skill Gap Bar Model (Matching MentorDashboard.tsx Live Skill Bar Chart)
class MentorSkillGapBar extends Equatable {
  final String name;
  final int val;
  final String colorHex;

  const MentorSkillGapBar({
    required this.name,
    required this.val,
    required this.colorHex,
  });

  factory MentorSkillGapBar.fromJson(Map<String, dynamic> json) {
    return MentorSkillGapBar(
      name: json['name']?.toString() ?? '',
      val: json['val'] is num ? (json['val'] as num).toInt() : 75,
      colorHex: json['colorHex']?.toString() ?? '#3B82F6',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'val': val,
        'colorHex': colorHex,
      };

  @override
  List<Object?> get props => [name, val, colorHex];
}

/// High-Achiever Leaderboard Matrix Entry (Matching MentorDashboard.tsx Tab 5)
class MentorLeaderboardEntry extends Equatable {
  final String rank;
  final String name;
  final String fit;
  final int score;
  final String college;
  final String branch;
  final List<String> skills;
  final String gapAreas;
  final String avatarBg;

  const MentorLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.fit,
    required this.score,
    required this.college,
    required this.branch,
    required this.skills,
    required this.gapAreas,
    required this.avatarBg,
  });

  factory MentorLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return MentorLeaderboardEntry(
      rank: json['rank']?.toString() ?? 'Rank 1',
      name: json['name']?.toString() ?? 'Student',
      fit: json['fit']?.toString() ?? 'Stripe (React)',
      score: json['score'] is num ? (json['score'] as num).toInt() : 90,
      college: json['college']?.toString() ?? 'IIT Delhi',
      branch: json['branch']?.toString() ?? 'CSE',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Java', 'DSA', 'React'],
      gapAreas: json['gapAreas']?.toString() ?? 'Advanced Microservices Design',
      avatarBg: json['avatarBg']?.toString() ?? '#6366F1',
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'name': name,
        'fit': fit,
        'score': score,
        'college': college,
        'branch': branch,
        'skills': skills,
        'gapAreas': gapAreas,
        'avatarBg': avatarBg,
      };

  @override
  List<Object?> get props => [
        rank,
        name,
        fit,
        score,
        college,
        branch,
        skills,
        gapAreas,
        avatarBg,
      ];
}

/// Recent Activity Ticker Item with Checkbox State (Matching MentorDashboard.tsx Tab 5)
class MentorActivityTickerItem extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool done;

  const MentorActivityTickerItem({
    required this.id,
    required this.text,
    required this.time,
    required this.done,
  });

  factory MentorActivityTickerItem.fromJson(Map<String, dynamic> json) {
    return MentorActivityTickerItem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Just now',
      done: json['done'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'time': time,
        'done': done,
      };

  MentorActivityTickerItem copyWith({
    String? id,
    String? text,
    String? time,
    bool? done,
  }) {
    return MentorActivityTickerItem(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [id, text, time, done];
}
