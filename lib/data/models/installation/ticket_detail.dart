part of '../models.dart';

class TicketDetail {
  final String? ticketNo;
  final String? ticketType;
  final String? projectName;
  final String? spanName;
  final String? segmentName;
  final String? sectionName;
  final double? latitude;
  final double? longitude;
  final String? openedTime;
  final List<TicketAssignee>? ticketAssignees;
  final String? createdDate;
  final String? status;

  TicketDetail({
    this.ticketNo,
    this.ticketType,
    this.projectName,
    this.spanName,
    this.segmentName,
    this.sectionName,
    this.latitude,
    this.longitude,
    this.openedTime,
    this.ticketAssignees,
    this.createdDate,
    this.status,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) => TicketDetail(
      ticketNo: json['ticket_no'],
      ticketType: json["ticket_type"],
      projectName: json["project_name"],
      spanName: json["span_name"],
      segmentName: json["segment_name"],
      sectionName: json["section_name"],
      latitude: json["lat"],
      longitude: json["lng"],
      openedTime: json["opened_time"],
      ticketAssignees: json["ticket_assignees"] == null
          ? []
          : List<TicketAssignee>.from(
              json["ticket_assignees"]!.map(
                (x) => TicketAssignee.fromJson(x),
              ),
            ),
      createdDate: json["created_date"],
      status: json["status"]);
}
