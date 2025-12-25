/// Teacher Management Models
/// Models for career management, student oversight, and academy features

import 'career_model.dart';

// ============================================================
// SUPPORTED LANGUAGES
// ============================================================
enum SupportedLanguage { english, hindi, telugu, tamil, kannada, marathi }

extension SupportedLanguageExt on SupportedLanguage {
  String get code {
    switch (this) {
      case SupportedLanguage.english: return 'en';
      case SupportedLanguage.hindi: return 'hi';
      case SupportedLanguage.telugu: return 'te';
      case SupportedLanguage.tamil: return 'ta';
      case SupportedLanguage.kannada: return 'kn';
      case SupportedLanguage.marathi: return 'mr';
    }
  }

  String get displayName {
    switch (this) {
      case SupportedLanguage.english: return 'English';
      case SupportedLanguage.hindi: return 'हिंदी';
      case SupportedLanguage.telugu: return 'తెలుగు';
      case SupportedLanguage.tamil: return 'தமிழ்';
      case SupportedLanguage.kannada: return 'ಕನ್ನಡ';
      case SupportedLanguage.marathi: return 'मराठी';
    }
  }
}

// ============================================================
// GRADE VISIBILITY MODEL
// ============================================================
class GradeVisibility {
  final bool grade7;
  final bool grade8;
  final bool grade9;
  final bool grade10;
  final bool grade11;
  final bool grade12;

  GradeVisibility({
    this.grade7 = true,
    this.grade8 = true,
    this.grade9 = true,
    this.grade10 = true,
    this.grade11 = true,
    this.grade12 = true,
  });

  bool isVisibleForGrade(int grade) {
    switch (grade) {
      case 7: return grade7;
      case 8: return grade8;
      case 9: return grade9;
      case 10: return grade10;
      case 11: return grade11;
      case 12: return grade12;
      default: return false;
    }
  }

  Map<String, dynamic> toMap() => {
    'grade7': grade7,
    'grade8': grade8,
    'grade9': grade9,
    'grade10': grade10,
    'grade11': grade11,
    'grade12': grade12,
  };

  factory GradeVisibility.fromMap(Map<String, dynamic> map) => GradeVisibility(
    grade7: map['grade7'] ?? true,
    grade8: map['grade8'] ?? true,
    grade9: map['grade9'] ?? true,
    grade10: map['grade10'] ?? true,
    grade11: map['grade11'] ?? true,
    grade12: map['grade12'] ?? true,
  );

  GradeVisibility copyWith({
    bool? grade7, bool? grade8, bool? grade9,
    bool? grade10, bool? grade11, bool? grade12,
  }) => GradeVisibility(
    grade7: grade7 ?? this.grade7,
    grade8: grade8 ?? this.grade8,
    grade9: grade9 ?? this.grade9,
    grade10: grade10 ?? this.grade10,
    grade11: grade11 ?? this.grade11,
    grade12: grade12 ?? this.grade12,
  );
}

// ============================================================
// MULTI-LANGUAGE CONTENT
// ============================================================
class MultiLangContent {
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String> dayInLife;
  final Map<String, String> funFact;

  MultiLangContent({
    required this.title,
    required this.description,
    required this.dayInLife,
    required this.funFact,
  });

  String getTitle(SupportedLanguage lang) => title[lang.code] ?? title['en'] ?? '';
  String getDescription(SupportedLanguage lang) => description[lang.code] ?? description['en'] ?? '';
  String getDayInLife(SupportedLanguage lang) => dayInLife[lang.code] ?? dayInLife['en'] ?? '';
  String getFunFact(SupportedLanguage lang) => funFact[lang.code] ?? funFact['en'] ?? '';

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dayInLife': dayInLife,
    'funFact': funFact,
  };

  factory MultiLangContent.fromMap(Map<String, dynamic> map) => MultiLangContent(
    title: Map<String, String>.from(map['title'] ?? {}),
    description: Map<String, String>.from(map['description'] ?? {}),
    dayInLife: Map<String, String>.from(map['dayInLife'] ?? {}),
    funFact: Map<String, String>.from(map['funFact'] ?? {}),
  );
}

