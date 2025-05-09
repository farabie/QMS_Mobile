part of '../models.dart';

class PhotoStepInstallations {
  final int? id;
  final String? qmsInstallationStepId;
  final String? photoUrl;

  PhotoStepInstallations({
    this.id,
    this.qmsInstallationStepId,
    this.photoUrl,
  });

  factory PhotoStepInstallations.fromJson(Map<String, dynamic> json) =>
      PhotoStepInstallations(
        id: json["id"],
        qmsInstallationStepId: json["qms_installation_step_id"],
        photoUrl: json["photo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "qms_installation_step_id": qmsInstallationStepId,
        "photo_url": photoUrl,
      };
}
