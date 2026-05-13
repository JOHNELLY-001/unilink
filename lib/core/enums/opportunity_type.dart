enum OpportunityType {
  scholarship,
  internship,
  bootcamp,
  competition,
  workshop,
  event,
  universityProgram;

  String get displayName {
    switch (this) {
      case OpportunityType.scholarship:
        return 'Scholarship';
      case OpportunityType.internship:
        return 'Internship';
      case OpportunityType.bootcamp:
        return 'Bootcamp';
      case OpportunityType.competition:
        return 'Competition';
      case OpportunityType.workshop:
        return 'Workshop';
      case OpportunityType.event:
        return 'Event';
      case OpportunityType.universityProgram:
        return 'University Program';
    }
  }

  String get emoji {
    switch (this) {
      case OpportunityType.scholarship:
        return '🎓';
      case OpportunityType.internship:
        return '💼';
      case OpportunityType.bootcamp:
        return '🚀';
      case OpportunityType.competition:
        return '🏆';
      case OpportunityType.workshop:
        return '🛠️';
      case OpportunityType.event:
        return '📅';
      case OpportunityType.universityProgram:
        return '🏛️';
    }
  }
}