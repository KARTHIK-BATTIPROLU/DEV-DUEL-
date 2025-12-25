/// Career Model - Comprehensive Career Data Structure
/// Supports grade-adaptive content for Grades 7-12

// Stream Tags
enum StreamTag { mpc, bipc, mec, cec, hec, vocational }

extension StreamTagExtension on StreamTag {
  String get displayName {
    switch (this) {
      case StreamTag.mpc: return 'MPC (Maths/Physics/Chemistry)';
      case StreamTag.bipc: return 'BiPC (Biology/Physics/Chemistry)';
      case StreamTag.mec: return 'MEC (Maths/Economics/Commerce)';
      case StreamTag.cec: return 'CEC (Civics/Economics/Commerce)';
      case StreamTag.hec: return 'HEC (History/Economics/Civics)';
      case StreamTag.vocational: return 'Vocational/Skill-Based';
    }
  }

  String get shortName {
    switch (this) {
      case StreamTag.mpc: return 'MPC';
      case StreamTag.bipc: return 'BiPC';
      case StreamTag.mec: return 'MEC';
      case StreamTag.cec: return 'CEC';
      case StreamTag.hec: return 'HEC';
      case StreamTag.vocational: return 'Vocational';
    }
  }
}

/// Grade 7-8 Discovery Content
class DiscoveryContent {
  final String dayInLife; // 500-word narrative
  final String funFact;
  final List<String> visualAids; // illustration URLs
  final List<String> introVideos; // 2-min video URLs

  DiscoveryContent({
    required this.dayInLife,
    required this.funFact,
    required this.visualAids,
    required this.introVideos,
  });

  Map<String, dynamic> toMap() => {
    'dayInLife': dayInLife,
    'funFact': funFact,
    'visualAids': visualAids,
    'introVideos': introVideos,
  };

  factory DiscoveryContent.fromMap(Map<String, dynamic> map) => DiscoveryContent(
    dayInLife: map['dayInLife'] ?? '',
    funFact: map['funFact'] ?? '',
    visualAids: List<String>.from(map['visualAids'] ?? []),
    introVideos: List<String>.from(map['introVideos'] ?? []),
  );
}

/// Grade 9-10 Bridge Content
class BridgeContent {
  final String required11thStream; // Subject combinations
  final List<String> foundationTopics; // NCERT chapters
  final StreamComparison streamComparison;
  final List<String> keySkillsToStart;

  BridgeContent({
    required this.required11thStream,
    required this.foundationTopics,
    required this.streamComparison,
    required this.keySkillsToStart,
  });

  Map<String, dynamic> toMap() => {
    'required11thStream': required11thStream,
    'foundationTopics': foundationTopics,
    'streamComparison': streamComparison.toMap(),
    'keySkillsToStart': keySkillsToStart,
  };

  factory BridgeContent.fromMap(Map<String, dynamic> map) => BridgeContent(
    required11thStream: map['required11thStream'] ?? '',
    foundationTopics: List<String>.from(map['foundationTopics'] ?? []),
    streamComparison: StreamComparison.fromMap(map['streamComparison'] ?? {}),
    keySkillsToStart: List<String>.from(map['keySkillsToStart'] ?? []),
  );
}

class StreamComparison {
  final String comparedStream;
  final List<String> pros;
  final List<String> cons;

  StreamComparison({
    required this.comparedStream,
    required this.pros,
    required this.cons,
  });

  Map<String, dynamic> toMap() => {
    'comparedStream': comparedStream,
    'pros': pros,
    'cons': cons,
  };

  factory StreamComparison.fromMap(Map<String, dynamic> map) => StreamComparison(
    comparedStream: map['comparedStream'] ?? '',
    pros: List<String>.from(map['pros'] ?? []),
    cons: List<String>.from(map['cons'] ?? []),
  );
}


/// Grade 11-12 Execution Content
class ExecutionContent {
  final List<EntranceExam> entranceExams;
  final List<College> topColleges;
  final FinancialReality financialReality;
  final PlanB planB;

