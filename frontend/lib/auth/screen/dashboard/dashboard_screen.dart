import 'package:flutter/material.dart';

import '../../../features/home/screen/home_shell.dart';
import '../../../features/dashboard/repository/dashboard_repository.dart';
import '../../../features/presensi/repository/presensi_repository.dart';

/// Route entry point after authentication.
///
/// The dashboard itself lives in [HomeShell], which already owns the app's
/// bottom navigation. Keeping this small adapter avoids a second dashboard
/// implementation and preserves the existing named-route architecture.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.repository, required this.dashboardRepository});

  static const routeName = '/dashboard';
  final PresensiRepository repository;
  final DashboardRepository dashboardRepository;

  @override
  Widget build(BuildContext context) => HomeShell(
        presensiRepository: repository,
        dashboardRepository: dashboardRepository,
      );
}