// ============================================================
// SUPPORTING DOCUMENT
// ============================================================
class SupportingDocument {
  final String id;
  final String title;
  final String type; // pdf, link, video
  final String url;
  final DateTime uploadedAt;

  SupportingDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type,
    'url': url,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory SupportingDocument.fromMap(Map<String, dynamic> map) => SupportingDocument(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    type: map['type'] ?? 'link',
    url: map['url'] ?? '',
    uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
  );
}


// ============================================================
// MANAGED CAREER MODEL (Extended CareerModel for Teacher Management)
// ============================================================
class ManagedCareer {
  final String id;
  final String title;
  final StreamTag streamTag;
  final String shortDescription;
  final String iconName;
  final GradeVisibility gradeVisibility;
  final MultiLangContent? multiLangContent;
  final List<SupportingDocument> documents;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Teacher UID

  // Grade-Adaptive Content
  final DiscoveryContent discoveryContent;
  final BridgeContent bridgeContent;
  final ExecutionContent executionContent;
  final RealityTask realityTask;
  final RealityCheck realityCheck;
  final ResourceLibrary resourceLibrary;
  final CareerRoadmap roadmap;

  ManagedCareer({
    required this.id,
    required this.title,
    required this.streamTag,
    required this.shortDescription,
    required this.iconName,
    required this.gradeVisibility,
    this.multiLangContent,
    this.documents = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
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
    'gradeVisibility': gradeVisibility.toMap(),
    'multiLangContent': multiLangContent?.toMap(),
    'documents': documents.map((d) => d.toMap()).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'discoveryContent': discoveryContent.toMap(),
    'bridgeContent': bridgeContent.toMap(),
    'executionContent': executionContent.toMap(),
    'realityTask': realityTask.toMap(),
    'realityCheck': realityCheck.toMap(),
    'resourceLibrary': resourceLibrary.toMap(),
    'roadmap': roadmap.toMap(),
  };

  factory ManagedCareer.fromMap(Map<String, dynamic> map) => ManagedCareer(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    streamTag: StreamTag.values.firstWhere((s) => s.name == map['streamTag'], orElse: () => StreamTag.mpc),
    shortDescription: map['shortDescription'] ?? '',
    iconName: map['iconName'] ?? 'work',
    gradeVisibility: GradeVisibility.fromMap(map['gradeVisibility'] ?? {}),
    multiLangContent: map['multiLangContent'] != null ? MultiLangContent.fromMap(map['multiLangContent']) : null,
    documents: (map['documents'] as List?)?.map((d) => SupportingDocument.fromMap(d)).toList() ?? [],
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    createdBy: map['createdBy'] ?? '',
    discoveryContent: DiscoveryContent.fromMap(map['discoveryContent'] ?? {}),
    bridgeContent: BridgeContent.fromMap(map['bridgeContent'] ?? {}),
    executionContent: ExecutionContent.fromMap(map['executionContent'] ?? {}),
    realityTask: RealityTask.fromMap(map['realityTask'] ?? {}),
    realityCheck: RealityCheck.fromMap(map['realityCheck'] ?? {}),
    resourceLibrary: ResourceLibrary.fromMap(map['resourceLibrary'] ?? {}),
    roadmap: CareerRoadmap.fromMap(map['roadmap'] ?? {}),
  );

  ManagedCareer copyWith({
    String? id, String? title, StreamTag? streamTag, String? shortDescription,
    String? iconName, GradeVisibility? gradeVisibility, MultiLangContent? multiLangContent,
    List<SupportingDocument>? documents, bool? isActive, DateTime? createdAt,
    DateTime? updatedAt, String? createdBy, DiscoveryContent? discoveryContent,
    BridgeContent? bridgeContent, ExecutionContent? executionContent,
    RealityTask? realityTask, RealityCheck? realityCheck,
    ResourceLibrary? resourceLibrary, CareerRoadmap? roadmap,
  }) => ManagedCareer(
    id: id ?? this.id,
    title: title ?? this.title,
    streamTag: streamTag ?? this.streamTag,
    shortDescription: shortDescription ?? this.shortDescription,
    iconName: iconName ?? this.iconName,
    gradeVisibility: gradeVisibility ?? this.gradeVisibility,
    multiLangContent: multiLangContent ?? this.multiLangContent,
    documents: documents ?? this.documents,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    createdBy: createdBy ?? this.createdBy,
    discoveryContent: discoveryContent ?? this.discoveryContent,
    bridgeContent: bridgeContent ?? this.bridgeContent,
    executionContent: executionContent ?? this.executionContent,
    realityTask: realityTask ?? this.realityTask,
    realityCheck: realityCheck ?? this.realityCheck,
    resourceLibrary: resourceLibrary ?? this.resourceLibrary,
    roadmap: roadmap ?? this.roadmap,
  );
}

// ============================================================
// STUDENT SUBMISSION & REVIEW MODELS
// ============================================================
enum SubmissionStatus { pending, approved, rejected, revisionRequired }

extension SubmissionStatusExt on SubmissionStatus {
  String get displayName {
    switch (this) {
      case SubmissionStatus.pending: return 'Pending Review';
      case SubmissionStatus.approved: return 'Approved';
      case SubmissionStatus.rejected: return 'Rejected';
      case SubmissionStatus.revisionRequired: return 'Revision Required';
    }
  }

