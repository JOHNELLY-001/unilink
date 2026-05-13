import '../models/opportunity_model.dart';
import '../core/enums/opportunity_type.dart';

class MockOpportunities {
  MockOpportunities._();

  static final List<OpportunityModel> all = [
    OpportunityModel(
      id: 'opp_001',
      title: 'MasterCard Foundation Scholars Program',
      organization: 'MasterCard Foundation',
      type: OpportunityType.scholarship,
      shortDescription: 'Full scholarship for academically talented but financially disadvantaged students from Africa.',
      description: 'The MasterCard Foundation Scholars Program provides full scholarships to students from Africa who demonstrate academic talent and financial need. The program covers tuition, accommodation, meals, travel, and a stipend. Recipients also receive mentoring, leadership training, and networking opportunities.',
      location: 'Multiple African Universities',
      isRemote: false,
      deadline: DateTime.now().add(const Duration(days: 45)),
      startDate: DateTime(2025, 8, 1),
      eligibility: [
        'Tanzanian or African citizen',
        'Form 6 graduate or current university student',
        'Demonstrated financial need',
        'Academic excellence (minimum B+ average)',
        'Leadership potential',
      ],
      benefits: [
        'Full tuition coverage',
        'Accommodation and meals',
        'Return air travel',
        'Monthly stipend',
        'Mentorship program',
        'Leadership training',
      ],
      requiredDocuments: ['Academic transcripts', 'Financial need letter', 'Two recommendation letters', 'Personal statement'],
      fundingAmount: 'Full scholarship (estimated \$50,000+)',
      isBookmarked: false,
      isFeatured: true,
      isRecommended: true,
      careerCategory: 'All Fields',
      applicationCount: 3400,
      createdAt: DateTime(2024, 10, 1),
      targetEducationLevels: ['form6', 'university'],
    ),

    OpportunityModel(
      id: 'opp_002',
      title: 'Software Engineering Intern',
      organization: 'Vodacom Tanzania',
      type: OpportunityType.internship,
      shortDescription: '3-month paid internship in the technology and digital team at Vodacom Tanzania.',
      description: 'Join Vodacom Tanzania\'s technology team for a 3-month hands-on internship. You will work alongside experienced engineers on real products used by millions of Tanzanians. Projects include mobile money systems, network monitoring tools, and customer experience applications.',
      location: 'Dar es Salaam, Tanzania',
      isRemote: false,
      deadline: DateTime.now().add(const Duration(days: 18)),
      startDate: DateTime(2025, 2, 1),
      eligibility: [
        'Final year Computer Science or Engineering student',
        'Knowledge of at least one programming language',
        'Available for 3 months full-time',
      ],
      benefits: [
        'Monthly stipend (TZS 500,000)',
        'Mentorship from senior engineers',
        'Possible full-time offer',
        'Certificate of completion',
      ],
      requiredDocuments: ['CV', 'Transcripts', 'Cover letter'],
      stipendAmount: 'TZS 500,000/month',
      isBookmarked: true,
      isFeatured: true,
      isRecommended: true,
      applicationStatus: 'not_applied',
      careerCategory: 'Software Engineering',
      applicationCount: 287,
      createdAt: DateTime(2024, 12, 1),
      targetEducationLevels: ['university'],
    ),

    OpportunityModel(
      id: 'opp_003',
      title: 'Google Africa Developer Scholarship',
      organization: 'Google & Andela',
      type: OpportunityType.scholarship,
      shortDescription: 'Scholarships for Android, Flutter, or Google Cloud development training in Africa.',
      description: 'Google and Andela offer technology scholarships for African students and graduates to access world-class training in Flutter, Android development, and Google Cloud. Top scholars receive additional benefits and access to Google mentors.',
      location: 'Online (Remote)',
      isRemote: true,
      deadline: DateTime.now().add(const Duration(days: 30)),
      eligibility: [
        'African citizen aged 18+',
        'Basic programming knowledge',
        'Commitment to complete the program',
      ],
      benefits: [
        'Free access to premium courses',
        'Community of 1000+ scholars',
        'Google certificate upon completion',
        'Top scholars get extended mentorship',
      ],
      requiredDocuments: ['Online application form', 'Personal statement'],
      isBookmarked: false,
      isFeatured: false,
      isRecommended: true,
      careerCategory: 'Software Engineering',
      applicationCount: 8900,
      createdAt: DateTime(2024, 11, 15),
      targetEducationLevels: ['form6', 'university', 'graduate'],
    ),

    OpportunityModel(
      id: 'opp_004',
      title: 'CRDB Bank Graduate Trainee Program',
      organization: 'CRDB Bank',
      type: OpportunityType.internship,
      shortDescription: 'One-year structured graduate trainee program at Tanzania\'s largest bank.',
      description: 'CRDB Bank\'s Graduate Trainee Program accepts recent university graduates and provides one year of structured training across different departments. This is one of the most competitive and prestigious early-career opportunities in Tanzanian banking.',
      location: 'Dar es Salaam, Tanzania',
      isRemote: false,
      deadline: DateTime.now().add(const Duration(days: 12)),
      eligibility: [
        'University graduate (degree in Business, Finance, IT, or related)',
        'GPA of 3.5 or equivalent',
        'Age below 30',
        'Tanzanian citizen',
      ],
      benefits: [
        'Competitive salary',
        'Medical insurance',
        'Structured mentorship',
        'Possible permanent employment',
      ],
      requiredDocuments: ['Degree certificate', 'Transcripts', 'CV', 'Cover letter', 'National ID'],
      isBookmarked: false,
      isFeatured: true,
      isRecommended: false,
      careerCategory: 'Finance',
      applicationCount: 1240,
      createdAt: DateTime(2024, 12, 5),
      targetEducationLevels: ['graduate'],
    ),

    OpportunityModel(
      id: 'opp_005',
      title: 'ALX Africa Software Engineering Program',
      organization: 'ALX Africa',
      type: OpportunityType.bootcamp,
      shortDescription: 'Intensive 12-month software engineering program designed for African youth.',
      description: 'ALX Africa offers a rigorous, full-time software engineering program that produces job-ready engineers in 12 months. The curriculum covers C, Python, web development, databases, and systems programming. Tuition is free — you repay only after getting a job.',
      location: 'Online (Remote)',
      isRemote: true,
      deadline: DateTime.now().add(const Duration(days: 60)),
      startDate: DateTime(2025, 3, 1),
      eligibility: [
        'African citizen or resident',
        'Age 18-35',
        'No prior coding experience required',
        'Available full-time for 12 months',
        'Pass admissions test',
      ],
      benefits: [
        'Free until employed (ISA model)',
        'World-class curriculum',
        'Global peer network',
        'Career placement support',
        'Certificate recognized globally',
      ],
      requiredDocuments: ['Online application', 'Complete admissions test'],
      isBookmarked: false,
      isFeatured: false,
      isRecommended: true,
      careerCategory: 'Software Engineering',
      applicationCount: 22000,
      createdAt: DateTime(2024, 11, 1),
      targetEducationLevels: ['form6', 'university', 'graduate'],
    ),

    OpportunityModel(
      id: 'opp_006',
      title: 'UDSM Open Day & University Fair',
      organization: 'University of Dar es Salaam',
      type: OpportunityType.event,
      shortDescription: 'Annual open day for prospective students to explore programs, meet faculty and students.',
      description: 'UDSM Open Day is the largest university fair in Tanzania. Form 5 and Form 6 students are invited to explore all faculties, talk to current students, meet professors, and understand the application process. Attendance is free.',
      location: 'UDSM Campus, Dar es Salaam',
      isRemote: false,
      deadline: DateTime.now().add(const Duration(days: 8)),
      startDate: DateTime.now().add(const Duration(days: 8)),
      eligibility: ['Form 5 and Form 6 students', 'Open to parents and guardians'],
      benefits: ['Free entry', 'Campus tours', 'Q&A with faculty', 'Application guidance'],
      requiredDocuments: [],
      isBookmarked: false,
      isFeatured: false,
      isRecommended: true,
      careerCategory: 'All Fields',
      applicationCount: 0,
      createdAt: DateTime(2024, 12, 10),
      targetEducationLevels: ['form5', 'form6'],
    ),

    OpportunityModel(
      id: 'opp_007',
      title: 'African Union Youth Volunteer Corps',
      organization: 'African Union',
      type: OpportunityType.competition,
      shortDescription: 'Represent Tanzania as a volunteer contributing to AU initiatives across Africa.',
      description: 'The African Union Youth Volunteer Corps places young Africans in volunteer assignments across AU member states. Volunteers contribute to peace, development, and integration projects and receive a living allowance and valuable international experience.',
      location: 'Various African Countries',
      isRemote: false,
      deadline: DateTime.now().add(const Duration(days: 90)),
      eligibility: [
        'African citizen aged 18-35',
        'University degree or equivalent',
        'Proficiency in at least one AU language (English, French, Arabic, Portuguese)',
      ],
      benefits: [
        'Monthly living allowance',
        'Health insurance',
        'Return travel',
        'AU certificate',
        'Network with African leaders',
      ],
      requiredDocuments: ['CV', 'Degree certificate', 'Language certificate', 'Motivation letter'],
      isBookmarked: false,
      isFeatured: false,
      isRecommended: false,
      careerCategory: 'All Fields',
      applicationCount: 560,
      createdAt: DateTime(2024, 10, 20),
      targetEducationLevels: ['university', 'graduate'],
    ),
  ];

  static OpportunityModel? getById(String id) {
    try {
      return all.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<OpportunityModel> getByType(OpportunityType type) =>
      all.where((o) => o.type == type).toList();

  static List<OpportunityModel> getFeatured() =>
      all.where((o) => o.isFeatured).toList();

  static List<OpportunityModel> getRecommended() =>
      all.where((o) => o.isRecommended).toList();

  static List<OpportunityModel> getDeadlineSoon() =>
      all.where((o) => o.isDeadlineSoon).toList();
}