import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_mobile_app/core/network/dio_client.dart';
import '../../domain/entities/chat_create_group_entity.dart';
import '../../domain/entities/chat_group.dart';
import '../../domain/entities/last_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_groups_usecase.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/clients/signalr_client.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ChatRepositoryImpl(dio);
});

final getChatGroupsProvider = Provider<GetChatGroupsUseCase>((ref) {
  return GetChatGroupsUseCase(ref.read(chatRepositoryProvider));
});

final chatGroupsNotifierProvider =
StateNotifierProvider<ChatGroupsNotifier, AsyncValue<List<ChatGroup>>>((ref) {
  return ChatGroupsNotifier(
      ref.read(getChatGroupsProvider),
      ref.read(chatRepositoryProvider),
  );
});

class ChatGroupsNotifier extends StateNotifier<AsyncValue<List<ChatGroup>>> {
  final GetChatGroupsUseCase _usecase;
  final ChatRepository _repo;
  int? _currentOpenGroupId;
  ChatGroupsNotifier(this._usecase, this._repo) : super(const AsyncLoading()) {
    // Lắng nghe realtime từ SignalR
    SignalRService().events.listen(_handleSignalREvent);
  }

  Future<void> fetch({required int idGroup, required int type}) async {
    state = const AsyncLoading();

    try {
      // 1️⃣ Lấy danh sách group từ API gốc
      final groups = await _usecase(idGroup: idGroup, type: type);

      // 2️⃣ Lấy last message từ Redis
      final lastMsgs = await _repo.getLastMessagesRedis();

      // Convert sang map để merge nhanh
      final Map<int, LastMessage> mapLast = {
        for (var m in lastMsgs) m.idGroup: m
      };

      // 3️⃣ Merge LastMessage vào ChatGroup
      final merged = groups.map((g) {
        final lm = mapLast[g.idGroup];

        return ChatGroup(
          idGroup: g.idGroup,
          groupName: g.groupName,
          avatarImg: g.avatarImg,
          backgroundImg: g.backgroundImg,
          isGroup: g.isGroup,
          idUser: g.idUser,
          createDate: g.createDate,
          creatorName: g.creatorName,
          userName1: g.userName1,
          userName2: g.userName2,
          idUser1: g.idUser1,
          idUser2: g.idUser2,
          content: g.content,
          typeMessage: g.typeMessage,
          fileSend: g.fileSend,
          idSender: g.idSender,
          senderName: g.senderName,
          idMessage: g.idMessage,
          dateSort: g.dateSort,
          rn: g.rn,

          // 🚀 Merge field mới
          lastMessage: lm?.content ?? g.content ?? "",
          lastMessageDate: lm?.dateSent ?? g.dateSent,
          unreadCount: g.unreadCount,
        );
      }).toList();

      // 4️⃣ Sort theo thời gian gửi gần nhất
      merged.sort((a, b) {
        final da = mapLast[a.idGroup]?.dateSent ?? a.dateSort ?? DateTime(2000);
        final db = mapLast[b.idGroup]?.dateSent ?? b.dateSort ?? DateTime(2000);
        return db.compareTo(da);
      });

      // 5️⃣ Cập nhật state
      state = AsyncValue.data(merged);

      // 6️⃣ Join tất cả group vào SignalR
      final signalR = SignalRService();
      for (final g in merged) {
        try {
          await signalR.joinConversation(g.idGroup);
        } catch (_) {}
      }

      print("[ChatGroupsNotifier] Joined ${merged.length} groups!");

    } catch (e, st) {
      print("❌ ChatGroupsNotifier.fetch error: $e");
      state = AsyncError(e, st);
    }
  }

  void addNewGroupFromCreate(ChatCreateGroupEntity created) {
    state.whenData((list) {
      final newGroup = ChatGroup(
        idGroup: created.idGroup,
        groupName: created.groupName,
        avatarImg: null,
        backgroundImg: null,
        isGroup: 1,
        idUser: null,
        createDate: DateTime.now(),
        creatorName: null,
        userName1: null,
        userName2: null,
        idUser1: null,
        idUser2: null,
        content: "",
        typeMessage: null,
        fileSend: null,
        idSender: null,
        senderName: null,
        idMessage: null,
        dateSort: DateTime.now(),
        rn: 0,

        // 👇 rất quan trọng
        lastMessage: "",
        lastMessageDate: DateTime.now(),
        unreadCount: 0,
      );

      final updated = [newGroup, ...list];

      state = AsyncValue.data(updated);
    });

    // 🚀 join SignalR group ngay
    SignalRService().joinConversation(created.idGroup);
  }



  void _handleSignalREvent(Map<String, dynamic> event) {
    if (event['type'] != 'ReceiveLastMessage') return;

    final data = event['data'];
    final int groupId = data['idGroup'];

    final newDate = DateTime.tryParse(data['dateSent'] ?? "");

    state.whenData((list) {
      final updated = list.map((g) {
        if (g.idGroup != groupId) return g;

        final bool isNewMessage =
            g.lastMessageDate == null || newDate!.isAfter(g.lastMessageDate!);

        final bool isOpen = (groupId == _currentOpenGroupId);

        return g.copyWith(
          lastMessage: data['content'],
          lastMessageDate: newDate,

          // 🎯 Chỉ cộng +1 nếu: group không mở + đây là tin mới
          unreadCount: (!isOpen && isNewMessage) ? g.unreadCount + 1 : g.unreadCount,
        );
      }).toList();

      // Sort cho group lên đầu
      updated.sort((a, b) {
        final d1 = a.lastMessageDate ?? DateTime(2000);
        final d2 = b.lastMessageDate ?? DateTime(2000);
        return d2.compareTo(d1);
      });

      state = AsyncValue.data(updated);
    });
  }

  void setCurrentOpenGroup(int groupId) {
    _currentOpenGroupId = groupId;
    markAsRead(groupId);
  }
  void markAsRead(int groupId) {
    state.whenData((list) {
      final updated = list.map((g) {
        if (g.idGroup != groupId) return g;

        return g.copyWith(
          unreadCount: 0,
        );
      }).toList();

      state = AsyncValue.data(updated);
    });
  }



}
