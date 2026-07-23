import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/presensi/repository/presensi_repository.dart';
import 'features/home/screen/home_shell.dart';
import 'features/presensi/service/presensi_service.dart';

void main() {
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  const accessToken = String.fromEnvironment('API_TOKEN');

  runApp(
    RuwaMagangApp(
      repository: PresensiRepository(
        PresensiService(baseUrl: apiBaseUrl, accessToken: accessToken),
      ),

    ),
  );
}

class RuwaMagangApp extends StatelessWidget {
  const RuwaMagangApp({super.key, required this.repository});

  final PresensiRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ruwa Magang',
    theme: AppTheme.theme,
    home: HomeShell(repository: repository),
  );
}
