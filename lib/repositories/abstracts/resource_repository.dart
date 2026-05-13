import '../../models/resource_model.dart';

abstract class ResourceRepository {
  Future<List<ResourceModel>> getResources({
    String? category,
    ResourceType? type,
    bool? freeOnly,
    bool? aiRecommendedOnly,
    String? searchQuery,
  });

  Future<ResourceModel?> getResourceById(String resourceId);

  Future<List<ResourceModel>> getSavedResources(String userId);

  Future<bool> toggleSaveResource({
    required String userId,
    required String resourceId,
  });

  Future<List<ResourceModel>> getAiRecommendedResources(String userId);

  Future<List<String>> getResourceCategories();
}