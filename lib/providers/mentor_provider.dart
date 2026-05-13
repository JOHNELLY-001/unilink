import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mentor_model.dart';
import '../models/session_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

// ─── Mentor list with filters ─────────────────────────────────────────────

class MentorFilter {
  final String? category;
  final String? searchQuery;
  final bool availableOnly;
  final bool freeOnly;

  const MentorFilter({
    this.category,
    this.searchQuery,
    this.availableOnly = false,
    this.freeOnly = false,
  });

  MentorFilter copyWith({
    String? category,
    String? searchQuery,
    bool? availableOnly,
    bool? freeOnly,
  }) =>
      MentorFilter(
        category: category ?? this.category,
        searchQuery: searchQuery ?? this.searchQuery,
        availableOnly: availableOnly ?? this.availableOnly,
        freeOnly: freeOnly ?? this.freeOnly,
      );
}

final mentorFilterProvider =
StateProvider<MentorFilter>((ref) => const MentorFilter());

final mentorsProvider = FutureProvider<List<MentorModel>>((ref) async {
  final repo = ref.read(mentorRepositoryProvider);
  final filter = ref.watch(mentorFilterProvider);
  return repo.getMentors(
    category: filter.category,
    searchQuery: filter.searchQuery,
    availableOnly: filter.availableOnly ? true : null,
    freeOnly: filter.freeOnly ? true : null,
  );
});

final mentorDetailProvider =
FutureProvider.family<MentorModel?, String>((ref, mentorId) async {
  final repo = ref.read(mentorRepositoryProvider);
  return repo.getMentorById(mentorId);
});

final recommendedMentorsProvider = FutureProvider<List<MentorModel>>((ref) async {
  final repo = ref.read(mentorRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getRecommendedMentors(user.id);
});

final mySessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  final repo = ref.read(mentorRepositoryProvider);
  return repo.getMySessions();
});

final upcomingSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  final sessions = await ref.watch(mySessionsProvider.future);
  return sessions.where((s) => s.isUpcoming).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
});