/// Career Data - Comprehensive Database
import '../models/career_model.dart';

class CareerData {
  static List<CareerModel> getAllCareers() => [
    _softwareArchitect,
    _surgeon,
    _charteredAccountant,
    _corporateLawyer,
    _webDeveloper,
  ];

  static List<CareerModel> getCareersByStream(StreamTag stream) =>
      getAllCareers().where((c) => c.streamTag == stream).toList();

  // SOFTWARE ARCHITECT - MPC
  static final CareerModel _softwareArchitect = CareerModel(
    id: 'software_architect',
    title: 'Software Architect',
    streamTag: StreamTag.mpc,
    shortDescription: 'Design and build digital systems that power our world',
    iconName: 'computer',
    discoveryContent: DiscoveryContent(
      dayInLife: '''Imagine waking up at 8 AM, sitting at your desk surrounded by monitors glowing with code. You're Priya, a Software Architect at a tech company in Bangalore.

Your morning starts with coffee and checking messages from your global team. Today's challenge: designing a system to help millions of students learn online!

By 9:30 AM, you're sketching ideas on a digital whiteboard, explaining how different parts of the app will communicate. It's like being an architect for buildings, but with code instead of bricks!

The afternoon flies by reviewing code and mentoring junior developers. At 4 PM, there's a breakthrough - your new design reduces loading time from 5 seconds to 1 second. The team celebrates!

Before bed, you read about new technologies. Tomorrow brings new puzzles to solve and new opportunities to build something amazing.''',
      funFact: 'The first computer "bug" was an actual moth! In 1947, Grace Hopper found a moth stuck in a computer. She taped it in her logbook and wrote "First actual case of bug being found." That\'s why we call fixing errors "debugging"!',
      visualAids: ['https://example.com/software-workspace.jpg'],
      introVideos: ['https://youtube.com/watch?v=software-intro'],
    ),
    bridgeContent: BridgeContent(
      required11thStream: 'MPC: Mathematics, Physics, Chemistry (Computer Science recommended)',
      foundationTopics: [
        'Chapter 1: Real Numbers - Foundation for programming',
        'Chapter 3: Linear Equations - Logic and problem-solving',
        'Chapter 15: Probability - Essential for AI applications',
      ],
      streamComparison: StreamComparison(
        comparedStream: 'BiPC',
        pros: ['Higher starting salaries (₹6-15 LPA)', 'Work from anywhere', 'Global opportunities', 'Multiple career paths'],
        cons: ['Continuous learning required', 'Long hours during deadlines', 'Competitive field'],
      ),
      keySkillsToStart: ['Start with Python basics', 'Practice logical puzzles', 'Learn HTML for websites', 'Understand how apps work'],
    ),
    executionContent: ExecutionContent(
      entranceExams: [
        EntranceExam(name: 'JEE Main', month: 'January & April', eligibility: '75% in 12th', syllabusFocus: 'Physics, Chemistry, Mathematics', difficultyIndex: 8),
        EntranceExam(name: 'JEE Advanced', month: 'May-June', eligibility: 'Top 2.5 lakh JEE Main', syllabusFocus: 'Advanced PCM', difficultyIndex: 10),
        EntranceExam(name: 'BITSAT', month: 'May', eligibility: '75% in PCM', syllabusFocus: 'PCM + English + Reasoning', difficultyIndex: 7),
      ],
      topColleges: [
        College(name: 'IIT Bombay', location: 'Mumbai', avgFees: '₹2.5L/year', rating: 5.0, specialization: 'CSE, AI/ML'),
        College(name: 'IIT Delhi', location: 'Delhi', avgFees: '₹2.5L/year', rating: 5.0, specialization: 'CSE'),
        College(name: 'BITS Pilani', location: 'Pilani', avgFees: '₹5L/year', rating: 4.8, specialization: 'CS'),
        College(name: 'NIT Trichy', location: 'Trichy', avgFees: '₹1.5L/year', rating: 4.6, specialization: 'CSE'),
        College(name: 'IIIT Hyderabad', location: 'Hyderabad', avgFees: '₹3L/year', rating: 4.7, specialization: 'CSE, AI'),
      ],
      financialReality: FinancialReality(
        entrySalary: '₹6-15 LPA', fiveYearSalary: '₹20-40 LPA', tenYearSalary: '₹50-1.5 Cr LPA',
        growthData: [SalaryDataPoint(year: 0, salaryLakhs: 10), SalaryDataPoint(year: 5, salaryLakhs: 35), SalaryDataPoint(year: 10, salaryLakhs: 90)],
      ),
      planB: PlanB(
        title: 'Alternative Paths', description: 'Multiple routes to software careers',
        alternativePaths: ['BCA + MCA', 'B.Sc CS + Certifications', 'Coding Bootcamps after any graduation'],
      ),
    ),
    realityTask: RealityTask(
      taskTitle: 'Logic Puzzle: Discount Calculator',
      taskInstructions: 'Calculate total after 10% discount on items: ₹100, ₹250, ₹180, ₹320, ₹150',
      taskType: TaskType.calculation,
      questions: [
        TaskQuestion(question: 'What is the total before discount?', options: ['₹900', '₹1000', '₹1100', '₹800'], correctIndex: 1, explanation: '100+250+180+320+150 = ₹1000'),
        TaskQuestion(question: 'What is 10% of ₹1000?', options: ['₹10', '₹100', '₹1000', '₹50'], correctIndex: 1, explanation: '10% = 0.1, so 1000 × 0.1 = ₹100'),
        TaskQuestion(question: 'Final amount after discount?', options: ['₹900', '₹1000', '₹800', '₹950'], correctIndex: 0, explanation: '1000 - 100 = ₹900'),
      ],
      successOutcome: 'You thought like a programmer! Breaking problems into steps is the core of software development.',
    ),
    realityCheck: RealityCheck(avgSalary: '₹25-50 LPA', jobStressIndex: 6, studyHoursDaily: 4, yearsToMaster: 8, workLifeBalance: 'Good', jobAvailability: 'Very High'),
    resourceLibrary: ResourceLibrary(
      courses: [ResourceLink(title: 'CS50: Intro to CS', url: 'https://cs50.harvard.edu/', source: 'Harvard', type: 'Course')],
      videos: [ResourceLink(title: 'How Computers Work', url: 'https://khanacademy.org/', source: 'Khan Academy', type: 'Video')],
      articles: [ResourceLink(title: 'Software Careers', url: 'https://skillindia.gov.in/', source: 'Skill India', type: 'Article')],
      ncertChapters: [ResourceLink(title: 'Class 10 - Real Numbers', url: 'https://ncert.nic.in/', source: 'NCERT', type: 'Chapter')],
    ),
    roadmap: CareerRoadmap(nodes: [
      RoadmapNode(order: 1, title: 'Class 10', description: 'Focus on Maths & Science', duration: 'Current'),
      RoadmapNode(order: 2, title: 'Class 11-12 MPC', description: 'JEE prep + Learn coding basics', duration: '2 years'),
      RoadmapNode(order: 3, title: 'B.Tech CSE', description: 'Core CS + Projects + Internships', duration: '4 years'),
      RoadmapNode(order: 4, title: 'Software Developer', description: 'First job, learn on the job', duration: '2-3 years'),
      RoadmapNode(order: 5, title: 'Software Architect', description: 'Design systems, lead teams', duration: 'Ongoing'),
    ]),
  );


