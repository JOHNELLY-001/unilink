import '../../models/mentor_model.dart';
import '../../models/session_model.dart';

abstract class MentorRepository {
  /// Fetch paginated list of approved mentors.
  Future<List<MentorModel>> getMentors({
    int page = 1,
    int pageSize = 12,
    String? category,
    String? searchQuery,
    bool? availableOnly,
    bool? freeOnly,
  });

  /// Fetch a single mentor by ID.
  Future<MentorModel?> getMentorById(String mentorId);

  /// Fetch reviews for a mentor.
  Future<List<MentorReviewModel>> getMentorReviews(String mentorId);

  /// Book a session with a mentor.
  Future<SessionModel> bookSession({
    required String mentorId,
    required String studentId,
    required String topic,
    required DateTime scheduledAt,
    String? notes,
  });

  /// Cancel a previously booked session.
  Future<void> cancelSession(String sessionId);

  /// Fetch upcoming and past sessions for the current user.
  Future<List<SessionModel>> getMySessions({String? status});

  /// Submit a review for a completed session.
  Future<void> reviewSession({
    required String sessionId,
    required double rating,
    required String comment,
  });

  /// Apply to become a mentor (creates a pending application).
  Future<void> applyAsMentor({
    required Map<String, dynamic> applicationData,
  });

  /// Get mentors recommended for the current user by AI/algorithm.
  Future<List<MentorModel>> getRecommendedMentors(String userId);
}