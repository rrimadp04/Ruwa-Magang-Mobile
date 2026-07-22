# Ruwa Magang Mobile

## Konfigurasi API development

Seluruh request API menggunakan `ApiConfig` di `lib/core/config/api_config.dart`.

- Android Emulator: jalankan seperti biasa. Default-nya adalah
  `http://10.0.2.2:8001/api`.
- HP fisik pada jaringan Wi-Fi yang sama: jalankan dengan `dart-define`, tanpa
  mengubah source code:

  ```bash
  flutter run --dart-define=API_BASE_URL=http://192.168.9.168:8001/api
  ```

  Ganti IP pada perintah tersebut dengan IP LAN laptop yang sedang aktif.
  Parameter yang sama juga digunakan pada `flutter build`, sehingga URL
  development tidak tersimpan sebagai hardcode di service atau screen.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
