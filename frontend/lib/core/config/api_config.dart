/// Konfigurasi endpoint API aplikasi.
///
/// Android Emulator memakai alamat host khusus `10.0.2.2` secara default.
/// Untuk perangkat fisik (atau environment lain), berikan URL saat menjalankan
/// atau membangun aplikasi, misalnya:
///
/// flutter run --dart-define=API_BASE_URL=http://192.168.9.168:8001/api
///
/// Nilai dari `--dart-define` sengaja tidak disimpan di source code agar IP
/// jaringan development tidak perlu diubah di banyak file atau dikomit.
abstract final class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _androidEmulatorBaseUrl =
      'http://10.0.2.2:8001/api';

  /// Base URL tunggal yang digunakan seluruh HTTP service.
  static String get baseUrl {
    final configuredUrl = _configuredBaseUrl.trim();
    final url = configuredUrl.isEmpty ? _androidEmulatorBaseUrl : configuredUrl;
    return url.replaceFirst(RegExp(r'/+$'), '');
  }
}
