import 'package:equatable/equatable.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/mentor_overview_model.dart';

/// Centralized API service for ALL mentor module endpoints.
/// Every GET / POST route lives here. isMock governed by try/catch.
class MentorApiService {
  final DioClient _dio;

  MentorApiService({DioClient? dio}) : _dio = dio ?? DioClient();

  // ─── Students (also powers career roadmaps) ─────────────────────────
  Future<MentorStudentsResponse> getStudents({
    String? query,
    String? stage,
  }) async {
    try {
      final res = await _dio.instance.get(
        ApiEndpoints.mentorStudents,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (stage != null && stage != 'All') 'stage': stage,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data;
        List<dynamic>? list;
        if (data is Map<String, dynamic>) {
          list = (data['data'] ?? data['students']) as List<dynamic>?;
        } else if (data is List) {
          list = data;
        }
        if (list != null) {
          final students = list
              .map((e) => MentorStudentModel.fromJson(
                    e as Map<String, dynamic>,
                    isMock: false,
                  ))
              .toList();
          return MentorStudentsResponse(students: students, isMock: false);
        }
      }
    } catch (_) {}
    return MentorStudentsResponse(students: MockSeed.students(), isMock: true);
  }

  // ─── Toggle Milestone ──────────────────────────────────────────────
  Future<MentorStudentModel> toggleMilestone({
    required MentorStudentModel student,
    required int milestoneIndex,
  }) async {
    final updated = _applyToggleLocally(student, milestoneIndex);
    try {
      final res = await _dio.instance.put(
        '${ApiEndpoints.mentorStudents}/${student.id}/milestones',
        data: {
          'milestones': updated.milestones.map((m) => m.toJson()).toList(),
          'progress': updated.progress,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final payload = res.data['data'] as Map<String, dynamic>?;
        if (payload != null) {
          // Backend echoes {id, milestones, progress}; merge into a
          // full student so name/college/role/avatar survive.
          final echoed = MentorStudentModel.fromJson(payload, isMock: false);
          return student.copyWith(
            milestones: echoed.milestones.isEmpty
                ? updated.milestones
                : echoed.milestones,
            progress: payload['progress'] ?? updated.progress,
            isMock: false,
          );
        }
      }
    } catch (_) {}
    return updated.copyWith(isMock: true);
  }

  // ─── Add Milestone ─────────────────────────────────────────────────
  Future<MentorStudentModel> addMilestone({
    required MentorStudentModel student,
    required String name,
    required String status,
  }) async {
    final newMilestones = [
      ...student.milestones,
      MilestoneModel(name: name, status: status),
    ];
    final doneCount =
        newMilestones.where((m) => m.status == 'done').length;
    final progCount =
        newMilestones.where((m) => m.status == 'progress').length;
    final progress = ((doneCount * 33) + (progCount * 15) + 30)
        .clamp(0, 100)
        .toInt();

    try {
      final res = await _dio.instance.put(
        '${ApiEndpoints.mentorStudents}/${student.id}/milestones',
        data: {
          'milestones': newMilestones.map((m) => m.toJson()).toList(),
          'progress': progress,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final payload = res.data['data'] as Map<String, dynamic>?;
        if (payload != null) {
          final echoed = MentorStudentModel.fromJson(payload, isMock: false);
          return student.copyWith(
            milestones: echoed.milestones.isEmpty
                ? newMilestones
                : echoed.milestones,
            progress: payload['progress'] ?? progress,
            isMock: false,
          );
        }
      }
    } catch (_) {}
    return student
        .copyWith(milestones: newMilestones, progress: progress, isMock: true);
  }

  // ─── Dashboard ──────────────────────────────────────────────────────
  Future<MentorDashboardResponse> getDashboard() async {
    try {
      final res = await _dio.instance.get(ApiEndpoints.mentorDashboard);
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['data'] is Map<String, dynamic>) {
        final payload = res.data['data'] as Map<String, dynamic>;
        final students = (payload['students'] as List<dynamic>? ?? [])
            .map((e) => MentorStudentModel.fromJson(
                  e as Map<String, dynamic>,
                  isMock: false,
                ))
            .toList();
        final sessions = (payload['sessions'] as List<dynamic>? ?? [])
            .map((e) => MentorSessionModel.fromJson(
                  e as Map<String, dynamic>,
                  isMock: false,
                ))
            .toList();
        return MentorDashboardResponse(
          mentorName: payload['mentorName'] ?? 'Mentor',
          mentorId: payload['mentorId'] ?? '',
          averageRating: 0,
          students: students,
          sessions: sessions,
          isMock: false,
        );
      }
    } catch (_) {}
    return MentorDashboardResponse(
      mentorName: 'Dr. Sarah Jenkins',
      mentorId: 'M-2026',
      averageRating: 4.95,
      students: MockSeed.students(),
      sessions: MockSeed.sessions(),
      isMock: true,
    );
  }

  // ─── Sessions ──────────────────────────────────────────────────────
  Future<List<MentorSessionModel>> getSessions() async {
    try {
      final res = await _dio.instance.get(ApiEndpoints.mentorSessions);
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['data'] is List) {
        return (res.data['data'] as List)
            .map((e) => MentorSessionModel.fromJson(
                  e as Map<String, dynamic>,
                  isMock: false,
                ))
            .toList();
      }
    } catch (_) {}
    return MockSeed.sessions();
  }

