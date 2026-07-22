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
import 'features/dashboard/screen/participant_section_screen.dart';
import 'features/profile/repository/profile_repository.dart';
import 'features/profile/screen/participant_profile_screen.dart';
import 'features/profile/service/profile_service.dart';

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
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
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
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0757D8)),
            fontFamily: 'Roboto',
          ),
          home: repositories.isAuthenticated
              ? DashboardScreen(
                  repository: repositories.presensi,
                  dashboardRepository: repositories.dashboard,
                )
              : LoginScreen(
                  repository: repositories.presensi,
                  onAuthenticated: _refreshSession,
                ),
          routes: {
            LoginScreen.routeName: (_) => LoginScreen(
                  repository: repositories.presensi,
                  onAuthenticated: _refreshSession,
                ),
            RegisterScreen.routeName: (_) => RegisterScreen(
                  repository: repositories.presensi,
                  onAuthenticated: _refreshSession,
                ),
            DashboardScreen.routeName: (_) => DashboardScreen(
                  repository: repositories.presensi,
                  dashboardRepository: repositories.dashboard,
                ),
            '/presensi': (_) => PresensiScreen(repository: repositories.presensi),
            '/daftar': (_) => const ParticipantSectionScreen(title: 'Daftar', description: 'Lihat informasi pendaftaran dan penempatan magang Anda.', icon: Icons.assignment_outlined),
            '/logbook': (_) => const ParticipantSectionScreen(title: 'Logbook', description: 'Catat dan lengkapi aktivitas harian magang Anda.', icon: Icons.edit_note_outlined),
            '/nilai-sertifikat': (_) => const ParticipantSectionScreen(title: 'Nilai & Sertifikat', description: 'Pantau penilaian dan sertifikat magang yang diterbitkan.', icon: Icons.workspace_premium_outlined),
            '/profil': (_) => ParticipantProfileScreen(repository: repositories.profile),
          },
        );
      },
    );
  }

  Future<_Repositories> _buildRepositories() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(AuthRepository.tokenKey) ?? '';
    var token = AuthRepository.normalizeToken(storedToken);

    // Migrasikan nilai token lama ke format mentah tanpa mengubah sesi atau
    // alur navigasi aplikasi.
    if (token.isNotEmpty && token != storedToken) {
      await prefs.setString(AuthRepository.tokenKey, token);
    }

    // Keberadaan string token saja bukan bukti sesi masih valid. Validasi
    // dilakukan sebelum Dashboard dibuat agar token kedaluwarsa/tidak valid
    // selalu mengarahkan pengguna ke halaman Login.
    final authRepository = AuthRepository(
      service: AuthService(baseUrl: widget.apiBaseUrl),
      prefs: prefs,
    );
    if (token.isNotEmpty && !await authRepository.hasValidSession()) {
      await authRepository.clearToken();
      token = '';
    }

    return _Repositories(
      PresensiRepository(PresensiService(baseUrl: widget.apiBaseUrl, accessToken: token)),
      DashboardRepository(DashboardService(baseUrl: widget.apiBaseUrl, accessToken: token)),
      ProfileRepository(ProfileService(baseUrl: widget.apiBaseUrl, accessToken: token)),
      token.isNotEmpty,
    );
  }

  void _refreshSession() {
    setState(() {
      _repositoriesFuture = _buildRepositories();
    });
  }
}

class _Repositories {
  const _Repositories(this.presensi, this.dashboard, this.profile, this.isAuthenticated);
  final PresensiRepository presensi;
  final DashboardRepository dashboard;
  final ProfileRepository profile;
  final bool isAuthenticated;
}
