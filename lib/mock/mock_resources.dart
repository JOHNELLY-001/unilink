import '../models/resource_model.dart';

/// Exposes resource mock data for use outside repositories.
class MockResources {
  MockResources._();

  static final List<ResourceModel> all = [
    ResourceModel(
      id: 'res_001',
      title: 'Complete TCU Application Guide 2025',
      description:
      'Step-by-step guide to applying to Tanzanian universities through the TCU portal.',
      type: ResourceType.guide,
      category: 'University Applications',
      isFree: true,
      isAiRecommended: true,
      viewCount: 8400,
      rating: 4.8,
      author: 'UniLink Team',
      publishedAt: DateTime(2024, 11, 1),
    ),
    ResourceModel(
      id: 'res_002',
      title: 'Software Engineering Career Roadmap',
      description:
      'Complete visual roadmap from Form 6 to Senior Software Engineer in Tanzania.',
      type: ResourceType.roadmap,
      category: 'Career Roadmaps',
      isFree: true,
      isAiRecommended: true,
      viewCount: 12100,
      rating: 4.9,
      author: 'Grace Kimaro',
      publishedAt: DateTime(2024, 10, 15),
    ),
  ];
}