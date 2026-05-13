import '../models/university_model.dart';

class MockUniversities {
  MockUniversities._();

  static final List<UniversityModel> all = [
    UniversityModel(
      id: 'uni_001',
      name: 'University of Dar es Salaam',
      shortName: 'UDSM',
      location: 'Dar es Salaam, Tanzania',
      establishedYear: 1961,
      type: 'public',
      description: 'Tanzania\'s oldest and most prestigious university. Known for excellence in Engineering, Law, Computer Science, and Social Sciences. Located on a beautiful hilltop campus in Dar es Salaam.',
      availableCourses: ['Computer Science', 'Law', 'Engineering', 'Education', 'Natural Sciences', 'Social Sciences', 'Medicine'],
      featuredPrograms: ['BSc Computer Science', 'LLB Law', 'BSc Civil Engineering', 'BEd Education'],
      isPartner: true,
      ranking: 1.0,
    ),
    UniversityModel(
      id: 'uni_002',
      name: 'Muhimbili University of Health and Allied Sciences',
      shortName: 'MUHAS',
      location: 'Dar es Salaam, Tanzania',
      establishedYear: 1963,
      type: 'public',
      description: 'Tanzania\'s premier health sciences university. Trains the majority of Tanzania\'s doctors, pharmacists, nurses, and health professionals. Located adjacent to Muhimbili National Hospital.',
      availableCourses: ['Medicine', 'Pharmacy', 'Nursing', 'Dentistry', 'Allied Health Sciences'],
      featuredPrograms: ['MBChB Medicine', 'BSc Pharmacy', 'BSc Nursing', 'BDS Dentistry'],
      isPartner: true,
      ranking: 2.0,
    ),
    UniversityModel(
      id: 'uni_003',
      name: 'Nelson Mandela African Institution of Science and Technology',
      shortName: 'NM-AIST',
      location: 'Arusha, Tanzania',
      establishedYear: 2010,
      type: 'public',
      description: 'A postgraduate research-focused institution specializing in science, engineering, and technology. Known for cutting-edge research in AI, biosciences, and materials engineering.',
      availableCourses: ['Computer Science & Engineering', 'Biosciences', 'Materials Science', 'Water Infrastructure'],
      featuredPrograms: ['MSc Computer Science', 'MSc AI & ML', 'PhD Engineering'],
      isPartner: true,
      ranking: 3.0,
    ),
    UniversityModel(
      id: 'uni_004',
      name: 'Mzumbe University',
      shortName: 'Mzumbe',
      location: 'Morogoro, Tanzania',
      establishedYear: 1953,
      type: 'public',
      description: 'A leading institution for business, public administration, and law in Tanzania. Known for producing government administrators and business leaders.',
      availableCourses: ['Business Administration', 'Law', 'Public Administration', 'Accounting', 'Human Resources'],
      featuredPrograms: ['BBA Business Admin', 'LLB Law', 'BSc Accounting', 'MBA'],
      isPartner: false,
      ranking: 4.0,
    ),
    UniversityModel(
      id: 'uni_005',
      name: 'Institute of Finance Management',
      shortName: 'IFM',
      location: 'Dar es Salaam, Tanzania',
      establishedYear: 1972,
      type: 'public',
      description: 'Tanzania\'s specialized finance and insurance institution. Produces the majority of Tanzania\'s banking and finance professionals.',
      availableCourses: ['Finance', 'Banking', 'Insurance', 'Actuarial Science', 'Accounting'],
      featuredPrograms: ['BSc Finance', 'BSc Banking', 'BSc Actuarial Science', 'MBA Finance'],
      isPartner: true,
      ranking: 5.0,
    ),
    UniversityModel(
      id: 'uni_006',
      name: 'Sokoine University of Agriculture',
      shortName: 'SUA',
      location: 'Morogoro, Tanzania',
      establishedYear: 1984,
      type: 'public',
      description: 'Tanzania\'s agricultural university, also strong in veterinary medicine, food science, and environmental sciences.',
      availableCourses: ['Agriculture', 'Veterinary Medicine', 'Food Science', 'Environmental Science', 'Forestry'],
      featuredPrograms: ['BSc Agriculture', 'DVM Veterinary Medicine', 'BSc Food Science'],
      isPartner: false,
      ranking: 6.0,
    ),
  ];

  static UniversityModel? getById(String id) {
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}