part of '../models.dart';

class TicketIms {
  final String? ticketIms;
  final String? ticketDms;
  final String? jointer;
  final String? receivedDate;
  final List<TicketDetailIMS>? details;

  TicketIms({
    this.ticketIms,
    this.ticketDms,
    this.jointer,
    this.receivedDate,
    this.details,
  });

  factory TicketIms.fromJson(Map<String, dynamic> json) => TicketIms(
        ticketIms: json["ticket_ims"],
        ticketDms: json["ticket_dms"],
        jointer: json["jointer"],
        receivedDate: json["received_date"],
          details: (json['details'] as List)
          .map((detail) => TicketDetailIMS.fromJson(detail))
          .toList(),
      );
  Map<String, dynamic> toJson() => {
        "ticket_ims": ticketIms,
        "ticket_dms": ticketDms,
        "jointer": jointer,
        "received_date": receivedDate,
        "details": details,
    };

}
