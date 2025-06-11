

import 'dart:math';

import '../core/network/dio_client.dart';
import '../models/user_model.dart';


class UserRepository {
  final DioClient _dio = DioClient();

  Future<ChatMembersResponse?> getUsersByConversation(int conversationId) async {
    final response = await _dio.get('/api/v1/chat/get-users-by-conversation/$conversationId');

    if (response.isSuccess) {
      return ChatMembersResponse.fromJson(response.data);
    } else {
      print("GET error: $e");
      throw Exception(response.error);
    }
  }
}
