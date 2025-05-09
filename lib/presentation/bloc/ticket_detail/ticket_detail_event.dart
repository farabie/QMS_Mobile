part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailEvent {}

class FetchTicketDetail extends TicketDetailEvent {
  final String ticketNumber;

  FetchTicketDetail(this.ticketNumber);
}