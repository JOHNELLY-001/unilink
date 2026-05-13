import '../abstracts/community_repository.dart';
import '../../models/post_model.dart';
import '../../mock/mock_posts.dart';

class MockCommunityRepository implements CommunityRepository {
  // In-memory state for reactions and votes
  final List<PostModel> _posts = List.from(MockPosts.feed);

  @override
  Future<List<PostModel>> getFeed({
    int page = 1,
    int pageSize = 20,
    String? tag,
  }) async {
    await _delay();
    var posts = List<PostModel>.from(_posts);
    if (tag != null && tag.isNotEmpty) {
      posts = posts
          .where((p) => p.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
          .toList();
    }
    // Sort: pinned first, then by date
    posts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    final start = (page - 1) * pageSize;
    if (start >= posts.length) return [];
    return posts.sublist(start, (start + pageSize).clamp(0, posts.length));
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    await _delay();
    try {
      return _posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PostModel> createPost({
    required String authorId,
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
    PollModel? poll,
  }) async {
    await _delay(800);
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: 'You',
      authorRole: 'student',
      content: content,
      imageUrls: imageUrls,
      tags: tags,
      type: poll != null ? PostType.poll : PostType.text,
      poll: poll,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<void> reactToPost({
    required String postId,
    required String userId,
    required String emoji,
  }) async {
    await _delay(300);
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    final updatedReactions = Map<String, int>.from(post.reactions);
    updatedReactions[emoji] = (updatedReactions[emoji] ?? 0) + 1;
    _posts[idx] = PostModel(
      id: post.id, authorId: post.authorId, authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl, authorRole: post.authorRole,
      authorTitle: post.authorTitle, content: post.content,
      imageUrls: post.imageUrls, reactions: updatedReactions,
      userReaction: emoji, commentCount: post.commentCount,
      shareCount: post.shareCount, tags: post.tags,
      isPinned: post.isPinned, isFeatured: post.isFeatured,
      type: post.type, poll: post.poll,
      linkedOpportunityId: post.linkedOpportunityId,
      createdAt: post.createdAt, isLikedByUser: true,
    );
  }

  @override
  Future<void> removeReaction({
    required String postId,
    required String userId,
  }) async {
    await _delay(300);
    // Mock: no-op for now — full impl removes specific emoji reaction
  }

  @override
  Future<void> voteOnPoll({
    required String postId,
    required String optionId,
    required String userId,
  }) async {
    await _delay(400);
    // Mock: no-op — real impl updates vote count in DB
  }

  @override
  Future<List<PostModel>> getTrendingPosts() async {
    await _delay();
    final posts = List<PostModel>.from(_posts);
    posts.sort((a, b) => b.totalReactions.compareTo(a.totalReactions));
    return posts.take(5).toList();
  }

  @override
  Future<List<PostModel>> getPinnedPosts() async {
    await _delay();
    return _posts.where((p) => p.isPinned).toList();
  }

  @override
  Future<void> deletePost(String postId) async {
    await _delay(400);
    _posts.removeWhere((p) => p.id == postId);
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));
}