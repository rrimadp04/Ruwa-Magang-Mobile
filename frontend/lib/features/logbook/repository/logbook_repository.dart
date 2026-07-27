import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import '../service/logbook_service.dart';

class LogbookRepository {
  LogbookRepository(this._service);
  final LogbookService _service;

  Future<List<LogbookModel>> getLogbooks() => _service.fetchAll();

  Future<LogbookModel> createLogbook({
    required DateTime date,
    required String activity,
    List<AttachmentModel>? attachments,
  }) =>
      _service.create(date: date, activity: activity, attachments: attachments);

  Future<LogbookModel> updateLogbook(LogbookModel item) =>
      _service.update(item);

  Future<void> deleteLogbook(String id) => _service.delete(id);
}
