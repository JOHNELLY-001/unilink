import '../abstracts/resource_repository.dart';
import '../../models/resource_model.dart';

class MockResourceRepository implements ResourceRepository {
  final Set<String> _savedIds = {'res_002'};

  static final List<ResourceModel> _all = [
    ResourceModel(
      id: 'res_001',
      title: 'Complete TCU Application Guide 2025',
      description: 'Step-by-step guide to applying to Tanzanian universities through the TCU portal. Covers deadlines, required documents, and tips for a successful application.',
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
      description: 'A complete visual roadmap from Form 6 to Senior Software Engineer in Tanzania. Covers languages, frameworks, certifications, and job search strategies.',
      type: ResourceType.roadmap,
      category: 'Career Roadmaps',
      isFree: true,
      isAiRecommended: true,
      viewCount: 12100,
      rating: 4.9,
      author: 'Grace Kimaro',
      publishedAt: DateTime(2024, 10, 15),
    ),
    ResourceModel(
      id: 'res_003',
      title: 'A-Level Biology Revision Notes',
      description: 'Comprehensive revision notes for Tanzania A-Level Biology covering all topics from the NECTA syllabus. Includes past paper questions.',
      type: ResourceType.pdf,
      category: 'A-Level Revision',
      isFree: true,
      isAiRecommended: false,
      viewCount: 5600,
      rating: 4.6,
      author: 'Dr. Sarah Mwamba',
      publishedAt: DateTime(2024, 8, 20),
    ),
    ResourceModel(
      id: 'res_004',
      title: 'Introduction to Python Programming',
      description: 'Beginner-friendly video series teaching Python programming from scratch. Designed for Form 6 and university students in East Africa.',
      type: ResourceType.video,
      category: 'Programming',
      durationMinutes: 240,
      isFree: true,
      isAiRecommended: true,
      viewCount: 9800,
      rating: 4.7,
      author: 'David Mwangi',
      publishedAt: DateTime(2024, 9, 5),
    ),
    ResourceModel(
      id: 'res_005',
      title: 'Scholarship Application Masterclass',
      description: 'Learn how to write winning scholarship applications, craft compelling personal statements, and secure recommendation letters. Covers MasterCard Foundation and other major scholarships.',
      type: ResourceType.video,
      category: 'Scholarships',
      durationMinutes: 90,
      isFree: false,
      isAiRecommended: false,
      viewCount: 3200,
      rating: 4.9,
      author: 'UniLink Pro Team',
      publishedAt: DateTime(2024, 10, 1),
    ),
    ResourceModel(
      id: 'res_006',
      title: 'Finance Career in Tanzania — Complete Guide',
      description: 'Everything you need to know about building a career in Tanzanian banking and finance. Covers CRDB, NMB, IFM, CPA/ACCA qualifications, and DSE.',
      type: ResourceType.guide,
      category: 'Career Roadmaps',
      isFree: true,
      isAiRecommended: false,
      viewCount: 4100,
      rating: 4.5,
      author: 'James Tarimo',
      publishedAt: DateTime(2024, 11, 10),
    ),
  ];

  @override
  Future<List<ResourceModel>> getResources({
    String? category,
    ResourceType? type,
    bool? freeOnly,
    bool? aiRecommendedOnly,
    String? searchQuery,
  }) async {
    await _delay();
    var resources = _all.map((r) => r.copyWith(
      isSaved: _savedIds.contains(r.id),
    )).toList();

    if (category != null && category.isNotEmpty && category != 'All') {
      resources = resources.where((r) => r.category == category).toList();
    }
    if (type != null) {
      resources = resources.where((r) => r.type == type).toList();
    }
    if (freeOnly == true) {
      resources = resources.where((r) => r.isFree).toList();
    }
    if (aiRecommendedOnly == true) {
      resources = resources.where((r) => r.isAiRecommended).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      resources = resources
          .where((r) => r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q))
          .toList();
    }
    return resources;
  }

  @override
  Future<ResourceModel?> getResourceById(String resourceId) async {
    await _delay();
    try {
      final r = _all.firstWhere((r) => r.id == resourceId);
      return r.copyWith(isSaved: _savedIds.contains(resourceId));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ResourceModel>> getSavedResources(String userId) async {
    await _delay();
    return _all
        .where((r) => _savedIds.contains(r.id))
        .map((r) => r.copyWith(isSaved: true))
        .toList();
  }

  @override
  Future<bool> toggleSaveResource({
    required String userId,
    required String resourceId,
  }) async {
    await _delay(300);
    if (_savedIds.contains(resourceId)) {
      _savedIds.remove(resourceId);
      return false;
    } else {
      _savedIds.add(resourceId);
      return true;
    }
  }

  @override
  Future<List<ResourceModel>> getAiRecommendedResources(String userId) async {
    await _delay();
    return _all.where((r) => r.isAiRecommended).toList();
  }

  @override
  Future<List<String>> getResourceCategories() async {
    await _delay(200);
    return ['All', 'University Applications', 'Career Roadmaps', 'A-Level Revision', 'Programming', 'Scholarships'];
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));
}

// Extension to support copyWith on ResourceModel
extension ResourceModelCopyWith on ResourceModel {
  ResourceModel copyWith({bool? isSaved}) {
    return ResourceModel(
      id: id, title: title, description: description,
      type: type, category: category, thumbnailUrl: thumbnailUrl,
      fileUrl: fileUrl, externalUrl: externalUrl,
      durationMinutes: durationMinutes, pageCount: pageCount,
      isFree: isFree, isSaved: isSaved ?? this.isSaved,
      isAiRecommended: isAiRecommended, viewCount: viewCount,
      rating: rating, author: author, publishedAt: publishedAt,
    );
  }
}