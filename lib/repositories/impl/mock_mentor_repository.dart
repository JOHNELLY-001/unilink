import '../abstracts/mentor_repository.dart';
import '../../models/mentor_model.dart';
import '../../models/session_model.dart';
import '../../mock/mock_mentors.dart';

class MockMentorRepository implements MentorRepository {
  // Simulate in-memory session state
  final List<SessionModel> _sessions = _buildMockSessions();

  @override
  Future<List<MentorModel>> getMentors({
    int page = 1,
    int pageSize = 12,
    String? category,
    String? searchQuery,
    bool? availableOnly,
    bool? freeOnly,
  }) async {
    await _delay();
    var mentors = List<MentorModel>.from(MockMentors.all);

    if (category != null && category.isNotEmpty) {
      mentors = mentors
          .where((m) => m.careerCategory.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      mentors = mentors
          .where((m) =>
      m.fullName.toLowerCase().contains(q) ||
          m.title.toLowerCase().contains(q) ||
          m.expertise.any((e) => e.toLowerCase().contains(q)))
          .toList();
    }
    if (availableOnly == true) {
      mentors = mentors.where((m) => m.isAvailable).toList();
    }
    if (freeOnly == true) {
      mentors = mentors.where((m) => m.isFree).toList();
    }

    // Pagination
    final start = (page - 1) * pageSize;
    if (start >= mentors.length) return [];
    return mentors.sublist(start, (start + pageSize).clamp(0, mentors.length));
  }

  @override
  Future<MentorModel?> getMentorById(String mentorId) async {
    await _delay();
    return MockMentors.getById(mentorId);
  }

  @override
  Future<List<MentorReviewModel>> getMentorReviews(String mentorId) async {
    await _delay();
    return MockMentors.getById(mentorId)?.recentReviews ?? [];
  }

  @override
  Future<SessionModel> bookSession({
    required String mentorId,
    required String studentId,
    required String topic,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    await _delay(1200);
    final mentor = MockMentors.getById(mentorId);
    final session = SessionModel(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      mentorId: mentorId,
      mentorName: mentor?.fullName ?? 'Unknown Mentor',
      mentorAvatarUrl: mentor?.avatarUrl,
      studentId: studentId,
      topic: topic,
      notes: notes,
      scheduledAt: scheduledAt,
      durationMinutes: 45,
      status: SessionStatus.confirmed,
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await _delay(600);
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions.removeAt(idx);
    }
  }

  @override
  Future<List<SessionModel>> getMySessions({String? status}) async {
    await _delay();
    if (status == null) return List.from(_sessions);
    return _sessions
        .where((s) => s.status.name == status)
        .toList();
  }

  @override
  Future<void> reviewSession({
    required String sessionId,
    required double rating,
    required String comment,
  }) async {
    await _delay(600);
    // Mock: no-op — real impl updates DB record
  }

  @override
  Future<void> applyAsMentor({
    required Map<String, dynamic> applicationData,
  }) async {
    await _delay(1000);
    // Mock: no-op — real impl creates mentor application record
  }

  @override
  Future<List<MentorModel>> getRecommendedMentors(String userId) async {
    await _delay();
    // Return first 3 available mentors as recommendations
    return MockMentors.all
        .where((m) => m.isAvailable && m.isApproved)
        .take(3)
        .toList();
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));

  static List<SessionModel> _buildMockSessions() => [
    SessionModel(
      id: 'sess_001',
      mentorId: 'mtr_001',
      mentorName: 'Grace Kimaro',
      mentorAvatarUrl: 'https://i.pravatar.cc/150?img=23',
      studentId: 'usr_001',
      topic: 'Flutter Career Path & Portfolio Review',
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 10)),
      durationMinutes: 45,
      status: SessionStatus.confirmed,
    ),
    SessionModel(
      id: 'sess_002',
      mentorId: 'mtr_002',
      mentorName: 'James Tarimo',
      mentorAvatarUrl: 'https://i.pravatar.cc/150?img=15',
      studentId: 'usr_001',
      topic: 'Introduction to DSE Investing for Students',
      scheduledAt: DateTime.now().subtract(const Duration(days: 5)),
      durationMinutes: 45,
      status: SessionStatus.completed,
      rating: 5.0,
      reviewComment: 'Incredibly insightful session!',
    ),
  ];
}