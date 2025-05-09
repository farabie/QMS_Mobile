part of '../models.dart';

class Materials {
  final int? id;
  final String? qmsId;
  final String?  materialName;
  final String? materialQuantity;

  Materials({
    this.id,
    this.qmsId,
    this.materialName,
    this.materialQuantity
  });

  factory Materials.fromJson(Map<String, dynamic> json) =>
      Materials(
        id: json["id"],
        qmsId: json["qms_id"],
        materialName: json["material_name"],
        materialQuantity: json["material_quantity"],
      );
}