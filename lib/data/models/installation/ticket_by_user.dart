part of '../models.dart';

class TicketByUser {
  final String? ticketStatus;
  final String? ticketType;
  final String? spanName;
  final DateTime? ticketStatusDate;
  final int? sectionId;
  final int? spanId;
  final String? ticketDetailCategory;
  final String? sectionName;
  final int? ticketId;
  final String? ticketNumber;
  final String? servicePointName;

  TicketByUser({
    this.ticketStatus,
    this.ticketType,
    this.spanName,
    this.ticketStatusDate,
    this.sectionId,
    this.spanId,
    this.ticketDetailCategory,
    this.sectionName,
    this.ticketId,
    this.ticketNumber,
    this.servicePointName,
  });

  factory TicketByUser.fromJson(Map<String, dynamic> json) {
    return TicketByUser(
      ticketStatus: json['ticket_status'],
      ticketType: json['ticket_type'],
      spanName: json['span_name'],
      ticketStatusDate: json['ticket_status_date'] != null
          ? DateTime.parse(json['ticket_status_date'])
          : null,
      sectionId: json['section_id'],
      spanId: json['span_id'],
      ticketDetailCategory: json['ticket_detail_category'],
      sectionName: json['section_name'],
      ticketId: json['ticket_id'],
      ticketNumber: json['ticket_number'],
      servicePointName: json['service_point_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_status': ticketStatus,
      'ticket_type': ticketType,
      'span_name': spanName,
      'ticket_status_date': ticketStatusDate?.toIso8601String(),
      'section_id': sectionId,
      'span_id': spanId,
      'ticket_detail_category': ticketDetailCategory,
      'section_name': sectionName,
      'ticket_id': ticketId,
      'ticket_number': ticketNumber,
      'service_point_name': servicePointName
    };
  }
}
