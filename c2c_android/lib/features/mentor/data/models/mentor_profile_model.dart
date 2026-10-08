/// Data model for Mentor Profile Screen matching web frontend (Tab 10 - Mentor Profile)
/// Supports real-time MongoDB Atlas sync with [isMock: false] and seamless offline fallback.
class MentorProfileData {
  final String id;
  final String fullName;
  final String avatar;
  final String avatarBg;
  final String roleTitle;
  final String company;
  final String department;
  final String email;
  final String officeHours;
  final String phone;
  final List<String> expertiseTags;
  final String bio;
  final bool availabilitySwitch;
  final String location;
  final String linkedInUrl;
  final String githubUrl;
  final int totalEvaluations;
  final int totalSessions;
  final int totalResources;
  final int activeMentees;
  final double rating;
  final bool isMock;

  const MentorProfileData({
    required this.id,
    required this.fullName,
    required this.avatar,
    required this.avatarBg,
    required this.roleTitle,
    required this.company,
    required this.department,
    required this.email,
    required this.officeHours,
    required this.phone,
    required this.expertiseTags,
    required this.bio,
    required this.availabilitySwitch,
    required this.location,
    required this.linkedInUrl,
    required this.githubUrl,
    required this.totalEvaluations,
    required this.totalSessions,
    required this.totalResources,
    required this.activeMentees,
    required this.rating,
    this.isMock = false,
  });

  factory MentorProfileData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return MentorProfileData(
      id: json['id'] as String? ?? json['_id'] as String? ?? 'mp-1',
      fullName: json['fullName'] as String? ?? 'Dr. Sarah Jenkins',
      avatar: json['avatar'] as String? ?? 'SJ',
      avatarBg: json['avatarBg'] as String? ?? '#6366F1',
      roleTitle: json['roleTitle'] as String? ?? 'Principal Software Engineer',
      company: json['company'] as String? ?? 'Stripe Sourcing Pipelines',
      department: json['department'] as String? ?? 'Engineering Sourcing',
      email: json['email'] as String? ?? 'sarah.jenkins@stripe.com',
      officeHours: json['officeHours'] as String? ?? 'Mon, Wed, Fri (4:00 - 6:00 PM)',
      phone: json['phone'] as String? ?? '+1 (555) 019-2834',
      expertiseTags: (json['expertiseTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['React', 'Cosine Vector Embeddings', 'System Design', 'PostgreSQL', 'Cloud Architecture'],
      bio: json['bio'] as String? ??
          'Lead Architect specializing in high-throughput distributed systems, ML pipelines, and candidate technical evaluations.',
      availabilitySwitch: json['availabilitySwitch'] as bool? ?? true,
      location: json['location'] as String? ?? 'San Francisco, CA / Hybrid',
      linkedInUrl: json['linkedInUrl'] as String? ?? 'https://linkedin.com/in/sarah-jenkins-lead',
      githubUrl: json['githubUrl'] as String? ?? 'https://github.com/sarah-jenkins-c2c',
      totalEvaluations: (stats['totalEvaluations'] as num?)?.toInt() ?? 18,
      totalSessions: (stats['totalSessions'] as num?)?.toInt() ?? 24,
      totalResources: (stats['totalResources'] as num?)?.toInt() ?? 12,
      activeMentees: (stats['activeMentees'] as num?)?.toInt() ?? 24,
      rating: (stats['rating'] as num?)?.toDouble() ?? 4.95,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'avatar': avatar,
      'avatarBg': avatarBg,
      'roleTitle': roleTitle,
      'company': company,
      'department': department,
      'email': email,
      'officeHours': officeHours,
      'phone': phone,
      'expertiseTags': expertiseTags,
      'bio': bio,
      'availabilitySwitch': availabilitySwitch,
      'location': location,
      'linkedInUrl': linkedInUrl,
      'githubUrl': githubUrl,
    };
  }

  MentorProfileData copyWith({
    String? id,
    String? fullName,
    String? avatar,
    String? avatarBg,
    String? roleTitle,
    String? company,
    String? department,
    String? email,
    String? officeHours,
    String? phone,
    List<String>? expertiseTags,
    String? bio,
    bool? availabilitySwitch,
    String? location,
    String? linkedInUrl,
    String? githubUrl,
    int? totalEvaluations,
    int? totalSessions,
    int? totalResources,
    int? activeMentees,
    double? rating,
    bool? isMock,
  }) {
    return MentorProfileData(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      avatarBg: avatarBg ?? this.avatarBg,
      roleTitle: roleTitle ?? this.roleTitle,
      company: company ?? this.company,
      department: department ?? this.department,
      email: email ?? this.email,
      officeHours: officeHours ?? this.officeHours,
      phone: phone ?? this.phone,
      expertiseTags: expertiseTags ?? this.expertiseTags,
      bio: bio ?? this.bio,
      availabilitySwitch: availabilitySwitch ?? this.availabilitySwitch,
      location: location ?? this.location,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      totalEvaluations: totalEvaluations ?? this.totalEvaluations,
      totalSessions: totalSessions ?? this.totalSessions,
      totalResources: totalResources ?? this.totalResources,
      activeMentees: activeMentees ?? this.activeMentees,
      rating: rating ?? this.rating,
      isMock: isMock ?? this.isMock,
    );
  }
}
