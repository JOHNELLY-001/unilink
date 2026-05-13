import '../../models/career_model.dart';

abstract class CareerRepository {
  /// Fetch all careers with optional filters.
  Future<List<CareerModel>> getCareers({
    String? category,
    String? searchQuery,
    bool? trendingOnly,
  });

  /// Fetch a single career by ID.
  Future<CareerModel?> getCareerById(String careerId);

  /// Fetch trending careers.
  Future<List<CareerModel>> getTrendingCareers();

  /// Fetch careers saved/bookmarked by the current user.
  Future<List<CareerModel>> getSavedCareers(String userId);

  /// Toggle save/unsave a career for the current user.
  Future<bool> toggleSaveCareer({
    required String userId,
    required String careerId,
  });

  /// Get AI-recommended careers based on user profile.
  Future<List<CareerModel>> getRecommendedCareers(String userId);

  /// Search careers by keyword.
  Future<List<CareerModel>> searchCareers(String query);

  /// Get list of all available career categories.
  Future<List<String>> getCareerCategories();
}