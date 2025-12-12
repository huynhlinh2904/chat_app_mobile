class LastMessage {
  final int idGroup;
  final String content;
  final String fullnameUser;
  final DateTime dateSent;

  LastMessage({
    required this.idGroup,
    required this.content,
    required this.fullnameUser,
    required this.dateSent,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      idGroup: json["idGroup"],
      content: json["content"] ?? "",
      fullnameUser: json["fullnameUser"] ?? "",
      dateSent: DateTime.tryParse(json["dateSent"] ?? "") ?? DateTime.now(),
    );
  }
}
