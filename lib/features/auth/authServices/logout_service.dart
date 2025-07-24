import 'package:flutter/material.dart';
import '../../../core/constants/flutter_secure_storage.dart';

Future<void> logout(BuildContext context) async {
  await LocalStorageService.clear();
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}
