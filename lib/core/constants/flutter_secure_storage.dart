import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _keyToken = 'Token';
  static const _keyIDDV = 'IDDV';
  static const _keySM1 = 'SM1';
  static const _keySM2 = 'SM2';
  static const _keyQuyen = 'QUYEN';
  static const _keyUser = 'ID_USER';
  static const _keyFullNameUser = 'FULLNAME_USER';
  static const _keyAvatarUrl = 'IMG_AVA';

  // Save all login data
  static Future<void> saveLoginData({
    required String token,
    required int iddv,
    required String sm1,
    required String sm2,
    required String quyen,
    required int user,
    required String fullNameUser,
    required String avatarUrl,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyIDDV, value: iddv.toString());
    await _storage.write(key: _keySM1, value: sm1);
    await _storage.write(key: _keySM2, value: sm2);
    await _storage.write(key: _keyQuyen, value: quyen);
    await _storage.write(key: _keyUser, value: user.toString());
    await _storage.write(key: _keyFullNameUser, value: fullNameUser);
    await _storage.write(key: _keyAvatarUrl, value: avatarUrl);
  }

  // Getters
  static Future<int?> getIDDV() async {
    final value = await _storage.read(key: _keyIDDV);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<int?> getIDUser() async {
    final value = await _storage.read(key: _keyUser);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<String?> getToken() async => _storage.read(key: _keyToken);
  static Future<String?> getSM1() async => _storage.read(key: _keySM1);
  static Future<String?> getSM2() async => _storage.read(key: _keySM2);
  static Future<String?> getQuyen() async => _storage.read(key: _keyQuyen);
  static Future<String?> getFullNameUser() async =>
      _storage.read(key: _keyFullNameUser);
  static Future<String?> getAvatarUrl() async =>
      _storage.read(key: _keyAvatarUrl);

  // Clear all
  static Future<void> clear() async => _storage.deleteAll();
  static Future<void> debugPrintLoginData() async {
    final token = await getToken();
    final iddv = await getIDDV();
    final sm1 = await getSM1();
    final sm2 = await getSM2();
    final quyen = await getQuyen();
    final user = await getIDUser();
    final fullName = await getFullNameUser();
    final avatar = await getAvatarUrl();

    print("""
=============================
🔐 LOCAL STORAGE LOGIN DATA
=============================
Token: $token
IDDV: $iddv
SM1: $sm1
SM2: $sm2
Quyen: $quyen
UserID: $user
FullName: $fullName
Avatar: $avatar
=============================
""");
  }
}