  ExecutionContent({
    required this.entranceExams,
    required this.topColleges,
    required this.financialReality,
    required this.planB,
  });

  Map<String, dynamic> toMap() => {
    'entranceExams': entranceExams.map((e) => e.toMap()).toList(),
    'topColleges': topColleges.map((c) => c.toMap()).toList(),
    'financialReality': financialReality.toMap(),
    'planB': planB.toMap(),
  };

  factory ExecutionContent.fromMap(Map<String, dynamic> map) => ExecutionContent(
    entranceExams: (map['entranceExams'] as List?)
        ?.map((e) => EntranceExam.fromMap(e))
        .toList() ?? [],
    topColleges: (map['topColleges'] as List?)
        ?.map((c) => College.fromMap(c))
        .toList() ?? [],
    financialReality: FinancialReality.fromMap(map['financialReality'] ?? {}),
    planB: PlanB.fromMap(map['planB'] ?? {}),
  );
}

class EntranceExam {
  final String name;
  final String month;
  final String eligibility;
  final String syllabusFocus;
  final int difficultyIndex; // 1-10

  EntranceExam({
    required this.name,
    required this.month,
    required this.eligibility,
    required this.syllabusFocus,
    required this.difficultyIndex,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'month': month,
    'eligibility': eligibility,
    'syllabusFocus': syllabusFocus,
    'difficultyIndex': difficultyIndex,
  };

  factory EntranceExam.fromMap(Map<String, dynamic> map) => EntranceExam(
    name: map['name'] ?? '',
    month: map['month'] ?? '',
    eligibility: map['eligibility'] ?? '',
    syllabusFocus: map['syllabusFocus'] ?? '',
    difficultyIndex: map['difficultyIndex'] ?? 5,
  );
}

class College {
  final String name;
  final String location;
  final String avgFees; // Per year
  final double rating; // Out of 5
  final String specialization;

  College({
    required this.name,
    required this.location,
    required this.avgFees,
    required this.rating,
    required this.specialization,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'avgFees': avgFees,
    'rating': rating,
    'specialization': specialization,
  };

  factory College.fromMap(Map<String, dynamic> map) => College(
    name: map['name'] ?? '',
    location: map['location'] ?? '',
    avgFees: map['avgFees'] ?? '',
    rating: (map['rating'] ?? 0).toDouble(),
    specialization: map['specialization'] ?? '',
  );
}

class FinancialReality {
  final String entrySalary;
  final String fiveYearSalary;
  final String tenYearSalary;
  final List<SalaryDataPoint> growthData;

  FinancialReality({
    required this.entrySalary,
    required this.fiveYearSalary,
    required this.tenYearSalary,
    required this.growthData,
  });

  Map<String, dynamic> toMap() => {
    'entrySalary': entrySalary,
    'fiveYearSalary': fiveYearSalary,
    'tenYearSalary': tenYearSalary,
    'growthData': growthData.map((d) => d.toMap()).toList(),
  };

  factory FinancialReality.fromMap(Map<String, dynamic> map) => FinancialReality(
    entrySalary: map['entrySalary'] ?? '',
    fiveYearSalary: map['fiveYearSalary'] ?? '',
    tenYearSalary: map['tenYearSalary'] ?? '',
    growthData: (map['growthData'] as List?)
        ?.map((d) => SalaryDataPoint.fromMap(d))
        .toList() ?? [],
  );
}

class SalaryDataPoint {
  final int year;
  final double salaryLakhs;

  SalaryDataPoint({required this.year, required this.salaryLakhs});

  Map<String, dynamic> toMap() => {'year': year, 'salaryLakhs': salaryLakhs};

  factory SalaryDataPoint.fromMap(Map<String, dynamic> map) => SalaryDataPoint(
    year: map['year'] ?? 0,
    salaryLakhs: (map['salaryLakhs'] ?? 0).toDouble(),
  );
}

class PlanB {
  final String title;
  final String description;
  final List<String> alternativePaths;

