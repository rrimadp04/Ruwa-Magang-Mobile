class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  static const opd = '/opd';
  static const pendaftaran = '/pendaftaran';
  static const uploadDokumen = '/pendaftaran/upload';
  static const statusPendaftaran = '/pendaftaran/status';
}
