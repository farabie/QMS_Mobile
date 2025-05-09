part of 'models.dart';

class OpsApproval {
  final String? clusterName;
  final String? usernameOps;
  final String? opsName;
  final String? emailOps;
  final String? phoneOps;

  OpsApproval(
      {this.clusterName,
      this.usernameOps,
      this.opsName,
      this.emailOps,
      this.phoneOps});

  factory OpsApproval.fromJson(Map<String, dynamic> json) => OpsApproval(
        clusterName: json["cluster_name"],
        usernameOps: json['username_ops'],
        opsName: json['ops_name'],
        emailOps: json['email_ops'],
        phoneOps: json['phone_ops'],
      );
  Map<String, dynamic> toJson() => {
        "cluster_name": clusterName,
        "username_ops": usernameOps,
        "ops_name": opsName,
        "email_ops": emailOps,
        "phone_ops": phoneOps,
      };
}
