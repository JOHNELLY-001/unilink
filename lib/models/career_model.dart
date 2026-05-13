import 'package:equatable/equatable.dart';

class CareerModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final String description;
  final String shortDescription;
  final List<String> requiredSkills;
  final List<String> recommendedSubjects;
  final SalaryInsightModel salaryInsight;
  final List<String> universityPathways;
  final List<String> careerPaths;
  final List<String> topCompanies;
  final String growthOutlook; // 'high' | 'medium' | 'low'
  final String demandLevel; // 'high' | 'medium' | 'low'
  final bool isTrending;
  final bool isSaved;
  final String colorHex;
  final String emoji;
  final int viewCount;
  final List<String> relatedCareers;

  const CareerModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.shortDescription,
    required this.requiredSkills,
    this.recommendedSubjects = const [],
    required this.salaryInsight,
    this.universityPathways = const [],
    this.careerPaths = const [],
    this.topCompanies = const [],
    this.growthOutlook = 'medium',
    this.demandLevel = 'medium',
    this.isTrending = false,
    this.isSaved = false,
    required this.colorHex,
    required this.emoji,
    this.viewCount = 0,
    this.relatedCareers = const [],
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String,
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      recommendedSubjects:
      List<String>.from(json['recommended_subjects'] ?? []),
      salaryInsight: SalaryInsightModel.fromJson(
          json['salary_insight'] as Map<String, dynamic>),
      universityPathways:
      List<String>.from(json['university_pathways'] ?? []),
      careerPaths: List<String>.from(json['career_paths'] ?? []),
      topCompanies: List<String>.from(json['top_companies'] ?? []),
      growthOutlook: json['growth_outlook'] as String? ?? 'medium',
      demandLevel: json['demand_level'] as String? ?? 'medium',
      isTrending: json['is_trending'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      colorHex: json['color_hex'] as String,
      emoji: json['emoji'] as String,
      viewCount: json['view_count'] as int? ?? 0,
      relatedCareers: List<String>.from(json['related_careers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'short_description': shortDescription,
    'required_skills': requiredSkills,
    'recommended_subjects': recommendedSubjects,
    'salary_insight': salaryInsight.toJson(),
    'university_pathways': universityPathways,
    'career_paths': careerPaths,
    'top_companies': topCompanies,
    'growth_outlook': growthOutlook,
    'demand_level': demandLevel,
    'is_trending': isTrending,
    'is_saved': isSaved,
    'color_hex': colorHex,
    'emoji': emoji,
    'view_count': viewCount,
    'related_careers': relatedCareers,
  };

  CareerModel copyWith({bool? isSaved}) {
    return CareerModel(
      id: id, title: title, category: category,
      description: description, shortDescription: shortDescription,
      requiredSkills: requiredSkills, recommendedSubjects: recommendedSubjects,
      salaryInsight: salaryInsight, universityPathways: universityPathways,
      careerPaths: careerPaths, topCompanies: topCompanies,
      growthOutlook: growthOutlook, demandLevel: demandLevel,
      isTrending: isTrending, isSaved: isSaved ?? this.isSaved,
      colorHex: colorHex, emoji: emoji,
      viewCount: viewCount, relatedCareers: relatedCareers,
    );
  }

  @override
  List<Object?> get props => [id, title, category, isSaved];
}

class SalaryInsightModel extends Equatable {
  final int entryLevelTzs;    // Tanzanian Shilling
  final int midLevelTzs;
  final int seniorLevelTzs;
  final String currency;
  final String period; // 'monthly' | 'annual'

  const SalaryInsightModel({
    required this.entryLevelTzs,
    required this.midLevelTzs,
    required this.seniorLevelTzs,
    this.currency = 'TZS',
    this.period = 'monthly',
  });

  String formatSalary(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  String get entryDisplay => '${currency} ${formatSalary(entryLevelTzs)}';
  String get midDisplay => '${currency} ${formatSalary(midLevelTzs)}';
  String get seniorDisplay => '${currency} ${formatSalary(seniorLevelTzs)}';

  factory SalaryInsightModel.fromJson(Map<String, dynamic> json) {
    return SalaryInsightModel(
      entryLevelTzs: json['entry_level_tzs'] as int,
      midLevelTzs: json['mid_level_tzs'] as int,
      seniorLevelTzs: json['senior_level_tzs'] as int,
      currency: json['currency'] as String? ?? 'TZS',
      period: json['period'] as String? ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() => {
    'entry_level_tzs': entryLevelTzs,
    'mid_level_tzs': midLevelTzs,
    'senior_level_tzs': seniorLevelTzs,
    'currency': currency,
    'period': period,
  };

  @override
  List<Object?> get props =>
      [entryLevelTzs, midLevelTzs, seniorLevelTzs, currency, period];
}