  // ─── Post: Create Session ──────────────────────────────────────────
  Future<MentorSessionModel> createSession(MentorSessionModel session) async {
    try {
      final res = await _dio.instance.post(
        ApiEndpoints.mentorSessions,
        data: session.toJson(),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map<String, dynamic>) {
        final payload = res.data['data'] as Map<String, dynamic>?;
        if (payload != null) {
          return MentorSessionModel.fromJson(payload, isMock: false);
        }
      }
    } catch (_) {}
    return session.copyWith(isMock: true);
  }

  // ─── Post: Submit Feedback ─────────────────────────────────────────
  Future<bool> submitFeedback({
    required String studentName,
    required int techRating,
    required int commRating,
    required String comments,
  }) async {
    try {
      final res = await _dio.instance.post(
        ApiEndpoints.mentorFeedback,
        data: {
          'studentName': studentName,
          'techRating': techRating,
          'commRating': commRating,
          'comments': comments,
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return true;
    }
  }

  // ─── Post: Add Student Note ────────────────────────────────────────
  Future<List<String>> addStudentNote({
    required String studentId,
    required String note,
    required List<String> currentNotes,
  }) async {
    try {
      final res = await _dio.instance.post(
        '${ApiEndpoints.mentorStudents}/$studentId/notes',
        data: {'note': note},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        if (data is Map<String, dynamic> && data['notes'] is List) {
          return (data['notes'] as List).map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}
    return [note, ...currentNotes];
  }

  // ─── Study Resources ───────────────────────────────────────────────
  Future<MentorResourcesResponse> getResources() async {
    try {
      final res = await _dio.instance.get(ApiEndpoints.mentorResources);
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['data'] is List) {
        return MentorResourcesResponse(
          resources: (res.data['data'] as List)
              .map((e) => MentorResourceItem.fromJson(
                    e as Map<String, dynamic>,
                    isMock: false,
                  ))
              .toList(),
          isMock: false,
        );
      }
    } catch (_) {}
    return MentorResourcesResponse(
      resources: MockSeed.resources(),
      isMock: true,
    );
  }

  // ─── Activity Leaderboard ──────────────────────────────────────────
  Future<MentorActivityLeaderboardResponse> getActivityLeaderboard() async {
    try {
      final res =
          await _dio.instance.get(ApiEndpoints.mentorActivityLeaderboard);
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['data'] is Map<String, dynamic>) {
        return MentorActivityLeaderboardResponse.fromJson(
          res.data['data'] as Map<String, dynamic>,
          isMock: false,
        );
      }
    } catch (_) {}
    return MentorActivityLeaderboardResponse(
      activities: MockSeed.activities(),
      candidates: MockSeed.candidates(),
      isMock: true,
    );
  }

  // ─── Employability Matrix ──────────────────────────────────────────
  Future<MentorEmployabilityMatrixResponse> getEmployabilityMatrix() async {
    try {
      final res =
          await _dio.instance.get(ApiEndpoints.mentorEmployabilityMatrix);
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['data'] is Map<String, dynamic>) {
        return MentorEmployabilityMatrixResponse.fromJson(
          res.data['data'] as Map<String, dynamic>,
          isMock: false,
        );
      }
    } catch (_) {}
    return MentorEmployabilityMatrixResponse(
      students: MockSeed.matrixStudents(),
      isMock: true,
    );
  }

  // ─── Private Helpers ───────────────────────────────────────────────
  MentorStudentModel _applyToggleLocally(
    MentorStudentModel student,
    int milestoneIndex,
  ) {
    final milestones = List<MilestoneModel>.from(student.milestones);
    if (milestoneIndex < 0 || milestoneIndex >= milestones.length) {
      return student;
    }
    final old = milestones[milestoneIndex];
    final nextStatus = old.status == 'done'
        ? 'pending'
        : old.status == 'pending'
            ? 'progress'
            : 'done';
    milestones[milestoneIndex] =
        MilestoneModel(name: old.name, status: nextStatus);

    final doneCount = milestones.where((m) => m.status == 'done').length;
    final progCount = milestones.where((m) => m.status == 'progress').length;
    final progress = ((doneCount * 33) + (progCount * 15) + 30)
        .clamp(0, 100)
        .toInt();

    return student.copyWith(milestones: milestones, progress: progress);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Response wrappers with isMock seed fallbacks
// ═══════════════════════════════════════════════════════════════════════

class MentorDashboardResponse extends Equatable {
  final String mentorName;
  final String mentorId;
  final double averageRating;
  final List<MentorStudentModel> students;
  final List<MentorSessionModel> sessions;
  final bool isMock;

  const MentorDashboardResponse({
    required this.mentorName,
    required this.mentorId,
    required this.averageRating,
    required this.students,
    required this.sessions,
    required this.isMock,
  });

  @override
  List<Object?> get props => [
        mentorName,
        mentorId,
        averageRating,
        students,
        sessions,
        isMock,
      ];
}

class MentorStudentsResponse extends Equatable {
  final List<MentorStudentModel> students;
  final bool isMock;

  const MentorStudentsResponse({
    required this.students,
    required this.isMock,
  });

  @override
  List<Object?> get props => [students, isMock];
}

class MentorResourceItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final String description;
  final int downloadCount;
  final bool isMock;

  const MentorResourceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.downloadCount,
    this.isMock = false,
  });

