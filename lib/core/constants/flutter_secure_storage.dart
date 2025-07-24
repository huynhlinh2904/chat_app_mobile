import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _keyToken = 'Token';
  static const _keyIDDV = 'IDDV';
  static const _keySM1 = 'SM1';
  static const _keySM2 = 'SM2';
  static const _keyQuyen = 'QUYEN';

  // Save all login data
  static Future<void> saveLoginData({
    required String token,
    required String iddv,
    required String sm1,
    required String sm2,
    required String quyen,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyIDDV, value: iddv);
    await _storage.write(key: _keySM1, value: sm1);
    await _storage.write(key: _keySM2, value: sm2);
    await _storage.write(key: _keyQuyen, value: quyen);
  }

  // Getters
  static Future<String?> getToken() async => _storage.read(key: _keyToken);
  static Future<String?> getIDDV() async => _storage.read(key: _keyIDDV);
  static Future<String?> getSM1() async => _storage.read(key: _keySM1);
  static Future<String?> getSM2() async => _storage.read(key: _keySM2);
  static Future<String?> getQuyen() async => _storage.read(key: _keyQuyen);

  // Clear all
  static Future<void> clear() async => _storage.deleteAll();
}


