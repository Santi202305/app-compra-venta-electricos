import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato para almacenamiento seguro del token JWT.
abstract class TokenStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
}

/// Implementación basada en flutter_secure_storage (KeyStore en Android, Keychain en iOS/macOS, SecretService/libsecret en Linux).
/// Cuenta con fallback en memoria defensivo ante entornos de prueba unitaria sin binding nativo.
class SecureTokenStorageService implements TokenStorageService {
  final FlutterSecureStorage _storage;
  static const String _keyToken = 'jwt_auth_token_v1';
  final Map<String, String> _fallbackMemory = {};

  SecureTokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      debugPrint('Aviso SecureTokenStorage (modo fallback): $e');
      _fallbackMemory[_keyToken] = token;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      return _fallbackMemory[_keyToken];
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyToken);
    } catch (_) {
      _fallbackMemory.remove(_keyToken);
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }
}

/// Implementación en memoria para pruebas unitarias sin dependencias nativas del sistema operativo.
class InMemoryTokenStorageService implements TokenStorageService {
  String? _token;

  InMemoryTokenStorageService({String? initialToken}) : _token = initialToken;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<bool> hasToken() async {
    return _token != null && _token!.trim().isNotEmpty;
  }
}
