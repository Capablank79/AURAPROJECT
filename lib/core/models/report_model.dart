class ReportModel {
  const ReportModel({
    required this.id,
    required this.itemId,
    this.reporterId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      reporterId: json['reporter_id'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String itemId;
  final String? reporterId;
  final String reason;
  final String status;
  final DateTime createdAt;

  ReportModel copyWith({String? status}) {
    return ReportModel(
      id: id,
      itemId: itemId,
      reporterId: reporterId,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_id': itemId,
    'reporter_id': reporterId,
    'reason': reason,
    'status': status,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
