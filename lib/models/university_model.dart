import 'package:equatable/equatable.dart';

class UniversityModel extends Equatable {
  final String id;
  final String name;
  final String shortName;
  final String location;
  final String? logoUrl;
  final String? websiteUrl;
  final List<String> availableCourses;
  final List<String> featuredPrograms;
  final int establishedYear;
  final String type; // 'public' | 'private'
  final String description;
  final bool isPartner;
  final double? ranking;

  const UniversityModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.location,
    this.logoUrl,
    this.websiteUrl,
    this.availableCourses = const [],
    this.featuredPrograms = const [],
    required this.establishedYear,
    required this.type,
    required this.description,
    this.isPartner = false,
    this.ranking,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) =>
      UniversityModel(
        id: json['id'] as String,
        name: json['name'] as String,
        shortName: json['short_name'] as String,
        location: json['location'] as String,
        logoUrl: json['logo_url'] as String?,
        websiteUrl: json['website_url'] as String?,
        availableCourses:
        List<String>.from(json['available_courses'] ?? []),
        featuredPrograms:
        List<String>.from(json['featured_programs'] ?? []),
        establishedYear: json['established_year'] as int,
        type: json['type'] as String,
        description: json['description'] as String,
        isPartner: json['is_partner'] as bool? ?? false,
        ranking: (json['ranking'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'short_name': shortName,
    'location': location, 'logo_url': logoUrl,
    'website_url': websiteUrl, 'available_courses': availableCourses,
    'featured_programs': featuredPrograms,
    'established_year': establishedYear, 'type': type,
    'description': description, 'is_partner': isPartner,
    'ranking': ranking,
  };

  @override
  List<Object?> get props => [id, name, shortName, location];
}