import 'package:equatable/equatable.dart';
import '../core/enums/user_role.dart';
import '../core/enums/education_level.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final EducationLevel? educationLevel; // null for mentors
  final String? bio;
  final String? location;
  final List<String> skills;
  final List<String> interests;
  final String? schoolOrUniversity;
  final String planId; // 'free' | 'pro' | 'premium'
  final bool isVerified;
  final bool isProfileComplete;
  final int profileCompletionPercent;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.educationLevel,
    this.bio,
    this.location,
    this.skills = const [],
    this.interests = const [],
    this.schoolOrUniversity,
    this.planId = 'free',
    this.isVerified = false,
    this.isProfileComplete = false,
    this.profileCompletionPercent = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.preferences,
  });

  bool get isPro => planId == 'pro' || planId == 'premium';
  bool get isPremium => planId == 'premium';
  bool get isGuest => role == UserRole.guest;
  bool get isStudent => role == UserRole.student;
  bool get isMentor => role == UserRole.mentor;
  String get firstName => fullName.split(' ').first;

  // ─── Serialization ──────────────────────────────────────────────────────
  // fromJson: called when real API returns JSON — no UI changes needed
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.firstWhere(
            (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      educationLevel: json['education_level'] != null
          ? EducationLevel.values.firstWhere(
            (e) => e.name == json['education_level'],
        orElse: () => EducationLevel.form6,
      )
          : null,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      schoolOrUniversity: json['school_or_university'] as String?,
      planId: json['plan_id'] as String? ?? 'free',
      isVerified: json['is_verified'] as bool? ?? false,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      profileCompletionPercent:
      json['profile_completion_percent'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'education_level': educationLevel?.name,
      'bio': bio,
      'location': location,
      'skills': skills,
      'interests': interests,
      'school_or_university': schoolOrUniversity,
      'plan_id': planId,
      'is_verified': isVerified,
      'is_profile_complete': isProfileComplete,
      'profile_completion_percent': profileCompletionPercent,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    EducationLevel? educationLevel,
    String? bio,
    String? location,
    List<String>? skills,
    List<String>? interests,
    String? schoolOrUniversity,
    String? planId,
    bool? isVerified,
    bool? isProfileComplete,
    int? profileCompletionPercent,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      educationLevel: educationLevel ?? this.educationLevel,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      schoolOrUniversity: schoolOrUniversity ?? this.schoolOrUniversity,
      planId: planId ?? this.planId,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profileCompletionPercent:
      profileCompletionPercent ?? this.profileCompletionPercent,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
    id, email, fullName, avatarUrl, role, educationLevel,
    bio, location, skills, interests, schoolOrUniversity,
    planId, isVerified, isProfileComplete, profileCompletionPercent,
    createdAt, lastActiveAt, preferences,
  ];
}