  // SURGEON - BiPC
  static final CareerModel _surgeon = CareerModel(
    id: 'surgeon', title: 'Surgeon (MBBS/MS)', streamTag: StreamTag.bipc,
    shortDescription: 'Save lives through surgical expertise and precision', iconName: 'medical_services',
    discoveryContent: DiscoveryContent(
      dayInLife: '''Dr. Ananya's alarm rings at 5 AM. As a cardiac surgeon at AIIMS Delhi, her days start early.

By 6:30 AM, she's reviewing today's cases. First surgery: a bypass for a 45-year-old. She meets the anxious family: "We'll take good care of him."

The surgery begins at 8 AM. For 6 hours, her world shrinks to the patient's heart. She reroutes blood vessels with sutures thinner than hair.

At 2 PM, success! The heart beats strongly. She updates the family: "He did great."

Evening brings an emergency - a road accident victim. The next 3 hours are intense. By 9 PM, the patient is stable.

Before leaving, she checks on the morning's patient. He's awake, holding his wife's hand. "Thank you, doctor." These words make everything worth it.''',
      funFact: 'The first successful heart transplant was in 1967. The patient lived 18 days. Today, heart transplant patients can live 15+ years!',
      visualAids: [], introVideos: [],
    ),
    bridgeContent: BridgeContent(
      required11thStream: 'BiPC: Biology, Physics, Chemistry',
      foundationTopics: ['Chapter 6: Life Processes', 'Chapter 7: Control and Coordination', 'Chapter 8: Reproduction'],
      streamComparison: StreamComparison(comparedStream: 'MPC', pros: ['Save lives directly', 'High respect', 'Job security'], cons: ['10-12 years education', 'High stress', 'Irregular hours']),
      keySkillsToStart: ['Strong Biology foundation', 'Steady hands', 'Emotional resilience', 'Handle pressure'],
    ),
    executionContent: ExecutionContent(
      entranceExams: [
        EntranceExam(name: 'NEET-UG', month: 'May', eligibility: '50% in PCB', syllabusFocus: 'Physics, Chemistry, Biology', difficultyIndex: 9),
        EntranceExam(name: 'NEET-PG', month: 'January', eligibility: 'MBBS degree', syllabusFocus: 'All MBBS subjects', difficultyIndex: 9),
      ],
      topColleges: [
        College(name: 'AIIMS Delhi', location: 'Delhi', avgFees: '₹6K/year', rating: 5.0, specialization: 'All'),
        College(name: 'CMC Vellore', location: 'Vellore', avgFees: '₹70K/year', rating: 5.0, specialization: 'Surgery'),
        College(name: 'JIPMER', location: 'Puducherry', avgFees: '₹15K/year', rating: 4.9, specialization: 'All'),
      ],
      financialReality: FinancialReality(entrySalary: '₹8-15 LPA', fiveYearSalary: '₹20-40 LPA', tenYearSalary: '₹50 LPA - 2 Cr',
        growthData: [SalaryDataPoint(year: 0, salaryLakhs: 10), SalaryDataPoint(year: 5, salaryLakhs: 25), SalaryDataPoint(year: 10, salaryLakhs: 60)]),
      planB: PlanB(title: 'Alternative Medical Paths', description: 'Healthcare has many options',
        alternativePaths: ['BDS (Dentistry)', 'BAMS/BHMS', 'B.Sc Nursing', 'Pharmacy', 'Physiotherapy']),
    ),
    realityTask: RealityTask(
      taskTitle: 'Symptom Diagnosis', taskInstructions: 'Match symptoms to conditions', taskType: TaskType.matching,
      questions: [
        TaskQuestion(question: 'High fever, chills, body aches?', options: ['Cold', 'Malaria', 'Food Poisoning', 'Allergy'], correctIndex: 1, explanation: 'Classic malaria symptoms'),
        TaskQuestion(question: 'Runny nose, sneezing, mild fever?', options: ['Malaria', 'Common Cold', 'Typhoid', 'Dengue'], correctIndex: 1, explanation: 'Upper respiratory symptoms = cold'),
        TaskQuestion(question: 'Vomiting, diarrhea after eating?', options: ['Malaria', 'Cold', 'Food Poisoning', 'Appendicitis'], correctIndex: 2, explanation: 'GI symptoms after eating = food poisoning'),
      ],
      successOutcome: 'Great diagnostic thinking! Doctors use pattern recognition plus tests to confirm.',
    ),
    realityCheck: RealityCheck(avgSalary: '₹30-60 LPA', jobStressIndex: 9, studyHoursDaily: 6, yearsToMaster: 12, workLifeBalance: 'Challenging', jobAvailability: 'High'),
    resourceLibrary: ResourceLibrary(
      courses: [ResourceLink(title: 'Human Anatomy', url: 'https://khanacademy.org/', source: 'Khan Academy', type: 'Course')],
      videos: [], articles: [ResourceLink(title: 'NMC Guidelines', url: 'https://nmc.org.in/', source: 'NMC', type: 'Article')],
      ncertChapters: [ResourceLink(title: 'Life Processes', url: 'https://ncert.nic.in/', source: 'NCERT', type: 'Chapter')],
    ),
    roadmap: CareerRoadmap(nodes: [
      RoadmapNode(order: 1, title: 'Class 10', description: 'Strong Science foundation', duration: 'Current'),
      RoadmapNode(order: 2, title: 'Class 11-12 BiPC', description: 'NEET preparation', duration: '2 years'),
      RoadmapNode(order: 3, title: 'MBBS', description: '5.5 years with internship', duration: '5.5 years'),
      RoadmapNode(order: 4, title: 'MS Surgery', description: '3-year residency', duration: '3 years'),
      RoadmapNode(order: 5, title: 'Surgeon', description: 'Practice and specialize', duration: 'Ongoing'),
    ]),
  );


