part of '../models.dart';

class TicketAssignee {
  final String? spv;
  final String? clusterName;
  final String? worker;
  final String? manager;
  final String? serviceAreaName;
  final String? servicePointName;

  TicketAssignee({
    this.spv,
    this.clusterName,
    this.worker,
    this.manager,
    this.serviceAreaName,
    this.servicePointName,
  });

  factory TicketAssignee.fromJson(Map<String, dynamic> json) => TicketAssignee(
        spv: json["spv"],
        clusterName: json["cluster_name"],
        worker: json["worker"],
        manager: json["manager"],
        serviceAreaName: json["service_area_name"],
        servicePointName: json["service_point_name"],
      );

  Map<String, dynamic> toJson() => {
        "spv": spv,
        "cluster_name": clusterName,
        "worker": worker,
        "manager": manager,
        "service_area_name": serviceAreaName,
        "service_point_name": servicePointName,
      };
}
