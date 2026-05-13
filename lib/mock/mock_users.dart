import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/enums/education_level.dart';

class MockUsers {
  MockUsers._();

  static final UserModel currentStudent = UserModel(
    id: 'usr_001',
    email: 'amina.hassan@gmail.com',
    fullName: 'Amina Hassan',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    role: UserRole.student,
    educationLevel: EducationLevel.form6,
    bio: 'Form 6 student at Kilakala Secondary School, passionate about technology and entrepreneurship. Aspiring software engineer.',
    location: 'Dodoma, Tanzania',
    skills: ['Mathematics', 'Physics', 'Python Basics', 'Critical Thinking'],
    interests: ['Software Engineering', 'AI/ML', 'Entrepreneurship', 'Finance'],
    schoolOrUniversity: 'Kilakala Secondary School',
    planId: 'free',
    isVerified: true,
    isProfileComplete: false,
    profileCompletionPercent: 65,
    createdAt: DateTime(2024, 9, 1),
    lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  static final UserModel studentUniversity = UserModel(
    id: 'usr_002',
    email: 'david.mwangi@udsm.ac.tz',
    fullName: 'David Mwangi',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    role: UserRole.student,
    educationLevel: EducationLevel.university,
    bio: 'Second year Computer Science student at UDSM. Building apps and learning AI.',
    location: 'Dar es Salaam, Tanzania',
    skills: ['Java', 'Flutter', 'Machine Learning', 'Data Structures'],
    interests: ['Software Engineering', 'Data Science', 'Startups'],
    schoolOrUniversity: 'University of Dar es Salaam',
    planId: 'pro',
    isVerified: true,
    isProfileComplete: true,
    profileCompletionPercent: 100,
    createdAt: DateTime(2023, 10, 15),
    lastActiveAt: DateTime.now().subtract(const Duration(minutes: 30)),
  );

  static final UserModel mentorUser = UserModel(
    id: 'usr_003',
    email: 'grace.kimaro@gmail.com',
    fullName: 'Grace Kimaro',
    avatarUrl: 'https://i.pravatar.cc/150?img=23',
    role: UserRole.mentor,
    bio: 'Senior Software Engineer at Vodacom Tanzania. 8+ years building scalable systems.',
    location: 'Dar es Salaam, Tanzania',
    skills: ['Python', 'Cloud Architecture', 'Leadership', 'System Design'],
    interests: ['Mentorship', 'EdTech', 'Women in Tech'],
    planId: 'premium',
    isVerified: true,
    isProfileComplete: true,
    profileCompletionPercent: 100,
    createdAt: DateTime(2023, 5, 20),
    lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  /// Guest user — no auth required
  static final UserModel guest = UserModel(
    id: 'usr_guest',
    email: '',
    fullName: 'Guest',
    role: UserRole.guest,
    planId: 'free',
    createdAt: DateTime.now(),
  );
}