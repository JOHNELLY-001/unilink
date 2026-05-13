import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opportunity_model.dart';
import '../core/enums/opportunity_type.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

final selectedOpportunityTypeProvider =
StateProvider<OpportunityType?>((ref) => null);

final opportunitiesProvider =
FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.read(opportunityRepositoryProvider);
  final type = ref.watch(selectedOpportunityTypeProvider);
  return repo.getOpportunities(type: type);
});

final featuredOpportunitiesProvider =
FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.read(opportunityRepositoryProvider);
  return repo.getFeaturedOpportunities();
});

final recommendedOpportunitiesProvider =
FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.read(opportunityRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getRecommendedOpportunities(user.id);
});

final deadlineSoonOpportunitiesProvider =
FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.read(opportunityRepositoryProvider);
  return repo.getDeadlineSoon();
});

final bookmarkedOpportunitiesProvider =
FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.read(opportunityRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getBookmarkedOpportunities(user.id);
});

final opportunityDetailProvider =
FutureProvider.family<OpportunityModel?, String>(
        (ref, opportunityId) async {
      final repo = ref.read(opportunityRepositoryProvider);
      return repo.getOpportunityById(opportunityId);
    });