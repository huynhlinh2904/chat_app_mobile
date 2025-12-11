import 'dart:convert';
import 'package:chat_mobile_app/features/chat/data/dtos/chat_get_message_redis_response_dto.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_create_group_mapper.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_get_message_redis_mapper.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_message_mapper.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_send_message_mapper.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_update_one_to_group_mapper.dart';
import 'package:chat_mobile_app/features/chat/data/mappers/chat_user_mapper.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_create_group_entity.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_get_message_redis.dart';
import 'package:chat_mobile_app/features/chat/domain/entities/chat_send_message.dart';
import 'package:dio/dio.dart';
import 'package:chat_mobile_app/core/constants/app_contain.dart';
import '../../domain/entities/chat_get_message.dart';
import '../../domain/entities/chat_get_user_duan.dart';
import '../../domain/entities/chat_update_one_to_group.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_group.dart';
import '../dtos/chat_get_user_by_duan_response_dto.dart';
import '../dtos/chat_group_response_dto.dart';
import '../dtos/chat_message_response_dto.dart';
import '../dtos/chat_send_message_dto.dart';
import '../dtos/chat_update_one_to_group.dart' as dto;
import '../dtos/chat_user_response_dto.dart';
import '../dtos/create_group_request_dto.dart';
import '../dtos/create_group_response_dto.dart';
import '../mappers/chat_group_mapper.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  ChatRepositoryImpl(this._dio);

  // phần post get

  @override
  Future<List<ChatGroup>> getGroups({required int idGroup, required int type}) async {
    // Lấy credential đã lưu sau khi login
    final creds = await getChatCredentials();
    if (creds == null) {
      throw Exception('Thiếu thông tin xác thực (IDDV/SM1/SM2/ID_USER)');
    }

    final res = await _dio.post(
      EndPoint.groupChatUrl,
      data: {
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_GROUP': idGroup,
        'ID_USER': creds.userId,
        'TYPE': type, // 2 = nhóm
      },
    );

    dynamic raw = res.data;
    if (raw is String) raw = jsonDecode(raw);

    final dto = ChatGroupResponseDto.fromJson(raw as Map<String, dynamic>);
    return dto.message.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ChatUser>> getUsers({required int type}) async {
    try {
      final creds = await getChatCredentials();
      if (creds == null) throw Exception('Thiếu thông tin xác thực');

      final res = await _dio.post(EndPoint.chatListUserAPI, data: {
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_PB_PA': 0,
        'TYPE': type,
      });

      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);

      final dto = ChatUserResponseDto.fromJson(raw as Map<String, dynamic>);
      return dto.message.map((e) => e.toEntity()).toList();
    } catch (e) {
      print('Lỗi lấy danh sách user: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatGetMessage>> getMessages({
    required int idGroup,
    required String dateOlder,
    required int type,
  }) async {
    try {
      final creds = await getChatCredentials();
      if (creds == null) throw Exception('Thiếu thông tin xác thực');

      final payload = {
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_GROUP': idGroup,
        'NUMBER_MESS': 10,
        'DATE_OLDER': dateOlder,
        'TYPE': type,
      };

      print('\n🚀 [ChatRepositoryImpl] POST ${EndPoint.listMessageAPI}');
      print('📦 payload: $payload\n');

      final res = await _dio.post(EndPoint.listMessageAPI, data: payload);

      print('✅ status: ${res.statusCode}');
      print('✅ raw: ${res.data}\n');

      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);

      final dto = ChatGetMessageResponseDto.fromJson(raw); // ✅ đúng class
      print('📬 parsed: ${dto.message.length}\n');

      return dto.message.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      print('❌ DioException type=${e.type} code=${e.response?.statusCode}');
      print('👉 url: ${e.requestOptions.uri}');
      print('👉 req: ${e.requestOptions.data}');
      print('👉 res: ${e.response?.data}\n');
      rethrow;
    } catch (e, st) {
      print('💥 Unexpected: $e\n$st\n');
      rethrow;
    }
  }

  @override
  Future<List<ChatGetMessageRedis>> getMessageRedis({
    required int idGroup,
  }) async {
    try {
      final creds = await getChatCredentials();
      if (creds == null) throw Exception('Thiếu thông tin xác thực');

      final payload = {
        'ID_GROUP': idGroup,
      };

      print('\n🚀 [ChatRepositoryImpl] POST ${EndPoint.chatGetMessageRedisAPI}');
      print('📦 payload: $payload\n');

      final res = await _dio.post(EndPoint.chatGetMessageRedisAPI, data: payload);


      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);

      final dto = ChatGetMessageRedisResponseDto.fromJson(raw); // ✅ đúng class
      print('📬 parsed: ${dto.message.length}\n');
      print('🟢 [Redis] status: ${res.statusCode}');
      print('🟢 [Redis] raw: ${res.data}');

      return dto.message.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      print('❌ DioException type=${e.type} code=${e.response?.statusCode}');
      print('👉 url: ${e.requestOptions.uri}');
      print('👉 req: ${e.requestOptions.data}');
      print('👉 res: ${e.response?.data}\n');
      rethrow;
    } catch (e, st) {
      print('💥 Unexpected: $e\n$st\n');
      rethrow;
    }
  }

  @override
  Future<int?> getMessageIdByUuid(String uuid) async {
    try {
      final res = await _dio.post(
        'CHAT_get_MessageUuidMap',
        data: {'UUID': uuid},
      );
      // Tuỳ cấu trúc ApiResponse của bạn
      final data = res.data;
      final status = data['status'] ?? data['Status'] ?? data['eType'];
      if ('$status'.toUpperCase().contains('SUCCESS')) {
        final id = data['data']?['ID_MESSAGE'] ?? data['Data']?['ID_MESSAGE'];
        if (id != null) return int.tryParse('$id');
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  // ===============================
  // 🔹 GET USER BY DỰ ÁN
  // ===============================
  @override
  Future<List<ChatGetUserDuan>> getUserByDuan({
    required int idDv,
    required String sm1,
    required String sm2,
    required int idUser,
    int type = 0,
  }) async {
    try {
      final res = await _dio.post(
        EndPoint.getUserByDuanUrl,
        data: {
          "IDDV": idDv,
          "SM1": sm1,
          "SM2": sm2,
          "ID_USER": idUser,
          "TYPE": 0
        },
      );

      dynamic data = res.data;
      if (data is String) data = jsonDecode(data);

      if (data is! Map || data['TYPE'] != 'SUCCESS') {
        throw Exception('❌ Không thể tải danh sách người dùng dự án');
      }

      // ✅ Gọi đúng class với alias
      final dtoResponse = ChatGetUserByDuanResponseDto.fromJson(
        Map<String, dynamic>.from(data),
      );
      return dtoResponse.toEntities();
    } on DioException catch (e) {
      throw Exception('🌐 Lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('⚠️ Lỗi không xác định: $e');
    }
  }





  // phần post update
  @override
  Future<List<ChatSendMessage>> sendMessage({
    required int idGroup,
    required String content,
    required int type,
    int? replyToID,
    String? replyToContent,
    String  idMessage = '',
  }) async {
    try {
      final creds = await getChatCredentials();
      if (creds == null) throw Exception('Thiếu thông tin xác thực');

      final payload = {
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_GROUP': idGroup,
        'ID_SENDER': creds.userId,
        'FULLNAME_USER': creds.fullNameUser ?? '',
        'CONTENT': content,
        'TYPE': type,
        'REPLY_TO_ID': replyToID ?? 0,
        'REPLY_TO_CONTENT': replyToContent ?? '',
      };

      final res = await _dio.post(EndPoint.sendMessageAPI, data: payload);
      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);

      final dto = ChatSendMessageResponseDto.fromJson(raw);
      return dto.messages.map((e) => e.toEntity()).toList();

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatUpdateOneToGroupE>> chatUpdateOneToGroup({
    required int idGroup,
    required int idSender,
    required int idReceive,
    int type = 0,
  }) async {
    try {
      final creds = await getChatCredentials();
      if (creds == null) {
        throw Exception('Thiếu thông tin xác thực (IDDV/SM1/SM2/ID_USER)');
      }

      final payload = {
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_GROUP': idGroup,
        'ID_RECEIVE': idReceive,
        'ID_SENDER': idSender,
        'TYPE': type,
      };

      final res = await _dio.post(EndPoint.chatUpdateOneToGroupAPI, data: payload);

      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);
      final envelope = dto.ChatUpdateOneToGroup.fromJson(raw as Map<String, dynamic>);
      final items = envelope.messages.map((e) => e.toEntity()).toList(); // → List<ChatUpdateOneToGroupE>
      return items;
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatCreateGroupEntity>> createGroup(CreateGroupRequestDTO dto) async {
    try {
      // 1. Lấy credentials chung (giống chatUpdateOneToGroup)
      final creds = await getChatCredentials();
      if (creds == null) {
        throw Exception('Thiếu thông tin xác thực (IDDV/SM1/SM2/ID_USER)');
      }

      // 2. Ghép payload chung với dto.toJson()
      final payload = {
        ...dto.toJson(),
        'IDDV': creds.iddv,
        'SM1': creds.sm1,
        'SM2': creds.sm2,
        'ID_USER': creds.userId,
        'CURRENT_USER': creds.userId,
      };

      // 3. Gửi request
      final res = await _dio.post(
        EndPoint.createGroup,  // dùng endpoint chuẩn
        data: payload,
      );

      // 4. Chuẩn hóa response: server có thể trả về String JSON → parse lại
      dynamic raw = res.data;
      if (raw is String) raw = jsonDecode(raw);

      // 5. Parse DTO Envelope
      final envelope = ChatCreateGroupResponseDTO.fromJson(raw);

      // 6. Convert DTO → Entity
      final items = envelope.message.map((e) => e.toEntity()).toList();

      return items;
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

}
