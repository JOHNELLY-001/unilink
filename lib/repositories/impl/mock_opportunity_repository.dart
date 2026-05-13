import '../abstracts/opportunity_repository.dart';
import '../../models/opportunity_model.dart';
import '../../core/enums/opportunity_type.dart';
import '../../mock/mock_opportunities.dart';

class MockOpportunityRepository implements OpportunityRepository {
  final Set<String> _bookmarkedIds = {'opp_002'};
  final Map<String, String> _applicationStatuses = {};

  @override
  Future<List<OpportunityModel>> getOpportunities({
    OpportunityType? type,
    String? careerCategory,
    String? educationLevel,
    bool? remoteOnly,
    bool? deadlineSoonOnly,
    String? searchQuery,
    int page = 1,
    int pageSize = 15,
  }) async {
    await _delay();
    var opps = MockOpportunities.all.map((o) => o.copyWith(
      isBookmarked: _bookmarkedIds.contains(o.id),
      applicationStatus:
      _applicationStatuses[o.id] ?? o.applicationStatus,
    )).toList();

    if (type != null) {
      opps = opps.where((o) => o.type == type).toList();
    }
    if (remoteOnly == true) {
      opps = opps.where((o) => o.isRemote).toList();
    }
    if (deadlineSoonOnly == true) {
      opps = opps.where((o) => o.isDeadlineSoon).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      opps = opps
          .where((o) =>
      o.title.toLowerCase().contains(q) ||
          o.organization.toLowerCase().contains(q))
          .toList();
    }

    final start = (page - 1) * pageSize;
    if (start >= opps.length) return [];
    return opps.sublist(start, (start + pageSize).clamp(0, opps.length));
  }

  @override
  Future<OpportunityModel?> getOpportunityById(String opportunityId) async {
    await _delay();
    final opp = MockOpportunities.getById(opportunityId);
    if (opp == null) return null;
    return opp.copyWith(
      isBookmarked: _bookmarkedIds.contains(opportunityId),
      applicationStatus: _applicationStatuses[opportunityId] ?? opp.applicationStatus,
    );
  }

  @override
  Future<List<OpportunityModel>> getFeaturedOpportunities() async {
    await _delay();
    return MockOpportunities.getFeatured().map((o) => o.copyWith(
      isBookmarked: _bookmarkedIds.contains(o.id),
    )).toList();
  }

  @override
  Future<List<OpportunityModel>> getRecommendedOpportunities(String userId) async {
    await _delay();
    return MockOpportunities.getRecommended().map((o) => o.copyWith(
      isBookmarked: _bookmarkedIds.contains(o.id),
    )).toList();
  }

  @override
  Future<List<OpportunityModel>> getBookmarkedOpportunities(String userId) async {
    await _delay();
    return MockOpportunities.all
        .where((o) => _bookmarkedIds.contains(o.id))
        .map((o) => o.copyWith(isBookmarked: true))
        .toList();
  }

  @override
  Future<bool> toggleBookmark({
    required String userId,
    required String opportunityId,
  }) async {
    await _delay(300);
    if (_bookmarkedIds.contains(opportunityId)) {
      _bookmarkedIds.remove(opportunityId);
      return false;
    } else {
      _bookmarkedIds.add(opportunityId);
      return true;
    }
  }

  @override
  Future<void> markAsApplied({
    required String userId,
    required String opportunityId,
  }) async {
    await _delay(500);
    _applicationStatuses[opportunityId] = 'applied';
  }

  @override
  Future<List<OpportunityModel>> getDeadlineSoon({int days = 7}) async {
    await _delay();
    return MockOpportunities.all
        .where((o) => o.daysUntilDeadline <= days && o.daysUntilDeadline >= 0)
        .map((o) => o.copyWith(isBookmarked: _bookmarkedIds.contains(o.id)))
        .toList();
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));
}