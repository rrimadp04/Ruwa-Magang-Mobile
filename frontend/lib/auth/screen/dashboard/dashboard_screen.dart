import 'package:flutter/material.dart';

import '../../../features/home/screen/home_shell.dart';
import '../../../features/dashboard/repository/dashboard_repository.dart';
import '../../../features/dashboard/repository/registration_status_repository.dart';
import '../../../features/logbook/repository/logbook_repository.dart';
import '../../../features/nilai_sertifikat/repository/nilai_repository.dart';
import '../../../features/presensi/repository/presensi_repository.dart';
import '../../../features/profile/repository/profile_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.dashboardRepository,
    required this.registrationStatusRepository,
    required this.logbookRepository,
    required this.nilaiRepository,
    required this.profileRepository,
  });

  static const routeName = '/dashboard';
  final PresensiRepository repository;
  final DashboardRepository dashboardRepository;
  final RegistrationStatusRepository registrationStatusRepository;
  final LogbookRepository logbookRepository;
  final NilaiRepository nilaiRepository;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) => HomeShell(
        dashboardRepository: dashboardRepository,
        registrationStatusRepository: registrationStatusRepository,
        logbookRepository: logbookRepository,
        nilaiRepository: nilaiRepository,
        presensiRepository: repository,
        profileRepository: profileRepository,
      );
}