  String get colorHex {
    switch (this) {
      case SubmissionStatus.pending: return '#FFA500';
      case SubmissionStatus.approved: return '#22C55E';
      case SubmissionStatus.rejected: return '#EF4444';
      case SubmissionStatus.revisionRequired: return '#3B82F6';
    }
  }
}

class StudentSubmission {
  final String id;
  final String studentId;
  final String studentName;
  final int studentGrade;
  final String type; // reflection, journal, task_result
  final String title;
  final String content;
  final String? careerId;
  final SubmissionStatus status;
  final String? teacherComment;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  StudentSubmission({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentGrade,
    required this.type,
    required this.title,
    required this.content,
    this.careerId,
    this.status = SubmissionStatus.pending,
    this.teacherComment,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'studentGrade': studentGrade,
    'type': type,
    'title': title,
    'content': content,
    'careerId': careerId,
    'status': status.name,
    'teacherComment': teacherComment,
    'submittedAt': submittedAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedBy': reviewedBy,
  };

  factory StudentSubmission.fromMap(Map<String, dynamic> map) => StudentSubmission(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    studentGrade: map['studentGrade'] ?? 7,
    type: map['type'] ?? 'reflection',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    careerId: map['careerId'],
    status: SubmissionStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => SubmissionStatus.pending),
    teacherComment: map['teacherComment'],
    submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
    reviewedAt: map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt']) : null,
    reviewedBy: map['reviewedBy'],
  );

