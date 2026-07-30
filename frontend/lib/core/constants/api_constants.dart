class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.18.69:8001/api',
  );
  static const opd = '/opd';
  static const pendaftaran = '/pendaftaran';
  static const uploadDokumen = '/pendaftaran/upload';
  static const statusPendaftaran = '/pendaftaran/status';
}
