import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String authorRole;
  final String? authorTitle;
  final String content;
  final List<String> imageUrls;
  final Map<String, int> reactions; // emoji → count
  final String? userReaction;
  final int commentCount;
  final int shareCount;
  final List<String> tags;
  final bool isPinned;
  final bool isFeatured;
  final PostType type;
  final PollModel? poll;
  final String? linkedOpportunityId;
  final DateTime createdAt;
  final bool isLikedByUser;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.authorRole,
    this.authorTitle,
    required this.content,
    this.imageUrls = const [],
    this.reactions = const {},
    this.userReaction,
    this.commentCount = 0,
    this.shareCount = 0,
    this.tags = const [],
    this.isPinned = false,
    this.isFeatured = false,
    this.type = PostType.text,
    this.poll,
    this.linkedOpportunityId,
    required this.createdAt,
    this.isLikedByUser = false,
  });

  int get totalReactions =>
      reactions.values.fold(0, (sum, count) => sum + count);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorRole: json['author_role'] as String,
      authorTitle: json['author_title'] as String?,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
      userReaction: json['user_reaction'] as String?,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['is_pinned'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      type: PostType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => PostType.text,
      ),
      poll: json['poll'] != null
          ? PollModel.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      linkedOpportunityId: json['linked_opportunity_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isLikedByUser: json['is_liked_by_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'author_id': authorId, 'author_name': authorName,
    'author_avatar_url': authorAvatarUrl, 'author_role': authorRole,
    'author_title': authorTitle, 'content': content,
    'image_urls': imageUrls, 'reactions': reactions,
    'user_reaction': userReaction, 'comment_count': commentCount,
    'share_count': shareCount, 'tags': tags, 'is_pinned': isPinned,
    'is_featured': isFeatured, 'type': type.name,
    'poll': poll?.toJson(),
    'linked_opportunity_id': linkedOpportunityId,
    'created_at': createdAt.toIso8601String(),
    'is_liked_by_user': isLikedByUser,
  };

  @override
  List<Object?> get props => [id, authorId, content, createdAt, totalReactions];
}

enum PostType { text, image, poll, achievement, opportunity }

class PollModel extends Equatable {
  final String question;
  final List<PollOptionModel> options;
  final DateTime endsAt;
  final bool hasVoted;
  final String? userVotedOptionId;

  const PollModel({
    required this.question,
    required this.options,
    required this.endsAt,
    this.hasVoted = false,
    this.userVotedOptionId,
  });

  int get totalVotes =>
      options.fold(0, (sum, o) => sum + o.voteCount);

  factory PollModel.fromJson(Map<String, dynamic> json) => PollModel(
    question: json['question'] as String,
    options: (json['options'] as List<dynamic>)
        .map((o) =>
        PollOptionModel.fromJson(o as Map<String, dynamic>))
        .toList(),
    endsAt: DateTime.parse(json['ends_at'] as String),
    hasVoted: json['has_voted'] as bool? ?? false,
    userVotedOptionId: json['user_voted_option_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options.map((o) => o.toJson()).toList(),
    'ends_at': endsAt.toIso8601String(),
    'has_voted': hasVoted,
    'user_voted_option_id': userVotedOptionId,
  };

  @override
  List<Object?> get props => [question, endsAt, totalVotes];
}

class PollOptionModel extends Equatable {
  final String id;
  final String text;
  final int voteCount;

  const PollOptionModel({
    required this.id,
    required this.text,
    this.voteCount = 0,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      PollOptionModel(
        id: json['id'] as String,
        text: json['text'] as String,
        voteCount: json['vote_count'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'vote_count': voteCount};

  @override
  List<Object?> get props => [id, text, voteCount];
}