  StudentSubmission copyWith({
    SubmissionStatus? status,
    String? teacherComment,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) => StudentSubmission(
    id: id, studentId: studentId, studentName: studentName, studentGrade: studentGrade,
    type: type, title: title, content: content, careerId: careerId,
    status: status ?? this.status,
    teacherComment: teacherComment ?? this.teacherComment,
    submittedAt: submittedAt,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewedBy: reviewedBy ?? this.reviewedBy,
  );
}

// ============================================================
// PERSONALIZED CAREER NOTE
// ============================================================
class CareerNote {
  final String id;
  final String studentId;
  final String teacherId;
  final String teacherName;
  final String note;
  final List<String> recommendedCareers;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CareerNote({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.teacherName,
    required this.note,
    this.recommendedCareers = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'note': note,
    'recommendedCareers': recommendedCareers,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory CareerNote.fromMap(Map<String, dynamic> map) => CareerNote(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    teacherId: map['teacherId'] ?? '',
    teacherName: map['teacherName'] ?? '',
    note: map['note'] ?? '',
    recommendedCareers: List<String>.from(map['recommendedCareers'] ?? []),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
  );
}


// ============================================================
// NOTICE BOARD & EVENTS
// ============================================================
enum NoticeType { webinar, workshop, careerTalk, announcement, deadline }

extension NoticeTypeExt on NoticeType {
  String get displayName {
    switch (this) {
      case NoticeType.webinar: return 'Webinar';
      case NoticeType.workshop: return 'Workshop';
      case NoticeType.careerTalk: return 'Career Talk';
      case NoticeType.announcement: return 'Announcement';
      case NoticeType.deadline: return 'Deadline';
    }
  }

  String get icon {
    switch (this) {
      case NoticeType.webinar: return 'video_call';
      case NoticeType.workshop: return 'build';
      case NoticeType.careerTalk: return 'record_voice_over';
      case NoticeType.announcement: return 'campaign';
      case NoticeType.deadline: return 'alarm';
    }
  }
}

class Notice {
  final String id;
  final String title;
  final String description;
  final NoticeType type;
  final DateTime eventDate;
  final String? eventTime;
  final String? meetingLink;
  final List<int> targetGrades; // Empty = all grades
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.eventDate,
    this.eventTime,
    this.meetingLink,
    this.targetGrades = const [],
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'eventDate': eventDate.toIso8601String(),
    'eventTime': eventTime,
    'meetingLink': meetingLink,
    'targetGrades': targetGrades,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory Notice.fromMap(Map<String, dynamic> map) => Notice(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    type: NoticeType.values.firstWhere((t) => t.name == map['type'], orElse: () => NoticeType.announcement),
    eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
    eventTime: map['eventTime'],
    meetingLink: map['meetingLink'],
    targetGrades: List<int>.from(map['targetGrades'] ?? []),
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    createdBy: map['createdBy'] ?? '',
  );
}

// ============================================================
// OPPORTUNITY MODEL (Scholarships, Competitions, etc.)
// ============================================================
enum OpportunityType { scholarship, competition, olympiad, internship, course }

extension OpportunityTypeExt on OpportunityType {
  String get displayName {
    switch (this) {
      case OpportunityType.scholarship: return 'Scholarship';
      case OpportunityType.competition: return 'Competition';
      case OpportunityType.olympiad: return 'Olympiad';
      case OpportunityType.internship: return 'Internship';
      case OpportunityType.course: return 'Free Course';
    }
  }
}

class Opportunity {
  final String id;
  final String title;
  final String description;
  final OpportunityType type;
  final String? eligibility;
  final DateTime? deadline;
  final String? applicationLink;
  final List<int> targetGrades;
  final List<StreamTag> targetStreams;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.eligibility,
    this.deadline,
    this.applicationLink,
    this.targetGrades = const [],
    this.targetStreams = const [],
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'eligibility': eligibility,
    'deadline': deadline?.toIso8601String(),
    'applicationLink': applicationLink,
    'targetGrades': targetGrades,
    'targetStreams': targetStreams.map((s) => s.name).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory Opportunity.fromMap(Map<String, dynamic> map) => Opportunity(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    type: OpportunityType.values.firstWhere((t) => t.name == map['type'], orElse: () => OpportunityType.scholarship),
    eligibility: map['eligibility'],
    deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
    applicationLink: map['applicationLink'],
    targetGrades: List<int>.from(map['targetGrades'] ?? []),
    targetStreams: (map['targetStreams'] as List?)?.map((s) => StreamTag.values.firstWhere((t) => t.name == s, orElse: () => StreamTag.mpc)).toList() ?? [],
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    createdBy: map['createdBy'] ?? '',
  );
}

// ============================================================
// STUDENT OPPORTUNITY INTEREST
// ============================================================
enum InterestStatus { interested, applied, notInterested }

class StudentOpportunityInterest {
  final String id;
  final String studentId;
  final String opportunityId;
  final InterestStatus status;
  final DateTime markedAt;

  StudentOpportunityInterest({
    required this.id,
    required this.studentId,
    required this.opportunityId,
    required this.status,
    required this.markedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'opportunityId': opportunityId,
    'status': status.name,
    'markedAt': markedAt.toIso8601String(),
  };

  factory StudentOpportunityInterest.fromMap(Map<String, dynamic> map) => StudentOpportunityInterest(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    opportunityId: map['opportunityId'] ?? '',
    status: InterestStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => InterestStatus.interested),
    markedAt: DateTime.tryParse(map['markedAt'] ?? '') ?? DateTime.now(),
  );
}

// ============================================================
// QUIZ / ASSESSMENT MODEL
// ============================================================
class Quiz {
  final String id;
  final String title;
  final String description;
  final String? careerId;
  final List<int> targetGrades;
  final List<QuizQuestion> questions;
  final int timeLimitMinutes;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    this.careerId,
    this.targetGrades = const [],
    required this.questions,
    this.timeLimitMinutes = 15,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'careerId': careerId,
    'targetGrades': targetGrades,
    'questions': questions.map((q) => q.toMap()).toList(),
    'timeLimitMinutes': timeLimitMinutes,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory Quiz.fromMap(Map<String, dynamic> map) => Quiz(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    careerId: map['careerId'],
    targetGrades: List<int>.from(map['targetGrades'] ?? []),
    questions: (map['questions'] as List?)?.map((q) => QuizQuestion.fromMap(q)).toList() ?? [],
    timeLimitMinutes: map['timeLimitMinutes'] ?? 15,
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    createdBy: map['createdBy'] ?? '',
  );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
    question: map['question'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    correctIndex: map['correctIndex'] ?? 0,
    explanation: map['explanation'],
  );
}

class QuizAttempt {
  final String id;
  final String quizId;
  final String studentId;
  final int score;
  final int totalQuestions;
  final List<int> answers;
  final DateTime attemptedAt;
  final int timeTakenSeconds;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.attemptedAt,
    required this.timeTakenSeconds,
  });

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'quizId': quizId,
    'studentId': studentId,
    'score': score,
    'totalQuestions': totalQuestions,
    'answers': answers,
    'attemptedAt': attemptedAt.toIso8601String(),
    'timeTakenSeconds': timeTakenSeconds,
  };

