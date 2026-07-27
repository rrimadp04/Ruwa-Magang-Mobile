import 'package:flutter/material.dart';

import '../repository/logbook_repository.dart';
import 'logbook_form.dart';

class TambahLogbookScreen extends StatelessWidget {
  const TambahLogbookScreen({super.key, required this.repository});
  final LogbookRepository repository;

  @override
  Widget build(BuildContext context) => LogbookFormScreen(title: 'Tambah Logbook', repository: repository);
}
