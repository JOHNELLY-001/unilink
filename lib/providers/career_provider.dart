import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

final selectedCareerCategoryProvider = StateProvider<String>((ref) => 'All');
final careerSearchQueryProvider = StateProvider<String>((ref) => '');

final careersProvider = FutureProvider<List<CareerModel>>((ref) async {
  final repo = ref.read(careerRepositoryProvider);
  final category = ref.watch(selectedCareerCategoryProvider);
  final query = ref.watch(careerSearchQueryProvider);
  return repo.getCareers(
    category: category == 'All' ? null : category,
    searchQuery: query.isEmpty ? null : query,
  );
});

final trendingCareersProvider = FutureProvider<List<CareerModel>>((ref) async {
  final repo = ref.read(careerRepositoryProvider);
  return repo.getTrendingCareers();
});

final careerDetailProvider =
FutureProvider.family<CareerModel?, String>((ref, careerId) async {
  final repo = ref.read(careerRepositoryProvider);
  return repo.getCareerById(careerId);
});

final savedCareersProvider = FutureProvider<List<CareerModel>>((ref) async {
  final repo = ref.read(careerRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getSavedCareers(user.id);
});

final careerCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(careerRepositoryProvider);
  return repo.getCareerCategories();
});

final recommendedCareersProvider = FutureProvider<List<CareerModel>>((ref) async {
  final repo = ref.read(careerRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getRecommendedCareers(user.id);
});