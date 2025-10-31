class ChatUser {
  final int id;
  final String userName;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final int gender;
  final int departmentId;

  const ChatUser({
    required this.id,
    required this.userName,
    required this.fullName,
    this.email,
    this.phone,
    this.address,
    required this.gender,
    required this.departmentId,
  });
}