  // CHARTERED ACCOUNTANT - MEC
  static final CareerModel _charteredAccountant = CareerModel(
    id: 'chartered_accountant', title: 'Chartered Accountant (CA)', streamTag: StreamTag.mec,
    shortDescription: 'Master of finance, audit, and taxation', iconName: 'account_balance',
    discoveryContent: DiscoveryContent(
      dayInLife: '''Rahul starts his day at 8 AM at a Big 4 firm in Mumbai. As a CA, he's the financial guardian for major companies.

Morning: Reviewing audit reports for a manufacturing company. Every number tells a story - his job is to find the truth.

Afternoon: Meeting with a startup founder about tax planning. "How can we legally save taxes while growing?" Rahul loves these strategic discussions.

Evening: Preparing for tomorrow's board presentation. The CFO relies on his analysis for major decisions.

The best part? Seeing businesses grow with his financial guidance. Numbers aren't boring - they're the language of business!''',
      funFact: 'India has over 3.5 lakh CAs, but demand still exceeds supply! A CA can sign off on financial statements that move billions of rupees.',
      visualAids: [], introVideos: [],
    ),
    bridgeContent: BridgeContent(
      required11thStream: 'Commerce with Maths (MEC) or without (CEC)',
      foundationTopics: ['Basic Accounting concepts', 'Business Mathematics', 'Economics fundamentals'],
      streamComparison: StreamComparison(comparedStream: 'Science', pros: ['Direct professional qualification', 'High demand', 'Own practice possible'], cons: ['3-4 year articleship', 'Low pass rates', 'Intense study']),
      keySkillsToStart: ['Learn basic accounting', 'Practice mental math', 'Understand business news', 'Develop attention to detail'],
    ),
    executionContent: ExecutionContent(
      entranceExams: [
        EntranceExam(name: 'CA Foundation', month: 'May & November', eligibility: 'Class 12 pass', syllabusFocus: 'Accounting, Law, Maths, Economics', difficultyIndex: 6),
        EntranceExam(name: 'CA Intermediate', month: 'May & November', eligibility: 'CA Foundation', syllabusFocus: 'Advanced Accounting, Audit, Tax', difficultyIndex: 8),
        EntranceExam(name: 'CA Final', month: 'May & November', eligibility: 'CA Inter + Articleship', syllabusFocus: 'Financial Reporting, Strategic Management', difficultyIndex: 9),
      ],
      topColleges: [
        College(name: 'ICAI (Institute)', location: 'Pan India', avgFees: '₹50K total', rating: 5.0, specialization: 'CA Course'),
        College(name: 'SRCC Delhi', location: 'Delhi', avgFees: '₹30K/year', rating: 4.8, specialization: 'B.Com'),
        College(name: 'St. Xavier\'s Mumbai', location: 'Mumbai', avgFees: '₹25K/year', rating: 4.7, specialization: 'B.Com'),
      ],
      financialReality: FinancialReality(entrySalary: '₹7-12 LPA', fiveYearSalary: '₹20-40 LPA', tenYearSalary: '₹50 LPA - 1 Cr+',
        growthData: [SalaryDataPoint(year: 0, salaryLakhs: 8), SalaryDataPoint(year: 5, salaryLakhs: 25), SalaryDataPoint(year: 10, salaryLakhs: 50)]),
      planB: PlanB(title: 'Alternative Finance Paths', description: 'Commerce opens many doors',
        alternativePaths: ['CMA (Cost Accountant)', 'CS (Company Secretary)', 'MBA Finance', 'CFA', 'ACCA']),
    ),
    realityTask: RealityTask(
      taskTitle: 'Balance Sheet Basics', taskInstructions: 'Categorize these items correctly', taskType: TaskType.matching,
      questions: [
        TaskQuestion(question: 'Where does "Cash in Bank" go?', options: ['Liability', 'Asset', 'Expense', 'Income'], correctIndex: 1, explanation: 'Cash is an asset - something the company owns'),
        TaskQuestion(question: 'Where does "Bank Loan" go?', options: ['Asset', 'Liability', 'Income', 'Expense'], correctIndex: 1, explanation: 'Loan is a liability - something the company owes'),
        TaskQuestion(question: 'Where does "Office Rent Paid" go?', options: ['Asset', 'Liability', 'Expense', 'Income'], correctIndex: 2, explanation: 'Rent paid is an expense - cost of running business'),
      ],
      successOutcome: 'You understand the basics of accounting! Assets = Liabilities + Equity is the foundation of all finance.',
    ),
    realityCheck: RealityCheck(avgSalary: '₹15-35 LPA', jobStressIndex: 7, studyHoursDaily: 5, yearsToMaster: 5, workLifeBalance: 'Moderate', jobAvailability: 'High'),
    resourceLibrary: ResourceLibrary(
      courses: [ResourceLink(title: 'Accounting Fundamentals', url: 'https://skillsbuild.org/', source: 'IBM SkillsBuild', type: 'Course')],
      videos: [], articles: [ResourceLink(title: 'ICAI Official', url: 'https://icai.org/', source: 'ICAI', type: 'Article')],
      ncertChapters: [ResourceLink(title: 'Class 11 - Accountancy', url: 'https://ncert.nic.in/', source: 'NCERT', type: 'Chapter')],
    ),
    roadmap: CareerRoadmap(nodes: [
      RoadmapNode(order: 1, title: 'Class 10', description: 'Focus on Maths', duration: 'Current'),
      RoadmapNode(order: 2, title: 'Class 11-12 Commerce', description: 'Register for CA Foundation', duration: '2 years'),
      RoadmapNode(order: 3, title: 'CA Foundation', description: 'First level exam', duration: '4 months'),
      RoadmapNode(order: 4, title: 'CA Intermediate + Articleship', description: 'Work while studying', duration: '3 years'),
      RoadmapNode(order: 5, title: 'CA Final', description: 'Become a Chartered Accountant', duration: '1 year'),
    ]),
  );


