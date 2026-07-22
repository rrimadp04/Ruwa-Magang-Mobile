import '../model/participant_dashboard.dart';
import '../service/dashboard_service.dart';

class DashboardRepository {
  DashboardRepository(this._service);
  final DashboardService _service;

  Future<ParticipantDashboard> getDashboard() async =>
      ParticipantDashboard.fromResponse(await _service.fetchDashboard());
}
