import 'package:equatable/equatable.dart';

class MentorModel extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String avatarUrl;
  final String title;
  final String company;
  final String bio;
  final List<String> expertise;
  final List<String> languages;
  final String location;
  final double rating;
  final int totalReviews;
  final int totalSessions;
  final int yearsOfExperience;
  final bool isAvailable;
  final bool isApproved;
  final String approvalStatus; // 'pending' | 'approved' | 'rejected'
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  final double sessionPriceUsd; // 0.0 = free
  final bool offersFreeIntro;
  final List<String> linkedInUrl;
  final List<MentorReviewModel> recentReviews;
  final String careerCategory;
  final DateTime joinedAt;

  const MentorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.avatarUrl,
    required this.title,
    required this.company,
    required this.bio,
    required this.expertise,
    this.languages = const ['English', 'Swahili'],
    required this.location,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSessions = 0,
    required this.yearsOfExperience,
    this.isAvailable = true,
    this.isApproved = false,
    this.approvalStatus = 'pending',
    this.availableDays = const [],
    this.availableTimeSlots = const [],
    this.sessionPriceUsd = 0.0,
    this.offersFreeIntro = true,
    this.linkedInUrl = const [],
    this.recentReviews = const [],
    required this.careerCategory,
    required this.joinedAt,
  });

  bool get isFree => sessionPriceUsd == 0.0;
  String get displayPrice =>
      isFree ? 'Free' : '\$${sessionPriceUsd.toStringAsFixed(0)}/session';

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      bio: json['bio'] as String,
      expertise: List<String>.from(json['expertise'] ?? []),
      languages: List<String>.from(
          json['languages'] ?? ['English', 'Swahili']),
      location: json['location'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      yearsOfExperience: json['years_of_experience'] as int,
      isAvailable: json['is_available'] as bool? ?? true,
      isApproved: json['is_approved'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      availableDays: List<String>.from(json['available_days'] ?? []),
      availableTimeSlots:
      List<String>.from(json['available_time_slots'] ?? []),
      sessionPriceUsd:
      (json['session_price_usd'] as num?)?.toDouble() ?? 0.0,
      offersFreeIntro: json['offers_free_intro'] as bool? ?? true,
      linkedInUrl: List<String>.from(json['linkedin_url'] ?? []),
      recentReviews: (json['recent_reviews'] as List<dynamic>? ?? [])
          .map((r) => MentorReviewModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      careerCategory: json['career_category'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'title': title,
    'company': company,
    'bio': bio,
    'expertise': expertise,
    'languages': languages,
    'location': location,
    'rating': rating,
    'total_reviews': totalReviews,
    'total_sessions': totalSessions,
    'years_of_experience': yearsOfExperience,
    'is_available': isAvailable,
    'is_approved': isApproved,
    'approval_status': approvalStatus,
    'available_days': availableDays,
    'available_time_slots': availableTimeSlots,
    'session_price_usd': sessionPriceUsd,
    'offers_free_intro': offersFreeIntro,
    'linkedin_url': linkedInUrl,
    'recent_reviews': recentReviews.map((r) => r.toJson()).toList(),
    'career_category': careerCategory,
    'joined_at': joinedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, userId, fullName, title, company, rating];
}

class MentorReviewModel extends Equatable {
  final String id;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const MentorReviewModel({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory MentorReviewModel.fromJson(Map<String, dynamic> json) {
    return MentorReviewModel(
      id: json['id'] as String,
      reviewerName: json['reviewer_name'] as String,
      reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewer_name': reviewerName,
    'reviewer_avatar_url': reviewerAvatarUrl,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, reviewerName, rating, comment];
}