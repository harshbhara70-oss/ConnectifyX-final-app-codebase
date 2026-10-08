import 'package:equatable/equatable.dart';

/// Milestone item for a mentee's career progress
class MilestoneModel extends Equatable {
  final String name;
  final String status; // 'done', 'progress', 'pending'

  const MilestoneModel({
    required this.name,
    required this.status,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
      };

  @override
  List<Object?> get props => [name, status];
}

/// Student record matching web Student model
class MentorStudentModel extends Equatable {
  final String id;
  final String name;
  final String college;
  final String branch;
  final String semester;
  final String gpa;
  final String role;
  final String company;
  final int progress;
  final int matchScore;
  final int resumeScore;
  final int aptitudeScore;
  final int techSkillRating;
  final int softSkillRating;
  final int communicationRating;
  final String avatar;
  final String avatarBg;
  final String email;
  final String phone;
  final List<String> notes;
  final List<String> skills;
  final int attendance;
  final List<MilestoneModel> milestones;
  final String pipelineStage; // 'Enrolled' | 'Skill Assessment' | 'Learning Path' | 'Mentorship' | 'Mock Interview' | 'Placement Ready' | 'Hired'
  final bool isMock;

  const MentorStudentModel({
    required this.id,
    required this.name,
    required this.college,
    required this.branch,
    required this.semester,
    required this.gpa,
    required this.role,
    required this.company,
    required this.progress,
    required this.matchScore,
    required this.resumeScore,
    required this.aptitudeScore,
    required this.techSkillRating,
    required this.softSkillRating,
    required this.communicationRating,
    required this.avatar,
    required this.avatarBg,
    required this.email,
    required this.phone,
    required this.notes,
    required this.skills,
    required this.attendance,
    required this.milestones,
    required this.pipelineStage,
    this.isMock = false,
  });

  factory MentorStudentModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorStudentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? json['fullName'] as String? ?? 'Student',
      college: json['college'] as String? ?? json['collegeName'] as String? ?? 'DTU Delhi',
      branch: json['branch'] as String? ?? json['department'] as String? ?? 'Computer Science',
      semester: json['semester'] as String? ?? '8th Semester',
      gpa: (json['gpa'] ?? json['cgpa'] ?? '8.5').toString(),
      role: json['role'] as String? ?? 'Software Engineer',
      company: json['company'] as String? ?? 'Stripe',
      progress: (json['progress'] as num?)?.toInt() ?? 75,
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 90,
      resumeScore: (json['resumeScore'] as num?)?.toInt() ?? 88,
      aptitudeScore: (json['aptitudeScore'] as num?)?.toInt() ?? 85,
      techSkillRating: (json['techSkillRating'] as num?)?.toInt() ?? 85,
      softSkillRating: (json['softSkillRating'] as num?)?.toInt() ?? 80,
      communicationRating: (json['communicationRating'] as num?)?.toInt() ?? 85,
      avatar: json['avatar'] as String? ?? _getInitials(json['name'] ?? 'ST'),
      avatarBg: json['avatarBg'] as String? ?? '0xFF6366F1',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      attendance: (json['attendance'] as num?)?.toInt() ?? 90,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => MilestoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pipelineStage: json['pipelineStage'] as String? ?? 'Mentorship',
      isMock: isMock,
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'ST';
  }

