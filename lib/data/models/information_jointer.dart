part of 'models.dart';

class InformationJointer {
  final String? roleName;
  final int? userId;
  final String? phone;
  final String? userServiceRole;
  final String? fullName;
  final String? email;
  final String? username;

  InformationJointer({
    this.roleName,
    this.userId,
    this.phone,
    this.userServiceRole,
    this.fullName,
    this.email,
    this.username,
  });

  factory InformationJointer.fromJson(Map<String, dynamic> json) => InformationJointer(
        roleName: json["role_name"],
        userId: json['user_id'],
        phone: json["phone"],
        userServiceRole: json["user_service_role"],
        fullName: json["fullname"],
        email: json["email"],
        username: json["username"],
      );
  Map<String, dynamic> toJson() => {
        "role_name": roleName,
        "user_id": userId,
        "phone": phone,
        "user_service_role": userServiceRole,
        "fullname": fullName,
        "email": email,
        "username": username,
      };
}