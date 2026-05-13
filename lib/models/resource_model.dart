import 'package:equatable/equatable.dart';

class ResourceModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String category;
  final String? thumbnailUrl;
  final String? fileUrl;
  final String? externalUrl;
  final int? durationMinutes;
  final int? pageCount;
  final bool isFree;
  final bool isSaved;
  final bool isAiRecommended;
  final int viewCount;
  final double rating;
  final String author;
  final DateTime publishedAt;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.thumbnailUrl,
    this.fileUrl,
    this.externalUrl,
    this.durationMinutes,
    this.pageCount,
    this.isFree = true,
    this.isSaved = false,
    this.isAiRecommended = false,
    this.viewCount = 0,
    this.rating = 0.0,
    required this.author,
    required this.publishedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) => ResourceModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    type: ResourceType.values.firstWhere(
          (t) => t.name == json['type'],
      orElse: () => ResourceType.guide,
    ),
    category: json['category'] as String,
    thumbnailUrl: json['thumbnail_url'] as String?,
    fileUrl: json['file_url'] as String?,
    externalUrl: json['external_url'] as String?,
    durationMinutes: json['duration_minutes'] as int?,
    pageCount: json['page_count'] as int?,
    isFree: json['is_free'] as bool? ?? true,
    isSaved: json['is_saved'] as bool? ?? false,
    isAiRecommended: json['is_ai_recommended'] as bool? ?? false,
    viewCount: json['view_count'] as int? ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    author: json['author'] as String,
    publishedAt: DateTime.parse(json['published_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'type': type.name, 'category': category,
    'thumbnail_url': thumbnailUrl, 'file_url': fileUrl,
    'external_url': externalUrl, 'duration_minutes': durationMinutes,
    'page_count': pageCount, 'is_free': isFree, 'is_saved': isSaved,
    'is_ai_recommended': isAiRecommended, 'view_count': viewCount,
    'rating': rating, 'author': author,
    'published_at': publishedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, title, type, category, isSaved];
}

enum ResourceType { pdf, video, guide, article, roadmap, template }