  MentorStudentModel copyWith({
    String? id,
    String? name,
    String? college,
    String? branch,
    String? semester,
    String? gpa,
    String? role,
    String? company,
    int? progress,
    int? matchScore,
    int? resumeScore,
    int? aptitudeScore,
    int? techSkillRating,
    int? softSkillRating,
    int? communicationRating,
    String? avatar,
    String? avatarBg,
    String? email,
    String? phone,
    List<String>? notes,
    List<String>? skills,
    int? attendance,
    List<MilestoneModel>? milestones,
    String? pipelineStage,
    bool? isMock,
  }) {
    return MentorStudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      gpa: gpa ?? this.gpa,
      role: role ?? this.role,
      company: company ?? this.company,
      progress: progress ?? this.progress,
      matchScore: matchScore ?? this.matchScore,
      resumeScore: resumeScore ?? this.resumeScore,
      aptitudeScore: aptitudeScore ?? this.aptitudeScore,
      techSkillRating: techSkillRating ?? this.techSkillRating,
      softSkillRating: softSkillRating ?? this.softSkillRating,
      communicationRating: communicationRating ?? this.communicationRating,
      avatar: avatar ?? this.avatar,
      avatarBg: avatarBg ?? this.avatarBg,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      skills: skills ?? this.skills,
      attendance: attendance ?? this.attendance,
      milestones: milestones ?? this.milestones,
      pipelineStage: pipelineStage ?? this.pipelineStage,
      isMock: isMock ?? this.isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'college': college,
        'branch': branch,
        'semester': semester,
        'gpa': gpa,
        'role': role,
        'company': company,
        'progress': progress,
        'matchScore': matchScore,
        'resumeScore': resumeScore,
        'aptitudeScore': aptitudeScore,
        'techSkillRating': techSkillRating,
        'softSkillRating': softSkillRating,
        'communicationRating': communicationRating,
        'avatar': avatar,
        'avatarBg': avatarBg,
        'email': email,
        'phone': phone,
        'notes': notes,
        'skills': skills,
        'attendance': attendance,
        'milestones': milestones.map((m) => m.toJson()).toList(),
        'pipelineStage': pipelineStage,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        college,
        branch,
        semester,
        gpa,
        role,
        company,
        progress,
        matchScore,
        resumeScore,
        aptitudeScore,
        techSkillRating,
        softSkillRating,
        communicationRating,
        avatar,
        avatarBg,
        email,
        phone,
        notes,
        skills,
        attendance,
        milestones,
        pipelineStage,
        isMock,
      ];
}

/// Mentorship Session slot
class MentorSessionModel extends Equatable {
  final String id;
  final String studentName;
  final String type;
  final String time;
  final String date;
  final String day;
  final String meetingLink;
  final bool isMock;

  const MentorSessionModel({
    required this.id,
    required this.studentName,
    required this.type,
    required this.time,
    required this.date,
    required this.day,
    this.meetingLink = 'https://teams.microsoft.com/mock-link',
    this.isMock = false,
  });

  factory MentorSessionModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorSessionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      studentName: json['studentName'] as String? ?? 'Student',
      type: json['type'] as String? ?? 'Resume Review',
      time: json['time'] as String? ?? '10:00 AM - 11:00 AM',
      date: json['date'] as String? ?? 'Today',
      day: json['day'] as String? ?? 'Mon',
      meetingLink: json['meetingLink'] as String? ?? 'https://teams.microsoft.com/mock-link',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentName': studentName,
        'type': type,
        'time': time,
        'date': date,
        'day': day,
        'meetingLink': meetingLink,
      };

  MentorSessionModel copyWith({
    String? id,
    String? studentName,
    String? type,
    String? time,
    String? date,
    String? day,
    String? meetingLink,
    bool? isMock,
  }) {
    return MentorSessionModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      type: type ?? this.type,
      time: time ?? this.time,
      date: date ?? this.date,
      day: day ?? this.day,
      meetingLink: meetingLink ?? this.meetingLink,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, studentName, type, time, date, day, meetingLink, isMock];
}

/// Mentor Pending Task / Feedback item
class MentorTaskModel extends Equatable {
  final String id;
  final String name;
  final String studentName;
  final String dueDate;
  final String status; // 'Pending' | 'Reviewed' | 'In Progress'
  final bool isMock;

  const MentorTaskModel({
    required this.id,
    required this.name,
    required this.studentName,
    required this.dueDate,
    required this.status,
    this.isMock = false,
  });

  factory MentorTaskModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorTaskModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Review',
      studentName: json['studentName'] as String? ?? 'Student',
      dueDate: json['dueDate'] as String? ?? '2026-07-01',
      status: json['status'] as String? ?? 'Pending',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'studentName': studentName,
        'dueDate': dueDate,
        'status': status,
      };

  @override
  List<Object?> get props => [id, name, studentName, dueDate, status, isMock];
}

