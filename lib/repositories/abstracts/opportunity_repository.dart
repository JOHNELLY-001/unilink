import '../../models/opportunity_model.dart';
import '../../core/enums/opportunity_type.dart';

abstract class OpportunityRepository {
  /// Fetch all opportunities with optional filters.
  Future<List<OpportunityModel>> getOpportunities({
    OpportunityType? type,
    String? careerCategory,
    String? educationLevel,
    bool? remoteOnly,
    bool? deadlineSoonOnly,
    String? searchQuery,
    int page = 1,
    int pageSize = 15,
  });

  /// Fetch a single opportunity by ID.
  Future<OpportunityModel?> getOpportunityById(String opportunityId);

  /// Fetch featured opportunities.
  Future<List<OpportunityModel>> getFeaturedOpportunities();

  /// Fetch opportunities recommended for the current user.
  Future<List<OpportunityModel>> getRecommendedOpportunities(String userId);

  /// Fetch opportunities bookmarked by the current user.
  Future<List<OpportunityModel>> getBookmarkedOpportunities(String userId);

  /// Toggle bookmark on an opportunity.
  Future<bool> toggleBookmark({
    required String userId,
    required String opportunityId,
  });

  /// Track that the user applied to an opportunity.
  Future<void> markAsApplied({
    required String userId,
    required String opportunityId,
  });

  /// Fetch opportunities with deadlines within [days] days.
  Future<List<OpportunityModel>> getDeadlineSoon({int days = 7});
}