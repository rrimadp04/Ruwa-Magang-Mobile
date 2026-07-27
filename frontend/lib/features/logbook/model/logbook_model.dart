import 'attachment_model.dart';
import 'review_model.dart';

enum LogbookStatus { draft, pending, revision, approved }

class LogbookModel {
  const LogbookModel({
    required this.id,
    required this.userId,
    required this.opdId,
    required this.activity,
    required this.activityDate,
    required this.status,
    required this.createdAt,
    this.description,
    this.attachments = const [],
    this.reviews = const [],
    this.commentCount = 0,
  });

  final String id;
  final int userId;
  final int? opdId;
  final String activity;
  final DateTime activityDate;
  final LogbookStatus status;
  final DateTime? createdAt;
  final String? description;
  final List<AttachmentModel> attachments;
  final List<ReviewModel> reviews;
  final int commentCount;

  String get title => activity.length <= 56 ? activity : '${activity.substring(0, 56)}...';
  String get activityDescription => description?.trim().isNotEmpty == true
      ? description!.trim()
      : 'Menyelesaikan aktivitas magang harian dan mendokumentasikan hasil pekerjaan sesuai arahan pembimbing.';
  bool get canEdit => status == LogbookStatus.draft || status == LogbookStatus.revision;
  ReviewModel? get latestReview => reviews.isEmpty ? null : reviews.last;
  ReviewModel? get latestRevisionReview {
    for (final review in reviews.reversed) {
      if (review.requiresRevision) return review;
    }
    return null;
  }

  factory LogbookModel.fromJson(Map<String, dynamic> json) => LogbookModel(
        id: '${json['id']}',
        userId: _toInt(json['user_id']),
        opdId: json['opd_id'] == null ? null : _toInt(json['opd_id']),
        activity: '${json['title'] ?? json['activity_title'] ?? json['activity'] ?? ''}',
        description: '${json['description'] ?? json['activity_description'] ?? json['notes'] ?? ''}',
        activityDate: DateTime.tryParse('${json['logbook_date'] ?? json['activity_date'] ?? ''}') ?? DateTime.now(),
        status: _status('${json['status'] ?? 'pending'}'),
        createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      );

  LogbookModel copyWith({
    String? activity,
    String? description,
    DateTime? activityDate,
    LogbookStatus? status,
    List<AttachmentModel>? attachments,
    List<ReviewModel>? reviews,
  }) =>
      LogbookModel(
        id: id,
        userId: userId,
        opdId: opdId,
        activity: activity ?? this.activity,
        description: description ?? this.description,
        activityDate: activityDate ?? this.activityDate,
        status: status ?? this.status,
        createdAt: createdAt,
        attachments: attachments ?? this.attachments,
        reviews: reviews ?? this.reviews,
        commentCount: commentCount,
      );
}

int _toInt(dynamic value) => int.tryParse('$value') ?? 0;
LogbookStatus _status(String status) => switch (status.toLowerCase()) {
      'approved' || 'disetujui' => LogbookStatus.approved,
      'revision' || 'revisi' => LogbookStatus.revision,
      'draft' || 'draf' => LogbookStatus.draft,
      _ => LogbookStatus.pending,
    };

