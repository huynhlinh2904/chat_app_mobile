class CreateGroupRequestDTO {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final String groupName;
  final int isGroup;
  final int idUser;
  // final int idDuan;
  final String jsonMembers;
  final int type;
  final int currentUser;

  CreateGroupRequestDTO({
    required this.iddv,
    required this.sm1,
    required this.sm2,
    required this.idGroup,
    required this.groupName,
    required this.isGroup,
    required this.idUser,
    required this.jsonMembers,
    required this.type,
    required this.currentUser,
  });

  Map<String, dynamic> toJson() {
    return {
      "IDDV": iddv,
      "SM1": sm1,
      "SM2": sm2,
      "ID_GROUP": idGroup,
      "GROUP_NAME": groupName,
      "IS_GROUP": isGroup,
      "ID_USER": idUser,
      "Json_Members": jsonMembers,
      "TYPE": type,
      "CURRENT_USER": currentUser,
    };
  }
}
