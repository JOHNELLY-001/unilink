import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final String id;
  final String mentorId;
  final String mentorName;
  final String? mentorAvatarUrl;
  final String studentId;
  final String topic;
  final String? notes;
  final DateTime scheduledAt;
  final int durationMinutes;
  final SessionStatus status;
  final String? meetingUrl;
  final double? rating;
  final String? reviewComment;

  const SessionModel({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    this.mentorAvatarUrl,
    required this.studentId,
    required this.topic,
    this.notes,
    required this.scheduledAt,
    this.durationMinutes = 45,
    required this.status,
    this.meetingUrl,
    this.rating,
    this.reviewComment,
  });

  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) &&
          status == SessionStatus.confirmed;

  bool get isPast =>
      scheduledAt.isBefore(DateTime.now()) ||
          status == SessionStatus.completed;

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    id: json['id'] as String,
    mentorId: json['mentor_id'] as String,
    mentorName: json['mentor_name'] as String,
    mentorAvatarUrl: json['mentor_avatar_url'] as String?,
    studentId: json['student_id'] as String,
    topic: json['topic'] as String,
    notes: json['notes'] as String?,
    scheduledAt: DateTime.parse(json['scheduled_at'] as String),
    durationMinutes: json['duration_minutes'] as int? ?? 45,
    status: SessionStatus.values.firstWhere(
          (s) => s.name == json['status'],
      orElse: () => SessionStatus.pending,
    ),
    meetingUrl: json['meeting_url'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    reviewComment: json['review_comment'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'mentor_id': mentorId, 'mentor_name': mentorName,
    'mentor_avatar_url': mentorAvatarUrl, 'student_id': studentId,
    'topic': topic, 'notes': notes,
    'scheduled_at': scheduledAt.toIso8601String(),
    'duration_minutes': durationMinutes, 'status': status.name,
    'meeting_url': meetingUrl, 'rating': rating,
    'review_comment': reviewComment,
  };

  @override
  List<Object?> get props => [id, mentorId, studentId, scheduledAt, status];
}

enum SessionStatus { pending, confirmed, completed, cancelled, noShow }