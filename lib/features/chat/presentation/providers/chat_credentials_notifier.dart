import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_contain.dart';

final chatCredentialsProvider = FutureProvider((ref) async {
  return await getChatCredentials();
});
