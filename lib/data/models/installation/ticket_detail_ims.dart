part of '../models.dart';

class TicketDetailIMS {
  final String? detailId;
  final String? number;
  final String? name;
  final int? qty;

  TicketDetailIMS({
    this.detailId,
    this.number,
    this.name,
    this.qty,
  });

  factory TicketDetailIMS.fromJson(Map<String, dynamic> json) =>
      TicketDetailIMS(
        detailId: json["detail_id"],
        number: json["number"],
        name: json["name"],
        qty: json["qty"],
      );
  
  //  Map<String, dynamic> toJson() => {
  //       "detail_id": detailId,
  //       "number": number,
  //       "name": name,
  //       "qty": qty,
  //   };
}