  factory MentorResourceItem.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorResourceItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? 'Untitled',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, category, description, downloadCount, isMock];
}

class MentorResourcesResponse extends Equatable {
  final List<MentorResourceItem> resources;
  final bool isMock;

  const MentorResourcesResponse({
    required this.resources,
    required this.isMock,
  });

  @override
  List<Object?> get props => [resources, isMock];
}

class MentorActivityItem extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool done;
  final bool isMock;

  const MentorActivityItem({
    required this.id,
    required this.text,
    required this.time,
    required this.done,
    this.isMock = false,
  });

  factory MentorActivityItem.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorActivityItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      text: json['text'] ?? '',
      time: json['time'] ?? '',
      done: json['done'] as bool? ?? false,
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [id, text, time, done, isMock];
}

class MentorLeaderboardCandidate extends Equatable {
  final int rank;
  final String name;
  final String fit;
  final int score;
  final String college;
  final bool isMock;

  const MentorLeaderboardCandidate({
    required this.rank,
    required this.name,
    required this.fit,
    required this.score,
    required this.college,
    this.isMock = false,
  });

  factory MentorLeaderboardCandidate.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorLeaderboardCandidate(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      fit: json['fit'] ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      college: json['college'] ?? '',
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [rank, name, fit, score, college, isMock];
}

class MentorActivityLeaderboardResponse extends Equatable {
  final List<MentorActivityItem> activities;
  final List<MentorLeaderboardCandidate> candidates;
  final bool isMock;

  const MentorActivityLeaderboardResponse({
    required this.activities,
    required this.candidates,
    required this.isMock,
  });

