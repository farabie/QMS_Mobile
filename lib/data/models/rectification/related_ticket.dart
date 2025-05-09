import 'dart:convert';

enum RectificationType {
  installation,
  inspection,
  quality_audit,
}

class RelatedTicket {
  final String ticketNumber;
  final String relatedTicket;
  final DateTime createdAt;
  final String sequenceId;
  final String ttDms;
  final String project;
  final String segment;
  final String section;
  final String area;
  final String spanRoute;
  final String servicePoint;
  final String longitude;
  final String latitude;
  final RectificationType type; // Updated variable name

  RelatedTicket({
    required this.ticketNumber,
    required this.relatedTicket,
    required this.createdAt,
    required this.sequenceId,
    required this.ttDms,
    required this.project,
    required this.segment,
    required this.section,
    required this.area,
    required this.spanRoute,
    required this.servicePoint,
    required this.longitude,
    required this.latitude,
    required this.type,
  });

  // Factory method to create a Rectification from JSON
  factory RelatedTicket.fromJson(Map<String, dynamic> json) {
    return RelatedTicket(
      ticketNumber: json['ticket_number'] ?? '',
      relatedTicket: json['related_ticket'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      sequenceId: json['sequence_id'] ?? '',
      ttDms: json['tt_dms'] ?? '',
      servicePoint: json['service_point'] ?? '',
      project: json['project'] ?? '',
      segment: json['segment'] ?? '',
      section: json['section'] ?? '',
      area: json['area'] ?? '',
      spanRoute: json['span_route'] ?? '',
      longitude: json['longitude'] ?? '',
      latitude: json['latitude'] ?? '',
      type: RectificationType.values.firstWhere(
          (e) => e.toString() == 'RectificationType.${json['type']}'),
    );
  }
}