  PlanB({
    required this.title,
    required this.description,
    required this.alternativePaths,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'alternativePaths': alternativePaths,
  };

  factory PlanB.fromMap(Map<String, dynamic> map) => PlanB(
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    alternativePaths: List<String>.from(map['alternativePaths'] ?? []),
  );
}


/// Reality Task - Mini Simulator
class RealityTask {
  final String taskTitle;
  final String taskInstructions;
  final TaskType taskType;
  final List<TaskQuestion> questions;
  final String successOutcome;

  RealityTask({
    required this.taskTitle,
    required this.taskInstructions,
    required this.taskType,
    required this.questions,
    required this.successOutcome,
  });

  Map<String, dynamic> toMap() => {
    'taskTitle': taskTitle,
    'taskInstructions': taskInstructions,
    'taskType': taskType.name,
    'questions': questions.map((q) => q.toMap()).toList(),
    'successOutcome': successOutcome,
  };

  factory RealityTask.fromMap(Map<String, dynamic> map) => RealityTask(
    taskTitle: map['taskTitle'] ?? '',
    taskInstructions: map['taskInstructions'] ?? '',
    taskType: TaskType.values.firstWhere(
      (t) => t.name == map['taskType'],
      orElse: () => TaskType.logicPuzzle,
    ),
    questions: (map['questions'] as List?)
        ?.map((q) => TaskQuestion.fromMap(q))
        .toList() ?? [],
    successOutcome: map['successOutcome'] ?? '',
  );
}

enum TaskType { logicPuzzle, matching, calculation, analysis }

class TaskQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  TaskQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };

  factory TaskQuestion.fromMap(Map<String, dynamic> map) => TaskQuestion(
    question: map['question'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    correctIndex: map['correctIndex'] ?? 0,
    explanation: map['explanation'] ?? '',
  );
}

/// Reality Check Data
class RealityCheck {
  final String avgSalary;
  final int jobStressIndex; // 1-10
  final int studyHoursDaily;
  final int yearsToMaster;
  final String workLifeBalance;
  final String jobAvailability;

  RealityCheck({
    required this.avgSalary,
    required this.jobStressIndex,
    required this.studyHoursDaily,
    required this.yearsToMaster,
    required this.workLifeBalance,
    required this.jobAvailability,
  });

  Map<String, dynamic> toMap() => {
    'avgSalary': avgSalary,
    'jobStressIndex': jobStressIndex,
    'studyHoursDaily': studyHoursDaily,
    'yearsToMaster': yearsToMaster,
    'workLifeBalance': workLifeBalance,
    'jobAvailability': jobAvailability,
  };

  factory RealityCheck.fromMap(Map<String, dynamic> map) => RealityCheck(
    avgSalary: map['avgSalary'] ?? '',
    jobStressIndex: map['jobStressIndex'] ?? 5,
    studyHoursDaily: map['studyHoursDaily'] ?? 4,
    yearsToMaster: map['yearsToMaster'] ?? 5,
    workLifeBalance: map['workLifeBalance'] ?? 'Moderate',
    jobAvailability: map['jobAvailability'] ?? 'Moderate',
  );
}

/// Resource Library
class ResourceLibrary {
  final List<ResourceLink> courses;
  final List<ResourceLink> videos;
  final List<ResourceLink> articles;
  final List<ResourceLink> ncertChapters;

  ResourceLibrary({
    required this.courses,
    required this.videos,
    required this.articles,
    required this.ncertChapters,
  });

  Map<String, dynamic> toMap() => {
    'courses': courses.map((r) => r.toMap()).toList(),
    'videos': videos.map((r) => r.toMap()).toList(),
    'articles': articles.map((r) => r.toMap()).toList(),
    'ncertChapters': ncertChapters.map((r) => r.toMap()).toList(),
  };

