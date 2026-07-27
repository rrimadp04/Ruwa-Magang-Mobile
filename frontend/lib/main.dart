import 'package:flutter/material.dart';

import 'auth/screen/dashboard/dashboard_screen.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/dashboard/service/dashboard_service.dart';
import 'features/dashboard/repository/registration_status_repository.dart';
import 'features/dashboard/service/registration_status_service.dart';
import 'features/presensi/repository/presensi_repository.dart';
import 'features/presensi/service/presensi_service.dart';

void main() {
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  const accessToken = String.fromEnvironment('API_TOKEN');

  final presensiRepository = PresensiRepository(
    PresensiService(baseUrl: apiBaseUrl, accessToken: accessToken),
  );
  final dashboardRepository = DashboardRepository(
    DashboardService(baseUrl: apiBaseUrl, accessToken: accessToken),
  );
  final registrationStatusRepository = RegistrationStatusRepository(
    RegistrationStatusService(baseUrl: apiBaseUrl, accessToken: accessToken),
  );

  runApp(
    RuwaMagangApp(
      presensiRepository: presensiRepository,
      dashboardRepository: dashboardRepository,
      registrationStatusRepository: registrationStatusRepository,
    ),
  );
}

class RuwaMagangApp extends StatelessWidget {
  const RuwaMagangApp({
    super.key,
    required this.presensiRepository,
    required this.dashboardRepository,
    required this.registrationStatusRepository,
  });

  final PresensiRepository presensiRepository;
  final DashboardRepository dashboardRepository;
  final RegistrationStatusRepository registrationStatusRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruwa Magang',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FE),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0757D8)),
        fontFamily: 'Roboto',
      ),
      home: DashboardScreen(
        repository: presensiRepository,
        dashboardRepository: dashboardRepository,
        registrationStatusRepository: registrationStatusRepository,
      ),
    );
  }
}
