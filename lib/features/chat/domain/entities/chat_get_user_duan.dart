class ChatGetUserDuan {
  final int idDuAn;
  final String maDuAn;
  final String tenDuAn;
  final List<ChatGetGroupUserDuan> users;

  ChatGetUserDuan({
    required this.idDuAn,
    required this.maDuAn,
    required this.tenDuAn,
    required this.users,
  });
}


class ChatGetGroupUserDuan {
  final int idUser;
  final String fullNameUser;
  final String? chucVu;

  ChatGetGroupUserDuan({
    required this.idUser,
    required this.fullNameUser,
    this.chucVu,
  });
}