  // CORPORATE LAWYER - HEC
  static final CareerModel _corporateLawyer = CareerModel(
    id: 'corporate_lawyer', title: 'Corporate Lawyer', streamTag: StreamTag.hec,
    shortDescription: 'Navigate complex legal matters for businesses', iconName: 'gavel',
    discoveryContent: DiscoveryContent(
      dayInLife: '''Advocate Sharma arrives at her law firm at 9 AM. Today's agenda: a ₹500 crore merger deal.

Morning: Reviewing contracts clause by clause. One wrong word could cost millions. She spots an ambiguity and drafts a clarification.

Afternoon: Court appearance for a trademark dispute. Her client's brand is being copied. She argues passionately, citing precedents from memory.

Evening: Advising a startup on compliance. "How do we structure this investment legally?" She loves helping new businesses navigate the legal maze.

The thrill? Every case is a puzzle. Every argument is a battle of wits. And justice, when served, is deeply satisfying.''',
      funFact: 'India\'s top lawyers can charge ₹10-50 lakhs per court appearance! The legal profession is one of the oldest, dating back thousands of years.',
      visualAids: [], introVideos: [],
    ),
    bridgeContent: BridgeContent(
      required11thStream: 'Any stream works! Arts/Humanities (HEC) is traditional, but Science students also become lawyers',
      foundationTopics: ['Civics - Understanding governance', 'History - Legal evolution', 'English - Argumentation skills'],
      streamComparison: StreamComparison(comparedStream: 'Commerce', pros: ['Intellectual challenge', 'High earning potential', 'Social impact'], cons: ['5-year LLB or 3-year after graduation', 'Initial years are tough', 'Long working hours']),
      keySkillsToStart: ['Debate and public speaking', 'Reading comprehension', 'Logical reasoning', 'Current affairs awareness'],
    ),
    executionContent: ExecutionContent(
      entranceExams: [
        EntranceExam(name: 'CLAT', month: 'December', eligibility: 'Class 12 pass', syllabusFocus: 'English, GK, Legal Reasoning, Maths, Logic', difficultyIndex: 7),
        EntranceExam(name: 'AILET', month: 'December', eligibility: 'Class 12 pass', syllabusFocus: 'Similar to CLAT', difficultyIndex: 8),
        EntranceExam(name: 'LSAT India', month: 'Multiple', eligibility: 'Class 12 pass', syllabusFocus: 'Reading, Analytical Reasoning', difficultyIndex: 7),
      ],
      topColleges: [
        College(name: 'NLSIU Bangalore', location: 'Bangalore', avgFees: '₹2.5L/year', rating: 5.0, specialization: 'Corporate Law'),
        College(name: 'NALSAR Hyderabad', location: 'Hyderabad', avgFees: '₹2.5L/year', rating: 5.0, specialization: 'IP Law'),
        College(name: 'NLU Delhi', location: 'Delhi', avgFees: '₹2L/year', rating: 4.9, specialization: 'Constitutional Law'),
        College(name: 'NUJS Kolkata', location: 'Kolkata', avgFees: '₹2.5L/year', rating: 4.8, specialization: 'Corporate'),
      ],
      financialReality: FinancialReality(entrySalary: '₹8-20 LPA', fiveYearSalary: '₹25-60 LPA', tenYearSalary: '₹50 LPA - 2 Cr+',
        growthData: [SalaryDataPoint(year: 0, salaryLakhs: 12), SalaryDataPoint(year: 5, salaryLakhs: 35), SalaryDataPoint(year: 10, salaryLakhs: 80)]),
      planB: PlanB(title: 'Alternative Legal Paths', description: 'Law degree opens many doors',
        alternativePaths: ['Legal Journalism', 'Corporate Compliance', 'Legal Tech Startups', 'Judiciary (Judge)', 'Legal Academia']),
    ),
    realityTask: RealityTask(
      taskTitle: 'Legal Logic Challenge', taskInstructions: 'Find the contradiction in witness statements', taskType: TaskType.analysis,
      questions: [
        TaskQuestion(question: 'Witness A: "I saw the accident at 3 PM, the sun was setting." Witness B: "It was bright daylight." What\'s wrong?', 
          options: ['Nothing wrong', 'Sun doesn\'t set at 3 PM in India', 'Both are lying', 'Time doesn\'t matter'], 
          correctIndex: 1, explanation: 'In India, sunset is around 6-7 PM. Sun setting at 3 PM is impossible - Witness A is unreliable.'),
        TaskQuestion(question: 'A contract says "Party A will pay ₹10 lakhs" but also "Payment is optional." Is this valid?', 
          options: ['Yes, contracts can have options', 'No, it\'s contradictory', 'Depends on the judge', 'Only if signed'], 
          correctIndex: 1, explanation: 'A contract cannot simultaneously require and make optional the same obligation. This is a contradiction.'),
      ],
      successOutcome: 'Excellent legal reasoning! Lawyers constantly look for contradictions and logical flaws in arguments.',
    ),
    realityCheck: RealityCheck(avgSalary: '₹20-50 LPA', jobStressIndex: 8, studyHoursDaily: 5, yearsToMaster: 8, workLifeBalance: 'Variable', jobAvailability: 'Good'),
    resourceLibrary: ResourceLibrary(
      courses: [ResourceLink(title: 'Introduction to Law', url: 'https://swayam.gov.in/', source: 'SWAYAM', type: 'Course')],
      videos: [], articles: [ResourceLink(title: 'Bar Council of India', url: 'https://barcouncilofindia.org/', source: 'BCI', type: 'Article')],
      ncertChapters: [ResourceLink(title: 'Class 10 - Democratic Politics', url: 'https://ncert.nic.in/', source: 'NCERT', type: 'Chapter')],
    ),
    roadmap: CareerRoadmap(nodes: [
      RoadmapNode(order: 1, title: 'Class 10', description: 'Focus on English, Social Studies', duration: 'Current'),
      RoadmapNode(order: 2, title: 'Class 11-12', description: 'Any stream + CLAT prep', duration: '2 years'),
      RoadmapNode(order: 3, title: 'BA LLB / BBA LLB', description: '5-year integrated law degree', duration: '5 years'),
      RoadmapNode(order: 4, title: 'Associate Lawyer', description: 'Work at law firm', duration: '3-5 years'),
      RoadmapNode(order: 5, title: 'Partner / Independent', description: 'Lead practice', duration: 'Ongoing'),
    ]),
  );

