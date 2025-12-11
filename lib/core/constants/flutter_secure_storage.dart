import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyUsername  = "enc_username";
  static const _keyPassword  = "enc_password";

  // Keys
  static const _keyToken = 'Token';
  static const _keyIDDV = 'IDDV';
  static const _keySM1 = 'SM1';
  static const _keySM2 = 'SM2';
  static const _keyQuyen = 'QUYEN';
  static const _keyUser = 'ID_USER';
  static const _keyFullNameUser = 'FULLNAME_USER';
  static const _keyAvatarUrl = 'IMG_AVA';
  static const _keyTenPb = 'TEN_PB';
  static const _keyTenDv = 'TENDONVI';
  static const _keyIdPb = 'ID_PB';


  static Future<void> saveEncryptedCredentials(String username, String password) async {
    final encUser = base64Encode(utf8.encode(username));
    final encPass = base64Encode(utf8.encode(password));

    await _storage.write(key: _keyUsername, value: encUser);
    await _storage.write(key: _keyPassword, value: encPass);
  }

  static Future<(String?, String?)> getEncryptedCredentials() async {
    final u = await _storage.read(key: _keyUsername);
    final p = await _storage.read(key: _keyPassword);

    if (u == null || p == null) return (null, null);

    return (
    utf8.decode(base64Decode(u)),
    utf8.decode(base64Decode(p)),
    );
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
  }

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
    String? tenPb,
    String? tenDv,
    int? idPb,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyIDDV, value: iddv.toString());
    await _storage.write(key: _keySM1, value: sm1);
    await _storage.write(key: _keySM2, value: sm2);
    await _storage.write(key: _keyQuyen, value: quyen);
    await _storage.write(key: _keyUser, value: user.toString());
    await _storage.write(key: _keyFullNameUser, value: fullNameUser);
    await _storage.write(key: _keyAvatarUrl, value: avatarUrl);
    await _storage.write(key: _keyTenPb, value: tenPb ?? '');
    await _storage.write(key: _keyTenDv, value: tenDv ?? '');
    await _storage.write(key: _keyIdPb, value: idPb?.toString() ?? '');
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
  static Future<String?> getTenPb() async => _storage.read(key: _keyTenPb);
  static Future<String?> getTenDv() async => _storage.read(key: _keyTenDv);
  static Future<String?> getIdPb() async => _storage.read(key: _keyIdPb);

  // Clear all
  static Future<void> clear() async => _storage.deleteAll();

}
