import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/screen/login_screen.dart';
import 'auth/screen/register_screen.dart';
import 'auth/repositories/auth_repository.dart';
import 'auth/services/auth_service.dart';
import 'core/config/api_config.dart';

import 'auth/screen/dashboard/dashboard_screen.dart';
import 'features/presensi/repository/presensi_repository.dart';
import 'features/presensi/service/presensi_service.dart';
import 'features/presensi/screen/presensi_screen.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/dashboard/service/dashboard_service.dart';
import 'features/dashboard/repository/registration_status_repository.dart';
import 'features/dashboard/service/registration_status_service.dart';
import 'features/profile/repository/profile_repository.dart';
import 'features/profile/screen/participant_profile_screen.dart';
import 'features/profile/service/profile_service.dart';
import 'features/logbook/repository/logbook_repository.dart';
import 'features/logbook/screen/list_logbook_screen.dart';
import 'features/logbook/service/logbook_service.dart';
import 'features/nilai_sertifikat/repository/nilai_repository.dart';
import 'features/nilai_sertifikat/screen/nilai_sertifikat_screen.dart';
import 'features/nilai_sertifikat/screen/sertifikat_screen.dart';
import 'features/nilai_sertifikat/service/nilai_service.dart';
import 'features/opd/pages/opd_page.dart';

void main() {
  final apiBaseUrl = ApiConfig.baseUrl;

  debugPrint('[RuwaMagang] API: $apiBaseUrl');

  runApp(RuwaMagangApp(apiBaseUrl: apiBaseUrl));
}

class RuwaMagangApp extends StatefulWidget {
  const RuwaMagangApp({super.key, required this.apiBaseUrl});

  final String apiBaseUrl;

  @override
  State<RuwaMagangApp> createState() => _RuwaMagangAppState();
}

class _RuwaMagangAppState extends State<RuwaMagangApp> {
  late Future<_Repositories> _repositoriesFuture;

  @override
  void initState() {
    super.initState();
    _repositoriesFuture = _buildRepositories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Repositories>(
      future: _repositoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final repositories = snapshot.requireData;

        return MaterialApp(
          key: ValueKey(repositories.isAuthenticated),
          debugShowCheckedModeBanner: false,
          title: 'Ruwa Magang',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F9FE),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0757D8),
            ),
            fontFamily: 'Roboto',
          ),
          home: repositories.isAuthenticated
              ? DashboardScreen(
                  repository: repositories.presensi,
                  dashboardRepository: repositories.dashboard,
                  registrationStatusRepository: repositories.registrationStatus,
                  logbookRepository: repositories.logbook,
                  nilaiRepository: repositories.nilai,
                  profileRepository: repositories.profile,
                )
              : LoginScreen(
                  repository: repositories.presensi,
                  onAuthenticated: (token) => _refreshSession(freshToken: token),
                ),
          routes: {
            LoginScreen.routeName: (_) => LoginScreen(
              repository: repositories.presensi,
              onAuthenticated: (token) => _refreshSession(freshToken: token),
            ),
            RegisterScreen.routeName: (_) => RegisterScreen(
              repository: repositories.presensi,
              onAuthenticated: (token) => _refreshSession(freshToken: token),
            ),
            DashboardScreen.routeName: (_) => DashboardScreen(
              repository: repositories.presensi,
              dashboardRepository: repositories.dashboard,
              registrationStatusRepository: repositories.registrationStatus,
              logbookRepository: repositories.logbook,
              nilaiRepository: repositories.nilai,
              profileRepository: repositories.profile,
            ),
            '/presensi': (_) =>
                PresensiScreen(repository: repositories.presensi),
            '/daftar': (_) => const OpdPage(),
            '/logbook': (_) => ListLogbookScreen(
              repository: repositories.logbook,
            ),
            '/nilai-sertifikat': (_) => NilaiSertifikatScreen(
              repository: repositories.nilai,
            ),
            '/sertifikat': (_) => const SertifikatScreen(),
            '/profil': (_) =>
                ParticipantProfileScreen(repository: repositories.profile),
          },
        );
      },
    );
  }

  Future<_Repositories> _buildRepositories({String? freshToken}) async {
    final prefs = await SharedPreferences.getInstance();

    String token;
    if (freshToken != null) {
      // Token baru dari login/register — langsung pakai, tidak perlu validasi
      // ulang ke server karena baru saja diterbitkan.
      token = AuthRepository.normalizeToken(freshToken);
      await prefs.setString(AuthRepository.tokenKey, token);
    } else {
      final storedToken = prefs.getString(AuthRepository.tokenKey) ?? '';
      token = AuthRepository.normalizeToken(storedToken);

      // Migrasikan token lama yang tersimpan dengan awalan "Bearer ".
      if (token.isNotEmpty && token != storedToken) {
        await prefs.setString(AuthRepository.tokenKey, token);
      }

      // Validasi token lama (dari app restart) ke server sekali saja.
      if (token.isNotEmpty) {
        final authRepository = AuthRepository(
          service: AuthService(baseUrl: widget.apiBaseUrl),
          prefs: prefs,
        );
        if (!await authRepository.hasValidSession()) {
          await authRepository.clearToken();
          token = '';
        }
      }
    }

    return _Repositories(
      PresensiRepository(
        PresensiService(baseUrl: widget.apiBaseUrl, accessToken: token),
      ),
      DashboardRepository(
        DashboardService(baseUrl: widget.apiBaseUrl, accessToken: token),
      ),
      ProfileRepository(
        ProfileService(baseUrl: widget.apiBaseUrl, accessToken: token),
      ),
      RegistrationStatusRepository(
        RegistrationStatusService(
          baseUrl: widget.apiBaseUrl,
          accessToken: token,
        ),
      ),
      LogbookRepository(
        LogbookService(baseUrl: widget.apiBaseUrl, accessToken: token),
      ),
      NilaiRepository(
        NilaiService(baseUrl: widget.apiBaseUrl, accessToken: token),
      ),
      token.isNotEmpty,
    );
  }

  void _refreshSession({String? freshToken}) {
    setState(() {
      _repositoriesFuture = _buildRepositories(freshToken: freshToken);
    });
  }
}

class _Repositories {
  const _Repositories(
    this.presensi,
    this.dashboard,
    this.profile,
    this.registrationStatus,
    this.logbook,
    this.nilai,
    this.isAuthenticated,
  );
  final PresensiRepository presensi;
  final DashboardRepository dashboard;
  final ProfileRepository profile;
  final RegistrationStatusRepository registrationStatus;
  final LogbookRepository logbook;
  final NilaiRepository nilai;
  final bool isAuthenticated;
}
