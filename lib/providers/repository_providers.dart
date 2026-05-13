import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Abstract imports ─────────────────────────────────────────────────────
import '../repositories/abstracts/auth_repository.dart';
import '../repositories/abstracts/mentor_repository.dart';
import '../repositories/abstracts/career_repository.dart';
import '../repositories/abstracts/opportunity_repository.dart';
import '../repositories/abstracts/community_repository.dart';
import '../repositories/abstracts/message_repository.dart';
import '../repositories/abstracts/ai_repository.dart';
import '../repositories/abstracts/progress_repository.dart';
import '../repositories/abstracts/resource_repository.dart';

// ─── Mock implementations ─────────────────────────────────────────────────
import '../repositories/impl/mock_auth_repository.dart';
import '../repositories/impl/mock_mentor_repository.dart';
import '../repositories/impl/mock_career_repository.dart';
import '../repositories/impl/mock_opportunity_repository.dart';
import '../repositories/impl/mock_community_repository.dart';
import '../repositories/impl/mock_message_repository.dart';
import '../repositories/impl/mock_ai_repository.dart';
import '../repositories/impl/mock_progress_repository.dart';
import '../repositories/impl/mock_resource_repository.dart';

// ─── Services ─────────────────────────────────────────────────────────────
import '../services/abstracts/storage_service.dart';
import '../services/impl/local_storage_service.dart';

/// ════════════════════════════════════════════════════════════════════════
/// REPOSITORY PROVIDERS
///
/// TO SWITCH FROM MOCK → REAL API:
/// Change MockXRepository() → ApiXRepository() in the provider below.
/// That is the ONLY change needed. All UI and business logic stays the same.
/// ════════════════════════════════════════════════════════════════════════

final storageServiceProvider = Provider<StorageService>(
      (ref) => LocalStorageService(),
);

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => MockAuthRepository(),
  // TODO: swap → ApiAuthRepository(ref.read(storageServiceProvider))
);

final mentorRepositoryProvider = Provider<MentorRepository>(
      (ref) => MockMentorRepository(),
  // TODO: swap → ApiMentorRepository(baseUrl: ApiConstants.baseUrl)
);

final careerRepositoryProvider = Provider<CareerRepository>(
      (ref) => MockCareerRepository(),
);

final opportunityRepositoryProvider = Provider<OpportunityRepository>(
      (ref) => MockOpportunityRepository(),
);

final communityRepositoryProvider = Provider<CommunityRepository>(
      (ref) => MockCommunityRepository(),
);

final messageRepositoryProvider = Provider<MessageRepository>(
      (ref) => MockMessageRepository(),
);

final aiRepositoryProvider = Provider<AiRepository>(
      (ref) => MockAiRepository(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
      (ref) => MockProgressRepository(),
);

final resourceRepositoryProvider = Provider<ResourceRepository>(
      (ref) => MockResourceRepository(),
);