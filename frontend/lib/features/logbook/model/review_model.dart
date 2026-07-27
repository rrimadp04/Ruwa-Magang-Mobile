enum ReviewStatus { pending, revision, resubmitted, approved }

class ReviewChecklist {
  const ReviewChecklist({required this.label, required this.passed, this.note});

  final String label;
  final bool passed;
  final String? note;
}

class ReviewModel {
  const ReviewModel({
    this.id = '',
    required this.reviewer,
    required this.role,
    required this.message,
    required this.createdAt,
    required this.approved,
    this.institution = 'Diskominfotik Provinsi Lampung',
    this.photoUrl,
    this.status,
    this.checklist = const [],
  });

  final String id;
  final String reviewer;
  final String role;
  final String institution;
  final String? photoUrl;
  final String message;
  final DateTime createdAt;
  final bool approved;
  final ReviewStatus? status;
  final List<ReviewChecklist> checklist;

  ReviewStatus get effectiveStatus => status ?? (approved ? ReviewStatus.approved : ReviewStatus.revision);
  bool get requiresRevision => effectiveStatus == ReviewStatus.revision;
  bool get isApproved => effectiveStatus == ReviewStatus.approved || approved;
}
