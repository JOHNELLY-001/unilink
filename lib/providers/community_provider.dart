import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import 'repository_providers.dart';

final communityFeedProvider = FutureProvider<List<PostModel>>((ref) async {
  final repo = ref.read(communityRepositoryProvider);
  return repo.getFeed();
});

final trendingPostsProvider = FutureProvider<List<PostModel>>((ref) async {
  final repo = ref.read(communityRepositoryProvider);
  return repo.getTrendingPosts();
});

final pinnedPostsProvider = FutureProvider<List<PostModel>>((ref) async {
  final repo = ref.read(communityRepositoryProvider);
  return repo.getPinnedPosts();
});