
import '../utils/app_constant.dart';

class UserModel {
  final int? userId;
  final String userName;
  final int contact;
  final String email;
  final String password;
  final String role;
  final int? groupId;

  UserModel({
    this.userId,
    required this.userName,
    required this.contact,
    required this.email,
    required this.password,
    required this.role,
    this.groupId,
  });

  // Convert Map from DB to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map[USERID],
      userName: map[USERNAME],
      contact: map[CONTACT],
      email: map[EMAIL],
      password: map[PASSWORD],
      role: map[ROLE],
      groupId: map[GROUP_ID], // Foreign key, optional
    );
  }

  // Convert UserModel to Map for DB insert/update
  Map<String, dynamic> toMap() {
    return {
      USERID: userId,
      USERNAME: userName,
      CONTACT:contact,
      EMAIL: email,
      PASSWORD: password,
      ROLE: role,
      GROUP_ID : groupId, // foreign key
    };
  }
}
