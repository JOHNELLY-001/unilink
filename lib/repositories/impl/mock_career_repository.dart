import '../abstracts/career_repository.dart';
import '../../models/career_model.dart';
import '../../mock/mock_careers.dart';

class MockCareerRepository implements CareerRepository {
  // Tracks user-saved careers in memory
  // Real impl: reads from DB via userId foreign key
  final Set<String> _savedCareerIds = {'car_001', 'car_008'};

  @override
  Future<List<CareerModel>> getCareers({
    String? category,
    String? searchQuery,
    bool? trendingOnly,
  }) async {
    await _delay();
    var careers = MockCareers.all.map((c) => c.copyWith(
      isSaved: _savedCareerIds.contains(c.id),
    )).toList();

    if (category != null && category.isNotEmpty && category != 'All') {
      careers = careers
          .where((c) => c.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      careers = careers
          .where((c) =>
      c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.shortDescription.toLowerCase().contains(q))
          .toList();
    }
    if (trendingOnly == true) {
      careers = careers.where((c) => c.isTrending).toList();
    }
    return careers;
  }

  @override
  Future<CareerModel?> getCareerById(String careerId) async {
    await _delay();
    final career = MockCareers.getById(careerId);
    if (career == null) return null;
    return career.copyWith(isSaved: _savedCareerIds.contains(careerId));
  }

  @override
  Future<List<CareerModel>> getTrendingCareers() async {
    await _delay();
    return MockCareers.getTrending().map((c) => c.copyWith(
      isSaved: _savedCareerIds.contains(c.id),
    )).toList();
  }

  @override
  Future<List<CareerModel>> getSavedCareers(String userId) async {
    await _delay();
    return MockCareers.all
        .where((c) => _savedCareerIds.contains(c.id))
        .map((c) => c.copyWith(isSaved: true))
        .toList();
  }

  @override
  Future<bool> toggleSaveCareer({
    required String userId,
    required String careerId,
  }) async {
    await _delay(300);
    if (_savedCareerIds.contains(careerId)) {
      _savedCareerIds.remove(careerId);
      return false; // now unsaved
    } else {
      _savedCareerIds.add(careerId);
      return true; // now saved
    }
  }

  @override
  Future<List<CareerModel>> getRecommendedCareers(String userId) async {
    await _delay();
    // Mock: return tech-focused careers as recommendations
    return MockCareers.all
        .where((c) => c.category == 'Technology')
        .take(4)
        .map((c) => c.copyWith(isSaved: _savedCareerIds.contains(c.id)))
        .toList();
  }

  @override
  Future<List<CareerModel>> searchCareers(String query) async {
    return getCareers(searchQuery: query);
  }

  @override
  Future<List<String>> getCareerCategories() async {
    await _delay(200);
    return ['All', 'Technology', 'Healthcare', 'Business', 'Finance', 'Law', 'Design', 'Education'];
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));
}