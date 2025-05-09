part of 'ticket_ims_detail_bloc.dart';

@immutable
sealed class TicketImsDetailEvent {}

class FetchTicketImsTicketDetail extends TicketImsDetailEvent {
  final String ticketNumber;

  FetchTicketImsTicketDetail(this.ticketNumber);
}
