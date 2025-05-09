part of '../models.dart';

class InstallationType {
    final int? id;
    final String? typeName;

    InstallationType({
        this.id,
        this.typeName,
    });

    factory InstallationType.fromJson(Map<String, dynamic> json) => InstallationType(
        id: json["id"],
        typeName: json["type_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type_name": typeName,
    };
}