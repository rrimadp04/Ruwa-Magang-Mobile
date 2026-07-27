/// Header standar untuk seluruh endpoint API yang membutuhkan sesi pengguna.
/// Token selalu dinormalisasi agar nilai lama seperti `Bearer <token>` tidak
/// menghasilkan header `Bearer Bearer <token>`.
abstract final class ApiClient {
  static Map<String, String> authenticatedHeaders(
    String token, {
    bool json = false,
  }) {
    final normalizedToken = normalizeToken(token);

    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (normalizedToken.isNotEmpty) 'Authorization': 'Bearer $normalizedToken',
    };
  }

  static String normalizeToken(String token) {
    var normalized = token.trim();
    while (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring('bearer '.length).trim();
    }
    return normalized;
  }
}
