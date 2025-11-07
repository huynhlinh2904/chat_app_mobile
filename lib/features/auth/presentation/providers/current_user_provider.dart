import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/flutter_secure_storage.dart';

/// Provider đọc toàn bộ thông tin user đang đăng nhập từ secure storage
final currentUserProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final token = await LocalStorageService.getToken();
  final iddv = await LocalStorageService.getIDDV();
  final sm1 = await LocalStorageService.getSM1();
  final sm2 = await LocalStorageService.getSM2();
  final quyen = await LocalStorageService.getQuyen();
  final idUser = await LocalStorageService.getIDUser();
  final fullName = await LocalStorageService.getFullNameUser();
  final avatarUrl = await LocalStorageService.getAvatarUrl();
  final tenPb = await LocalStorageService.getTenPb();
  final tenDv = await LocalStorageService.getTenDv();
  final idPb = await LocalStorageService.getIdPb();


  return {
    'Token': token,
    'IDDV': iddv,
    'SM1': sm1,
    'SM2': sm2,
    'QUYEN': quyen,
    'ID_USER': idUser,
    'FULLNAME_USER': fullName,
    'IMG_AVA': avatarUrl,
    'TEN_PB': tenPb,
    'TENDONVI': tenDv,
    'ID_PB': idPb,
  };
});
