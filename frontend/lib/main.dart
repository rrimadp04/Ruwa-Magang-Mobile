import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'features/presensi/repository/presensi_repository.dart';
import 'features/home/screen/home_shell.dart';
import 'features/presensi/service/presensi_service.dart';
import 'features/nilai_sertifikat/repository/nilai_repository.dart';
import 'features/nilai_sertifikat/service/nilai_service.dart';
import 'features/logbook/repository/logbook_repository.dart';
import 'features/logbook/service/logbook_service.dart';

void main() {
  const defaultApiBaseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : 'http://10.0.2.2:8000/api';
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );
  const accessToken = String.fromEnvironment('API_TOKEN');

  runApp(
    RuwaMagangApp(
      repository: PresensiRepository(
        PresensiService(baseUrl: apiBaseUrl, accessToken: accessToken),
      ),
      nilaiRepository: NilaiRepository(
        NilaiService(baseUrl: apiBaseUrl, accessToken: accessToken),
      ),
      logbookRepository: LogbookRepository(LogbookService(baseUrl: apiBaseUrl, accessToken: accessToken)),
    ),
  );
}

class RuwaMagangApp extends StatelessWidget {
  const RuwaMagangApp({super.key, required this.repository, required this.nilaiRepository, required this.logbookRepository});

  final PresensiRepository repository;
  final NilaiRepository nilaiRepository;
  final LogbookRepository logbookRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruwa Magang',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          foregroundColor: Color(0xFF0F172A),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          elevation: 0,
          indicatorColor: const Color(0xFFE8F0FF),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: const Color(0x332563EB),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
      home: HomeShell(repository: repository, nilaiRepository: nilaiRepository, logbookRepository: logbookRepository),
    );
  }
}
