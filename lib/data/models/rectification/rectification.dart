class Rectification {
  final String ticketNumber;
  final String relatedTicket;
  final String relatedTicketSequence;
  final String ttDms;
  final String project;
  final String segment;
  final String section;
  final String sectionPatrol;
  final String area;
  final String servicePoint;
  final String spanRoute;
  final String longitude;
  final String latitude;
  final String description;
  final String type;
  final String acknowledged_by;
  final String createdAt; // Change to String
  final String acknowledgeAt; // Change to String
  final String openedAt; // Change to String
  final String reasonRejectedSpv; // Change to String
  final String status;

  Rectification({
    required this.ticketNumber,
    required this.relatedTicket,
    required this.relatedTicketSequence,
    required this.ttDms,
    required this.project,
    required this.segment,
    required this.section,
    required this.sectionPatrol,
    required this.area,
    required this.servicePoint,
    required this.spanRoute,
    required this.longitude,
    required this.latitude,
    required this.description,
    required this.type,
    required this.acknowledged_by,
    required this.createdAt,
    required this.acknowledgeAt,
    required this.openedAt,
    required this.status,
    required this.reasonRejectedSpv,
  });

  // Factory method to create a Rectification from JSON
  factory Rectification.fromJson(Map<String, dynamic> json) {
    return Rectification(
      ticketNumber: json['ticket_number'] ?? '',
      relatedTicket: json['related_ticket'] ?? '',
      relatedTicketSequence: json['related_ticket_sequence'] ?? '',
      ttDms: json['tt_dms'] ?? '',
      project: json['project'] ?? '',
      segment: json['segment'] ?? '',
      section: json['section'] ?? '',
      area: json['area'] ?? '',
      servicePoint: json['service_point'] ?? '',
      sectionPatrol: json['section_patrol'] ?? '',
      spanRoute: json['span_route'] ?? '',
      longitude: json['longitude'] ?? '',
      latitude: json['latitude'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      acknowledged_by: json['acknowledged_by'] ?? '',
      createdAt:
          json['created_at'] != null && json['created_at'].toString().isNotEmpty
              ? json['created_at'].toString()
              : '', // Set as empty string if null
      acknowledgeAt: json['acknowledge_at'] != null &&
              json['acknowledge_at'].toString().isNotEmpty
          ? json['acknowledge_at'].toString()
          : '', // Set as empty string if null
      openedAt:
          json['opened_at'] != null && json['opened_at'].toString().isNotEmpty
              ? json['opened_at'].toString()
              : '', // Set as empty string if null
      status: json['status'] ?? '',
      reasonRejectedSpv: json['reason_rejected_spv'] ?? '',
    );
  }
}
