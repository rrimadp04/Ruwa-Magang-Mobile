import '../service/registration_status_service.dart';

export '../service/registration_status_service.dart' show RegistrationStatus;

class RegistrationStatusRepository {
  RegistrationStatusRepository(this._service);
  final RegistrationStatusService _service;

  Future<RegistrationStatus> getStatus() => _service.fetchStatus();
}