  // WEB DEVELOPER - Vocational
  static final CareerModel _webDeveloper = CareerModel(
    id: 'web_developer', title: 'Web Developer', streamTag: StreamTag.vocational,
    shortDescription: 'Build websites and web applications', iconName: 'web',
    discoveryContent: DiscoveryContent(
      dayInLife: '''Arjun, 24, works from his home in Indore as a freelance web developer. No degree from IIT - just skills and determination.

Morning: Coffee and checking client messages. A restaurant owner in Dubai wants a website. Arjun sends a proposal.

Afternoon: Building an e-commerce site for a local boutique. HTML, CSS, JavaScript - his tools of creation. He adds a shopping cart feature.

Evening: Learning React.js through YouTube tutorials. The tech world moves fast - continuous learning is key.

Best part? He earns ₹80,000/month working from home, sets his own hours, and has clients worldwide. No entrance exam required - just skills!''',
      funFact: 'The first website ever created is still online! Tim Berners-Lee created it in 1991. Today, there are over 1.9 billion websites!',
      visualAids: [], introVideos: [],
    ),
    bridgeContent: BridgeContent(
      required11thStream: 'Any stream! Web development is skill-based, not degree-based',
      foundationTopics: ['Basic computer skills', 'Logical thinking', 'English for documentation'],
      streamComparison: StreamComparison(comparedStream: 'B.Tech CSE', pros: ['Start earning in 6 months', 'No entrance exams', 'Freelance freedom', 'Low cost'], cons: ['No degree credential', 'Self-discipline needed', 'Competitive market']),
      keySkillsToStart: ['Learn HTML basics (free online)', 'Practice CSS styling', 'Understand how websites work', 'Build simple projects'],
    ),
    executionContent: ExecutionContent(
      entranceExams: [
        EntranceExam(name: 'No entrance exam!', month: 'Anytime', eligibility: 'Willingness to learn', syllabusFocus: 'HTML, CSS, JavaScript', difficultyIndex: 3),
      ],
      topColleges: [
        College(name: 'freeCodeCamp', location: 'Online', avgFees: 'Free', rating: 4.8, specialization: 'Full Stack'),
        College(name: 'The Odin Project', location: 'Online', avgFees: 'Free', rating: 4.7, specialization: 'Web Dev'),
        College(name: 'Scaler Academy', location: 'Online', avgFees: '₹3L total', rating: 4.5, specialization: 'Full Stack'),
      ],
      financialReality: FinancialReality(entrySalary: '₹3-6 LPA', fiveYearSalary: '₹10-25 LPA', tenYearSalary: '₹25-50 LPA',
        growthData: [SalaryDataPoint(year: 0, salaryLakhs: 4), SalaryDataPoint(year: 3, salaryLakhs: 12), SalaryDataPoint(year: 6, salaryLakhs: 25)]),
      planB: PlanB(title: 'Related Tech Paths', description: 'Web skills transfer easily',
        alternativePaths: ['Mobile App Development', 'UI/UX Design', 'Digital Marketing', 'Tech Content Creation']),
    ),
    realityTask: RealityTask(
      taskTitle: 'HTML Basics', taskInstructions: 'Understand how websites are structured', taskType: TaskType.logicPuzzle,
      questions: [
        TaskQuestion(question: 'What does HTML stand for?', options: ['Hyper Text Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyperlink Text Mode Language'], correctIndex: 0, explanation: 'HTML = Hyper Text Markup Language - the skeleton of every website'),
        TaskQuestion(question: 'Which tag creates a heading?', options: ['<p>', '<h1>', '<div>', '<span>'], correctIndex: 1, explanation: '<h1> to <h6> create headings, with h1 being the largest'),
        TaskQuestion(question: 'What makes a website look pretty?', options: ['HTML', 'CSS', 'JavaScript', 'Python'], correctIndex: 1, explanation: 'CSS (Cascading Style Sheets) handles colors, fonts, layouts - the design!'),
      ],
      successOutcome: 'You know the basics! HTML structures content, CSS styles it, JavaScript makes it interactive.',
    ),
    realityCheck: RealityCheck(avgSalary: '₹8-20 LPA', jobStressIndex: 5, studyHoursDaily: 3, yearsToMaster: 3, workLifeBalance: 'Excellent', jobAvailability: 'Very High'),
    resourceLibrary: ResourceLibrary(
      courses: [
        ResourceLink(title: 'Responsive Web Design', url: 'https://freecodecamp.org/', source: 'freeCodeCamp', type: 'Course'),
        ResourceLink(title: 'Web Development', url: 'https://skillsbuild.org/', source: 'IBM SkillsBuild', type: 'Course'),
      ],
      videos: [ResourceLink(title: 'HTML Crash Course', url: 'https://youtube.com/', source: 'Traversy Media', type: 'Video')],
      articles: [ResourceLink(title: 'MDN Web Docs', url: 'https://developer.mozilla.org/', source: 'Mozilla', type: 'Article')],
      ncertChapters: [],
    ),
    roadmap: CareerRoadmap(nodes: [
      RoadmapNode(order: 1, title: 'Start Now', description: 'Learn HTML & CSS basics', duration: '1-2 months'),
      RoadmapNode(order: 2, title: 'JavaScript', description: 'Add interactivity', duration: '2-3 months'),
      RoadmapNode(order: 3, title: 'Projects', description: 'Build 5-10 websites', duration: '3-4 months'),
      RoadmapNode(order: 4, title: 'First Job/Freelance', description: 'Start earning', duration: '6-12 months'),
      RoadmapNode(order: 5, title: 'Specialize', description: 'React, Node.js, etc.', duration: 'Ongoing'),
    ]),
  );
}
