import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/logbook/model/attachment_model.dart';
import 'package:frontend/features/logbook/service/logbook_service.dart';

void main() {
  group('LogbookService', () {
    test('menyimpan attachments saat membuat logbook', () async {
      final service = LogbookService();
      final attachments = [
        AttachmentModel(
          name: 'foto-1.jpg',
          bytes: Uint8List.fromList([1, 2, 3, 4]),
        ),
      ];

      final item = await service.create(
        date: DateTime(2026, 7, 22),
        activity: 'Aktivitas uji',
        attachments: attachments,
      );

      expect(item.attachments, hasLength(1));
      expect(item.attachments.first.name, 'foto-1.jpg');
      expect(item.attachments.first.bytes, isNotNull);
    });
  });
}