/// Announcement bulletin item
class MentorAnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String date;
  final String category; // 'Workshop' | 'Deadline' | 'Policy' | 'Notice'
  final bool isMock;

  const MentorAnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.category,
    this.isMock = false,
  });

  factory MentorAnnouncementModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorAnnouncementModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      date: json['date'] as String? ?? 'Today',
      category: json['category'] as String? ?? 'Notice',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date,
        'category': category,
      };

  MentorAnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? date,
    String? category,
    bool? isMock,
  }) {
    return MentorAnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      category: category ?? this.category,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, title, content, date, category, isMock];
}

/// AI Quick Insight item
class MentorInsightModel extends Equatable {
  final String text;
  final String status; // 'optimal' | 'warning'
  final bool isMock;

  const MentorInsightModel({
    required this.text,
    required this.status,
    this.isMock = false,
  });

  factory MentorInsightModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorInsightModel(
      text: json['text'] as String? ?? '',
      status: json['status'] as String? ?? 'optimal',
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [text, status, isMock];
}

/// Mentor Goal / Target Metric
class MentorGoalModel extends Equatable {
  final String label;
  final int progress;
  final int total;
  final bool isMock;

  const MentorGoalModel({
    required this.label,
    required this.progress,
    required this.total,
    this.isMock = false,
  });

  factory MentorGoalModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorGoalModel(
      label: json['label'] as String? ?? '',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 10,
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [label, progress, total, isMock];
}

/// Aggregated Root State for Mentor Overview Screen
class MentorOverviewData extends Equatable {
  final String mentorName;
  final String mentorId;
  final List<MentorStudentModel> students;
  final List<MentorSessionModel> sessions;
  final List<MentorTaskModel> tasks;
  final List<MentorAnnouncementModel> announcements;
  final List<MentorInsightModel> insights;
  final List<MentorGoalModel> goals;
  final double averageRating;
  final bool isMock;

  const MentorOverviewData({
    required this.mentorName,
    required this.mentorId,
    required this.students,
    required this.sessions,
    required this.tasks,
    required this.announcements,
    required this.insights,
    required this.goals,
    required this.averageRating,
    this.isMock = false,
  });

  MentorOverviewData copyWith({
    String? mentorName,
    String? mentorId,
    List<MentorStudentModel>? students,
    List<MentorSessionModel>? sessions,
    List<MentorTaskModel>? tasks,
    List<MentorAnnouncementModel>? announcements,
    List<MentorInsightModel>? insights,
    List<MentorGoalModel>? goals,
    double? averageRating,
    bool? isMock,
  }) {
    return MentorOverviewData(
      mentorName: mentorName ?? this.mentorName,
      mentorId: mentorId ?? this.mentorId,
      students: students ?? this.students,
      sessions: sessions ?? this.sessions,
      tasks: tasks ?? this.tasks,
      announcements: announcements ?? this.announcements,
      insights: insights ?? this.insights,
      goals: goals ?? this.goals,
      averageRating: averageRating ?? this.averageRating,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        mentorName,
        mentorId,
        students,
        sessions,
        tasks,
        announcements,
        insights,
        goals,
        averageRating,
        isMock,
      ];
}

/// Action Priority Queue Item (Operational warnings and task alerts)
class ActionPriorityItemModel extends Equatable {
  final String id;
  final String text;
  final String status; // 'urgent' | 'notice'
  final bool isResolved;
  final bool isMock;

  const ActionPriorityItemModel({
    required this.id,
    required this.text,
    required this.status,
    this.isResolved = false,
    this.isMock = false,
  });

  factory ActionPriorityItemModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return ActionPriorityItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      text: json['text'] as String? ?? 'Operational Notice',
      status: json['status'] as String? ?? 'notice',
      isResolved: json['isResolved'] as bool? ?? false,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'status': status,
        'isResolved': isResolved,
      };

  ActionPriorityItemModel copyWith({
    String? id,
    String? text,
    String? status,
    bool? isResolved,
    bool? isMock,
  }) {
    return ActionPriorityItemModel(
      id: id ?? this.id,
      text: text ?? this.text,
      status: status ?? this.status,
      isResolved: isResolved ?? this.isResolved,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, text, status, isResolved, isMock];
}

