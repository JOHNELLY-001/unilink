import 'package:equatable/equatable.dart';
import '../core/enums/opportunity_type.dart';

class OpportunityModel extends Equatable {
  final String id;
  final String title;
  final String organization;
  final String? organizationLogoUrl;
  final OpportunityType type;
  final String description;
  final String shortDescription;
  final String location;
  final bool isRemote;
  final DateTime deadline;
  final DateTime? startDate;
  final String? applicationUrl;
  final List<String> eligibility;
  final List<String> benefits;
  final List<String> requiredDocuments;
  final String? fundingAmount;
  final String? stipendAmount;
  final bool isBookmarked;
  final bool isFeatured;
  final bool isRecommended;
  final String applicationStatus; // 'not_applied'|'applied'|'shortlisted'|'rejected'
  final List<String> targetEducationLevels;
  final String careerCategory;
  final int applicationCount;
  final DateTime createdAt;

  const OpportunityModel({
    required this.id,
    required this.title,
    required this.organization,
    this.organizationLogoUrl,
    required this.type,
    required this.description,
    required this.shortDescription,
    required this.location,
    this.isRemote = false,
    required this.deadline,
    this.startDate,
    this.applicationUrl,
    this.eligibility = const [],
    this.benefits = const [],
    this.requiredDocuments = const [],
    this.fundingAmount,
    this.stipendAmount,
    this.isBookmarked = false,
    this.isFeatured = false,
    this.isRecommended = false,
    this.applicationStatus = 'not_applied',
    this.targetEducationLevels = const [],
    required this.careerCategory,
    this.applicationCount = 0,
    required this.createdAt,
  });

  bool get isDeadlineSoon {
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    return daysLeft <= 7 && daysLeft >= 0;
  }

  bool get isExpired => deadline.isBefore(DateTime.now());

  int get daysUntilDeadline =>
      deadline.difference(DateTime.now()).inDays;

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      organization: json['organization'] as String,
      organizationLogoUrl: json['organization_logo_url'] as String?,
      type: OpportunityType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => OpportunityType.event,
      ),
      description: json['description'] as String,
      shortDescription: json['short_description'] as String,
      location: json['location'] as String,
      isRemote: json['is_remote'] as bool? ?? false,
      deadline: DateTime.parse(json['deadline'] as String),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      applicationUrl: json['application_url'] as String?,
      eligibility: List<String>.from(json['eligibility'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      requiredDocuments:
      List<String>.from(json['required_documents'] ?? []),
      fundingAmount: json['funding_amount'] as String?,
      stipendAmount: json['stipend_amount'] as String?,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? false,
      applicationStatus:
      json['application_status'] as String? ?? 'not_applied',
      targetEducationLevels:
      List<String>.from(json['target_education_levels'] ?? []),
      careerCategory: json['career_category'] as String,
      applicationCount: json['application_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'organization': organization,
    'organization_logo_url': organizationLogoUrl,
    'type': type.name,
    'description': description,
    'short_description': shortDescription,
    'location': location,
    'is_remote': isRemote,
    'deadline': deadline.toIso8601String(),
    'start_date': startDate?.toIso8601String(),
    'application_url': applicationUrl,
    'eligibility': eligibility,
    'benefits': benefits,
    'required_documents': requiredDocuments,
    'funding_amount': fundingAmount,
    'stipend_amount': stipendAmount,
    'is_bookmarked': isBookmarked,
    'is_featured': isFeatured,
    'is_recommended': isRecommended,
    'application_status': applicationStatus,
    'target_education_levels': targetEducationLevels,
    'career_category': careerCategory,
    'application_count': applicationCount,
    'created_at': createdAt.toIso8601String(),
  };

  OpportunityModel copyWith({bool? isBookmarked, String? applicationStatus}) {
    return OpportunityModel(
      id: id, title: title, organization: organization,
      organizationLogoUrl: organizationLogoUrl, type: type,
      description: description, shortDescription: shortDescription,
      location: location, isRemote: isRemote, deadline: deadline,
      startDate: startDate, applicationUrl: applicationUrl,
      eligibility: eligibility, benefits: benefits,
      requiredDocuments: requiredDocuments, fundingAmount: fundingAmount,
      stipendAmount: stipendAmount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFeatured: isFeatured, isRecommended: isRecommended,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      targetEducationLevels: targetEducationLevels,
      careerCategory: careerCategory,
      applicationCount: applicationCount, createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, organization, type, isBookmarked, applicationStatus];
}