  factory ResourceLibrary.fromMap(Map<String, dynamic> map) => ResourceLibrary(
    courses: (map['courses'] as List?)?.map((r) => ResourceLink.fromMap(r)).toList() ?? [],
    videos: (map['videos'] as List?)?.map((r) => ResourceLink.fromMap(r)).toList() ?? [],
    articles: (map['articles'] as List?)?.map((r) => ResourceLink.fromMap(r)).toList() ?? [],
    ncertChapters: (map['ncertChapters'] as List?)?.map((r) => ResourceLink.fromMap(r)).toList() ?? [],
  );
}

class ResourceLink {
  final String title;
  final String url;
  final String source; // IBM SkillsBuild, Khan Academy, etc.
  final String type;

  ResourceLink({
    required this.title,
    required this.url,
    required this.source,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'url': url,
    'source': source,
    'type': type,
  };

  factory ResourceLink.fromMap(Map<String, dynamic> map) => ResourceLink(
    title: map['title'] ?? '',
    url: map['url'] ?? '',
    source: map['source'] ?? '',
    type: map['type'] ?? '',
  );
}

/// Roadmap Timeline
class CareerRoadmap {
  final List<RoadmapNode> nodes;

  CareerRoadmap({required this.nodes});

  Map<String, dynamic> toMap() => {
    'nodes': nodes.map((n) => n.toMap()).toList(),
  };

  factory CareerRoadmap.fromMap(Map<String, dynamic> map) => CareerRoadmap(
    nodes: (map['nodes'] as List?)?.map((n) => RoadmapNode.fromMap(n)).toList() ?? [],
  );
}

class RoadmapNode {
  final String title;
  final String description;
  final String duration;
  final int order;

  RoadmapNode({
    required this.title,
    required this.description,
    required this.duration,
    required this.order,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'duration': duration,
    'order': order,
  };

  factory RoadmapNode.fromMap(Map<String, dynamic> map) => RoadmapNode(
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    duration: map['duration'] ?? '',
    order: map['order'] ?? 0,
  );
}


/// Main Career Model - Complete Structure
class CareerModel {
  final String id;
  final String title;
  final StreamTag streamTag;
  final String shortDescription;
  final String iconName;

  // Grade-Adaptive Content
  final DiscoveryContent discoveryContent; // Grades 7-8
  final BridgeContent bridgeContent; // Grades 9-10
  final ExecutionContent executionContent; // Grades 11-12

  // Common Content
  final RealityTask realityTask;
  final RealityCheck realityCheck;
  final ResourceLibrary resourceLibrary;
  final CareerRoadmap roadmap;

  CareerModel({
    required this.id,
    required this.title,
    required this.streamTag,
    required this.shortDescription,
    required this.iconName,
    required this.discoveryContent,
    required this.bridgeContent,
    required this.executionContent,
    required this.realityTask,
    required this.realityCheck,
    required this.resourceLibrary,
    required this.roadmap,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'streamTag': streamTag.name,
    'shortDescription': shortDescription,
    'iconName': iconName,
    'discoveryContent': discoveryContent.toMap(),
    'bridgeContent': bridgeContent.toMap(),
    'executionContent': executionContent.toMap(),
    'realityTask': realityTask.toMap(),
    'realityCheck': realityCheck.toMap(),
    'resourceLibrary': resourceLibrary.toMap(),
    'roadmap': roadmap.toMap(),
  };

  factory CareerModel.fromMap(Map<String, dynamic> map) => CareerModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    streamTag: StreamTag.values.firstWhere(
      (s) => s.name == map['streamTag'],
      orElse: () => StreamTag.mpc,
    ),
    shortDescription: map['shortDescription'] ?? '',
    iconName: map['iconName'] ?? 'work',
    discoveryContent: DiscoveryContent.fromMap(map['discoveryContent'] ?? {}),
    bridgeContent: BridgeContent.fromMap(map['bridgeContent'] ?? {}),
    executionContent: ExecutionContent.fromMap(map['executionContent'] ?? {}),
    realityTask: RealityTask.fromMap(map['realityTask'] ?? {}),
    realityCheck: RealityCheck.fromMap(map['realityCheck'] ?? {}),
    resourceLibrary: ResourceLibrary.fromMap(map['resourceLibrary'] ?? {}),
    roadmap: CareerRoadmap.fromMap(map['roadmap'] ?? {}),
  );
}