  factory QuizAttempt.fromMap(Map<String, dynamic> map) => QuizAttempt(
    id: map['id'] ?? '',
    quizId: map['quizId'] ?? '',
    studentId: map['studentId'] ?? '',
    score: map['score'] ?? 0,
    totalQuestions: map['totalQuestions'] ?? 0,
    answers: List<int>.from(map['answers'] ?? []),
    attemptedAt: DateTime.tryParse(map['attemptedAt'] ?? '') ?? DateTime.now(),
    timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
  );
}

// ============================================================
// STUDENT ACTIVITY TRACKING
// ============================================================
class StudentActivity {
  final String studentId;
  final String studentName;
  final int grade;
  final DateTime? lastLoginAt;
  final int careersExplored;
  final int tasksCompleted;
  final int quizzesAttempted;
  final List<String> exploredCareerIds;

  StudentActivity({
    required this.studentId,
    required this.studentName,
    required this.grade,
    this.lastLoginAt,
    this.careersExplored = 0,
    this.tasksCompleted = 0,
    this.quizzesAttempted = 0,
    this.exploredCareerIds = const [],
  });

  bool get isInactive {
    if (lastLoginAt == null) return true;
    return DateTime.now().difference(lastLoginAt!).inDays > 7;
  }

  int get daysSinceLastLogin {
    if (lastLoginAt == null) return -1;
    return DateTime.now().difference(lastLoginAt!).inDays;
  }

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'studentName': studentName,
    'grade': grade,
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'careersExplored': careersExplored,
    'tasksCompleted': tasksCompleted,
    'quizzesAttempted': quizzesAttempted,
    'exploredCareerIds': exploredCareerIds,
  };

  factory StudentActivity.fromMap(Map<String, dynamic> map) => StudentActivity(
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    grade: map['grade'] ?? 7,
    lastLoginAt: map['lastLoginAt'] != null ? DateTime.tryParse(map['lastLoginAt']) : null,
    careersExplored: map['careersExplored'] ?? 0,
    tasksCompleted: map['tasksCompleted'] ?? 0,
    quizzesAttempted: map['quizzesAttempted'] ?? 0,
    exploredCareerIds: List<String>.from(map['exploredCareerIds'] ?? []),
  );
}








