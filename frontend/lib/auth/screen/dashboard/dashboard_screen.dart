import 'package:flutter/material.dart';

import '../../../features/home/screen/home_shell.dart';
import '../../../features/dashboard/repository/dashboard_repository.dart';
import '../../../features/dashboard/repository/registration_status_repository.dart';
import '../../../features/presensi/repository/presensi_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.dashboardRepository,
    required this.registrationStatusRepository,
  });

  static const routeName = '/dashboard';
  final PresensiRepository repository;
  final DashboardRepository dashboardRepository;
  final RegistrationStatusRepository registrationStatusRepository;

  @override
  Widget build(BuildContext context) => HomeShell(
        presensiRepository: repository,
        dashboardRepository: dashboardRepository,
        registrationStatusRepository: registrationStatusRepository,
      );
}