  factory MentorActivityLeaderboardResponse.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorActivityLeaderboardResponse(
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((e) => MentorActivityItem.fromJson(
                e as Map<String, dynamic>,
                isMock: isMock,
              ))
          .toList(),
      candidates: (json['candidates'] as List<dynamic>? ?? [])
          .map((e) => MentorLeaderboardCandidate.fromJson(
                e as Map<String, dynamic>,
                isMock: isMock,
              ))
          .toList(),
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [activities, candidates, isMock];
}

class MentorMatrixStudent extends Equatable {
  final String id;
  final String name;
  final int score;
  final String fit;
  final String college;
  final bool isMock;

  const MentorMatrixStudent({
    required this.id,
    required this.name,
    required this.score,
    required this.fit,
    required this.college,
    this.isMock = false,
  });

  factory MentorMatrixStudent.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorMatrixStudent(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      fit: json['fit'] ?? '',
      college: json['college'] ?? '',
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [id, name, score, fit, college, isMock];
}

class MentorEmployabilityMatrixResponse extends Equatable {
  final List<MentorMatrixStudent> students;
  final bool isMock;

  const MentorEmployabilityMatrixResponse({
    required this.students,
    required this.isMock,
  });

  factory MentorEmployabilityMatrixResponse.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return MentorEmployabilityMatrixResponse(
      students: (json['students'] as List<dynamic>? ?? [])
          .map((e) => MentorMatrixStudent.fromJson(
                e as Map<String, dynamic>,
                isMock: isMock,
              ))
          .toList(),
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [students, isMock];
}

// ═══════════════════════════════════════════════════════════════════════
// Shared mock seed data matching web frontend (MentorDashboard.tsx)
// ═══════════════════════════════════════════════════════════════════════
class MockSeed {
  static List<MentorStudentModel> students() {
    return [
      const MentorStudentModel(
        id: '1',
        name: 'Rahul Sharma',
        college: 'Delhi Technological University',
        branch: 'Computer Science',
        semester: '8th Semester',
        gpa: '9.2',
        role: 'Frontend Developer',
        company: 'Stripe',
        progress: 82,
        matchScore: 94,
        resumeScore: 92,
        aptitudeScore: 88,
        techSkillRating: 90,
        softSkillRating: 85,
        communicationRating: 88,
        avatar: 'RS',
        avatarBg: '0xFF2563EB',
        email: 'rahul.sharma@dtu.edu',
        phone: '+91 98765 43210',
        notes: [
          'Completed mock system architecture challenge.',
          'Needs slight layout tuning.',
        ],
        skills: ['React', 'TypeScript', 'TailwindCSS'],
        attendance: 95,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'done'),
          MilestoneModel(name: 'HR Interview', status: 'progress'),
          MilestoneModel(name: 'Placement', status: 'pending'),
        ],
        pipelineStage: 'Mock Interview',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '2',
        name: 'Priya Singh',
        college: 'NIT Trichy',
        branch: 'Information Technology',
        semester: '8th Semester',
        gpa: '8.8',
        role: 'Full Stack Engineer',
        company: 'Atlassian',
        progress: 74,
        matchScore: 88,
        resumeScore: 94,
        aptitudeScore: 86,
        techSkillRating: 88,
        softSkillRating: 82,
        communicationRating: 84,
        avatar: 'PS',
        avatarBg: '0xFF059669',
        email: 'priya.singh@nitt.edu',
        phone: '+91 98765 43211',
        notes: [
          'Very responsive. Clean Postgres pool code.',
        ],
        skills: ['Node.js', 'PostgreSQL', 'Go'],
        attendance: 92,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'progress'),
          MilestoneModel(name: 'HR Interview', status: 'pending'),
          MilestoneModel(name: 'Placement', status: 'pending'),
        ],
        pipelineStage: 'Mentorship',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '3',
        name: 'Anjali Gupta',
        college: 'IIT Bombay',
        branch: 'Industrial Design',
        semester: '8th Semester',
        gpa: '9.4',
        role: 'UI/UX Designer',
        company: 'Notion',
        progress: 80,
        matchScore: 91,
        resumeScore: 89,
        aptitudeScore: 92,
        techSkillRating: 84,
        softSkillRating: 94,
        communicationRating: 95,
        avatar: 'AG',
        avatarBg: '0xFF4F46E5',
        email: 'anjali@iitb.ac.in',
        phone: '+91 98765 43212',
        notes: [
          'Strong Figma skills.',
        ],
        skills: ['Figma', 'UI Design', 'Design Systems'],
        attendance: 96,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'done'),
          MilestoneModel(name: 'HR Interview', status: 'progress'),
          MilestoneModel(name: 'Placement', status: 'pending'),
        ],
        pipelineStage: 'Placement Ready',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '4',
        name: 'Gaurav Verma',
        college: 'BITS Pilani',
        branch: 'Computer Science',
        semester: '8th Semester',
        gpa: '8.5',
        role: 'Backend Engineer',
        company: 'Vercel',
        progress: 68,
        matchScore: 85,
        resumeScore: 92,
        aptitudeScore: 80,
        techSkillRating: 82,
        softSkillRating: 78,
        communicationRating: 80,
        avatar: 'GV',
        avatarBg: '0xFF7C3AED',
        email: 'gaurav.verma@bits.edu',
        phone: '+91 98765 43213',
        notes: [
          'Strong with distributed systems.',
        ],
        skills: ['Java', 'Spring Boot', 'Redis'],
        attendance: 90,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'progress'),
          MilestoneModel(name: 'Aptitude Training', status: 'pending'),
          MilestoneModel(name: 'HR Interview', status: 'pending'),
          MilestoneModel(name: 'Placement', status: 'pending'),
        ],
        pipelineStage: 'Learning Path',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '5',
        name: 'Divya Nair',
        college: 'Delhi Technological University',
        branch: 'Computer Science',
        semester: '8th Semester',
        gpa: '9.0',
        role: 'Backend Engineer',
        company: 'Stripe',
        progress: 78,
        matchScore: 93,
        resumeScore: 88,
        aptitudeScore: 90,
        techSkillRating: 84,
        softSkillRating: 82,
        communicationRating: 86,
        avatar: 'DN',
        avatarBg: '0xFFDB2777',
        email: 'divya@dtu.edu',
        phone: '+91 98765 43214',
        notes: [
          'Strong async pipeline knowledge.',
        ],
        skills: ['Python', 'Django', 'PostgreSQL'],
        attendance: 94,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'progress'),
          MilestoneModel(name: 'HR Interview', status: 'pending'),
          MilestoneModel(name: 'Placement', status: 'pending'),
        ],
        pipelineStage: 'Skill Assessment',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '6',
        name: 'Sandeep Singh',
        college: 'Delhi Technological University',
        branch: 'Electronics',
        semester: '8th Semester',
        gpa: '8.4',
        role: 'QA Automation Engineer',
        company: 'Stripe',
        progress: 72,
        matchScore: 86,
        resumeScore: 85,
        aptitudeScore: 82,
        techSkillRating: 80,
        softSkillRating: 76,
        communicationRating: 78,
        avatar: 'SS',
        avatarBg: '0xFF0891B2',
        email: 'sandeep@dtu.edu',
        phone: '+91 98765 43215',
        notes: [
          'Excellent Cypress test suite architecture.',
        ],
        skills: ['Cypress', 'Selenium', 'Jest'],
        attendance: 88,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'done'),
          MilestoneModel(name: 'HR Interview', status: 'done'),
          MilestoneModel(name: 'Placement', status: 'progress'),
        ],
        pipelineStage: 'Placement Ready',
        isMock: true,
      ),
      const MentorStudentModel(
        id: '7',
        name: 'Kavya Patel',
        college: 'VJTI Mumbai',
        branch: 'Computer Engineering',
        semester: '8th Semester',
        gpa: '9.1',
        role: 'Data Scientist',
        company: 'Razorpay',
        progress: 85,
        matchScore: 92,
        resumeScore: 90,
        aptitudeScore: 91,
        techSkillRating: 93,
        softSkillRating: 88,
        communicationRating: 90,
        avatar: 'KP',
        avatarBg: '0xFFEA580C',
        email: 'kavya@vjti.ac.in',
        phone: '+91 98765 43216',
        notes: [
          'Outstanding ML model optimization skills.',
        ],
        skills: ['Python', 'TensorFlow', 'SQL'],
        attendance: 97,
        milestones: [
          MilestoneModel(name: 'Resume Completed', status: 'done'),
          MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
          MilestoneModel(name: 'Aptitude Training', status: 'done'),
          MilestoneModel(name: 'HR Interview', status: 'done'),
          MilestoneModel(name: 'Placement', status: 'done'),
        ],
        pipelineStage: 'Hired',
        isMock: true,
      ),
    ];
  }

  static List<MentorSessionModel> sessions() {
    return const [
      MentorSessionModel(
        id: 's1',
        studentName: 'Rahul Sharma',
        type: 'Mock Interview',
        time: '10:00 AM',
        date: '2026-09-10',
        day: 'Thursday',
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        isMock: true,
      ),
      MentorSessionModel(
        id: 's2',
        studentName: 'Priya Singh',
        type: 'Career Review',
        time: '2:30 PM',
        date: '2026-09-11',
        day: 'Friday',
        meetingLink: 'https://meet.google.com/xyz-uvwx-yz',
        isMock: true,
      ),
    ];
  }

  static List<MentorResourceItem> resources() {
    return const [
      MentorResourceItem(
        id: 'r1',
        title: 'React Hooks Deep Dive',
        category: 'Tutorial',
        description: 'Advanced React hooks patterns.',
        downloadCount: 142,
        isMock: true,
      ),
      MentorResourceItem(
        id: 'r2',
        title: 'System Design Primer',
        category: 'Book',
        description: 'Complete interview guide.',
        downloadCount: 298,
        isMock: true,
      ),
      MentorResourceItem(
        id: 'r3',
        title: 'SQL Performance Tuning',
        category: 'Article',
        description: 'Optimize database queries.',
        downloadCount: 87,
        isMock: true,
      ),
    ];
  }

  static List<MentorActivityItem> activities() {
    return const [
      MentorActivityItem(
        id: 'a1',
        text: 'Reviewed mock interview performance.',
        time: '2 hours ago',
        done: true,
        isMock: true,
      ),
      MentorActivityItem(
        id: 'a2',
        text: 'Updated resume feedback.',
        time: '5 hours ago',
        done: true,
        isMock: true,
      ),
      MentorActivityItem(
        id: 'a3',
        text: 'Scheduled system design session.',
        time: '1 day ago',
        done: false,
        isMock: true,
      ),
    ];
  }

  static List<MentorLeaderboardCandidate> candidates() {
    return const [
      MentorLeaderboardCandidate(
        rank: 1,
        name: 'Kavya Patel',
        fit: 'Excellent',
        score: 95,
        college: 'VJTI Mumbai',
        isMock: true,
      ),
      MentorLeaderboardCandidate(
        rank: 2,
        name: 'Rahul Sharma',
        fit: 'Excellent',
        score: 92,
        college: 'DTU Delhi',
        isMock: true,
      ),
      MentorLeaderboardCandidate(
        rank: 3,
        name: 'Anjali Gupta',
        fit: 'Strong',
        score: 89,
        college: 'IIT Bombay',
        isMock: true,
      ),
    ];
  }

  static List<MentorMatrixStudent> matrixStudents() {
    return const [
      MentorMatrixStudent(
        id: 'm1',
        name: 'Kavya Patel',
        score: 95,
        fit: 'Excellent',
        college: 'VJTI Mumbai',
        isMock: true,
      ),
      MentorMatrixStudent(
        id: 'm2',
        name: 'Rahul Sharma',
        score: 92,
        fit: 'Excellent',
        college: 'DTU Delhi',
        isMock: true,
      ),
      MentorMatrixStudent(
        id: 'm3',
        name: 'Priya Singh',
        score: 86,
        fit: 'Strong',
        college: 'NIT Trichy',
        isMock: true,
      ),
    ];
  }
}
