import '../models/ai_message_model.dart';

class MockAiResponses {
  MockAiResponses._();

  static final List<AiSuggestionChip> defaultSuggestions = [
    AiSuggestionChip(id: 's1', label: '🎓 Best universities for CS', prompt: 'What are the best universities in Tanzania for Computer Science?'),
    AiSuggestionChip(id: 's2', label: '💼 Top scholarships', prompt: 'What scholarships are available for Tanzanian students?'),
    AiSuggestionChip(id: 's3', label: '🤝 Find a mentor', prompt: 'Help me find a mentor in software engineering'),
    AiSuggestionChip(id: 's4', label: '📊 Explore careers', prompt: 'I am interested in data science, what should I do?'),
    AiSuggestionChip(id: 's5', label: '🚀 Career roadmap', prompt: 'Create a career roadmap for software engineering from Form 6'),
    AiSuggestionChip(id: 's6', label: '💰 Salary insights', prompt: 'What are typical salaries for software engineers in Tanzania?'),
  ];

  static AiMessageModel getResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('software') || lower.contains('programming') || lower.contains('coding')) {
      return _softwareEngineeringResponse();
    } else if (lower.contains('medicine') || lower.contains('doctor') || lower.contains('medical')) {
      return _medicineResponse();
    } else if (lower.contains('scholarship') || lower.contains('funding')) {
      return _scholarshipResponse();
    } else if (lower.contains('mentor')) {
      return _mentorResponse();
    } else if (lower.contains('university') || lower.contains('udsm') || lower.contains('admission')) {
      return _universityResponse();
    } else if (lower.contains('salary') || lower.contains('earn') || lower.contains('money')) {
      return _salaryResponse();
    } else if (lower.contains('finance') || lower.contains('banking') || lower.contains('investment')) {
      return _financeResponse();
    } else {
      return _defaultResponse(userMessage);
    }
  }

  static AiMessageModel _softwareEngineeringResponse() => AiMessageModel(
    id: 'ai_resp_001',
    role: AiMessageRole.assistant,
    type: AiMessageType.careerGuide,
    content: '''Great choice! Software Engineering is one of the fastest-growing and best-paid careers in Tanzania right now. Here's your complete guide:

**🎓 Best Universities in Tanzania:**
- UDSM (University of Dar es Salaam) — BSc Computer Science
- UDOM — BSc Computer Engineering  
- NM-AIST — MSc Software Engineering (postgrad)
- CoICT — BSc Information Technology

**📚 What to Study Right Now:**
Start with Python — it's the most beginner-friendly and in-demand language. Spend 30 minutes a day on platforms like freeCodeCamp or CS50 (Harvard's free online course).

**💰 Salary Expectations in Tanzania:**
- Entry level: TZS 1.2M - 2M/month
- Mid-level: TZS 3.5M - 5M/month
- Senior: TZS 8M+/month (or remote global salaries in USD)

**🚀 Your Next Steps:**
1. Start learning Python today (free on YouTube)
2. Build one small project per month
3. Create a GitHub profile
4. Connect with a software engineering mentor on UniLink''',
    actionCards: [
      AiActionCard(id: 'ac1', title: 'Grace Kimaro', subtitle: 'Software Engineer @ Vodacom', actionType: 'view_mentor', actionTargetId: 'mtr_001', emoji: '👩‍💻'),
      AiActionCard(id: 'ac2', title: 'Software Engineering', subtitle: 'Full career guide', actionType: 'view_career', actionTargetId: 'car_001', emoji: '💻'),
      AiActionCard(id: 'ac3', title: 'Google Africa Scholarship', subtitle: 'Free coding training', actionType: 'view_opportunity', actionTargetId: 'opp_003', emoji: '🎓'),
    ],
    suggestions: [
      AiSuggestionChip(id: 's1', label: '📍 UDSM application process', prompt: 'How do I apply to UDSM for Computer Science?'),
      AiSuggestionChip(id: 's2', label: '🛣️ Full roadmap', prompt: 'Give me a full software engineering roadmap from Form 6 to first job'),
      AiSuggestionChip(id: 's3', label: '💼 Internships available', prompt: 'What internships are available for software engineering students in Tanzania?'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _medicineResponse() => AiMessageModel(
    id: 'ai_resp_002',
    role: AiMessageRole.assistant,
    type: AiMessageType.careerGuide,
    content: '''Medicine is a deeply respected and impactful career in Tanzania. Here's what you need to know:

**🏥 Medical Schools in Tanzania:**
- MUHAS (Muhimbili University of Health & Allied Sciences) — Top choice
- UDSM Faculty of Medicine — Well-established
- KCMUCo (Kilimanjaro Christian Medical University) — Excellent for research
- Hubert Kairuki Memorial University — Private option

**📝 Entry Requirements:**
- A-Level: Biology + Chemistry are mandatory
- Minimum points: 4.5+ for MUHAS Medicine
- Physics or Mathematics as third subject is an advantage
- Strong personal statement

**⏱️ Duration:** 5 years (MBChB) + 1 year internship

**💰 Career Earnings in Tanzania:**
- Government Medical Officer: TZS 2.5M/month
- Specialist/Consultant: TZS 8M-15M+/month
- Private practice: Significantly higher

**🩺 Connect with Dr. Sarah Mwamba** — She's available for free mentorship sessions and can guide you through the application process!''',
    actionCards: [
      AiActionCard(id: 'ac1', title: 'Dr. Sarah Mwamba', subtitle: 'Medical Doctor @ MNH', actionType: 'view_mentor', actionTargetId: 'mtr_003', emoji: '👩‍⚕️'),
      AiActionCard(id: 'ac2', title: 'Medicine & Healthcare', subtitle: 'Full career guide', actionType: 'view_career', actionTargetId: 'car_003', emoji: '🩺'),
    ],
    suggestions: [
      AiSuggestionChip(id: 's1', label: '📋 MUHAS application', prompt: 'How do I apply to MUHAS for Medicine?'),
      AiSuggestionChip(id: 's2', label: '📖 A-Level Biology tips', prompt: 'How do I score A in A-Level Biology?'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _scholarshipResponse() => AiMessageModel(
    id: 'ai_resp_003',
    role: AiMessageRole.assistant,
    type: AiMessageType.scholarshipSuggestion,
    content: '''Here are the best scholarship opportunities currently available for Tanzanian students:

**🥇 Top Scholarships Right Now:**

1. **MasterCard Foundation Scholars Program** — Full scholarship, deadline in 45 days
2. **Google Africa Developer Scholarship** — Free tech training, remote
3. **DAAD Scholarship (Germany)** — Full postgraduate funding
4. **Commonwealth Scholarship** — For postgraduate study in UK
5. **UDSM Government Loans Board** — For all admitted Tanzanian students

**💡 Tips for Strong Applications:**
- Start early — most deadlines are 2-3 months away
- Your personal statement is CRITICAL — make it authentic
- Get strong recommendation letters from teachers who know you well
- Show leadership and community involvement, not just grades

**📬 I'll also notify you when new scholarships matching your profile open up.**''',
    actionCards: [
      AiActionCard(id: 'ac1', title: 'MasterCard Foundation', subtitle: 'Full scholarship • 45 days left', actionType: 'view_opportunity', actionTargetId: 'opp_001', emoji: '🎓'),
      AiActionCard(id: 'ac2', title: 'Google Africa Scholarship', subtitle: 'Tech training • Remote', actionType: 'view_opportunity', actionTargetId: 'opp_003', emoji: '🌐'),
    ],
    suggestions: [
      AiSuggestionChip(id: 's1', label: '✍️ Personal statement tips', prompt: 'Help me write a strong scholarship personal statement'),
      AiSuggestionChip(id: 's2', label: '📅 All deadlines', prompt: 'Show me all scholarship deadlines this month'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _mentorResponse() => AiMessageModel(
    id: 'ai_resp_004',
    role: AiMessageRole.assistant,
    type: AiMessageType.mentorSuggestion,
    content: '''Based on your interests, here are the best mentors available on UniLink right now. All of them are verified Tanzanian professionals who have helped students just like you:

I've matched you with mentors who are currently available and offer free introductory sessions. Booking a session is the single best thing you can do to accelerate your journey.''',
    actionCards: [
      AiActionCard(id: 'ac1', title: 'Grace Kimaro', subtitle: 'Software Engineer @ Vodacom • ⭐ 4.9', actionType: 'view_mentor', actionTargetId: 'mtr_001', emoji: '👩‍💻'),
      AiActionCard(id: 'ac2', title: 'James Tarimo', subtitle: 'Investment Analyst @ CRDB • ⭐ 4.8', actionType: 'view_mentor', actionTargetId: 'mtr_002', emoji: '💼'),
      AiActionCard(id: 'ac3', title: 'Zawadi Mwasonga', subtitle: 'UX Designer @ Jumo Africa • ⭐ 4.8', actionType: 'view_mentor', actionTargetId: 'mtr_005', emoji: '🎨'),
    ],
    suggestions: [
      AiSuggestionChip(id: 's1', label: '📅 Book a session', prompt: 'How do I book a mentorship session?'),
      AiSuggestionChip(id: 's2', label: '🔍 More mentors', prompt: 'Show me more mentors in technology'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _universityResponse() => AiMessageModel(
    id: 'ai_resp_005',
    role: AiMessageRole.assistant,
    type: AiMessageType.careerGuide,
    content: '''Here's a comprehensive overview of Tanzanian universities and the application process:

**🏛️ Top Universities in Tanzania:**

| University | Strength | Type |
|---|---|---|
| UDSM | Technology, Law, Medicine | Public |
| MUHAS | Medicine, Pharmacy, Nursing | Public |
| SUA | Agriculture, Science | Public |
| Mzumbe | Business, Law | Public |
| NM-AIST | Research & Technology | Public |
| IFM | Finance, Banking | Public |

**📋 Application Process (TCU):**
1. Apply through the Tanzania Commission for Universities (TCU) portal: apply.tcu.go.tz
2. Applications usually open February-April
3. Results announced June-July
4. You can apply to up to 5 programs

**💡 Key tip:** Apply to your dream program AND a backup. Competition for UDSM Medicine and UDSM CS is extremely high.''',
    suggestions: [
      AiSuggestionChip(id: 's1', label: '📝 TCU application guide', prompt: 'Walk me through the TCU application process step by step'),
      AiSuggestionChip(id: 's2', label: '🏆 Cut-off points', prompt: 'What are the cut-off points for top university programs in Tanzania?'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _salaryResponse() => AiMessageModel(
    id: 'ai_resp_006',
    role: AiMessageRole.assistant,
    type: AiMessageType.text,
    content: '''Here's a realistic overview of salaries in Tanzania across top career fields (2024 data):

**💰 Monthly Salary Ranges (TZS):**

🖥️ **Software Engineering**
Entry: 1.2M | Mid: 3.5M | Senior: 8M+

🩺 **Medicine**
Entry (Gov): 2.5M | Specialist: 6M | Consultant: 15M+

💼 **Finance & Banking**
Entry: 1.1M | Mid: 3.8M | Senior: 14M+

⚖️ **Law**
Entry: 1M | Senior Partner: 20M+

📊 **Data Science**
Entry: 1.4M | Mid: 4M | Senior: 9M+

🎨 **UX/Product Design**
Entry: 1.2M | Mid: 4M | Senior: 10M+

**🌍 Remote Work Bonus:**
Senior tech professionals (software, AI, design) who work for international companies from Tanzania can earn 3,000-10,000/month (USD) — far above local market rates.

**💡 Key insight:** Skills + experience = salary. The difference between entry and senior in tech can be 6-10x.''',
    suggestions: [
      AiSuggestionChip(id: 's1', label: '🌍 Remote work opportunities', prompt: 'How do I find remote work opportunities as a Tanzanian developer?'),
      AiSuggestionChip(id: 's2', label: '📈 Highest paying careers', prompt: 'What are the highest paying careers in Tanzania right now?'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _financeResponse() => AiMessageModel(
    id: 'ai_resp_007',
    role: AiMessageRole.assistant,
    type: AiMessageType.careerGuide,
    content: '''Finance is an excellent career choice in Tanzania! With a booming banking sector, growing DSE stock market, and mobile money revolution, there are more opportunities than ever.

**🏦 Top Employers in Tanzanian Finance:**
- CRDB Bank — Largest local bank, excellent graduate program
- NMB Bank — Strong in retail banking
- Stanbic Bank — Great for investment banking
- Deloitte / PwC Tanzania — Top for accounting/consulting
- DSE (Dar es Salaam Stock Exchange)

**🎓 Best Qualifications:**
- BSc Finance/Accounting — IFM or Mzumbe University
- ACCA / CPA — Professional qualifications, highly valued
- CFA — For investment & portfolio roles

**💡 James Tarimo's tip:** "Start learning about the DSE as a student. Open a small investment account. Employers love candidates who have practical market experience."

I've matched you with James Tarimo — an investment analyst at CRDB Bank who mentors aspiring finance professionals for free.''',
    actionCards: [
      AiActionCard(id: 'ac1', title: 'James Tarimo', subtitle: 'Investment Analyst @ CRDB • ⭐ 4.8', actionType: 'view_mentor', actionTargetId: 'mtr_002', emoji: '💼'),
      AiActionCard(id: 'ac2', title: 'Finance & Banking', subtitle: 'Full career guide', actionType: 'view_career', actionTargetId: 'car_005', emoji: '💰'),
    ],
    createdAt: DateTime.now(),
  );

  static AiMessageModel _defaultResponse(String message) => AiMessageModel(
    id: 'ai_resp_default',
    role: AiMessageRole.assistant,
    type: AiMessageType.text,
    content: '''I'm UniLink AI — your personal education and career guide for Tanzania and beyond! 🇹🇿

I can help you with:
- **Career exploration** — Understand any career path in detail
- **University guidance** — Applications, requirements, cut-off points
- **Mentor matching** — Connect with professionals in your field
- **Scholarships** — Find funding for your education
- **Study tips** — Improve your A-Level or university performance
- **Career roadmaps** — Step-by-step plans from where you are to where you want to be

What would you like to explore today? You can type anything or pick a suggestion below.''',
    suggestions: defaultSuggestions,
    createdAt: DateTime.now(),
  );

  static AiMessageModel get welcomeMessage => AiMessageModel(
    id: 'ai_welcome',
    role: AiMessageRole.assistant,
    type: AiMessageType.text,
    content: 'Habari! 👋 I\'m your UniLink AI guide. I\'m here to help you navigate your education and career journey in Tanzania. Whether you\'re choosing between medicine and engineering, looking for scholarships, or want to connect with a mentor — I\'ve got you covered. What\'s on your mind?',
    suggestions: defaultSuggestions,
    createdAt: DateTime.now(),
  );
}