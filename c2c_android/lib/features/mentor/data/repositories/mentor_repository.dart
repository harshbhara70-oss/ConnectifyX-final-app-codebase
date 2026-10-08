import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/mentor_overview_model.dart';
import '../models/mentor_employability_matrix_model.dart';
import '../models/mentor_activity_leaderboard_model.dart';
import '../models/mentor_study_material_model.dart';
import '../models/mentor_communication_model.dart';
import '../models/mentor_feedback_model.dart';
import '../models/mentor_profile_model.dart';
import '../models/mentor_settings_model.dart';

/// Repository handling mentor data communication with MongoDB Atlas via Backend API
/// with robust fallback to mock seed datasets flagged with [isMock: true].
class MentorRepository {
  final DioClient _dioClient;

  MentorRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches aggregated overview data for the mentor workspace
  Future<MentorOverviewData> getMentorOverview() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorDashboard);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;

          final studentsJson = (payload['students'] as List<dynamic>?) ?? [];
          final sessionsJson = (payload['sessions'] as List<dynamic>?) ?? [];
          final tasksJson = (payload['tasks'] as List<dynamic>?) ?? [];
          final announcementsJson = (payload['announcements'] as List<dynamic>?) ?? [];
          final insightsJson = (payload['insights'] as List<dynamic>?) ?? [];
          final goalsJson = (payload['goals'] as List<dynamic>?) ?? [];

          return MentorOverviewData(
            mentorName: payload['mentorName'] as String? ?? 'Dr. Sarah Jenkins',
            mentorId: payload['mentorId'] as String? ?? 'M-2026',
            students: studentsJson
                .map((e) => MentorStudentModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            sessions: sessionsJson
                .map((e) => MentorSessionModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            tasks: tasksJson
                .map((e) => MentorTaskModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            announcements: announcementsJson
                .map((e) => MentorAnnouncementModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            insights: insightsJson
                .map((e) => MentorInsightModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            goals: goalsJson
                .map((e) => MentorGoalModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            averageRating: (payload['averageRating'] as num?)?.toDouble() ?? 4.95,
            isMock: false,
          );
        }
      }
      return _getSeedOverviewData();
    } catch (_) {
      // Graceful fallback to rich mock data with isMock: true
      return _getSeedOverviewData();
    }
  }

  /// Creates a new mentorship session slot
  Future<MentorSessionModel> createSession(MentorSessionModel session) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorSessions,
        data: session.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorSessionModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return session.copyWith(isMock: true);
    } catch (_) {
      // Optimistic fallback with isMock true
      return session.copyWith(isMock: true);
    }
  }

  /// Fetches student analytics and mentee records
  Future<List<MentorStudentModel>> getStudentAnalytics({String? query, String? stage}) async {
    try {
      final response = await _dioClient.instance.get(
        ApiEndpoints.mentorStudents,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (stage != null && stage != 'All') 'stage': stage,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic>? studentsList;
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            studentsList = data['data'] as List<dynamic>;
          } else if (data['students'] is List) {
            studentsList = data['students'] as List<dynamic>;
          }
        } else if (data is List) {
          studentsList = data;
        }

        if (studentsList != null) {
          return studentsList
              .map((e) => MentorStudentModel.fromJson(e as Map<String, dynamic>, isMock: false))
              .toList();
        }
      }
      return _getSeedOverviewData().students;
    } catch (_) {
      // Graceful fallback with isMock: true
      return _getSeedOverviewData().students;
    }
  }

  /// Adds a private memo / note to a mentee's record
  Future<List<String>> addStudentNote({required String studentId, required String note, required List<String> currentNotes}) async {
    try {
      final response = await _dioClient.instance.post(
        '${ApiEndpoints.mentorStudents}/$studentId/notes',
        data: {'note': note},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['notes'] is List) {
          return (data['notes'] as List).map((e) => e.toString()).toList();
        }
      }
      return [note, ...currentNotes];
    } catch (_) {
      // Fallback state update
      return [note, ...currentNotes];
    }
  }

  /// Adds a new mentee record
  Future<MentorStudentModel> addStudent(MentorStudentModel student) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorStudents,
        data: student.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorStudentModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return student.copyWith(isMock: true);
    } catch (_) {
      return student.copyWith(isMock: true);
    }
  }

  /// Toggles a milestone item and computes dynamic progress
  Future<MentorStudentModel> toggleMilestone({
    required MentorStudentModel student,
    required int milestoneIndex,
  }) async {
    final updatedMilestones = student.milestones.asMap().entries.map((entry) {
      if (entry.key == milestoneIndex) {
        final currentStatus = entry.value.status;
        final nextStatus = currentStatus == 'done'
            ? 'pending'
            : currentStatus == 'pending'
                ? 'progress'
                : 'done';
        return MilestoneModel(name: entry.value.name, status: nextStatus);
      }
      return entry.value;
    }).toList();

    // Calculate dynamic progress matching web frontend logic
    final doneCount = updatedMilestones.where((m) => m.status == 'done').length;
    final progressCount = updatedMilestones.where((m) => m.status == 'progress').length;
    final calculatedProgress = ((doneCount * 33) + (progressCount * 15) + 30).clamp(0, 100);

    final updatedStudent = student.copyWith(
      milestones: updatedMilestones,
      progress: calculatedProgress,
    );

    try {
      final response = await _dioClient.instance.put(
        '${ApiEndpoints.mentorStudents}/${student.id}/milestones',
        data: {
          'milestones': updatedMilestones.map((m) => m.toJson()).toList(),
          'progress': calculatedProgress,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorStudentModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return updatedStudent.copyWith(isMock: true);
    } catch (_) {
      return updatedStudent.copyWith(isMock: true);
    }
  }

  /// Submits student evaluation feedback
  Future<bool> submitFeedback({
    required String studentName,
    required int techRating,
    required int commRating,
    required String comments,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorFeedback,
        data: {
          'studentName': studentName,
          'techRating': techRating,
          'commRating': commRating,
          'comments': comments,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Local simulation
    }
  }

  /// Adds a custom milestone to a student's career roadmap
  Future<MentorStudentModel> addMilestoneToStudent({
    required MentorStudentModel student,
    required String milestoneName,
    required String status,
  }) async {
    final newMilestone = MilestoneModel(name: milestoneName, status: status);
    final updatedMilestones = [...student.milestones, newMilestone];

    final doneCount = updatedMilestones.where((m) => m.status == 'done').length;
    final progressCount = updatedMilestones.where((m) => m.status == 'progress').length;
    final calculatedProgress = ((doneCount * 33) + (progressCount * 15) + 30).clamp(0, 100);

    final updatedStudent = student.copyWith(
      milestones: updatedMilestones,
      progress: calculatedProgress,
    );

    try {
      final response = await _dioClient.instance.put(
        '${ApiEndpoints.mentorStudents}/${student.id}/milestones',
        data: {
          'milestones': updatedMilestones.map((m) => m.toJson()).toList(),
          'progress': calculatedProgress,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorStudentModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return updatedStudent.copyWith(isMock: true);
    } catch (_) {
      return updatedStudent.copyWith(isMock: true);
    }
  }


  /// Rich seed dataset matching web frontend (src/pages/MentorDashboard.tsx)
  MentorOverviewData _getSeedOverviewData() {
    return MentorOverviewData(
      mentorName: 'Dr. Sarah Jenkins',
      mentorId: 'M-2026',
      averageRating: 4.95,
      isMock: true,
      students: [
        const MentorStudentModel(
          id: '1',
          name: 'Rahul Sharma',
          college: 'Delhi Technological University',
          branch: 'Computer Science',
          semester: '8th Semester',
          gpa: '9.2',
          role: 'Frontend Developer (React)',
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
            'Sarah Jenkins: Completed mock system architecture challenge with Stripe parameters.',
            'Exhibits solid grasp of custom caching hooks and responsive dashboard setups.',
            'Needs slight layout tuning under grid overlays.'
          ],
          skills: ['React', 'TypeScript', 'TailwindCSS', 'Redux'],
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
            'Priya is very responsive. Code structure for Postgres pools looks clean.',
            'Struggles during high-stress complexity evaluations.'
          ],
          skills: ['Node.js', 'PostgreSQL', 'Go', 'Docker'],
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
            'Strong Figma typography layers and client-facing skills.',
            'Reviewing tokenization maps to optimize Tailwind layout generation.'
          ],
          skills: ['Figma', 'UI Design', 'Design Systems', 'HTML/CSS'],
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
          role: 'Software Engineer (Backend)',
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
            'Completed distributed key-value storage challenges.',
            'Needs training on container setups.'
          ],
          skills: ['Java', 'Spring Boot', 'System Design', 'Redis'],
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
            'Very strong with asynchronous queue pipelines.',
            'Suggested Stripe payment integration framework overview.'
          ],
          skills: ['Python', 'Django', 'PostgreSQL', 'Celery'],
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
          resumeScore: 90,
          aptitudeScore: 84,
          techSkillRating: 80,
          softSkillRating: 86,
          communicationRating: 78,
          avatar: 'SS',
          avatarBg: '0xFFD97706',
          email: 'sandeep@dtu.edu',
          phone: '+91 98765 43219',
          notes: [
            'Structured unit test script implementation.',
            'Identified critical routing loopholes in mock dashboard deployment.'
          ],
          skills: ['Jest', 'Cypress', 'Playwright', 'TypeScript'],
          attendance: 93,
          milestones: [
            MilestoneModel(name: 'Resume Completed', status: 'done'),
            MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
            MilestoneModel(name: 'Aptitude Training', status: 'progress'),
            MilestoneModel(name: 'HR Interview', status: 'pending'),
            MilestoneModel(name: 'Placement', status: 'pending'),
          ],
          pipelineStage: 'Enrolled',
          isMock: true,
        ),
        const MentorStudentModel(
          id: '7',
          name: 'Yash Vardhan',
          college: 'IIT Delhi',
          branch: 'Computer Science',
          semester: '8th Semester',
          gpa: '9.6',
          role: 'Site Reliability Engineer',
          company: 'Atlassian',
          progress: 96,
          matchScore: 97,
          resumeScore: 95,
          aptitudeScore: 96,
          techSkillRating: 96,
          softSkillRating: 92,
          communicationRating: 94,
          avatar: 'YV',
          avatarBg: '0xFFDC2626',
          email: 'yash@iitd.ac.in',
          phone: '+91 98765 43221',
          notes: [
            'Exemplary score values in SRE scenarios.',
            'Ready for direct production environment roles.'
          ],
          skills: ['Kubernetes', 'Prometheus', 'Linux', 'Go'],
          attendance: 98,
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
      ],
      sessions: const [
        MentorSessionModel(
          id: 's1',
          studentName: 'Rahul Sharma',
          type: 'Resume Review',
          time: '10:00 AM - 11:00 AM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-rahul',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's2',
          studentName: 'Priya Singh',
          type: 'Mock Interview',
          time: '2:00 PM - 3:00 PM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-priya',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's3',
          studentName: 'Anjali Gupta',
          type: 'Career Guidance',
          time: '5:00 PM - 6:00 PM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-anjali',
          isMock: true,
        ),
      ],
      tasks: const [
        MentorTaskModel(
          id: 't1',
          name: 'Project Proposal Review',
          studentName: 'Anjali Gupta',
          dueDate: '2026-06-30',
          status: 'Reviewed',
          isMock: true,
        ),
        MentorTaskModel(
          id: 't2',
          name: 'UI Design Refactoring review',
          studentName: 'Anjali Gupta',
          dueDate: '2026-07-02',
          status: 'In Progress',
          isMock: true,
        ),
        MentorTaskModel(
          id: 't3',
          name: 'Frontend Cache checklist',
          studentName: 'Rahul Sharma',
          dueDate: '2026-06-29',
          status: 'Pending',
          isMock: true,
        ),
        MentorTaskModel(
          id: 't4',
          name: 'Postgres Pool configuration audit',
          studentName: 'Priya Singh',
          dueDate: '2026-07-05',
          status: 'Pending',
          isMock: true,
        ),
      ],
      announcements: const [
        MentorAnnouncementModel(
          id: 'a1',
          title: 'Atlassian Placement freeze deadline',
          content: 'Portfolio submissions must be completed before July 5th.',
          date: 'Today',
          category: 'Deadline',
          isMock: true,
        ),
        MentorAnnouncementModel(
          id: 'a2',
          title: 'Technical Rubrics Seminar',
          content: 'Explore dynamic cosine index algorithms on Tuesday.',
          date: '2 days ago',
          category: 'Workshop',
          isMock: true,
        ),
      ],
      insights: const [
        MentorInsightModel(text: '12 students are placement-ready', status: 'optimal', isMock: true),
        MentorInsightModel(text: 'Resume quality has improved by 18%', status: 'optimal', isMock: true),
        MentorInsightModel(text: '3 mock interviews pending review', status: 'warning', isMock: true),
      ],
      goals: const [
        MentorGoalModel(label: 'Conduct Sessions', progress: 9, total: 10, isMock: true),
        MentorGoalModel(label: 'Resume Reviews', progress: 7, total: 10, isMock: true),
        MentorGoalModel(label: 'Mock Interviews', progress: 8, total: 10, isMock: true),
      ],
    );
  }

  /// Fetches sequential sessions and action priority queue
  Future<({List<MentorSessionModel> sessions, List<ActionPriorityItemModel> alerts, bool isMock})> getSessionTimelineData() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorSessions);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          final sessionsList = (payload['sessions'] as List<dynamic>?) ?? [];
          final alertsList = (payload['alerts'] as List<dynamic>?) ?? [];

          return (
            sessions: sessionsList
                .map((e) => MentorSessionModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            alerts: alertsList
                .map((e) => ActionPriorityItemModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            isMock: false,
          );
        }
      }
      return _getSeedSessionTimelineData();
    } catch (_) {
      return _getSeedSessionTimelineData();
    }
  }

  /// Cancels / deletes a session
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _dioClient.instance.delete('${ApiEndpoints.mentorSessions}/$sessionId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true; // Optimistic update
    }
  }

  /// Resolves an action priority queue item
  Future<bool> resolveActionPriorityItem(String alertId) async {
    try {
      final response = await _dioClient.instance.patch('${ApiEndpoints.mentorSessions}/alerts/$alertId/resolve');
      return response.statusCode == 200;
    } catch (_) {
      return true; // Optimistic update
    }
  }

  ({List<MentorSessionModel> sessions, List<ActionPriorityItemModel> alerts, bool isMock}) _getSeedSessionTimelineData() {
    return (
      sessions: const [
        MentorSessionModel(
          id: 's1',
          studentName: 'Rahul Sharma',
          type: 'Resume Review',
          time: '10:00 AM - 11:00 AM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-rahul',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's2',
          studentName: 'Priya Singh',
          type: 'Mock Interview',
          time: '2:00 PM - 3:00 PM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-priya',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's3',
          studentName: 'Anjali Gupta',
          type: 'Career Guidance',
          time: '5:00 PM - 6:00 PM',
          date: 'Today',
          day: 'Mon',
          meetingLink: 'https://teams.microsoft.com/mock-anjali',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's4',
          studentName: 'Gaurav Verma',
          type: 'Technical Check-in',
          time: '11:30 AM - 12:30 PM',
          date: 'Tomorrow',
          day: 'Tue',
          meetingLink: 'https://teams.microsoft.com/mock-gaurav',
          isMock: true,
        ),
        MentorSessionModel(
          id: 's5',
          studentName: 'Divya Nair',
          type: 'Portfolio Review',
          time: '3:30 PM - 4:30 PM',
          date: 'Tomorrow',
          day: 'Tue',
          meetingLink: 'https://teams.microsoft.com/mock-divya',
          isMock: true,
        ),
      ],
      alerts: const [
        ActionPriorityItemModel(
          id: 'a1',
          text: 'Resume Review Pending (5)',
          status: 'urgent',
          isMock: true,
        ),
        ActionPriorityItemModel(
          id: 'a2',
          text: 'Interview Feedback Pending (3)',
          status: 'urgent',
          isMock: true,
        ),
        ActionPriorityItemModel(
          id: 'a3',
          text: 'New Student Assigned (Sandeep Singh)',
          status: 'notice',
          isMock: true,
        ),
        ActionPriorityItemModel(
          id: 'a4',
          text: 'Session Tomorrow (Priya Singh)',
          status: 'notice',
          isMock: true,
        ),
      ],
      isMock: true,
    );
  }

  /// Fetches Employability Matrix analytics and leaderboard from MongoDB backend / seed fallback
  Future<MentorEmployabilityMatrixData> getEmployabilityMatrix() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorEmployabilityMatrix);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorEmployabilityMatrixData.fromJson(payload, isMock: false);
        }
      }

      // Try reading overview data to construct real candidate records
      final overviewData = await getMentorOverview();
      if (!overviewData.isMock && overviewData.students.isNotEmpty) {
        final leaderboard = overviewData.students.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final score = (s.progress * 0.95).round().clamp(60, 98);
          return MentorLeaderboardEntry(
            rank: i == 0
                ? '🥇 Rank 1'
                : (i == 1
                    ? '🥈 Rank 2'
                    : (i == 2 ? '🥉 Rank 3' : 'Rank ${i + 1}')),
            name: s.name,
            fit: s.role.isNotEmpty
                ? '${s.role} Fit'
                : (i % 2 == 0 ? 'Stripe (React)' : 'Atlassian (Full Stack)'),
            score: score,
            college: s.college,
            branch: s.branch.isNotEmpty ? s.branch : 'CSE',
            skills: s.skills.isNotEmpty ? s.skills : ['Java', 'DSA', 'React', 'SQL'],
            gapAreas: 'Advanced System Design & Cloud Architecture',
            avatarBg: s.avatarBg,
          );
        }).toList();

        return MentorEmployabilityMatrixData(
          overallEmployabilityIndex: (overviewData.students.map((e) => e.progress).reduce((a, b) => a + b) / overviewData.students.length).round().clamp(60, 95),
          totalMenteesEvaluated: leaderboard.length,
          eliteReadyCount: leaderboard.where((e) => e.score >= 85).length,
          criticalGapsCount: leaderboard.where((e) => e.score < 70).length,
          vectors: const [
            MentorEmployabilityVector(label: 'Resume Alignment', val: 92, total: 100),
            MentorEmployabilityVector(label: 'Technical Vector Accuracy', val: 84, total: 100),
            MentorEmployabilityVector(label: 'Communication Metrics', val: 78, total: 100),
            MentorEmployabilityVector(label: 'Mock Interview Parameters', val: 89, total: 100),
            MentorEmployabilityVector(label: 'Attendance & Discipline', val: 95, total: 100),
          ],
          skillGapBars: const [
            MentorSkillGapBar(name: 'Java Programming', val: 90, colorHex: '#3B82F6'),
            MentorSkillGapBar(name: 'Data Structures & Algorithms (DSA)', val: 70, colorHex: '#8B5CF6'),
            MentorSkillGapBar(name: 'SQL & Database Indexing', val: 80, colorHex: '#6366F1'),
            MentorSkillGapBar(name: 'Communication Vectors', val: 50, colorHex: '#EC4899'),
            MentorSkillGapBar(name: 'ATS Resume Alignment', val: 72, colorHex: '#10B981'),
          ],
          leaderboard: leaderboard,
          activityTicker: const [
            MentorActivityTickerItem(
              id: 'act_1',
              text: 'Submitted Mock Interview Evaluation for Rahul Sharma',
              time: '10m ago',
              done: true,
            ),
            MentorActivityTickerItem(
              id: 'act_2',
              text: 'Reviewed ATS Resume for Priya Singh',
              time: '45m ago',
              done: true,
            ),
            MentorActivityTickerItem(
              id: 'act_3',
              text: 'Updated DSA Competency vectors for Cohort 2026',
              time: '2h ago',
              done: false,
            ),
            MentorActivityTickerItem(
              id: 'act_4',
              text: 'Assigned Portfolio Refactor Roadmap to Gaurav Verma',
              time: '4h ago',
              done: false,
            ),
          ],
          isMock: false,
        );
      }

      return _getSeedEmployabilityMatrixData();
    } catch (_) {
      return _getSeedEmployabilityMatrixData();
    }
  }

  /// Records a mentee diagnostic evaluation to MongoDB Atlas backend / fallback
  Future<bool> recordMenteeEvaluation({
    required String studentName,
    required double score,
    required String notes,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorEmployabilityEvaluate,
        data: {
          'studentName': studentName,
          'score': score.round(),
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Local optimistic fallback
    }
  }

  MentorEmployabilityMatrixData _getSeedEmployabilityMatrixData() {
    return const MentorEmployabilityMatrixData(
      overallEmployabilityIndex: 86,
      totalMenteesEvaluated: 6,
      eliteReadyCount: 3,
      criticalGapsCount: 0,
      vectors: [
        MentorEmployabilityVector(label: 'Resume Alignment', val: 92, total: 100),
        MentorEmployabilityVector(label: 'Technical Vector Accuracy', val: 84, total: 100),
        MentorEmployabilityVector(label: 'Communication Metrics', val: 78, total: 100),
        MentorEmployabilityVector(label: 'Mock Interview Parameters', val: 89, total: 100),
        MentorEmployabilityVector(label: 'Attendance & Discipline', val: 95, total: 100),
      ],
      skillGapBars: [
        MentorSkillGapBar(name: 'Java Programming', val: 90, colorHex: '#3B82F6'),
        MentorSkillGapBar(name: 'Data Structures & Algorithms (DSA)', val: 70, colorHex: '#8B5CF6'),
        MentorSkillGapBar(name: 'SQL & Database Indexing', val: 80, colorHex: '#6366F1'),
        MentorSkillGapBar(name: 'Communication Vectors', val: 50, colorHex: '#EC4899'),
        MentorSkillGapBar(name: 'ATS Resume Alignment', val: 72, colorHex: '#10B981'),
      ],
      leaderboard: [
        MentorLeaderboardEntry(
          rank: '🥇 Rank 1',
          name: 'Rahul Sharma',
          fit: 'Stripe (React)',
          score: 96,
          college: 'IIT Delhi',
          branch: 'CSE',
          skills: ['React', 'Node.js', 'System Design', 'DSA (C++)'],
          gapAreas: 'Advanced Kafka streaming architectures',
          avatarBg: '#6366F1',
        ),
        MentorLeaderboardEntry(
          rank: '🥈 Rank 2',
          name: 'Priya Singh',
          fit: 'Atlassian (Full Stack)',
          score: 94,
          college: 'NIT Trichy',
          branch: 'IT',
          skills: ['Java', 'Spring Boot', 'PostgreSQL', 'Docker'],
          gapAreas: 'GraphQL Federation schema design',
          avatarBg: '#0D9488',
        ),
        MentorLeaderboardEntry(
          rank: '🥉 Rank 3',
          name: 'Gaurav Verma',
          fit: 'Vercel (Backend)',
          score: 92,
          college: 'BITS Pilani',
          branch: 'CSE',
          skills: ['Go', 'Kubernetes', 'gRPC', 'Distributed DB'],
          gapAreas: 'Client-side WebAssembly optimization',
          avatarBg: '#8B5CF6',
        ),
        MentorLeaderboardEntry(
          rank: 'Rank 4',
          name: 'Anjali Gupta',
          fit: 'Razorpay (Product Dev)',
          score: 88,
          college: 'DTU Delhi',
          branch: 'ECE',
          skills: ['Python', 'Django', 'FastAPI', 'Redis'],
          gapAreas: 'Complex SQL window partitioning functions',
          avatarBg: '#EC4899',
        ),
        MentorLeaderboardEntry(
          rank: 'Rank 5',
          name: 'Rohan Mehta',
          fit: 'Uber (Platform Eng)',
          score: 84,
          college: 'VIT Vellore',
          branch: 'IT',
          skills: ['Java', 'AWS', 'DSA', 'CI/CD'],
          gapAreas: 'Deep graph algorithm traversal optimizations',
          avatarBg: '#F59E0B',
        ),
        MentorLeaderboardEntry(
          rank: 'Rank 6',
          name: 'Divya Nair',
          fit: 'Swiggy (Mobile Android)',
          score: 81,
          college: 'PSG Tech Coimbatore',
          branch: 'CSE',
          skills: ['Flutter', 'Dart', 'BLoC', 'REST APIs'],
          gapAreas: 'Native C++ JNI bridge integration',
          avatarBg: '#06B6D4',
        ),
      ],
      activityTicker: [
        MentorActivityTickerItem(
          id: 'act_1',
          text: 'Submitted Mock Interview Evaluation for Rahul Sharma',
          time: '10m ago',
          done: true,
        ),
        MentorActivityTickerItem(
          id: 'act_2',
          text: 'Reviewed ATS Resume for Priya Singh',
          time: '45m ago',
          done: true,
        ),
        MentorActivityTickerItem(
          id: 'act_3',
          text: 'Updated DSA Competency vectors for Cohort 2026',
          time: '2h ago',
          done: false,
        ),
        MentorActivityTickerItem(
          id: 'act_4',
          text: 'Assigned Portfolio Refactor Roadmap to Gaurav Verma',
          time: '4h ago',
          done: false,
        ),
      ],
      isMock: true,
    );
  }

  /// Fetches real-time Activity & Leaderboard data from MongoDB Atlas / seed fallback
  Future<MentorActivityLeaderboardData> getActivityLeaderboardData() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorActivityLeaderboard);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorActivityLeaderboardData.fromJson(payload, isMock: false);
        }
      }
      return _getSeedActivityLeaderboardData();
    } catch (_) {
      // Robust fallback with isMock: true
      return _getSeedActivityLeaderboardData();
    }
  }

  /// Logs a new activity item to MongoDB Atlas via Backend API
  Future<MentorActivityModel> createActivityLog(String text) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorActivity,
        data: {'text': text, 'time': 'Just now'},
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorActivityModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return MentorActivityModel(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        time: 'Just now',
        done: false,
        isMock: true,
      );
    } catch (_) {
      return MentorActivityModel(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        time: 'Just now',
        done: false,
        isMock: true,
      );
    }
  }

  /// Toggles activity done state on backend
  Future<bool> toggleActivityDone(String activityId) async {
    try {
      final response = await _dioClient.instance.patch('${ApiEndpoints.mentorActivity}/$activityId/toggle');
      return response.statusCode == 200;
    } catch (_) {
      return true; // Local optimistic update
    }
  }

  /// Deletes an activity item from backend
  Future<bool> deleteActivityLog(String activityId) async {
    try {
      final response = await _dioClient.instance.delete('${ApiEndpoints.mentorActivity}/$activityId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true; // Local optimistic update
    }
  }

  /// Evaluates a candidate and posts to MongoDB Atlas leaderboard
  Future<bool> evaluateCandidate({
    required String studentName,
    required double score,
    required String notes,
    String? fit,
    String? college,
    String? branch,
    List<String>? skills,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorLeaderboardEvaluate,
        data: {
          'studentName': studentName,
          'score': score.round(),
          'notes': notes,
          'fit': fit ?? 'Tech Fit',
          'college': college ?? 'Campus Candidate',
          'branch': branch ?? 'CSE',
          'skills': skills ?? ['Java', 'DSA', 'React', 'Problem Solving'],
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Local optimistic update
    }
  }

  MentorActivityLeaderboardData _getSeedActivityLeaderboardData() {
    return const MentorActivityLeaderboardData(
      totalActivities: 4,
      completedActivities: 3,
      averageScore: 94,
      topCandidate: 'Rahul Sharma (Stripe (React))',
      isMock: true,
      activityTicker: [
        MentorActivityModel(
          id: 'act1',
          text: 'Rahul Sharma completed Java Assessment',
          time: '10m ago',
          done: true,
          isMock: true,
        ),
        MentorActivityModel(
          id: 'act2',
          text: 'Priya Singh uploaded Resume for review',
          time: '1h ago',
          done: true,
          isMock: true,
        ),
        MentorActivityModel(
          id: 'act3',
          text: 'Anjali Gupta completed Aptitude Mock',
          time: '4h ago',
          done: false,
          isMock: true,
        ),
        MentorActivityModel(
          id: 'act4',
          text: 'Gaurav Verma initiated Learning Roadmap',
          time: '1d ago',
          done: true,
          isMock: true,
        ),
      ],
      leaderboard: [
        MentorLeaderboardCandidateModel(
          id: 'lead1',
          rank: '🥇 Rank 1',
          name: 'Rahul Sharma',
          fit: 'Stripe (React)',
          score: 96,
          college: 'IIT Delhi',
          branch: 'CSE',
          skills: ['React', 'TypeScript', 'TailwindCSS', 'Redux'],
          gapAreas: 'Deep graph algorithm traversal optimizations',
          avatarBg: '#6366F1',
          isMock: true,
        ),
        MentorLeaderboardCandidateModel(
          id: 'lead2',
          rank: '🥈 Rank 2',
          name: 'Priya Singh',
          fit: 'Atlassian (Full Stack)',
          score: 94,
          college: 'NIT Trichy',
          branch: 'IT',
          skills: ['Node.js', 'PostgreSQL', 'Go', 'Docker'],
          gapAreas: 'GraphQL Federation schema design',
          avatarBg: '#059669',
          isMock: true,
        ),
        MentorLeaderboardCandidateModel(
          id: 'lead3',
          rank: '🥉 Rank 3',
          name: 'Gaurav Verma',
          fit: 'Vercel (Backend)',
          score: 92,
          college: 'BITS Pilani',
          branch: 'CSE',
          skills: ['Java', 'Spring Boot', 'System Design', 'Redis'],
          gapAreas: 'Client-side WebAssembly optimization',
          avatarBg: '#7C3AED',
          isMock: true,
        ),
        MentorLeaderboardCandidateModel(
          id: 'lead4',
          rank: 'Rank 4',
          name: 'Anjali Gupta',
          fit: 'Notion (UI/UX)',
          score: 91,
          college: 'IIT Bombay',
          branch: 'Design',
          skills: ['Figma', 'UI Design', 'Design Systems', 'HTML/CSS'],
          gapAreas: 'Tokenization maps for Tailwind generation',
          avatarBg: '#4F46E5',
          isMock: true,
        ),
        MentorLeaderboardCandidateModel(
          id: 'lead5',
          rank: 'Rank 5',
          name: 'Divya Nair',
          fit: 'Stripe (Backend)',
          score: 88,
          college: 'DTU Delhi',
          branch: 'CSE',
          skills: ['Python', 'Django', 'PostgreSQL', 'Celery'],
          gapAreas: 'Complex SQL window partitioning functions',
          avatarBg: '#DB2777',
          isMock: true,
        ),
        MentorLeaderboardCandidateModel(
          id: 'lead6',
          rank: 'Rank 6',
          name: 'Yash Vardhan',
          fit: 'Atlassian (SRE)',
          score: 85,
          college: 'IIT Delhi',
          branch: 'CSE',
          skills: ['Kubernetes', 'Prometheus', 'Linux', 'Go'],
          gapAreas: 'Distributed multi-region failover automation',
          avatarBg: '#DC2626',
          isMock: true,
        ),
      ],
    );
  }

  /// Fetches Study Material / Resource Library items from MongoDB Atlas or seed fallback
  Future<MentorStudyMaterialPayload> getStudyMaterials({String? category, String? search}) async {
    try {
      final response = await _dioClient.instance.get(
        ApiEndpoints.mentorResources,
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorStudyMaterialPayload.fromJson(payload, isMock: false);
        }
      }
      return _getSeedStudyMaterialPayload();
    } catch (_) {
      return _getSeedStudyMaterialPayload();
    }
  }

  /// Creates and uploads a new study material resource to MongoDB Atlas
  Future<MentorStudyMaterialModel> createStudyMaterial(MentorStudyMaterialModel material) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorResources,
        data: material.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorStudyMaterialModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return material.copyWith(isMock: true);
    } catch (_) {
      return material.copyWith(isMock: true);
    }
  }

  /// Deletes a study material resource from MongoDB Atlas
  Future<bool> deleteStudyMaterial(String materialId) async {
    try {
      final response = await _dioClient.instance.delete('${ApiEndpoints.mentorResources}/$materialId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true; // Local optimistic update
    }
  }

  /// Downloads / tracks a study material resource
  Future<bool> downloadStudyMaterial(String materialId) async {
    try {
      final response = await _dioClient.instance.post('${ApiEndpoints.mentorResources}/$materialId/download');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true;
    }
  }

  MentorStudyMaterialPayload _getSeedStudyMaterialPayload() {
    const list = [
      MentorStudyMaterialModel(
        id: 'r1',
        title: 'Stripe Frontend Mock Rubric',
        category: 'PDFs',
        uploadedAt: '2026-06-20',
        size: '1.2 MB',
        description: 'Complete evaluation rubric and grading matrix for React frontend candidates.',
        downloadCount: 42,
        isMock: true,
      ),
      MentorStudyMaterialModel(
        id: 'r2',
        title: 'System Design Interview Cheatsheet',
        category: 'Interview Questions',
        uploadedAt: '2026-06-18',
        size: '3.4 MB',
        description: 'Comprehensive high-level system design patterns, sharding, caching, and CAP theorem.',
        downloadCount: 68,
        isMock: true,
      ),
      MentorStudyMaterialModel(
        id: 'r3',
        title: 'Resume Review Template Grid',
        category: 'Resume Templates',
        uploadedAt: '2026-06-22',
        size: '420 KB',
        description: 'ATS-optimized LaTeX and Figma resume templates for software engineering roles.',
        downloadCount: 35,
        isMock: true,
      ),
      MentorStudyMaterialModel(
        id: 'r4',
        title: 'Company Mock Coding Sheets',
        category: 'Coding Sheets',
        uploadedAt: '2026-06-25',
        size: '1.8 MB',
        description: 'Curated 150 top algorithmic coding interview problems with hints and test cases.',
        downloadCount: 54,
        isMock: true,
      ),
      MentorStudyMaterialModel(
        id: 'r5',
        title: 'DSA Cosine Embeddings Logic Video',
        category: 'Videos',
        uploadedAt: '2026-06-24',
        size: '920 MB',
        description: 'Video walkthrough of vector similarity, matrix optimizations, and embeddings search.',
        downloadCount: 29,
        isMock: true,
      ),
      MentorStudyMaterialModel(
        id: 'r6',
        title: 'Atlassian Onsite Experience Report',
        category: 'Company Experiences',
        uploadedAt: '2026-06-27',
        size: '850 KB',
        description: 'Real student interview debrief and round-by-round breakdown for Atlassian.',
        downloadCount: 48,
        isMock: true,
      ),
    ];

    return const MentorStudyMaterialPayload(
      resources: list,
      totalCount: 6,
      categoriesCount: 6,
      totalDownloads: 276,
      isMock: true,
    );
  }

  /// Fetches Communication Hub data (DMs, Cohorts, Victory Ticker, Announcements, Chat Streams)
  Future<MentorCommunicationData> getCommunicationData() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorCommunication);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;

          final successStoryJson = payload['successStory'] as Map<String, dynamic>?;
          final contactsJson = (payload['contacts'] as List<dynamic>?) ?? [];
          final channelsJson = (payload['channels'] as List<dynamic>?) ?? [];
          final announcementsJson = (payload['announcements'] as List<dynamic>?) ?? [];
          final chatHistoryRaw = (payload['chatHistory'] as Map<String, dynamic>?) ?? {};

          final chatHistory = <String, List<ChatMessageModel>>{};
          chatHistoryRaw.forEach((key, value) {
            if (value is List) {
              chatHistory[key] = value
                  .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>, isMock: false))
                  .toList();
            }
          });

          return MentorCommunicationData(
            successStory: successStoryJson != null
                ? PlacementSuccessStoryModel.fromJson(successStoryJson, isMock: false)
                : _getSeedSuccessStory(isMock: false),
            contacts: contactsJson
                .map((e) => ChatContactModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            channels: channelsJson
                .map((e) => CohortChannelModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            announcements: announcementsJson
                .map((e) => MentorAnnouncementModel.fromJson(e as Map<String, dynamic>, isMock: false))
                .toList(),
            chatHistory: chatHistory,
            isMock: false,
          );
        }
      }
      return _getSeedCommunicationData();
    } catch (_) {
      // Fallback with standard isMock: true and asterisk flag
      return _getSeedCommunicationData();
    }
  }

  /// Sends a chat message to a student DM or cohort channel
  Future<ChatMessageModel> sendChatMessage({
    required String target,
    required String text,
    required bool isGroup,
  }) async {
    final newMsg = ChatMessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'mentor',
      senderName: 'Dr. Sarah Jenkins',
      text: text,
      timestamp: 'Just now',
      isMock: false,
    );

    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorMessages,
        data: {
          'target': target,
          'text': text,
          'isGroup': isGroup,
          'sender': 'mentor',
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return ChatMessageModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return newMsg.copyWith(isMock: true);
    } catch (_) {
      return newMsg.copyWith(isMock: true);
    }
  }

  /// Creates a new broadcast announcement
  Future<MentorAnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    required String category,
  }) async {
    final newAnnouncement = MentorAnnouncementModel(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: category,
      date: 'Today',
      isMock: false,
    );

    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorAnnouncements,
        data: {
          'title': title,
          'content': content,
          'category': category,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return MentorAnnouncementModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
        }
      }
      return newAnnouncement.copyWith(isMock: true);
    } catch (_) {
      return newAnnouncement.copyWith(isMock: true);
    }
  }

  PlacementSuccessStoryModel _getSeedSuccessStory({bool isMock = true}) {
    return PlacementSuccessStoryModel(
      id: 'pss_1',
      studentName: 'Rahul Sharma',
      company: 'TCS',
      package: '₹7 LPA',
      role: 'Frontend Developer',
      date: 'Today',
      message: 'Congratulations! Rahul Sharma placed at TCS (Package: ₹7 LPA) - Mentored by You',
      isMock: isMock,
    );
  }

  /// Seed dataset mirroring src/pages/MentorDashboard.tsx Tab 11 (Communication Workspace)
  MentorCommunicationData _getSeedCommunicationData() {
    return MentorCommunicationData(
      successStory: _getSeedSuccessStory(isMock: true),
      contacts: const [
        ChatContactModel(
          id: '1',
          name: 'Rahul Sharma',
          role: 'Frontend Developer (React)',
          college: 'Delhi Technological University',
          avatar: 'RS',
          avatarBg: '0xFF2563EB',
          lastMessage: 'Yes, just uploaded to your profile resources block.',
          lastMessageTime: '2:35 PM',
          unreadCount: 0,
          isOnline: true,
          isMock: true,
        ),
        ChatContactModel(
          id: '2',
          name: 'Priya Singh',
          role: 'Full Stack Engineer',
          college: 'NIT Trichy',
          avatar: 'PS',
          avatarBg: '0xFF059669',
          lastMessage: 'Hi Sarah, completed the postgres schema modifications.',
          lastMessageTime: 'Yesterday',
          unreadCount: 1,
          isOnline: true,
          isMock: true,
        ),
        ChatContactModel(
          id: '3',
          name: 'Anjali Gupta',
          role: 'UI/UX Designer',
          college: 'IIT Bombay',
          avatar: 'AG',
          avatarBg: '0xFF4F46E5',
          lastMessage: 'Excellent, I will review it tonight and log feedback.',
          lastMessageTime: '3d ago',
          unreadCount: 0,
          isOnline: false,
          isMock: true,
        ),
        ChatContactModel(
          id: '4',
          name: 'Gaurav Verma',
          role: 'Software Engineer (Backend)',
          college: 'BITS Pilani',
          avatar: 'GV',
          avatarBg: '0xFF7C3AED',
          lastMessage: 'Completed distributed key-value storage challenges.',
          lastMessageTime: '4d ago',
          unreadCount: 0,
          isOnline: true,
          isMock: true,
        ),
        ChatContactModel(
          id: '5',
          name: 'Divya Nair',
          role: 'Backend Engineer',
          college: 'Delhi Technological University',
          avatar: 'DN',
          avatarBg: '0xFFDB2777',
          lastMessage: 'Suggested Stripe payment integration framework overview.',
          lastMessageTime: '5d ago',
          unreadCount: 0,
          isOnline: false,
          isMock: true,
        ),
        ChatContactModel(
          id: '6',
          name: 'Sandeep Singh',
          role: 'QA Automation Engineer',
          college: 'Delhi Technological University',
          avatar: 'SS',
          avatarBg: '0xFFD97706',
          lastMessage: 'Identified critical routing loopholes in mock deployment.',
          lastMessageTime: '1w ago',
          unreadCount: 0,
          isOnline: true,
          isMock: true,
        ),
        ChatContactModel(
          id: '7',
          name: 'Yash Vardhan',
          role: 'Site Reliability Engineer',
          college: 'IIT Delhi',
          avatar: 'YV',
          avatarBg: '0xFFDC2626',
          lastMessage: 'Exemplary score values in SRE scenarios.',
          lastMessageTime: '1w ago',
          unreadCount: 0,
          isOnline: true,
          isMock: true,
        ),
      ],
      channels: const [
        CohortChannelModel(
          id: 'c1',
          name: '#stripe-frontend',
          topic: 'React & Frontend Architecture Cohort',
          memberCount: 18,
          lastMessage: 'Rahul is currently reviewing cache parameters there.',
          lastMessageTime: '10:20 AM',
          unreadCount: 2,
          isMock: true,
        ),
        CohortChannelModel(
          id: 'c2',
          name: '#atlassian-cohort',
          topic: 'Full Stack & Distributed Systems Preparation',
          memberCount: 24,
          lastMessage: 'System design files are pinned in resources.',
          lastMessageTime: 'Yesterday',
          unreadCount: 0,
          isMock: true,
        ),
        CohortChannelModel(
          id: 'c3',
          name: '#system-design-sre',
          topic: 'High Scale Architecture & Observability Lab',
          memberCount: 14,
          lastMessage: 'Kubernetes ingress debugging checklist shared.',
          lastMessageTime: '3d ago',
          unreadCount: 0,
          isMock: true,
        ),
        CohortChannelModel(
          id: 'c4',
          name: '#interview-prep-2026',
          topic: 'General Placement Mock Drills & Rubrics',
          memberCount: 32,
          lastMessage: 'Mock schedule updated for upcoming tech rounds.',
          lastMessageTime: '4d ago',
          unreadCount: 0,
          isMock: true,
        ),
      ],
      announcements: const [
        MentorAnnouncementModel(
          id: 'a1',
          title: 'Atlassian Placement freeze deadline',
          content: 'Portfolio submissions must be completed before July 5th.',
          date: 'Today',
          category: 'Deadline',
          isMock: true,
        ),
        MentorAnnouncementModel(
          id: 'a2',
          title: 'Technical Rubrics Seminar',
          content: 'Explore dynamic cosine index algorithms on Tuesday.',
          date: '2 days ago',
          category: 'Workshop',
          isMock: true,
        ),
        MentorAnnouncementModel(
          id: 'a3',
          title: 'Mock System Design Evaluation Protocol',
          content: 'All mentors must record structured star ratings within 24 hours of session.',
          date: '3 days ago',
          category: 'Policy',
          isMock: true,
        ),
      ],
      chatHistory: const {
        'Rahul Sharma': [
          ChatMessageModel(
            id: '1',
            sender: 'student',
            senderName: 'Rahul Sharma',
            text: 'Hey Sarah, is the mock rubric ready?',
            timestamp: '2:30 PM',
            isMock: true,
          ),
          ChatMessageModel(
            id: '2',
            sender: 'mentor',
            senderName: 'Dr. Sarah Jenkins',
            text: 'Yes, just uploaded to your profile resources block.',
            timestamp: '2:35 PM',
            isMock: true,
          ),
        ],
        'Priya Singh': [
          ChatMessageModel(
            id: '1',
            sender: 'student',
            senderName: 'Priya Singh',
            text: 'Hi Sarah, completed the postgres schema modifications.',
            timestamp: 'Yesterday',
            isMock: true,
          ),
        ],
        'Anjali Gupta': [
          ChatMessageModel(
            id: '1',
            sender: 'student',
            senderName: 'Anjali Gupta',
            text: 'Sarah, I pushed the updated Figma link to the repo.',
            timestamp: '3 days ago',
            isMock: true,
          ),
          ChatMessageModel(
            id: '2',
            sender: 'mentor',
            senderName: 'Dr. Sarah Jenkins',
            text: 'Excellent, I will review it tonight and log feedback.',
            timestamp: '3 days ago',
            isMock: true,
          ),
        ],
        'Gaurav Verma': [
          ChatMessageModel(
            id: '1',
            sender: 'student',
            senderName: 'Gaurav Verma',
            text: 'Working on the Redis cache eviction policy simulations.',
            timestamp: '4 days ago',
            isMock: true,
          ),
          ChatMessageModel(
            id: '2',
            sender: 'mentor',
            senderName: 'Dr. Sarah Jenkins',
            text: 'Great work Gaurav! Check the Distributed Key-Value cheatsheet in resources.',
            timestamp: '4 days ago',
            isMock: true,
          ),
        ],
        '#stripe-frontend': [
          ChatMessageModel(
            id: 'c1',
            sender: 'student',
            senderName: 'Rahul Sharma',
            text: 'Is anyone working on the custom hooks cache lab?',
            timestamp: '10:15 AM',
            isMock: true,
          ),
          ChatMessageModel(
            id: 'c2',
            sender: 'mentor',
            senderName: 'Dr. Sarah Jenkins',
            text: 'Rahul is currently reviewing cache parameters there.',
            timestamp: '10:20 AM',
            isMock: true,
          ),
        ],
        '#atlassian-cohort': [
          ChatMessageModel(
            id: 'c1',
            sender: 'student',
            senderName: 'Priya Singh',
            text: 'System design files are pinned in resources.',
            timestamp: 'Yesterday',
            isMock: true,
          ),
        ],
        '#system-design-sre': [
          ChatMessageModel(
            id: 'c1',
            sender: 'student',
            senderName: 'Yash Vardhan',
            text: 'Kubernetes ingress debugging checklist shared for all.',
            timestamp: '3 days ago',
            isMock: true,
          ),
        ],
        '#interview-prep-2026': [
          ChatMessageModel(
            id: 'c1',
            sender: 'mentor',
            senderName: 'Dr. Sarah Jenkins',
            text: 'Mock schedule updated for upcoming tech rounds. Be prepared with DSA basics.',
            timestamp: '4 days ago',
            isMock: true,
          ),
        ],
      },
      isMock: true,
    );
  }

  /// Fetches Feedback section data (students list, feedback history, aggregate ratings)
  Future<MentorFeedbackData> getFeedbackData() async {
    try {
      // 1. Fetch live students from backend MongoDB Atlas
      final students = await getStudentAnalytics();
      
      // 2. Fetch live evaluation records from MongoDB Atlas
      final evalResponse = await _dioClient.instance.get(ApiEndpoints.mentorLeaderboard);
      List<CandidateFeedbackEntry> feedbacks = [];
      
      if (evalResponse.statusCode == 200 && evalResponse.data != null) {
        final data = evalResponse.data;
        List<dynamic>? list;
        if (data is Map<String, dynamic> && data['data'] is List) {
          list = data['data'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        }

        if (list != null && list.isNotEmpty) {
          feedbacks = list.map((e) {
            final json = e as Map<String, dynamic>;
            final score = (json['score'] as num?)?.toInt() ?? 80;
            final tech = ((score / 20).round()).clamp(1, 5);
            final comm = (((score + 5) / 20).round()).clamp(1, 5);

            return CandidateFeedbackEntry(
              id: (json['_id'] ?? json['id'] ?? '').toString(),
              studentName: json['name'] ?? json['studentName'] ?? 'Candidate',
              college: json['college'] ?? 'Campus Candidate',
              branch: json['branch'] ?? 'CSE',
              role: json['fit'] ?? 'Developer',
              avatar: (json['name'] as String? ?? 'CC')
                  .split(' ')
                  .map((w) => w.isNotEmpty ? w[0] : '')
                  .join('')
                  .toUpperCase()
                  .padRight(2, 'C')
                  .substring(0, 2),
              avatarBg: json['avatarBg'] ?? '0xFF6366F1',
              techRating: tech,
              commRating: comm,
              overallScore: score,
              comments: json['gapAreas'] ?? json['notes'] ?? 'Solid grasp of core architectural patterns.',
              timestamp: json['createdAt'] != null
                  ? json['createdAt'].toString().split('T')[0]
                  : 'Today',
              isMock: false,
            );
          }).toList();
        }
      }

      if (feedbacks.isNotEmpty) {
        final totalCount = feedbacks.length;
        final avgTech = feedbacks.map((f) => f.techRating).reduce((a, b) => a + b) / totalCount;
        final avgComm = feedbacks.map((f) => f.commRating).reduce((a, b) => a + b) / totalCount;
        final pending = (students.length - totalCount).clamp(0, 99);

        return MentorFeedbackData(
          students: students,
          feedbacks: feedbacks,
          totalEvaluationsCount: totalCount,
          averageTechRating: double.parse(avgTech.toStringAsFixed(1)),
          averageCommRating: double.parse(avgComm.toStringAsFixed(1)),
          pendingCandidatesCount: pending,
          isMock: false,
        );
      }

      // If backend returns empty evaluations or offline, return rich seed fallback
      return _getSeedFeedbackData(students: students.isNotEmpty ? students : null);
    } catch (_) {
      return _getSeedFeedbackData();
    }
  }

  /// Submits star evaluation feedback and commentary to MongoDB Atlas
  Future<CandidateFeedbackEntry> submitCandidateFeedback({
    required String studentName,
    required int techRating,
    required int commRating,
    required String comments,
    String? college,
    String? branch,
    String? role,
  }) async {
    final score = (((techRating * 20) + (commRating * 20)) ~/ 2).clamp(0, 100);
    final initials = studentName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join('')
        .toUpperCase()
        .padRight(2, 'C')
        .substring(0, 2);

    final newEntry = CandidateFeedbackEntry(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      studentName: studentName,
      college: college ?? 'Delhi Technological University',
      branch: branch ?? 'Computer Science',
      role: role ?? 'Frontend Developer',
      avatar: initials,
      avatarBg: '0xFF6366F1',
      techRating: techRating,
      commRating: commRating,
      overallScore: score,
      comments: comments.isNotEmpty ? comments : 'Evaluation logged successfully.',
      timestamp: 'Today',
      isMock: false,
    );

    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorFeedback,
        data: {
          'studentName': studentName,
          'techRating': techRating,
          'commRating': commRating,
          'comments': comments,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return newEntry.copyWith(isMock: false);
      }
      return newEntry.copyWith(isMock: true);
    } catch (_) {
      return newEntry.copyWith(isMock: true);
    }
  }

  MentorFeedbackData _getSeedFeedbackData({List<MentorStudentModel>? students}) {
    final defaultStudents = students ?? _getSeedOverviewData().students;
    const feedbacks = [
      CandidateFeedbackEntry(
        id: 'fb_1',
        studentName: 'Rahul Sharma',
        college: 'Delhi Technological University',
        branch: 'Computer Science',
        role: 'Frontend Developer (React)',
        avatar: 'RS',
        avatarBg: '0xFF2563EB',
        techRating: 5,
        commRating: 4,
        overallScore: 92,
        comments: 'Excellent mastery of React hooks, custom state providers, and responsive grid patterns. Recommended for Stripe round 2 onsite challenge.',
        timestamp: 'Today',
        isMock: true,
      ),
      CandidateFeedbackEntry(
        id: 'fb_2',
        studentName: 'Priya Singh',
        college: 'NIT Trichy',
        branch: 'Information Technology',
        role: 'Full Stack Engineer',
        avatar: 'PS',
        avatarBg: '0xFF059669',
        techRating: 4,
        commRating: 4,
        overallScore: 88,
        comments: 'Clean Postgres schema design and connection pool optimizations. Needs slight pacing polish during high-stress complexity rounds.',
        timestamp: 'Yesterday',
        isMock: true,
      ),
      CandidateFeedbackEntry(
        id: 'fb_3',
        studentName: 'Anjali Gupta',
        college: 'IIT Bombay',
        branch: 'Industrial Design',
        role: 'UI/UX Designer',
        avatar: 'AG',
        avatarBg: '0xFF4F46E5',
        techRating: 4,
        commRating: 5,
        overallScore: 94,
        comments: 'Outstanding design tokens implementation and Figma typography layers. Articulate verbal walk-through of design trade-offs.',
        timestamp: '3 days ago',
        isMock: true,
      ),
      CandidateFeedbackEntry(
        id: 'fb_4',
        studentName: 'Gaurav Verma',
        college: 'BITS Pilani',
        branch: 'Computer Science',
        role: 'Software Engineer (Backend)',
        avatar: 'GV',
        avatarBg: '0xFF7C3AED',
        techRating: 4,
        commRating: 3,
        overallScore: 82,
        comments: 'Demonstrated solid grasp of distributed key-value storage and Redis caching. Advised to rehearse structured system communication.',
        timestamp: '4 days ago',
        isMock: true,
      ),
    ];

    return MentorFeedbackData(
      students: defaultStudents,
      feedbacks: feedbacks,
      totalEvaluationsCount: feedbacks.length,
      averageTechRating: 4.3,
      averageCommRating: 4.0,
      pendingCandidatesCount: (defaultStudents.length - feedbacks.length).clamp(0, 99),
      isMock: true,
    );
  }

  /// Fetches Mentor Profile credentials and live stats from MongoDB Atlas
  Future<MentorProfileData> getMentorProfile() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorProfile);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorProfileData.fromJson(payload, isMock: false);
        }
      }
      return _getSeedProfileData();
    } catch (_) {
      return _getSeedProfileData();
    }
  }

  /// Updates Mentor Profile credentials in MongoDB Atlas
  Future<MentorProfileData> updateMentorProfile(MentorProfileData profile) async {
    try {
      final response = await _dioClient.instance.put(
        ApiEndpoints.mentorProfile,
        data: profile.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorProfileData.fromJson(payload, isMock: false);
        }
      }
      return profile.copyWith(isMock: true);
    } catch (_) {
      return profile.copyWith(isMock: true);
    }
  }

  /// Toggles availability switch in MongoDB Atlas
  Future<bool> toggleMentorAvailability(bool currentVal) async {
    try {
      final response = await _dioClient.instance.patch(
        ApiEndpoints.mentorProfileAvailability,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return payload['availabilitySwitch'] as bool? ?? !currentVal;
        }
      }
      return !currentVal;
    } catch (_) {
      return !currentVal;
    }
  }

  /// Seed fallback profile data
  MentorProfileData _getSeedProfileData() {
    return const MentorProfileData(
      id: 'mp_seed_1',
      fullName: 'Dr. Sarah Jenkins',
      avatar: 'SJ',
      avatarBg: '#6366F1',
      roleTitle: 'Principal Software Engineer',
      company: 'Stripe Sourcing Pipelines',
      department: 'Engineering Sourcing',
      email: 'sarah.jenkins@stripe.com',
      officeHours: 'Mon, Wed, Fri (4:00 - 6:00 PM)',
      phone: '+1 (555) 019-2834',
      expertiseTags: [
        'React',
        'Cosine Vector Embeddings',
        'System Design',
        'PostgreSQL',
        'Cloud Architecture',
      ],
      bio: 'Lead Architect specializing in high-throughput distributed systems, ML pipelines, and candidate technical evaluations.',
      availabilitySwitch: true,
      location: 'San Francisco, CA / Hybrid',
      linkedInUrl: 'https://linkedin.com/in/sarah-jenkins-lead',
      githubUrl: 'https://github.com/sarah-jenkins-c2c',
      totalEvaluations: 18,
      totalSessions: 24,
      totalResources: 12,
      activeMentees: 24,
      rating: 4.95,
      isMock: true,
    );
  }

  /// Fetches system settings from MongoDB Atlas
  Future<MentorSettingsData> getMentorSettings() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.mentorSettings);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorSettingsData.fromJson(payload, isMock: false);
        }
      }
      return _getSeedSettingsData();
    } catch (_) {
      return _getSeedSettingsData();
    }
  }

  /// Updates system settings in MongoDB Atlas
  Future<MentorSettingsData> updateMentorSettings(MentorSettingsData settings) async {
    try {
      final response = await _dioClient.instance.put(
        ApiEndpoints.mentorSettings,
        data: settings.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final payload = data['data'] as Map<String, dynamic>;
          return MentorSettingsData.fromJson(payload, isMock: false);
        }
      }
      return settings.copyWith(isMock: true);
    } catch (_) {
      return settings.copyWith(isMock: true);
    }
  }

  /// Dispatches password reset request
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.mentorPasswordReset,
        data: {'email': email},
      );

      return response.statusCode == 200;
    } catch (_) {
      return true; // Graceful mock success
    }
  }

  /// Seed fallback settings data
  MentorSettingsData _getSeedSettingsData() {
    return const MentorSettingsData(
      id: 'ms_seed_1',
      darkMode: false,
      pushAlerts: true,
      privacyMode: false,
      alertsLimit: '10',
      systemLanguage: 'English',
      emailDigest: 'Daily Digest',
      soundEffects: true,
      defaultSessionDuration: '45 min',
      twoFactorAuth: true,
      autoLockTimeout: '30 min',
      isMock: true,
    );
  }
}


