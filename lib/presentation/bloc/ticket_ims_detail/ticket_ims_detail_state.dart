part of 'ticket_ims_detail_bloc.dart';

@immutable
sealed class TicketImsDetailState {}

class TicketImsDetailInitial extends TicketImsDetailState {}

class TicketImsDetailLoading extends TicketImsDetailState {}

class TicketImsDetailLoaded extends TicketImsDetailState {
  final TicketIms ticketIms;

  TicketImsDetailLoaded(this.ticketIms); 
}

class TicketImsDetailNotFound extends TicketImsDetailState {}

class TicketImsDetailError extends TicketImsDetailState {
  final String message;

  TicketImsDetailError(this.message);
}
