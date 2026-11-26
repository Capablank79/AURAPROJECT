import '../../../core/models/report_model.dart';

abstract interface class ReportRepository {
  Future<ReportModel> createReport({
    required String itemId,
    required String reporterId,
    required String reason,
  });

  Future<List<ReportModel>> getReports();

  Future<ReportModel> updateReportStatus({
    required String reportId,
    required String status,
  });
}

class MockReportRepository implements ReportRepository {
  final List<ReportModel> _reports = [];

  @override
  Future<ReportModel> createReport({
    required String itemId,
    required String reporterId,
    required String reason,
  }) async {
    final report = ReportModel(
      id: 'report-${_reports.length + 1}',
      itemId: itemId,
      reporterId: reporterId,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now().toUtc(),
    );
    _reports.add(report);
    return report;
  }

  @override
  Future<List<ReportModel>> getReports() async => List.unmodifiable(_reports);

  @override
  Future<ReportModel> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      throw StateError('Report $reportId not found.');
    }
    final updated = _reports[index].copyWith(status: status);
    _reports[index] = updated;
    return updated;
  }
}
