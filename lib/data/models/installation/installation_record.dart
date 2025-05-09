part of '../models.dart';

class InstallationRecords {
  final int? id;
  final String? username;
  final String? dmsId;
  final String? qmsId;
  final String? imsId;
  final String? imsCloseDate;
  final String? servicePoint;
  final String? project;
  final String? segment;
  final String? sectionName;
  final String? area;
  final double? latitude;
  final double? longitude;
  final int? idTypeOfInstallation;
  final String? typeOfInstallation;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Materials>? materials;
  final String? emailUser;
  final String? phoneUser;
  final String? approvalOps;
  final String? emailOps;
  final String? phoneOps;

  InstallationRecords({
    this.id,
    this.username,
    this.dmsId,
    this.qmsId,
    this.imsId,
    this.imsCloseDate,
    this.servicePoint,
    this.project,
    this.segment,
    this.sectionName,
    this.area,
    this.latitude,
    this.longitude,
    this.idTypeOfInstallation,
    this.typeOfInstallation,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.materials,
    this.emailUser,
    this.phoneUser,
    this.approvalOps,
    this.emailOps,
    this.phoneOps,
  });

  factory InstallationRecords.fromJson(Map<String, dynamic> json) =>
      InstallationRecords(
        id: json["id"],
        username: json["username"],
        dmsId: json["dms_id"],
        qmsId: json["qms_id"],
        imsId: json["ims_id"],
        imsCloseDate: json["ims_close_date"],
        servicePoint: json["service_point"],
        project: json["project"],
        segment: json["segment"],
        sectionName: json["section_name"],
        area: json["area"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        idTypeOfInstallation: json['id_type_of_installation'],
        typeOfInstallation: json["type_of_installation"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        materials: (json['materials'] as List<dynamic>?)
                ?.map((material) => Materials.fromJson(material))
                .toList() ??
            [],
        emailUser: json["email_user"],
        phoneUser: json["phone_user"],
        approvalOps: json["approval_ops"],
        emailOps: json["email_ops"],
        phoneOps: json["phone_ops"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "dms_id": dmsId,
        "qms_id": qmsId,
        "ims_id": imsId,
        "ims_close_date": imsCloseDate,
        "service_point": servicePoint,
        "project": project,
        "segment": segment,
        "section_name": sectionName,
        "area": area,
        "latitude": latitude,
        "longitude": longitude,
        "id_type_of_installation": idTypeOfInstallation,
        "type_of_installation": typeOfInstallation,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "materials": materials,
        "email_user": emailUser,
        "phone_user": phoneUser,
        "approval_ops": approvalOps,
        "email_ops": emailOps,
        "phone_ops": phoneOps
      };
}
