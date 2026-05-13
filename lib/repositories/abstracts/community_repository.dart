import '../../models/post_model.dart';

abstract class CommunityRepository {
  /// Fetch paginated community feed.
  Future<List<PostModel>> getFeed({
    int page = 1,
    int pageSize = 20,
    String? tag,
  });

  /// Fetch a single post by ID.
  Future<PostModel?> getPostById(String postId);

  /// Create a new post.
  Future<PostModel> createPost({
    required String authorId,
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
    PollModel? poll,
  });

  /// React to a post with an emoji.
  Future<void> reactToPost({
    required String postId,
    required String userId,
    required String emoji,
  });

  /// Remove a reaction from a post.
  Future<void> removeReaction({
    required String postId,
    required String userId,
  });

  /// Vote on a poll option.
  Future<void> voteOnPoll({
    required String postId,
    required String optionId,
    required String userId,
  });

  /// Fetch trending posts (most reactions/comments in last 24h).
  Future<List<PostModel>> getTrendingPosts();

  /// Fetch pinned/featured posts for the top of the feed.
  Future<List<PostModel>> getPinnedPosts();

  /// Delete a post (own posts only).
  Future<void> deletePost(String postId);
}