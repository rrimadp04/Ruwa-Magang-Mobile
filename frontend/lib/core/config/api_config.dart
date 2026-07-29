/// Konfigurasi endpoint API aplikasi.
///
/// Perangkat fisik memakai alamat LAN backend website secara default.
/// Untuk Android Emulator atau environment lain, berikan URL saat menjalankan
/// atau membangun aplikasi, misalnya:
///
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2/api
///
/// Nilai dari `--dart-define` sengaja tidak disimpan di source code agar IP
/// jaringan development tidak perlu diubah di banyak file atau dikomit.
abstract final class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  // Harus menunjuk ke backend yang sama dengan APP_URL pada proyek Laravel.
  // URL ini dapat ditimpa dengan --dart-define=API_BASE_URL untuk perangkat
  // atau server development lain.
  static const String _defaultBaseUrl =
      'http://192.168.18.69:8001/api';

  /// Base URL tunggal yang digunakan seluruh HTTP service.
  static String get baseUrl {
    final configuredUrl = _configuredBaseUrl.trim();
    final url = configuredUrl.isEmpty ? _defaultBaseUrl : configuredUrl;
    return url.replaceFirst(RegExp(r'/+$'), '');
  }
}
