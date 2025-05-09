part of 'models.dart';

class User {
  final String? clusterName;
  final String? atasanName;
  final String? nama;
  final String? username;
  final String? phone;
  final String? spv;
  final int? idUser;
  final String? jabatan;
  final String? email;
  final String? serpo;
  final String? userEmail;
  final String? passEmail;

  User({
    this.clusterName,
    this.atasanName,
    this.nama,
    this.username,
    this.phone,
    this.spv,
    this.idUser,
    this.jabatan,
    this.email,
    this.serpo,
    this.userEmail,
    this.passEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        clusterName: json["cluster_name"],
        atasanName: json['atasan_1_name'],
        nama: json["nama"],
        username: json["username"],
        phone: json["phone"],
        spv: json["spv"],
        idUser: json["id_user"],
        jabatan: json["jabatan"],
        email: json["email"],
        serpo: json["serpo"],
        userEmail: json["user_email"],
        passEmail: json["pass_email"]
      );
  Map<String, dynamic> toJson() => {
        "cluster_name": clusterName,
        "atasan_1_name": atasanName,
        "nama": nama,
        "username": username,
        "phone": phone,
        "spv": spv,
        "id_user": idUser,
        "jabatan": jabatan,
        "email": email,
        "serpo": serpo,
        "user_email": userEmail,
        "pass_email": passEmail
      };
}
